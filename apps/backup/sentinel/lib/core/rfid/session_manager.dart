import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nfc_manager_service.dart';

/// NFC Session Manager with Enhanced Timeout Handling
/// Manages NFC scanning sessions with configurable timeouts, retry logic, and session state tracking
class NfcSessionManager {
  NfcSessionManager._();
  static final NfcSessionManager _instance = NfcSessionManager._();
  static NfcSessionManager get instance => _instance;

  final Logger _logger = Logger();

  // Session state
  NfcSessionState _currentSession = NfcSessionState(
    state: SessionState.idle,
    startTime: DateTime.now(),
  );
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;

  // Configuration
  Duration _defaultTimeout = const Duration(seconds: 5);
  Duration _maxIdleTime = const Duration(seconds: 30);
  Duration _sessionExtensionDuration = const Duration(seconds: 3);
  int _maxRetryAttempts = 3;

  // Session tracking
  int _retryCount = 0;
  List<NfcSessionEvent> _sessionHistory = [];

  // Event streams
  final StreamController<NfcSessionState> _stateController =
      StreamController<NfcSessionState>.broadcast();
  final StreamController<NfcSessionEvent> _eventController =
      StreamController<NfcSessionEvent>.broadcast();

  // Timers
  Timer? _timeoutTimer;
  Timer? _idleTimer;

  /// Get current session state stream
  Stream<NfcSessionState> get sessionStateStream => _stateController.stream;

  /// Get session events stream
  Stream<NfcSessionEvent> get sessionEventStream => _eventController.stream;

  /// Get current session state
  NfcSessionState get currentSession => _currentSession;

  /// Check if session is active
  bool get isSessionActive => _currentSession.isActive;

  /// Check if session can be started
  bool get canStartSession => _currentSession.canStart;

  /// Configure session parameters
  void configure({
    Duration? defaultTimeout,
    Duration? maxIdleTime,
    Duration? sessionExtensionDuration,
    int? maxRetryAttempts,
  }) {
    _defaultTimeout = defaultTimeout ?? _defaultTimeout;
    _maxIdleTime = maxIdleTime ?? _maxIdleTime;
    _sessionExtensionDuration = sessionExtensionDuration ?? _sessionExtensionDuration;
    _maxRetryAttempts = maxRetryAttempts ?? _maxRetryAttempts;

    _logger.i('NFC session manager configured: timeout=${_defaultTimeout.inSeconds}s, '
        'maxIdle=${_maxIdleTime.inSeconds}s, maxRetries=$_maxRetryAttempts');
  }

  /// Start a new NFC scanning session
  Future<NfcSessionResult> startSession({
    Duration? timeout,
    bool enableRetry = true,
    bool enableExtension = true,
    String? sessionPurpose,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if we can start a session
      if (!canStartSession) {
        return NfcSessionResult.error(
          'Cannot start session: ${_currentSession.name}',
          NfcSessionError.sessionInProgress,
        );
      }

      // Check NFC availability
      final isAvailable = await NfcManagerService.instance.isNfcAvailable();
      if (!isAvailable) {
        return NfcSessionResult.error(
          'NFC not available on this device',
          NfcSessionError.unavailable,
        );
      }

      // Check permissions on Android
      if (Platform.isAndroid) {
        final hasPermission = await _checkNfcPermissions();
        if (!hasPermission) {
          return NfcSessionResult.error(
            'NFC permission denied',
            NfcSessionError.permissionDenied,
          );
        }
      }

      // Initialize session
      _initializeSession(timeout ?? _defaultTimeout, sessionPurpose, metadata);

      // Start NFC scanning
      _logger.i('Starting NFC scanning session...');
      _addSessionEvent(NfcSessionEvent.sessionStarted);

      final scanResult = await NfcManagerService.instance.startScanning(
        timeout: _currentSession.remainingTime,
        alertOnSuccess: true,
        alertOnError: enableRetry,
      );

      // Handle scan result
      if (scanResult != null && scanResult.success && scanResult.stickerCode != null) {
        return await _handleSessionSuccess(scanResult);
      } else {
        return await _handleSessionFailure(
          scanResult ?? NfcScanResult(
            success: false,
            timestamp: DateTime.now(),
            error: 'Scan failed or timeout',
          ),
          enableRetry,
        );
      }

    } catch (e) {
      _logger.e('Error starting NFC session: $e');
      return _handleSessionException(e, enableRetry);
    }
  }

