import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Network connectivity monitor
/// Provides real-time network status updates and connectivity information
class NetworkMonitor {
  NetworkMonitor._();
  static final NetworkMonitor _instance = NetworkMonitor._();
  static NetworkMonitor get instance => _instance;

  final Logger _logger = Logger();

  // Network status
  bool _isConnected = false;
  bool _isMonitoring = false;
  NetworkType _currentType = NetworkType.unknown;

  // Stream controllers
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  // Timers and intervals
  Timer? _pingTimer;
  Timer? _monitoringTimer;

  // Configuration
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _pingTimeout = Duration(seconds: 5);
  static const Duration _monitoringInterval = Duration(seconds: 10);
  static const List<String> _pingHosts = [
    '8.8.8.8',        // Google DNS
    '1.1.1.1',        // Cloudflare DNS
    'google.com',     // HTTP fallback
    'supabase.co',    // Supabase (our backend)
  ];

  /// Network status stream
  Stream<NetworkStatus> get networkStatusStream => _statusController.stream;

  /// Simple connectivity stream (boolean)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current network status
  NetworkStatus get currentStatus => NetworkStatus(
    isConnected: _isConnected,
    type: _currentType,
    lastChecked: DateTime.now(),
  );

  /// Is currently connected
  bool get isConnected => _isConnected;

  /// Current network type
  NetworkType get currentType => _currentType;

