import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../models/rfid_scan_metric.dart';
import '../models/rfid_sticker.dart';
import '../services/nfc_service.dart';
import '../services/rfid_performance_service.dart';
import '../utils/constants.dart';

/// RFID Error Handler Service
///
/// Comprehensive error handling for RFID scanning operations,
/// including error classification, recovery strategies, and
/// user-friendly error messages.
class RfidErrorHandler {
  final RfidPerformanceService _performanceService;

  // Error tracking
  final Map<String, int> _errorCounts = {};
  final List<RfidErrorEvent> _recentErrors = [];
  static const int _maxRecentErrors = 100;

  // Error recovery state
  final Map<String, DateTime> _lastErrorTime = {};
  final Map<String, int> _consecutiveErrors = {};

  RfidErrorHandler({
    required RfidPerformanceService performanceService,
  }) : _performanceService = performanceService;

  /// Handle an RFID error
  Future<RfidErrorResult> handleError({
    required String errorCode,
    required String errorDetails,
    required String scanMethod,
    String? rfidCode,
    Map<String, dynamic>? context,
    DateTime? timestamp,
  }) async {
    final errorTime = timestamp ?? DateTime.now();

    // Track error
    _trackError(errorCode, errorTime);

    // Classify error severity
    final severity = _classifyErrorSeverity(errorCode, _consecutiveErrors[errorCode] ?? 1);

    // Create error event
    final errorEvent = RfidErrorEvent(
      id: errorTime.millisecondsSinceEpoch.toString(),
      errorCode: errorCode,
      errorDetails: errorDetails,
      severity: severity,
      scanMethod: scanMethod,
      rfidCode: rfidCode,
      context: context ?? {},
      timestamp: errorTime,
      consecutiveCount: _consecutiveErrors[errorCode] ?? 1,
    );

    // Add to recent errors
    _addRecentError(errorEvent);

    // Log error
    _logError(errorEvent);

    // Record performance metric
    await _recordErrorMetric(errorEvent);

    // Determine recovery strategy
    final recovery = _determineRecoveryStrategy(errorEvent);

    // Generate user-friendly message
    final userMessage = _generateUserMessage(errorEvent, recovery);

    return RfidErrorResult(
      success: false,
      errorCode: errorCode,
      errorDetails: errorDetails,
      userMessage: userMessage,
      severity: severity,
      recoveryStrategy: recovery,
      canRetry: recovery.canRetry,
      suggestedActions: recovery.suggestedActions,
      errorEvent: errorEvent,
    );
  }