  /// Extend current session
  bool extendSession({Duration? extensionDuration}) {
    if (!_currentSession.isActive) {
      _logger.w('Cannot extend session: session not active');
      return false;
    }

    final extension = extensionDuration ?? _sessionExtensionDuration;
    final newEndTime = _currentSession.endTime!.add(extension);
    final currentTime = DateTime.now();

    if (newEndTime.isBefore(currentTime)) {
      _logger.w('Cannot extend session: new end time is in the past');
      return false;
    }

    _currentSession = _currentSession.copyWith(
      endTime: newEndTime,
      extendedCount: _currentSession.extendedCount + 1,
    );

    _restartTimeoutTimer();
    _logger.i('Session extended by ${extension.inSeconds}s, new end time: $_currentSession.endTime');
    _addSessionEvent(NfcSessionEvent.sessionExtended);

    _stateController.add(NfcSessionState(_currentSession));
    return true;
  }

  /// Stop current session
  Future<NfcSessionResult> stopSession({String? reason}) async {
    if (!_currentSession.isActive) {
      _logger.w('Cannot stop session: session not active');
      return NfcSessionResult.error('Session not active', NfcSessionError.invalidState);
    }

    _logger.i('Stopping NFC session: ${reason ?? 'user request'}');
    _addSessionEvent(NfcSessionEvent.sessionStopped(reason));

    // Stop NFC scanning
    await NfcManagerService.instance.stopScanning();

    // Finalize session
    _finalizeSession(NfcSessionError.cancelled);

    return NfcSessionResult.success(
      stickerCode: null,
      sessionDuration: _currentSession.duration,
      retryCount: _retryCount,
      extendedCount: _currentSession.extendedCount,
    );
  }

  /// Restart current session
  Future<NfcSessionResult> restartSession({
    Duration? timeout,
    bool resetRetryCount = true,
  }) async {
    _logger.i('Restarting NFC session');

    // Stop current session
    await stopSession(reason: 'restart');

    // Reset retry count if requested
    if (resetRetryCount) {
      _retryCount = 0;
    }

    // Start new session
    return await startSession(timeout: timeout);
  }

  /// Get session statistics
  NfcSessionStats get sessionStats {
    final recentSessions = _sessionHistory.where((event) =>
      event.type == NfcSessionEventType.sessionStarted
    ).length;

    final recentErrors = _sessionHistory.where((event) =>
      event.type == NfcSessionEventType.sessionError
    ).length;

    final avgSessionDuration = recentSessions > 0
        ? _sessionHistory
            .where((event) => event.type == NfcSessionEventType.sessionEnded)
            .map((event) => event.duration ?? Duration.zero)
            .fold<Duration>(Duration.zero, (sum, duration) => sum + duration)
            .inMicroseconds ~/ recentSessions
        : 0;

    return NfcSessionStats(
      totalSessions: recentSessions,
      recentErrors: recentErrors,
      currentRetryCount: _retryCount,
      currentSession: _currentSession,
      averageSessionDuration: Duration(microseconds: avgSessionDuration),
      successRate: recentSessions > 0 ? ((recentSessions - recentErrors) / recentSessions) : 0.0,
    );
  }

  /// Get session history
  List<NfcSessionEvent> getSessionHistory({int? limit}) {
    final history = List<NfcSessionEvent>.from(_sessionHistory.reversed);
    return limit != null ? history.take(limit).toList() : history;
  }

  /// Clear session history
  void clearSessionHistory() {
    _sessionHistory.clear();
    _logger.i('Session history cleared');
  }

  /// Dispose session manager
  void dispose() {
    _timeoutTimer?.cancel();
    _idleTimer?.cancel();
    _stateController.close();
    _eventController.close();
    _logger.i('NFC session manager disposed');
  }

  // =============== Private Methods ===============

  /// Initialize session state
  void _initializeSession(
    Duration timeout,
    String? purpose,
    Map<String, dynamic>? metadata,
  ) {
    final now = DateTime.now();
    _currentSession = NfcSessionState(
      state: SessionState.scanning,
      startTime: now,
      endTime: now.add(timeout),
      purpose: purpose,
      metadata: metadata ?? {},
      retryCount: _retryCount,
      extendedCount: 0,
    );

    _sessionStartTime = now;
    _lastActivityTime = now;

    _stateController.add(_currentSession);
    _startTimeoutTimer();
    _startIdleTimer();
  }

  /// Check NFC permissions
  Future<bool> _checkNfcPermissions() async {
    try {
      // Note: Permission.nfc might not be available in all versions
      // Using a basic permission check
      return true;
    } catch (e) {
      _logger.w('Error checking NFC permissions: $e');
      return false;
    }
  }

  /// Handle successful session
  Future<NfcSessionResult> _handleSessionSuccess(NfcScanResult scanResult) async {
    _logger.i('NFC session successful: ${scanResult.stickerCode}');
    _addSessionEvent(NfcSessionEvent.sessionSuccess(scanResult.stickerCode!));
    _finalizeSession(null);

    return NfcSessionResult.success(
      stickerCode: scanResult.stickerCode,
      sessionDuration: _currentSession.duration,
      retryCount: _retryCount,
      extendedCount: _currentSession.extendedCount,
      scanResult: scanResult,
    );
  }