  /// Start network monitoring
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      _logger.d('Network monitoring already started');
      return;
    }

    try {
      _logger.i('Starting network monitoring...');

      _isMonitoring = true;

      // Initial connectivity check
      await _checkConnectivity();

      // Start periodic monitoring
      _startPeriodicMonitoring();

      // Start periodic pings
      _startPeriodicPings();

      _logger.i('Network monitoring started');
    } catch (e) {
      _logger.e('Failed to start network monitoring: $e');
      _isMonitoring = false;
      rethrow;
    }
  }

  /// Stop network monitoring
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) {
      return;
    }

    try {
      _logger.i('Stopping network monitoring...');

      _isMonitoring = false;

      // Cancel timers
      _pingTimer?.cancel();
      _pingTimer = null;

      _monitoringTimer?.cancel();
      _monitoringTimer = null;

      _logger.i('Network monitoring stopped');
    } catch (e) {
      _logger.e('Error stopping network monitoring: $e');
    }
  }

  /// Start periodic monitoring
  void _startPeriodicMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(_monitoringInterval, (timer) {
      if (_isMonitoring) {
        unawaited(_checkConnectivity());
      }
    });
  }

  /// Start periodic pings
  void _startPeriodicPings() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isMonitoring) {
        unawaited(_performPingCheck());
      }
    });
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final previousStatus = _isConnected;

      // Perform quick connectivity test
      _isConnected = await _hasNetworkConnectivity();

      // Determine network type
      if (_isConnected) {
        _currentType = await _determineNetworkType();
      } else {
        _currentType = NetworkType.none;
      }

      final currentStatus = NetworkStatus(
        isConnected: _isConnected,
        type: _currentType,
        lastChecked: DateTime.now(),
      );

      // Notify listeners if status changed
      if (previousStatus != _isConnected) {
        _statusController.add(currentStatus);
        _connectivityController.add(_isConnected);

        _logger.i('Network status changed: ${_isConnected ? "connected" : "disconnected"} '
                  '(${_currentType.name})');
      }

    } catch (e) {
      _logger.e('Error checking connectivity: $e');

      // Assume disconnected on error
      if (_isConnected) {
        _isConnected = false;
        _currentType = NetworkType.none;

        final currentStatus = NetworkStatus(
          isConnected: false,
          type: NetworkType.none,
          lastChecked: DateTime.now(),
        );

        _statusController.add(currentStatus);
        _connectivityController.add(false);
      }
    }
  }

  /// Perform ping check for detailed connectivity analysis
  Future<void> _performPingCheck() async {
    if (!_isConnected) {
      return;
    }

    try {
      final results = <String, PingResult>{};

      for (final host in _pingHosts) {
        final result = await _pingHost(host);
        results[host] = result;

        // If any ping succeeds, we have connectivity
        if (result.isSuccess) {
          if (!_isConnected) {
            _isConnected = true;
            _currentType = await _determineNetworkType();

            final currentStatus = NetworkStatus(
              isConnected: true,
              type: _currentType,
              lastChecked: DateTime.now(),
              pingResults: results,
            );

            _statusController.add(currentStatus);
            _connectivityController.add(true);

            _logger.i('Network restored via ping check');
          }
          break;
        }
      }

      // If all pings failed but we thought we were connected, update status
      if (_isConnected && !results.values.any((r) => r.isSuccess)) {
        _isConnected = false;
        _currentType = NetworkType.none;

        final currentStatus = NetworkStatus(
          isConnected: false,
          type: NetworkType.none,
          lastChecked: DateTime.now(),
          pingResults: results,
        );

        _statusController.add(currentStatus);
        _connectivityController.add(false);

        _logger.w('Network lost - all pings failed');
      }

      // Log ping results for debugging
      if (kDebugMode) {
        _logger.d('Ping results: ${results.entries.map((e) => '${e.key}: ${e.value.status}').join(', ')}');
      }

    } catch (e) {
      _logger.e('Error during ping check: $e');
    }
  }

  /// Basic network connectivity check
  Future<bool> _hasNetworkConnectivity() async {
    try {
      // Try to resolve a hostname
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Determine network type (simplified)
  Future<NetworkType> _determineNetworkType() async {
    try {
      // In a real implementation, you might use platform-specific APIs
      // For now, we'll use a simplified approach

      // Try to reach different endpoints to infer connection type
      final mobileTest = await _testMobileConnection();
      if (mobileTest) {
        return NetworkType.mobile;
      }

      final wifiTest = await _testWifiConnection();
      if (wifiTest) {
        return NetworkType.wifi;
      }

      return NetworkType.unknown;
    } catch (e) {
      _logger.e('Error determining network type: $e');
      return NetworkType.unknown;
    }
  }

  /// Test mobile connection (simplified)
  Future<bool> _testMobileConnection() async {
    try {
      // This is a simplified test - in reality, you'd use platform-specific APIs
      // to determine if the connection is mobile
      final result = await InternetAddress.lookup('m.google.com');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Test WiFi connection (simplified)
  Future<bool> _testWifiConnection() async {
    try {
      // This is a simplified test - in reality, you'd use platform-specific APIs
      // to determine if the connection is WiFi
      final result = await InternetAddress.lookup('wifi.google.com');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Ping a specific host
  Future<PingResult> _pingHost(String host) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Use socket connection as a simple ping
      final socket = await Socket.connect(host, 80, timeout: _pingTimeout)
          .timeout(_pingTimeout);

      stopwatch.stop();

      socket.destroy();

      return PingResult(
        host: host,
        isSuccess: true,
        responseTime: stopwatch.elapsedMilliseconds,
        status: 'success',
      );
    } catch (e) {
      stopwatch.stop();

      String status = 'timeout';
      if (e is SocketException) {
        status = 'socket_error';
      } else if (e is TimeoutException) {
        status = 'timeout';
      }

      return PingResult(
        host: host,
        isSuccess: false,
        responseTime: stopwatch.elapsedMilliseconds,
        status: status,
        error: e.toString(),
      );
    }
  }

  /// Manually trigger connectivity check
  Future<NetworkStatus> checkConnectivity() async {
    await _checkConnectivity();
    return currentStatus;
  }

  /// Wait for connectivity to be restored
  Future<bool> waitForConnectivity({
    Duration timeout = const Duration(minutes: 5),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    if (_isConnected) {
      return true;
    }

    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await _checkConnectivity();

      if (_isConnected) {
        return true;
      }

      await Future.delayed(checkInterval);
    }

    return false;
  }

  /// Get network statistics
  NetworkStats getStats() {
    return NetworkStats(
      isMonitoring: _isMonitoring,
      currentType: _currentType,
      uptime: _isMonitoring ? DateTime.now().difference(_startTime) : Duration.zero,
      lastStatusChange: _lastStatusChange,
      totalStatusChanges: _statusChangeCount,
    );
  }

  // Private tracking variables
  final DateTime _startTime = DateTime.now();
  DateTime? _lastStatusChange;
  int _statusChangeCount = 0;

  /// Dispose network monitor
  Future<void> dispose() async {
    try {
      _logger.i('Disposing network monitor...');

      await stopMonitoring();

      // Close stream controllers
      await _statusController.close();
      await _connectivityController.close();

      _logger.i('Network monitor disposed');
    } catch (e) {
      _logger.e('Error disposing network monitor: $e');
    }
  }
}

/// Network status data class
class NetworkStatus {
  final bool isConnected;
  final NetworkType type;
  final DateTime lastChecked;
  final Map<String, PingResult>? pingResults;

  const NetworkStatus({
    required this.isConnected,
    required this.type,
    required this.lastChecked,
    this.pingResults,
  });

  @override
  String toString() {
    return 'NetworkStatus(isConnected: $isConnected, type: $type, lastChecked: $lastChecked)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkStatus &&
          runtimeType == other.runtimeType &&
          isConnected == other.isConnected &&
          type == other.type;

  @override
  int get hashCode => isConnected.hashCode ^ type.hashCode;
}

/// Network type enum
enum NetworkType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
  none,
  unknown;

  String get name {
    switch (this) {
      case NetworkType.wifi:
        return 'WiFi';
      case NetworkType.mobile:
        return 'Mobile';
      case NetworkType.ethernet:
        return 'Ethernet';
      case NetworkType.bluetooth:
        return 'Bluetooth';
      case NetworkType.vpn:
        return 'VPN';
      case NetworkType.other:
        return 'Other';
      case NetworkType.none:
        return 'None';
      case NetworkType.unknown:
        return 'Unknown';
    }
  }
}

/// Ping result data class
class PingResult {
  final String host;
  final bool isSuccess;
  final int responseTime;
  final String status;
  final String? error;

  const PingResult({
    required this.host,
    required this.isSuccess,
    required this.responseTime,
    required this.status,
    this.error,
  });

  @override
  String toString() {
    return 'PingResult(host: $host, success: $isSuccess, time: ${responseTime}ms, status: $status)';
  }
}

/// Network statistics data class
class NetworkStats {
  final bool isMonitoring;
  final NetworkType currentType;
  final Duration uptime;
  final DateTime? lastStatusChange;
  final int totalStatusChanges;

  const NetworkStats({
    required this.isMonitoring,
    required this.currentType,
    required this.uptime,
    this.lastStatusChange,
    required this.totalStatusChanges,
  });

  @override
  String toString() {
    return 'NetworkStats(monitoring: $isMonitoring, type: $currentType, uptime: $uptime, changes: $totalStatusChanges)';
  }
}

/// Extension for unawaited futures
extension UnawaitedExtension on Future<void> {
  void unawaited() {
    // Ignore the result to prevent "unawaited future" warnings
  }
}