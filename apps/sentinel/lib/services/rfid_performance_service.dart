import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/rfid_scan_metric.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';

/// RFID Performance Monitoring Service
///
/// Tracks RFID scan performance metrics including scan times,
/// success rates, and error patterns to ensure the <5 second
/// verification requirement is met.
class RfidPerformanceService {
  final SupabaseService _supabaseService;
  final OfflineCacheService _cacheService;

  static const String _metricsBoxName = 'rfid_scan_metrics';
  static const int _maxMetricsInMemory = 1000;
  static const int _maxMetricsInCache = 10000;

  Box<RfidScanMetric>? _metricsBox;
  Timer? _cleanupTimer;
  Timer? _syncTimer;

  // Performance thresholds
  static const Duration _scanTimeWarning = Duration(seconds: 4);
  static const Duration _scanTimeCritical = Duration(seconds: 6);
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _cleanupInterval = Duration(hours: 1);

  // In-memory metrics for real-time monitoring
  final List<RfidScanMetric> _recentMetrics = [];

  // Performance statistics cache
  RfidPerformanceStats? _cachedStats;
  DateTime? _lastStatsUpdate;

  RfidPerformanceService({
    required SupabaseService supabaseService,
    required OfflineCacheService cacheService,
  }) : _supabaseService = supabaseService,
       _cacheService = cacheService;