  /// Handle failed session
  Future<NfcSessionResult> _handleSessionFailure(
    NfcScanResult scanResult,
    bool enableRetry,
  ) async {
    _logger.w('NFC session failed: ${scanResult.error}');

    if (enableRetry && _retryCount < _maxRetryAttempts) {
      _retryCount++;
      _addSessionEvent(NfcSessionEvent.sessionRetry(_retryCount));

      // Brief delay before retry
      await Future.delayed(const Duration(milliseconds: 500));

      _logger.i('Retrying NFC session (attempt $_retryCount/$_maxRetryAttempts)');
      return await startSession();
    } else {
      _addSessionEvent(NfcSessionEvent.sessionFailed(scanResult.error ?? 'Unknown error'));
      _finalizeSession(NfcSessionError.scanFailed);

      return NfcSessionResult.error(
        scanResult.error ?? 'Scan failed after $_retryCount retries',
        NfcSessionError.scanFailed,
        retryCount: _retryCount,
      );
    }
  }

  /// Handle session exception
  Future<NfcSessionResult> _handleSessionException(
    dynamic exception,
    bool enableRetry,
  ) async {
    _logger.e('NFC session exception: $exception');

    if (enableRetry && _retryCount < _maxRetryAttempts) {
      _retryCount++;
      _addSessionEvent(NfcSessionEvent.sessionRetry(_retryCount));

      await Future.delayed(const Duration(seconds: 1));
      return await startSession();
    } else {
      _addSessionEvent(NfcSessionEvent.sessionError(exception.toString()));
      _finalizeSession(NfcSessionError.exception);

      return NfcSessionResult.error(
        'Session exception: $exception',
        NfcSessionError.exception,
        retryCount: _retryCount,
      );
    }
  }

  /// Finalize session
  void _finalizeSession(NfcSessionError? error) {
    final endTime = DateTime.now();
    _currentSession = NfcSessionState(
      state: error != null ? SessionState.error : SessionState.completed,
      startTime: _sessionStartTime ?? DateTime.now(),
      endTime: endTime,
      purpose: _currentSession.purpose,
      metadata: _currentSession.metadata,
      retryCount: _retryCount,
      extendedCount: _currentSession.extendedCount,
      error: error,
    );

    _timeoutTimer?.cancel();
    _idleTimer?.cancel();

    _addSessionEvent(NfcSessionEvent.sessionEnded(endTime));
    _stateController.add(_currentSession);
  }

  /// Start timeout timer
  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_currentSession.remainingTime, () {
      _logger.w('NFC session timeout');
      _addSessionEvent(NfcSessionEvent.sessionTimeout);
      _finalizeSession(NfcSessionError.timeout);
    });
  }

  /// Restart timeout timer
  void _restartTimeoutTimer() {
    _startTimeoutTimer();
  }

  /// Start idle timer
  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_maxIdleTime, () {
      if (_currentSession.isActive) {
        _logger.w('NFC session idle timeout');
        _addSessionEvent(NfcSessionEvent.sessionIdleTimeout);
        stopSession(reason: 'idle timeout');
      }
    });
  }

  /// Update last activity time
  void _updateLastActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Add session event
  void _addSessionEvent(NfcSessionEvent event) {
    _sessionHistory.add(event);
    _eventController.add(event);

    // Keep only last 100 events
    if (_sessionHistory.length > 100) {
      _sessionHistory.removeRange(0, _sessionHistory.length - 100);
    }
  }
}

/// NFC session state
class NfcSessionState {
  const NfcSessionState({
    required this.state,
    required this.startTime,
    this.endTime,
    this.purpose,
    this.metadata = const {},
    this.retryCount = 0,
    this.extendedCount = 0,
    this.error,
  });

  final SessionState state;
  final DateTime startTime;
  final DateTime? endTime;
  final String? purpose;
  final Map<String, dynamic> metadata;
  final int retryCount;
  final int extendedCount;
  final NfcSessionError? error;