  /// Handle NFC unavailable error
  RfidErrorResult handleNfcUnavailable({String? details}) {
    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.nfcNotAvailable,
      errorDetails: details ?? 'NFC is not available on this device',
      userMessage: 'NFC is not available on this device. Please use manual verification.',
      severity: ErrorSeverity.critical,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: RecoveryType.useAlternative,
        canRetry: false,
        suggestedActions: [
          'Use manual verification instead',
          'Check if device supports NFC',
          'Enable NFC in device settings',
        ],
        alternativeMethod: 'manual_verification',
      ),
      canRetry: false,
      suggestedActions: [
        'Use manual verification instead',
        'Check if device supports NFC',
        'Enable NFC in device settings',
      ],
    );
  }

  /// Handle NFC permission denied error
  RfidErrorResult handleNfcPermissionDenied({String? details}) {
    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.nfcPermissionDenied,
      errorDetails: details ?? 'NFC permission was denied',
      userMessage: 'NFC permission is required. Please grant permission to scan RFID stickers.',
      severity: ErrorSeverity.high,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: RecoveryType.requestPermission,
        canRetry: true,
        suggestedActions: [
          'Grant NFC permission when prompted',
          'Check app permissions in settings',
          'Restart the app after granting permission',
        ],
      ),
      canRetry: true,
      suggestedActions: [
        'Grant NFC permission when prompted',
        'Check app permissions in settings',
        'Restart the app after granting permission',
      ],
    );
  }

  /// Handle scan timeout error
  RfidErrorResult handleScanTimeout({
    required Duration timeoutDuration,
    String? rfidCode,
  }) {
    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.nfcTimeout,
      errorDetails: 'Scan timed out after ${timeoutDuration.inSeconds}s',
      userMessage: 'Scan timed out. Please try again with a quicker scan.',
      severity: ErrorSeverity.medium,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: RecoveryType.retryWithAdjustments,
        canRetry: true,
        suggestedActions: [
          'Hold the device closer to the RFID sticker',
          'Hold the device steady for 2-3 seconds',
          'Ensure the RFID sticker is properly positioned',
        ],
        retryDelay: const Duration(seconds: 1),
      ),
      canRetry: true,
      suggestedActions: [
        'Hold the device closer to the RFID sticker',
        'Hold the device steady for 2-3 seconds',
        'Ensure the RFID sticker is properly positioned',
      ],
    );
  }

  /// Handle network error during RFID verification
  Future<RfidErrorResult> handleNetworkError({
    required String operation,
    String? details,
  }) async {
    final isConsecutive = _isConsecutiveError(RfidErrorCodes.networkError);

    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.networkError,
      errorDetails: details ?? 'Network connection failed during $operation',
      userMessage: isConsecutive
          ? 'Network connection is unstable. Please check your connection.'
          : 'Network connection failed. Retrying...',
      severity: isConsecutive ? ErrorSeverity.high : ErrorSeverity.medium,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: isConsecutive ? RecoveryType.useOffline : RecoveryType.retry,
        canRetry: true,
        suggestedActions: isConsecutive
            ? [
                'Check internet connection',
                'Try again when connection is stable',
                'Use offline mode if available',
              ]
            : [
                'Retrying automatically...',
                'Check network if problem persists',
              ],
        retryDelay: isConsecutive ? const Duration(seconds: 5) : const Duration(seconds: 2),
        fallbackAvailable: true,
      ),
      canRetry: true,
      suggestedActions: isConsecutive
          ? [
              'Check internet connection',
              'Try again when connection is stable',
              'Use offline mode if available',
            ]
          : [
              'Retrying automatically...',
              'Check network if problem persists',
            ],
    );
  }

  /// Handle invalid RFID format error
  RfidErrorResult handleInvalidFormat({
    required String invalidCode,
    String? expectedFormat,
  }) {
    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.invalidFormat,
      errorDetails: 'Invalid RFID format: $invalidCode',
      userMessage: 'Invalid RFID sticker detected. Please use a valid sticker.',
      severity: ErrorSeverity.medium,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: RecoveryType.useAlternative,
        canRetry: true,
        suggestedActions: [
          'Use a valid RFID sticker',
          'Check if the sticker is damaged',
          'Clean the RFID sticker',
          'Use manual verification as alternative',
        ],
      ),
      canRetry: true,
      suggestedActions: [
        'Use a valid RFID sticker',
        'Check if the sticker is damaged',
        'Clean the RFID sticker',
        'Use manual verification as alternative',
      ],
    );
  }

  /// Handle RFID sticker not found error
  RfidErrorResult handleStickerNotFound({
    required String rfidCode,
    bool isTemporary = false,
  }) {
    return RfidErrorResult(
      success: false,
      errorCode: RfidErrorCodes.stickerNotFound,
      errorDetails: 'RFID sticker not found: $rfidCode',
      userMessage: isTemporary
          ? 'Unable to verify RFID sticker. Please try again.'
          : 'RFID sticker not found in system. Please use manual verification.',
      severity: ErrorSeverity.medium,
      recoveryStrategy: ErrorRecoveryStrategy(
        type: RecoveryType.useAlternative,
        canRetry: !isTemporary,
        suggestedActions: isTemporary
            ? [
                'Try scanning again',
                'Hold device closer to sticker',
                'Check if sticker is properly positioned',
              ]
            : [
                'Use manual verification',
                'Contact administrator if this is a valid sticker',
                'Check if the sticker is registered in the system',
              ],
        alternativeMethod: 'manual_verification',
      ),
      canRetry: !isTemporary,
      suggestedActions: isTemporary
          ? [
              'Try scanning again',
              'Hold device closer to sticker',
              'Check if sticker is properly positioned',
            ]
          : [
              'Use manual verification',
              'Contact administrator if this is a valid sticker',
              'Check if the sticker is registered in the system',
            ],
    );
  }

  /// Get error statistics for monitoring
  Map<String, dynamic> getErrorStatistics() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last1h = now.subtract(const Duration(hours: 1));

    final recentErrors = _recentErrors.where((e) => e.timestamp.isAfter(last24h)).toList();
    final veryRecentErrors = _recentErrors.where((e) => e.timestamp.isAfter(last1h)).toList();

    final errorsByCode = <String, int>{};
    final errorsBySeverity = <ErrorSeverity, int>{};
    final errorsByMethod = <String, int>{};

    for (final error in recentErrors) {
      errorsByCode[error.errorCode] = (errorsByCode[error.errorCode] ?? 0) + 1;
      errorsBySeverity[error.severity] = (errorsBySeverity[error.severity] ?? 0) + 1;
      errorsByMethod[error.scanMethod] = (errorsByMethod[error.scanMethod] ?? 0) + 1;
    }

    // Get most frequent errors
    final sortedErrors = errorsByCode.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalErrors24h': recentErrors.length,
      'totalErrors1h': veryRecentErrors.length,
      'uniqueErrorTypes': errorsByCode.length,
      'errorsByCode': errorsByCode,
      'errorsBySeverity': errorsBySeverity.map((k, v) => MapEntry(k.toString(), v)),
      'errorsByMethod': errorsByMethod,
      'mostFrequentErrors': sortedErrors.take(5).toList(),
      'consecutiveErrors': Map.from(_consecutiveErrors),
      'lastUpdated': now.toIso8601String(),
    };
  }

  /// Get recent error events
  List<RfidErrorEvent> getRecentErrors({int limit = 50}) {
    return _recentErrors.take(limit).toList();
  }

  /// Clear error history
  void clearErrorHistory() {
    _recentErrors.clear();
    _errorCounts.clear();
    _lastErrorTime.clear();
    _consecutiveErrors.clear();
    developer.log('Error history cleared', name: 'sentinel.rfid.errors');
  }

  /// Check if error rate is high
  bool isErrorRateHigh({Duration period = const Duration(hours: 1)}) {
    final cutoff = DateTime.now().subtract(period);
    final recentErrors = _recentErrors.where((e) => e.timestamp.isAfter(cutoff)).toList();

    // Consider high error rate if more than 10 errors per hour
    return recentErrors.length > 10;
  }

  /// Get health status based on errors
  RfidSystemHealth getSystemHealth() {
    final stats = getErrorStatistics();
    final errorRate = stats['totalErrors1h'] as int;
    final criticalErrors = stats['errorsBySeverity'][ErrorSeverity.critical.toString()] ?? 0;

    if (criticalErrors > 0 || errorRate > 20) {
      return RfidSystemHealth.critical;
    } else if (errorRate > 10 || stats['totalErrors24h'] > 50) {
      return RfidSystemHealth.degraded;
    } else if (errorRate > 5) {
      return RfidSystemHealth.warning;
    } else {
      return RfidSystemHealth.healthy;
    }
  }

  // Private helper methods

  void _trackError(String errorCode, DateTime timestamp) {
    // Update error count
    _errorCounts[errorCode] = (_errorCounts[errorCode] ?? 0) + 1;

    // Update consecutive error count
    final lastTime = _lastErrorTime[errorCode];
    if (lastTime != null && timestamp.difference(lastTime).inMinutes < 5) {
      _consecutiveErrors[errorCode] = (_consecutiveErrors[errorCode] ?? 0) + 1;
    } else {
      _consecutiveErrors[errorCode] = 1;
    }

    _lastErrorTime[errorCode] = timestamp;
  }

  void _addRecentError(RfidErrorEvent errorEvent) {
    _recentErrors.insert(0, errorEvent);
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeRange(_maxRecentErrors, _recentErrors.length);
    }
  }

  ErrorSeverity _classifyErrorSeverity(String errorCode, int consecutiveCount) {
    // Critical errors that always have high severity
    switch (errorCode) {
      case RfidErrorCodes.nfcNotAvailable:
      case RfidErrorCodes.stickerDisabled:
      case RfidErrorCodes.stickerLost:
        return ErrorSeverity.critical;
    }

    // Upgrade severity based on consecutive errors
    if (consecutiveCount >= 5) {
      return ErrorSeverity.critical;
    } else if (consecutiveCount >= 3) {
      return ErrorSeverity.high;
    }

    // Default severity based on error type
    switch (errorCode) {
      case RfidErrorCodes.nfcPermissionDenied:
      case RfidErrorCodes.serverError:
        return ErrorSeverity.high;
      case RfidErrorCodes.nfcTimeout:
      case RfidErrorCodes.networkError:
      case RfidErrorCodes.stickerNotFound:
      case RfidErrorCodes.invalidFormat:
        return ErrorSeverity.medium;
      default:
        return ErrorSeverity.low;
    }
  }

  ErrorRecoveryStrategy _determineRecoveryStrategy(RfidErrorEvent errorEvent) {
    switch (errorEvent.errorCode) {
      case RfidErrorCodes.nfcNotAvailable:
        return ErrorRecoveryStrategy(
          type: RecoveryType.useAlternative,
          canRetry: false,
          suggestedActions: [
            'Use manual verification instead',
            'Check device compatibility',
          ],
          alternativeMethod: 'manual_verification',
        );

      case RfidErrorCodes.nfcPermissionDenied:
        return ErrorRecoveryStrategy(
          type: RecoveryType.requestPermission,
          canRetry: true,
          suggestedActions: [
            'Grant NFC permission',
            'Check app settings',
          ],
        );

      case RfidErrorCodes.nfcTimeout:
        return ErrorRecoveryStrategy(
          type: RecoveryType.retryWithAdjustments,
          canRetry: true,
          suggestedActions: [
            'Move device closer',
            'Hold steady for 2-3 seconds',
          ],
          retryDelay: const Duration(seconds: 1),
        );

      case RfidErrorCodes.stickerNotFound:
        if (errorEvent.consecutiveCount < 3) {
          return ErrorRecoveryStrategy(
            type: RecoveryType.retry,
            canRetry: true,
            suggestedActions: [
              'Try scanning again',
              'Check sticker position',
            ],
            retryDelay: const Duration(seconds: 2),
          );
        } else {
          return ErrorRecoveryStrategy(
            type: RecoveryType.useAlternative,
            canRetry: false,
            suggestedActions: [
              'Use manual verification',
              'Contact administrator',
            ],
            alternativeMethod: 'manual_verification',
          );
        }

      case RfidErrorCodes.networkError:
        if (errorEvent.consecutiveCount < 2) {
          return ErrorRecoveryStrategy(
            type: RecoveryType.retry,
            canRetry: true,
            suggestedActions: [
              'Retrying...',
              'Check network connection',
            ],
            retryDelay: const Duration(seconds: 3),
            fallbackAvailable: true,
          );
        } else {
          return ErrorRecoveryStrategy(
            type: RecoveryType.useOffline,
            canRetry: false,
            suggestedActions: [
              'Using offline mode',
              'Check connection later',
            ],
            fallbackAvailable: true,
          );
        }

      default:
        return ErrorRecoveryStrategy(
          type: RecoveryType.retry,
          canRetry: true,
          suggestedActions: [
            'Try again',
            'Contact support if problem persists',
          ],
          retryDelay: const Duration(seconds: 2),
        );
    }
  }

  String _generateUserMessage(RfidErrorEvent errorEvent, ErrorRecoveryStrategy recovery) {
    // Base message on error type and severity
    switch (errorEvent.errorCode) {
      case RfidErrorCodes.nfcNotAvailable:
        return 'NFC is not available on this device. Please use manual verification.';

      case RfidErrorCodes.nfcPermissionDenied:
        return 'NFC permission is required. Please grant permission to scan RFID stickers.';

      case RfidErrorCodes.nfcTimeout:
        return 'Scan timed out. Please hold the device closer to the RFID sticker and try again.';

      case RfidErrorCodes.stickerNotFound:
        return errorEvent.consecutiveCount > 2
            ? 'RFID sticker not recognized. Please use manual verification.'
            : 'Unable to read RFID sticker. Please try again.';

      case RfidErrorCodes.stickerExpired:
        return 'This RFID sticker has expired. Please contact the administrator.';

      case RfidErrorCodes.stickerDisabled:
        return 'This RFID sticker has been disabled. Please contact the administrator.';

      case RfidErrorCodes.stickerLost:
        return 'This RFID sticker has been reported as lost. Please contact security.';

      case RfidErrorCodes.networkError:
        return errorEvent.consecutiveCount > 1
            ? 'Network connection is unstable. Using offline mode.'
            : 'Network connection failed. Retrying...';

      case RfidErrorCodes.serverError:
        return 'Server error occurred. Please try again in a moment.';

      case RfidErrorCodes.invalidFormat:
        return 'Invalid RFID sticker detected. Please use a valid sticker.';

      default:
        return 'An error occurred during scanning. Please try again.';
    }
  }

  void _logError(RfidErrorEvent errorEvent) {
    final logLevel = switch (errorEvent.severity) {
      ErrorSeverity.critical => 1000,
      ErrorSeverity.high => 900,
      ErrorSeverity.medium => 800,
      ErrorSeverity.low => 700,
    };

    developer.log(
      'RFID Error [${errorEvent.errorCode}]: ${errorEvent.errorDetails}',
      name: 'sentinel.rfid.errors',
      level: logLevel,
      error: errorEvent,
    );
  }

  Future<void> _recordErrorMetric(RfidErrorEvent errorEvent) async {
    try {
      await _performanceService.recordScanAttempt(
        rfidCode: errorEvent.rfidCode ?? 'unknown',
        startTime: errorEvent.timestamp,
        endTime: errorEvent.timestamp, // Same timestamp for error events
        successful: false,
        scanMethod: errorEvent.scanMethod,
        errorMessage: errorEvent.errorDetails,
        errorCode: errorEvent.errorCode,
        additionalData: {
          'severity': errorEvent.severity.toString(),
          'consecutiveCount': errorEvent.consecutiveCount,
          'context': errorEvent.context,
        },
      );
    } catch (e) {
      developer.log('Failed to record error metric: $e',
                   name: 'sentinel.rfid.errors', level: 900);
    }
  }

  bool _isConsecutiveError(String errorCode) {
    final lastTime = _lastErrorTime[errorCode];
    if (lastTime == null) return false;

    return DateTime.now().difference(lastTime).inMinutes < 5;
  }
}

