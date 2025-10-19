import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../services/rfid_performance_service.dart';
import '../services/rfid_error_handler.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';
import '../services/entry_service.dart';

/// Performance monitoring provider state
class PerformanceMonitoringState {
  final bool isInitialized;
  final bool isMonitoring;
  final RfidPerformanceStats? recentStats;
  final List<RfidPerformanceAlert> alerts;
  final Map<String, dynamic>? errorStats;
  final RfidSystemHealth systemHealth;
  final String? error;

  const PerformanceMonitoringState({
    required this.isInitialized,
    required this.isMonitoring,
    this.recentStats,
    this.alerts = const [],
    this.errorStats,
    required this.systemHealth,
    this.error,
  });

  PerformanceMonitoringState copyWith({
    bool? isInitialized,
    bool? isMonitoring,
    RfidPerformanceStats? recentStats,
    List<RfidPerformanceAlert>? alerts,
    Map<String, dynamic>? errorStats,
    RfidSystemHealth? systemHealth,
    String? error,
  }) {
    return PerformanceMonitoringState(
      isInitialized: isInitialized ?? this.isInitialized,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      recentStats: recentStats ?? this.recentStats,
      alerts: alerts ?? this.alerts,
      errorStats: errorStats ?? this.errorStats,
      systemHealth: systemHealth ?? this.systemHealth,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceMonitoringState &&
        other.isInitialized == isInitialized &&
        other.isMonitoring == isMonitoring &&
        other.recentStats == recentStats &&
        other.systemHealth == systemHealth &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        isInitialized,
        isMonitoring,
        recentStats,
        systemHealth,
        error,
      );
}

/// Performance monitoring provider
class PerformanceMonitoringProvider extends StateNotifier<PerformanceMonitoringState> {
  final RfidPerformanceService _performanceService;
  final RfidErrorHandler _errorHandler;

  Timer? _updateTimer;
  static const Duration _updateInterval = Duration(seconds: 30);

  PerformanceMonitoringProvider({
    required RfidPerformanceService performanceService,
    required RfidErrorHandler errorHandler,
  }) : _performanceService = performanceService,
       _errorHandler = errorHandler,
       super(const PerformanceMonitoringState(
         isInitialized: false,
         isMonitoring: false,
         systemHealth: RfidSystemHealth.healthy,
       ));

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      state = state.copyWith(isInitialized: true, error: null);

      await _performanceService.initialize();

      // Start periodic updates
      _startPeriodicUpdates();

      state = state.copyWith(
        isMonitoring: true,
        systemHealth: _errorHandler.getSystemHealth(),
      );