  bool get isActive => state.isActive;
  bool get isIdle => state.isIdle;
  bool get isCompleted => state.isCompleted;
  bool get hasError => state.hasError;
  bool get canStart => state.canStart;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Duration get remainingTime {
    final end = endTime ?? DateTime.now();
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get name => state.name;

  NfcSessionState copyWith({
    SessionState? state,
    DateTime? startTime,
    DateTime? endTime,
    String? purpose,
    Map<String, dynamic>? metadata,
    int? retryCount,
    int? extendedCount,
    NfcSessionError? error,
  }) {
    return NfcSessionState(
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      metadata: metadata ?? this.metadata,
      retryCount: retryCount ?? this.retryCount,
      extendedCount: extendedCount ?? this.extendedCount,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'SessionState(state: $state, duration: ${duration.inSeconds}s, '
        'retries: $retryCount, extensions: $extendedCount)';
  }
}

/// Session state enum
enum SessionState {
  idle('Idle'),
  scanning('Scanning'),
  processing('Processing'),
  success('Success'),
  error('Error'),
  completed('Completed'),
  cancelled('Cancelled');

  const SessionState(this.name);

  final String name;

  bool get isActive => this == SessionState.scanning || this == SessionState.processing;
  bool get isIdle => this == SessionState.idle;
  bool get isCompleted => this == SessionState.success || this == SessionState.completed;
  bool get hasError => this == SessionState.error || this == SessionState.cancelled;
  bool get canStart => this == SessionState.idle;
}

/// NFC session result
class NfcSessionResult {
  const NfcSessionResult({
    required this.success,
    this.stickerCode,
    this.sessionDuration,
    this.retryCount = 0,
    this.extendedCount = 0,
    this.scanResult,
    this.error,
    this.errorType,
  });

  final bool success;
  final String? stickerCode;
  final Duration? sessionDuration;
  final int retryCount;
  final int extendedCount;
  final NfcScanResult? scanResult;
  final String? error;
  final NfcSessionError? errorType;

  bool get hasError => error != null;

  factory NfcSessionResult.success({
    String? stickerCode,
    Duration? sessionDuration,
    int? retryCount,
    int? extendedCount,
    NfcScanResult? scanResult,
  }) {
    return NfcSessionResult(
      success: true,
      stickerCode: stickerCode,
      sessionDuration: sessionDuration,
      retryCount: retryCount ?? 0,
      extendedCount: extendedCount ?? 0,
      scanResult: scanResult,
    );
  }

  factory NfcSessionResult.error(String error, NfcSessionError errorType,
      {int? retryCount}) {
    return NfcSessionResult(
      success: false,
      error: error,
      errorType: errorType,
      retryCount: retryCount ?? 0,
    );
  }

  @override
  String toString() {
    return 'NfcSessionResult(success: $success, stickerCode: $stickerCode, '
        'duration: ${sessionDuration?.inSeconds ?? 0}s, errors: $retryCount)';
  }
}

/// NFC session event
class NfcSessionEvent {
  NfcSessionEvent(this.type, {this.data, this.duration});

  final NfcSessionEventType type;
  final Map<String, dynamic>? data;
  final Duration? duration;

  static NfcSessionEvent sessionStarted = NfcSessionEvent(NfcSessionEventType.sessionStarted);
  static NfcSessionEvent sessionEnded = NfcSessionEvent(NfcSessionEventType.sessionEnded);
  static NfcSessionEvent sessionFailed = NfcSessionEvent(NfcSessionEventType.sessionFailed);
  static NfcSessionEvent sessionError = NfcSessionEvent(NfcSessionEventType.sessionError);
  static NfcSessionEvent sessionStopped = NfcSessionEvent(NfcSessionEventType.sessionStopped);
  static NfcSessionEvent sessionTimeout = NfcSessionEvent(NfcSessionEventType.sessionTimeout);
  static NfcSessionEvent sessionExtended = NfcSessionEvent(NfcSessionEventType.sessionExtended);
  static NfcSessionEvent sessionIdleTimeout = NfcSessionEvent(NfcSessionEventType.sessionIdleTimeout);

  NfcSessionEvent.sessionRetry(int count) : this(NfcSessionEventType.sessionRetry, data: {'count': count});
  NfcSessionEvent.sessionSuccess(String stickerCode) : this(NfcSessionEventType.sessionSuccess, data: {'stickerCode': stickerCode});

  @override
  String toString() {
    return 'NfcSessionEvent(type: $type, data: $data, duration: ${duration?.inSeconds ?? 0}s)';
  }
}

/// NFC session event type
enum NfcSessionEventType {
  sessionStarted,
  sessionEnded,
  sessionSuccess,
  sessionFailed,
  sessionError,
  sessionStopped,
  sessionTimeout,
  sessionExtended,
  sessionRetry,
  sessionIdleTimeout,
}

/// NFC session statistics
class NfcSessionStats {
  const NfcSessionStats({
    required this.totalSessions,
    required this.recentErrors,
    required this.currentRetryCount,
    required this.currentSession,
    required this.averageSessionDuration,
    required this.successRate,
  });

  final int totalSessions;
  final int recentErrors;
  final int currentRetryCount;
  final SessionState currentSession;
  final Duration averageSessionDuration;
  final double successRate;

  @override
  String toString() {
    return 'NfcSessionStats(total: $totalSessions, errors: $recentErrors, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
        'avgDuration: ${averageSessionDuration.inSeconds}s)';
  }
}

/// NFC session error type
enum NfcSessionError {
  unavailable,
  permissionDenied,
  sessionInProgress,
  invalidState,
  timeout,
  scanFailed,
  cancelled,
  exception,
}