/// RFID Error Event
class RfidErrorEvent {
  final String id;
  final String errorCode;
  final String errorDetails;
  final ErrorSeverity severity;
  final String scanMethod;
  final String? rfidCode;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final int consecutiveCount;

  const RfidErrorEvent({
    required this.id,
    required this.errorCode,
    required this.errorDetails,
    required this.severity,
    required this.scanMethod,
    this.rfidCode,
    required this.context,
    required this.timestamp,
    required this.consecutiveCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'errorCode': errorCode,
      'errorDetails': errorDetails,
      'severity': severity.toString(),
      'scanMethod': scanMethod,
      'rfidCode': rfidCode,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'consecutiveCount': consecutiveCount,
    };
  }

  @override
  String toString() {
    return 'RfidErrorEvent('
        'errorCode: $errorCode, '
        'severity: $severity, '
        'consecutiveCount: $consecutiveCount, '
        'timestamp: $timestamp'
        ')';
  }
}

/// RFID Error Result
class RfidErrorResult {
  final bool success;
  final String errorCode;
  final String errorDetails;
  final String userMessage;
  final ErrorSeverity severity;
  final ErrorRecoveryStrategy recoveryStrategy;
  final bool canRetry;
  final List<String> suggestedActions;
  final RfidErrorEvent? errorEvent;