  /// Initialize the performance monitoring service
  Future<void> initialize() async {
    try {
      // Open Hive box for metrics storage
      _metricsBox = await Hive.openBox<RfidScanMetric>(_metricsBoxName);

      // Load recent metrics from cache
      await _loadRecentMetricsFromCache();

      // Start periodic cleanup
      _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _cleanupOldMetrics());

      // Start periodic sync
      _syncTimer = Timer.periodic(_syncInterval, (_) => _syncMetricsToServer());

      developer.log('RFID Performance Service initialized', name: 'sentinel.performance');
    } catch (e) {
      developer.log('Failed to initialize RFID Performance Service: $e',
                   name: 'sentinel.performance', level: 1000);
    }
  }

  /// Record a RFID scan attempt
  Future<void> recordScanAttempt({
    required String rfidCode,
    required DateTime startTime,
    required DateTime endTime,
    required bool successful,
    required String scanMethod,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? additionalData,
  }) async {
    final metric = RfidScanMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rfidCode: rfidCode,
      scanStartTime: startTime,
      scanEndTime: endTime,
      successful: successful,
      scanMethod: scanMethod,
      errorMessage: errorMessage,
      errorCode: errorCode,
      additionalData: additionalData,
    );

    // Add to in-memory list
    _recentMetrics.add(metric);
    if (_recentMetrics.length > _maxMetricsInMemory) {
      _recentMetrics.removeAt(0);
    }

    // Save to local cache
    await _saveMetricToCache(metric);

    // Invalidate cached stats
    _cachedStats = null;
    _lastStatsUpdate = null;

    // Log performance warnings
    _checkPerformanceThresholds(metric);

    // Debug log in debug mode
    if (kDebugMode) {
      developer.log('RFID Scan recorded: ${metric.scanDuration.inMilliseconds}ms, '
                   'success: ${metric.successful}, method: ${metric.scanMethod}',
                   name: 'sentinel.performance');
    }
  }

  /// Get recent performance statistics
  RfidPerformanceStats getRecentStats({Duration period = const Duration(hours: 24)}) {
    final now = DateTime.now();
    final cutoff = now.subtract(period);

    final relevantMetrics = _recentMetrics
        .where((m) => m.scanEndTime.isAfter(cutoff))
        .toList();

    return _calculateStatsFromMetrics(relevantMetrics);
  }

  /// Get cached performance statistics (more efficient for frequent calls)
  Future<RfidPerformanceStats> getCachedStats({Duration period = const Duration(hours: 24)}) async {
    final now = DateTime.now();

    // Return cached stats if available and recent (within 1 minute)
    if (_cachedStats != null &&
        _lastStatsUpdate != null &&
        now.difference(_lastStatsUpdate!).inMinutes < 1) {
      return _cachedStats!;
    }

    // Calculate fresh stats
    final cutoff = now.subtract(period);
    final allMetrics = await _getAllMetricsSince(cutoff);
    _cachedStats = _calculateStatsFromMetrics(allMetrics);
    _lastStatsUpdate = now;

    return _cachedStats!;
  }

  /// Get performance metrics for a specific time range
  Future<List<RfidScanMetric>> getMetricsForTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Get from cache
      final cachedMetrics = await _getCachedMetricsForTimeRange(startTime, endTime);

      // Try to get from server if online
      if (_supabaseService.isInitialized) {
        try {
          final serverMetrics = await _getMetricsFromServer(startTime, endTime);
          // Merge and deduplicate
          final allMetrics = {...cachedMetrics, ...serverMetrics}.toList();
          allMetrics.sort((a, b) => b.scanEndTime.compareTo(a.scanEndTime));
          return allMetrics;
        } catch (e) {
          developer.log('Failed to get metrics from server: $e',
                       name: 'sentinel.performance', level: 900);
        }
      }

      return cachedMetrics;
    } catch (e) {
      developer.log('Error getting metrics for time range: $e',
                   name: 'sentinel.performance', level: 1000);
      return [];
    }
  }

  /// Get performance alerts based on recent metrics
  List<RfidPerformanceAlert> getPerformanceAlerts({Duration period = const Duration(hours: 1)}) {
    final now = DateTime.now();
    final cutoff = now.subtract(period);

    final recentMetrics = _recentMetrics
        .where((m) => m.scanEndTime.isAfter(cutoff))
        .toList();

    if (recentMetrics.isEmpty) return [];

    final alerts = <RfidPerformanceAlert>[];

    // Check scan time performance
    final avgScanTime = _calculateAverageScanTime(recentMetrics);
    if (avgScanTime > _scanTimeCritical) {
      alerts.add(RfidPerformanceAlert(
        id: 'critical_scan_time',
        severity: AlertSeverity.critical,
        title: 'Critical: Slow Scan Times',
        message: 'Average scan time is ${avgScanTime.inSeconds}s (target: <5s)',
        recommendation: 'Check NFC scanner hardware and network connectivity',
        timestamp: now,
      ));
    } else if (avgScanTime > _scanTimeWarning) {
      alerts.add(RfidPerformanceAlert(
        id: 'warning_scan_time',
        severity: AlertSeverity.warning,
        title: 'Warning: Degraded Scan Performance',
        message: 'Average scan time is ${avgScanTime.inSeconds}s (target: <5s)',
        recommendation: 'Monitor performance and check for interference',
        timestamp: now,
      ));
    }

    // Check success rate
    final successRate = _calculateSuccessRate(recentMetrics);
    if (successRate < 0.9) {
      alerts.add(RfidPerformanceAlert(
        id: 'low_success_rate',
        severity: successRate < 0.8 ? AlertSeverity.critical : AlertSeverity.warning,
        title: 'Low Scan Success Rate',
        message: 'Success rate is ${(successRate * 100).toStringAsFixed(1)}% (target: >95%)',
        recommendation: 'Check RFID sticker placement and scanner positioning',
        timestamp: now,
      ));
    }

    // Check error patterns
    final errorCounts = <String, int>{};
    for (final metric in recentMetrics) {
      if (!metric.successful && metric.errorCode != null) {
        errorCounts[metric.errorCode!] = (errorCounts[metric.errorCode] ?? 0) + 1;
      }
    }

    // Alert on frequent errors
    errorCounts.forEach((errorCode, count) {
      if (count >= 5) { // 5+ occurrences in the period
        alerts.add(RfidPerformanceAlert(
          id: 'frequent_error_$errorCode',
          severity: AlertSeverity.warning,
          title: 'Frequent Error: $errorCode',
          message: 'Error occurred $count times in the last hour',
          recommendation: 'Investigate root cause of $errorCode errors',
          timestamp: now,
        ));
      }
    });

    return alerts;
  }

  /// Generate performance report
  Future<RfidPerformanceReport> generatePerformanceReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    final reportStart = startTime ?? now.subtract(const Duration(days: 7));
    final reportEnd = endTime ?? now;

    final metrics = await getMetricsForTimeRange(reportStart, reportEnd);
    final stats = _calculateStatsFromMetrics(metrics);
    final alerts = getPerformanceAlerts(period: reportEnd.difference(reportStart));

    return RfidPerformanceReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: reportStart,
      endTime: reportEnd,
      stats: stats,
      alerts: alerts,
      generatedAt: now,
    );
  }

  /// Dispose of the service
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _syncTimer?.cancel();

    // Final sync of metrics
    await _syncMetricsToServer();

    await _metricsBox?.close();

    developer.log('RFID Performance Service disposed', name: 'sentinel.performance');
  }

  // Private helper methods

  Future<void> _loadRecentMetricsFromCache() async {
    try {
      final allMetrics = _metricsBox?.values.toList() ?? [];

      // Load metrics from last 24 hours
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      final recentMetrics = allMetrics
          .where((m) => m.scanEndTime.isAfter(cutoff))
          .toList();

      _recentMetrics.clear();
      _recentMetrics.addAll(recentMetrics);

      // Limit memory usage
      if (_recentMetrics.length > _maxMetricsInMemory) {
        _recentMetrics.sort((a, b) => b.scanEndTime.compareTo(a.scanEndTime));
        _recentMetrics.removeRange(_maxMetricsInMemory, _recentMetrics.length);
      }
    } catch (e) {
      developer.log('Error loading recent metrics from cache: $e',
                   name: 'sentinel.performance', level: 900);
    }
  }

  Future<void> _saveMetricToCache(RfidScanMetric metric) async {
    try {
      await _metricsBox?.put(metric.id, metric);

      // Cleanup old metrics if cache is too large
      if ((_metricsBox?.length ?? 0) > _maxMetricsInCache) {
        await _cleanupOldMetrics();
      }
    } catch (e) {
      developer.log('Error saving metric to cache: $e',
                   name: 'sentinel.performance', level: 900);
    }
  }

  Future<void> _cleanupOldMetrics() async {
    try {
      final allMetrics = _metricsBox?.values.toList() ?? [];

      // Remove metrics older than 30 days
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final validMetrics = allMetrics
          .where((m) => m.scanEndTime.isAfter(cutoff))
          .toList();

      if (validMetrics.length != allMetrics.length) {
        await _metricsBox?.clear();
        for (final metric in validMetrics) {
          await _metricsBox?.put(metric.id, metric);
        }
      }

      developer.log('Cleaned up ${allMetrics.length - validMetrics.length} old metrics',
                   name: 'sentinel.performance');
    } catch (e) {
      developer.log('Error during cleanup: $e',
                   name: 'sentinel.performance', level: 900);
    }
  }

  Future<void> _syncMetricsToServer() async {
    if (!_supabaseService.isInitialized) return;

    try {
      // Get unsynced metrics
      final unsyncedMetrics = await _getUnsyncedMetrics();

      if (unsyncedMetrics.isEmpty) return;

      // TODO: Implement actual sync with Supabase
      // For now, mark as synced (mock implementation)

      developer.log('Synced ${unsyncedMetrics.length} metrics to server',
                   name: 'sentinel.performance');
    } catch (e) {
      developer.log('Error syncing metrics to server: $e',
                   name: 'sentinel.performance', level: 900);
    }
  }

  Future<List<RfidScanMetric>> _getAllMetricsSince(DateTime cutoff) async {
    try {
      // Get from cache
      final cachedMetrics = await _getCachedMetricsForTimeRange(cutoff, DateTime.now());

      // Add recent in-memory metrics
      final memoryMetrics = _recentMetrics
          .where((m) => m.scanEndTime.isAfter(cutoff))
          .toList();

      // Combine and deduplicate
      final allMetrics = <String, RfidScanMetric>{};
      for (final metric in cachedMetrics) {
        allMetrics[metric.id] = metric;
      }
      for (final metric in memoryMetrics) {
        allMetrics[metric.id] = metric;
      }

      return allMetrics.values.toList()..sort((a, b) => b.scanEndTime.compareTo(a.scanEndTime));
    } catch (e) {
      developer.log('Error getting all metrics since $cutoff: $e',
                   name: 'sentinel.performance', level: 1000);
      return [];
    }
  }

  Future<List<RfidScanMetric>> _getCachedMetricsForTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final allMetrics = _metricsBox?.values.toList() ?? [];

      return allMetrics
          .where((m) => m.scanEndTime.isAfter(startTime) &&
                       m.scanEndTime.isBefore(endTime))
          .toList();
    } catch (e) {
      developer.log('Error getting cached metrics for time range: $e',
                   name: 'sentinel.performance', level: 1000);
      return [];
    }
  }

  Future<List<RfidScanMetric>> _getMetricsFromServer(
    DateTime startTime,
    DateTime endTime,
  ) async {
    // TODO: Implement server metrics retrieval
    // For now, return empty list
    return [];
  }

  Future<List<RfidScanMetric>> _getUnsyncedMetrics() async {
    // TODO: Implement unsynced metrics retrieval
    // For now, return empty list
    return [];
  }

  void _checkPerformanceThresholds(RfidScanMetric metric) {
    if (metric.successful) {
      if (metric.scanDuration > _scanTimeCritical) {
        developer.log('🚨 CRITICAL: Slow scan time detected: ${metric.scanDuration.inSeconds}s',
                     name: 'sentinel.performance', level: 1000);
      } else if (metric.scanDuration > _scanTimeWarning) {
        developer.log('⚠️ WARNING: Degraded scan time: ${metric.scanDuration.inSeconds}s',
                     name: 'sentinel.performance', level: 900);
      }
    }
  }

  RfidPerformanceStats _calculateStatsFromMetrics(List<RfidScanMetric> metrics) {
    if (metrics.isEmpty) {
      return RfidPerformanceStats(
        totalScans: 0,
        successfulScans: 0,
        averageScanTime: Duration.zero,
        successRate: 0.0,
        fastestScan: Duration.zero,
        slowestScan: Duration.zero,
        scanMethodCounts: {},
        errorCounts: {},
        hourlyStats: {},
        dateRange: null,
      );
    }

    final successfulMetrics = metrics.where((m) => m.successful).toList();
    final scanTimes = successfulMetrics.map((m) => m.scanDuration).toList();

    // Calculate basic stats
    final totalScans = metrics.length;
    final successfulScans = successfulMetrics.length;
    final averageScanTime = scanTimes.isNotEmpty
        ? Duration(milliseconds: scanTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ scanTimes.length)
        : Duration.zero;
    final fastestScan = scanTimes.isNotEmpty ? scanTimes.reduce((a, b) => a < b ? a : b) : Duration.zero;
    final slowestScan = scanTimes.isNotEmpty ? scanTimes.reduce((a, b) => a > b ? a : b) : Duration.zero;
    final successRate = totalScans > 0 ? successfulScans / totalScans : 0.0;

    // Calculate scan method counts
    final scanMethodCounts = <String, int>{};
    for (final metric in metrics) {
      scanMethodCounts[metric.scanMethod] = (scanMethodCounts[metric.scanMethod] ?? 0) + 1;
    }

    // Calculate error counts
    final errorCounts = <String, int>{};
    for (final metric in metrics) {
      if (!metric.successful && metric.errorCode != null) {
        errorCounts[metric.errorCode!] = (errorCounts[metric.errorCode!] ?? 0) + 1;
      }
    }

    // Calculate hourly stats
    final hourlyStats = <String, RfidPerformanceStats>{};
    for (final metric in metrics) {
      final hour = metric.scanEndTime.toIso8601String().substring(0, 13); // YYYY-MM-DDTHH
      if (!hourlyStats.containsKey(hour)) {
        final hourMetrics = metrics.where((m) =>
          m.scanEndTime.toIso8601String().substring(0, 13) == hour
        ).toList();
        hourlyStats[hour] = _calculateStatsFromMetrics(hourMetrics);
      }
    }

    // Calculate date range
    final timestamps = metrics.map((m) => m.scanEndTime).toList();
    timestamps.sort();
    final dateRange = timestamps.isNotEmpty
        ? DateTimeRange(start: timestamps.first, end: timestamps.last)
        : null;

    return RfidPerformanceStats(
      totalScans: totalScans,
      successfulScans: successfulScans,
      averageScanTime: averageScanTime,
      successRate: successRate,
      fastestScan: fastestScan,
      slowestScan: slowestScan,
      scanMethodCounts: scanMethodCounts,
      errorCounts: errorCounts,
      hourlyStats: hourlyStats,
      dateRange: dateRange,
    );
  }

  Duration _calculateAverageScanTime(List<RfidScanMetric> metrics) {
    final successfulMetrics = metrics.where((m) => m.successful).toList();
    if (successfulMetrics.isEmpty) return Duration.zero;

    final totalMs = successfulMetrics
        .map((m) => m.scanDuration.inMilliseconds)
        .reduce((a, b) => a + b);

    return Duration(milliseconds: totalMs ~/ successfulMetrics.length);
  }

  double _calculateSuccessRate(List<RfidScanMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    final successful = metrics.where((m) => m.successful).length;
    return successful / metrics.length;
  }
}