      debugPrint('Performance monitoring initialized');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize performance monitoring: $e',
      );
      debugPrint('Failed to initialize performance monitoring: $e');
    }
  }

  /// Record a successful scan
  Future<void> recordSuccessfulScan({
    required String rfidCode,
    required DateTime startTime,
    required DateTime endTime,
    required String scanMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _performanceService.recordScanAttempt(
        rfidCode: rfidCode,
        startTime: startTime,
        endTime: endTime,
        successful: true,
        scanMethod: scanMethod,
        additionalData: additionalData,
      );

      // Update stats after recording
      await _updateStats();
    } catch (e) {
      debugPrint('Failed to record successful scan: $e');
    }
  }

  /// Record a failed scan
  Future<void> recordFailedScan({
    required String rfidCode,
    required DateTime startTime,
    required DateTime endTime,
    required String scanMethod,
    required String errorCode,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _errorHandler.handleError(
        errorCode: errorCode,
        errorDetails: errorMessage ?? 'Unknown error',
        scanMethod: scanMethod,
        rfidCode: rfidCode,
        context: additionalData,
        timestamp: startTime,
      );

      // Update stats after recording
      await _updateStats();
    } catch (e) {
      debugPrint('Failed to record failed scan: $e');
    }
  }

  /// Get current performance stats
  Future<RfidPerformanceStats> getCurrentStats({Duration period = const Duration(hours: 24)}) async {
    try {
      return await _performanceService.getCachedStats(period: period);
    } catch (e) {
      debugPrint('Failed to get current stats: $e');
      rethrow;
    }
  }

  /// Get recent alerts
  List<RfidPerformanceAlert> getRecentAlerts({Duration period = const Duration(hours: 1)}) {
    try {
      return _performanceService.getPerformanceAlerts(period: period);
    } catch (e) {
      debugPrint('Failed to get recent alerts: $e');
      return [];
    }
  }

  /// Generate performance report
  Future<RfidPerformanceReport> generateReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      return await _performanceService.generatePerformanceReport(
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      debugPrint('Failed to generate performance report: $e');
      rethrow;
    }
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    try {
      return _errorHandler.getErrorStatistics();
    } catch (e) {
      debugPrint('Failed to get error statistics: $e');
      return {};
    }
  }

  /// Get recent error events
  List<RfidErrorEvent> getRecentErrors({int limit = 50}) {
    try {
      return _errorHandler.getRecentErrors(limit: limit);
    } catch (e) {
      debugPrint('Failed to get recent errors: $e');
      return [];
    }
  }

  /// Check if scan time meets performance target
  bool meetsPerformanceTarget(Duration scanTime) {
    return scanTime.inSeconds < 5;
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final stats = state.recentStats;
    final alerts = state.alerts;

    if (stats == null) return recommendations;

    // Check scan time performance
    if (stats.averageScanTime.inSeconds >= 5) {
      recommendations.add('Average scan time exceeds 5-second target');
      recommendations.add('Consider optimizing NFC positioning or hardware');
    }

    // Check success rate
    if (stats.successRate < 0.95) {
      recommendations.add('Success rate is below 95% target');
      recommendations.add('Review error patterns and provide additional training');
    }

    // Check error patterns
    final errorStats = getErrorStatistics();
    final totalErrors = errorStats['totalErrors24h'] as int? ?? 0;

    if (totalErrors > 50) {
      recommendations.add('High error rate detected in last 24 hours');
      recommendations.add('Check NFC hardware and environmental factors');
    }

    // Check specific alerts
    for (final alert in alerts) {
      if (alert.severity == AlertSeverity.critical) {
        recommendations.add(alert.recommendation);
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('Performance is within acceptable parameters');
    }

    return recommendations;
  }

  /// Clear error history
  void clearErrorHistory() {
    try {
      _errorHandler.clearErrorHistory();
      _updateStats();
    } catch (e) {
      debugPrint('Failed to clear error history: $e');
    }
  }

  /// Force refresh of statistics
  Future<void> refreshStats() async {
    await _updateStats();
  }

  /// Dispose of the provider
  @override
  void dispose() {
    _updateTimer?.cancel();
    _performanceService.dispose();
    super.dispose();
  }

  // Private helper methods

  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (_) => _updateStats());
  }

  Future<void> _updateStats() async {
    try {
      // Get performance stats
      final stats = await _performanceService.getCachedStats();

      // Get alerts
      final alerts = _performanceService.getPerformanceAlerts();

      // Get error stats
      final errorStats = _errorHandler.getErrorStatistics();

      // Get system health
      final systemHealth = _errorHandler.getSystemHealth();

      state = state.copyWith(
        recentStats: stats,
        alerts: alerts,
        errorStats: errorStats,
        systemHealth: systemHealth,
        error: null,
      );
    } catch (e) {
      debugPrint('Failed to update stats: $e');
      state = state.copyWith(error: 'Failed to update statistics: $e');
    }
  }
}

// Providers

/// Provider for performance service
final rfidPerformanceServiceProvider = Provider<RfidPerformanceService>((ref) {
  return RfidPerformanceService(
    supabaseService: ref.watch(supabaseServiceProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

/// Provider for error handler
final rfidErrorHandlerProvider = Provider<RfidErrorHandler>((ref) {
  return RfidErrorHandler(
    performanceService: ref.watch(rfidPerformanceServiceProvider),
  );
});

/// Provider for performance monitoring
final rfidPerformanceMonitoringProvider = StateNotifierProvider<PerformanceMonitoringProvider, PerformanceMonitoringState>((ref) {
  return PerformanceMonitoringProvider(
    performanceService: ref.watch(rfidPerformanceServiceProvider),
    errorHandler: ref.watch(rfidErrorHandlerProvider),
  );
});

/// Provider for performance stats (read-only)
final rfidPerformanceStatsProvider = Provider<RfidPerformanceStats?>((ref) {
  return ref.watch(rfidPerformanceMonitoringProvider.select((state) => state.recentStats));
});

/// Provider for performance alerts (read-only)
final rfidPerformanceAlertsProvider = Provider<List<RfidPerformanceAlert>>((ref) {
  return ref.watch(rfidPerformanceMonitoringProvider.select((state) => state.alerts));
});

/// Provider for system health (read-only)
final rfidSystemHealthProvider = Provider<RfidSystemHealth>((ref) {
  return ref.watch(rfidPerformanceMonitoringProvider.select((state) => state.systemHealth));
});

/// Provider for performance recommendations (read-only)
final rfidPerformanceRecommendationsProvider = Provider<List<String>>((ref) {
  final provider = ref.watch(rfidPerformanceMonitoringProvider.notifier);
  return provider.getPerformanceRecommendations();
});

/// Provider for error statistics (read-only)
final rfidErrorStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final provider = ref.watch(rfidPerformanceMonitoringProvider.notifier);
  return provider.getErrorStatistics();
});

/// Provider for recent error events (read-only)
final rfidRecentErrorEventsProvider = Provider<List<RfidErrorEvent>>((ref) {
  final provider = ref.watch(rfidPerformanceMonitoringProvider.notifier);
  return provider.getRecentErrors();
});

// Helper providers that should be defined elsewhere
// These would typically be defined in a main providers file

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final cacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});

final entryServiceProvider = Provider<EntryService>((ref) {
  return EntryService(
    supabaseService: ref.watch(supabaseServiceProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});