  const RfidErrorResult({
    required this.success,
    required this.errorCode,
    required this.errorDetails,
    required this.userMessage,
    required this.severity,
    required this.recoveryStrategy,
    required this.canRetry,
    required this.suggestedActions,
    this.errorEvent,
  });

  factory RfidErrorResult.success() {
    return RfidErrorResult(
      success: true,
      errorCode: 'none',
      errorDetails: 'No error',
      userMessage: 'Success',
      severity: ErrorSeverity.low,
      recoveryStrategy: ErrorRecoveryStrategy.none(),
      canRetry: false,
      suggestedActions: [],
    );
  }
}

/// Error Recovery Strategy
class ErrorRecoveryStrategy {
  final RecoveryType type;
  final bool canRetry;
  final List<String> suggestedActions;
  final Duration? retryDelay;
  final String? alternativeMethod;
  final bool fallbackAvailable;

  const ErrorRecoveryStrategy({
    required this.type,
    required this.canRetry,
    required this.suggestedActions,
    this.retryDelay,
    this.alternativeMethod,
    this.fallbackAvailable = false,
  });

  factory ErrorRecoveryStrategy.none() {
    return const ErrorRecoveryStrategy(
      type: RecoveryType.none,
      canRetry: false,
      suggestedActions: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'canRetry': canRetry,
      'suggestedActions': suggestedActions,
      'retryDelay': retryDelay?.inMilliseconds,
      'alternativeMethod': alternativeMethod,
      'fallbackAvailable': fallbackAvailable,
    };
  }
}

/// Recovery type enumeration
enum RecoveryType {
  none,
  retry,
  retryWithAdjustments,
  requestPermission,
  useAlternative,
  useOffline,
  restartService,
}

/// Error severity enumeration
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// RFID System Health
enum RfidSystemHealth {
  healthy,
  warning,
  degraded,
  critical,
}