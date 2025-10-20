import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'guard_session.g.dart';

/// Guard Session model for authentication session management
@JsonSerializable()
class GuardSession {
  final String id;
  final String guardId;
  final String tenantId;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final String? deviceInfo;
  final String? ipAddress;
  final String? userAgent;
  final bool isActive;
  final String? sessionTokenHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GuardSession({
    required this.id,
    required this.guardId,
    required this.tenantId,
    required this.loginTime,
    this.logoutTime,
    this.deviceInfo,
    this.ipAddress,
    this.userAgent,
    required this.isActive,
    this.sessionTokenHash,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new guard session with generated ID and timestamps
  factory GuardSession.create({
    required String guardId,
    required String tenantId,
    String? deviceInfo,
    String? ipAddress,
    String? userAgent,
    String? sessionTokenHash,
  }) {
    final now = DateTime.now();
    return GuardSession(
      id: const Uuid().v4(),
      guardId: guardId,
      tenantId: tenantId,
      loginTime: now,
      logoutTime: null,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      userAgent: userAgent,
      isActive: true,
      sessionTokenHash: sessionTokenHash,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create guard session from JSON
  factory GuardSession.fromJson(Map<String, dynamic> json) => _$GuardSessionFromJson(json);

  /// Convert guard session to JSON
  Map<String, dynamic> toJson() => _$GuardSessionToJson(this);

  /// Create a copy with updated fields
  GuardSession copyWith({
    String? id,
    String? guardId,
    String? tenantId,
    DateTime? loginTime,
    DateTime? logoutTime,
    String? deviceInfo,
    String? ipAddress,
    String? userAgent,
    bool? isActive,
    String? sessionTokenHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuardSession(
      id: id ?? this.id,
      guardId: guardId ?? this.guardId,
      tenantId: tenantId ?? this.tenantId,
      loginTime: loginTime ?? this.loginTime,
      logoutTime: logoutTime ?? this.logoutTime,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      isActive: isActive ?? this.isActive,
      sessionTokenHash: sessionTokenHash ?? this.sessionTokenHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// End the current session
  GuardSession endSession({String? reason}) {
    final now = DateTime.now();
    return copyWith(
      logoutTime: now,
      isActive: false,
      updatedAt: now,
    );
  }

  /// Reactivate session (use with caution)
  GuardSession reactivateSession() {
    return copyWith(
      isActive: true,
      logoutTime: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Update session token hash
  GuardSession updateSessionToken(String newTokenHash) {
    return copyWith(
      sessionTokenHash: newTokenHash,
      updatedAt: DateTime.now(),
    );
  }

  /// Get session duration
  Duration? get duration {
    if (logoutTime == null) return null;
    return logoutTime!.difference(loginTime);
  }

  /// Get formatted session duration
  String get formattedDuration {
    if (duration == null) return 'Active';

    final dur = duration!;
    if (dur.inDays > 0) {
      return '${dur.inDays}d ${dur.inHours.remainder(24)}h';
    } else if (dur.inHours > 0) {
      return '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
    } else if (dur.inMinutes > 0) {
      return '${dur.inMinutes}m ${dur.inSeconds.remainder(60)}s';
    } else {
      return '${dur.inSeconds}s';
    }
  }

  /// Check if session is expired
  bool get isExpired {
    if (!isActive) return true;
    const maxSessionDuration = Duration(hours: 12); // Max 12 hours
    return DateTime.now().difference(loginTime) > maxSessionDuration;
  }

  /// Check if session is expiring soon (within 1 hour)
  bool get isExpiringSoon {
    if (!isActive) return false;
    const oneHour = Duration(hours: 1);
    const maxSessionDuration = Duration(hours: 12);
    final remainingTime = maxSessionDuration - DateTime.now().difference(loginTime);
    return remainingTime <= oneHour && remainingTime > Duration.zero;
  }

  /// Get session status display text
  String get statusDisplayText {
    if (!isActive) return 'Ended';
    if (isExpired) return 'Expired';
    if (isExpiringSoon) return 'Expiring Soon';
    return 'Active';
  }

  /// Get device type from user agent
  String get deviceType {
    if (userAgent == null) return 'Unknown';

    final ua = userAgent!.toLowerCase();
    if (ua.contains('android')) return 'Android';
    if (ua.contains('ios') || ua.contains('iphone') || ua.contains('ipad')) return 'iOS';
    if (ua.contains('windows')) return 'Windows';
    if (ua.contains('mac')) return 'macOS';
    if (ua.contains('linux')) return 'Linux';

    return 'Unknown';
  }

  /// Check if session is from mobile device
  bool get isMobileDevice {
    final device = deviceType.toLowerCase();
    return device.contains('android') || device.contains('ios');
  }

  /// Get IP location info (basic)
  String get ipLocation {
    if (ipAddress == null) return 'Unknown';

    // Basic IP address validation and categorization
    final ip = ipAddress!;
    if (ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.')) {
      return 'Local Network';
    } else if (ip.startsWith('127.')) {
      return 'Localhost';
    } else {
      return 'External';
    }
  }

  /// Validate guard session data
  bool isValidData() {
    return _validateGuardId(guardId) &&
        _validateTenantId(tenantId) &&
        _validateDeviceInfo(deviceInfo) &&
        _validateIpAddress(ipAddress) &&
        _validateUserAgent(userAgent);
  }

  bool _validateGuardId(String id) {
    return id.trim().isNotEmpty;
  }

  bool _validateTenantId(String id) {
    return id.trim().isNotEmpty;
  }

  bool _validateDeviceInfo(String? info) {
    if (info == null || info.trim().isEmpty) return true; // Optional
    return info.trim().length <= 500;
  }

  bool _validateIpAddress(String? ip) {
    if (ip == null || ip.trim().isEmpty) return true; // Optional
    // Basic IP validation - can be enhanced
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  bool _validateUserAgent(String? ua) {
    if (ua == null || ua.trim().isEmpty) return true; // Optional
    return ua.trim().length <= 1000;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuardSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GuardSession(id: $id, guardId: $guardId, isActive: $isActive, loginTime: $loginTime, duration: $formattedDuration)';
  }
}

/// Session validation errors
enum GuardSessionValidationError {
  guardIdInvalid,
  tenantIdInvalid,
  deviceInfoInvalid,
  ipAddressInvalid,
  userAgentInvalid,
  sessionExpired,
  sessionInactive,
}

/// Session validation result
class GuardSessionValidationResult {
  final bool isValid;
  final List<GuardSessionValidationError> errors;
  final String? message;

  const GuardSessionValidationResult(this.isValid, this.errors, [this.message]);

  factory GuardSessionValidationResult.success() {
    return const GuardSessionValidationResult(true, []);
  }

  factory GuardSessionValidationResult.failure(List<GuardSessionValidationError> errors, [String? message]) {
    return GuardSessionValidationResult(false, errors, message);
  }
}

/// Session analytics data
class SessionAnalytics {
  final int totalSessions;
  final int activeSessions;
  final Duration averageSessionDuration;
  final Map<String, int> deviceTypeCounts;
  final Map<String, int> ipLocationCounts;
  final List<GuardSession> recentSessions;

  const SessionAnalytics({
    required this.totalSessions,
    required this.activeSessions,
    required this.averageSessionDuration,
    required this.deviceTypeCounts,
    required this.ipLocationCounts,
    required this.recentSessions,
  });

  /// Get most used device type
  String? get mostUsedDeviceType {
    if (deviceTypeCounts.isEmpty) return null;
    return deviceTypeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most common IP location
  String? get mostCommonIpLocation {
    if (ipLocationCounts.isEmpty) return null;
    return ipLocationCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}