/// Performance statistics for RFID scans
class RfidPerformanceStats {
  final int totalScans;
  final int successfulScans;
  final Duration averageScanTime;
  final double successRate;
  final Duration fastestScan;
  final Duration slowestScan;
  final Map<String, int> scanMethodCounts;
  final Map<String, int> errorCounts;
  final Map<String, RfidPerformanceStats> hourlyStats;
  final DateTimeRange? dateRange;

  const RfidPerformanceStats({
    required this.totalScans,
    required this.successfulScans,
    required this.averageScanTime,
    required this.successRate,
    required this.fastestScan,
    required this.slowestScan,
    required this.scanMethodCounts,
    required this.errorCounts,
    required this.hourlyStats,
    this.dateRange,
  });

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'totalScans': totalScans,
      'successfulScans': successfulScans,
      'averageScanTimeMs': averageScanTime.inMilliseconds,
      'successRate': successRate,
      'fastestScanMs': fastestScan.inMilliseconds,
      'slowestScanMs': slowestScan.inMilliseconds,
      'scanMethodCounts': scanMethodCounts,
      'errorCounts': errorCounts,
      'hourlyStats': hourlyStats.map((k, v) => MapEntry(k, v.toJson())),
      'dateRange': dateRange != null ? {
        'start': dateRange!.start.toIso8601String(),
        'end': dateRange!.end.toIso8601String(),
      } : null,
    };
  }

  @override
  String toString() {
    return 'RfidPerformanceStats('
        'totalScans: $totalScans, '
        'successfulScans: $successfulScans, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
        'avgScanTime: ${averageScanTime.inMilliseconds}ms'
        ')';
  }
}

/// Performance alert for threshold violations
class RfidPerformanceAlert {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String recommendation;
  final DateTime timestamp;

  const RfidPerformanceAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity.toString(),
      'title': title,
      'message': message,
      'recommendation': recommendation,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Performance report containing stats and alerts
class RfidPerformanceReport {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final RfidPerformanceStats stats;
  final List<RfidPerformanceAlert> alerts;
  final DateTime generatedAt;

  const RfidPerformanceReport({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.stats,
    required this.alerts,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'stats': stats.toJson(),
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Date range helper
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}