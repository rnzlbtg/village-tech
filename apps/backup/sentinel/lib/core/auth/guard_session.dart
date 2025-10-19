import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'guard_session.g.dart';

/// Guard profile model with tenant isolation
/// Represents a security guard's session and authorization context
@JsonSerializable()
class GuardProfile extends Equatable {
  const GuardProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.tenantId,
    required this.role,
    this.assignedGate,
    this.phoneNumber,
    this.badgeNumber,
    this.isActive = true,
    this.permissions = const [],
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Guard's unique identifier
  final String id;

  /// Guard's email address
  final String email;

  /// Guard's full name
  final String name;

  /// Tenant/Community ID for multi-tenant isolation
  final String tenantId;

  /// Guard's role (guard, admin, etc.)
  final String role;

  /// Assigned gate or post
  final String? assignedGate;

  /// Guard's phone number
  final String? phoneNumber;

  /// Badge number for identification
  final String? badgeNumber;

  /// Whether the guard is currently active
  final bool isActive;

  /// Guard's permissions
  final List<String> permissions;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Account creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Create copy with updated values
  GuardProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? tenantId,
    String? role,
    String? assignedGate,
    String? phoneNumber,
    String? badgeNumber,
    bool? isActive,
    List<String>? permissions,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuardProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      assignedGate: assignedGate ?? this.assignedGate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$GuardProfileToJson(this);

  /// Create from JSON
  factory GuardProfile.fromJson(Map<String, dynamic> json) =>
      _$GuardProfileFromJson(json);

  /// Create from Supabase User
  factory GuardProfile.fromSupabaseUser(User user, String tenantId) {
    return GuardProfile(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? '',
      tenantId: tenantId,
      role: user.appMetadata?['role'] ?? 'guard',
      assignedGate: user.userMetadata?['assigned_gate'],
      phoneNumber: user.userMetadata?['phone_number'],
      badgeNumber: user.userMetadata?['badge_number'],
      isActive: user.userMetadata?['is_active'] ?? true,
      permissions: List<String>.from(user.userMetadata?['permissions'] ?? []),
      lastLoginAt: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
      createdAt: user.createdAt != null
          ? DateTime.tryParse(user.createdAt!)
          : null,
      updatedAt: user.updatedAt != null
          ? DateTime.tryParse(user.updatedAt!)
          : null,
    );
  }

  /// Check if guard has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'admin';
  }

  /// Check if guard can access specific tenant
  bool canAccessTenant(String tenantId) {
    return this.tenantId == tenantId || role == 'admin';
  }

  /// Check if guard is assigned to specific gate
  bool isAssignedToGate(String gate) {
    return assignedGate == gate || role == 'admin';
  }

  /// Get display name
  String get displayName => name.isNotEmpty ? name : email.split('@')[0];

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        tenantId,
        role,
        assignedGate,
        phoneNumber,
        badgeNumber,
        isActive,
        permissions,
        lastLoginAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'GuardProfile(id: $id, name: $name, tenantId: $tenantId, role: $role)';
  }
}

/// Session context for RLS (Row Level Security)
/// Ensures all database operations are tenant-scoped
class SessionContext extends Equatable {
  const SessionContext({
    required this.guardProfile,
    required this.tenantId,
    this.sessionStart,
    this.lastActivity,
  });

  final GuardProfile guardProfile;
  final String tenantId;
  final DateTime? sessionStart;
  final DateTime? lastActivity;

  /// Create active session context
  factory SessionContext.active(GuardProfile guardProfile) {
    final now = DateTime.now();
    return SessionContext(
      guardProfile: guardProfile,
      tenantId: guardProfile.tenantId,
      sessionStart: now,
      lastActivity: now,
    );
  }

  /// Update last activity timestamp
  SessionContext updateActivity() {
    return SessionContext(
      guardProfile: guardProfile,
      tenantId: tenantId,
      sessionStart: sessionStart,
      lastActivity: DateTime.now(),
    );
  }

  /// Check if session is still valid (within timeout)
  bool isValid({Duration timeout = const Duration(hours: 12)}) {
    if (lastActivity == null) return false;
    return DateTime.now().difference(lastActivity!) < timeout;
  }

  /// Get session duration
  Duration? get sessionDuration {
    if (sessionStart == null) return null;
    return DateTime.now().difference(sessionStart!);
  }

  @override
  List<Object?> get props => [guardProfile, tenantId, sessionStart, lastActivity];

  @override
  String toString() {
    return 'SessionContext(tenantId: $tenantId, guard: ${guardProfile.name})';
  }
}

/// Guard session manager
/// Handles session lifecycle and tenant isolation
class GuardSessionManager {
  GuardSessionManager._();
  static final GuardSessionManager _instance = GuardSessionManager._();
  static GuardSessionManager get instance => _instance;

  SessionContext? _currentSession;

  /// Get current session context
  SessionContext? get currentSession => _currentSession;

  /// Check if session is active
  bool get hasActiveSession => _currentSession?.isValid() ?? false;

  /// Start new guard session
  SessionContext startSession(GuardProfile guardProfile) {
    _currentSession = SessionContext.active(guardProfile);
    return _currentSession!;
  }

  /// End current session
  void endSession() {
    _currentSession = null;
  }

  /// Update session activity
  void updateActivity() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.updateActivity();
    }
  }

  /// Get current tenant ID
  String? get currentTenantId => _currentSession?.tenantId;

  /// Get current guard profile
  GuardProfile? get currentGuard => _currentSession?.guardProfile;

  /// Check if current guard has permission
  bool hasPermission(String permission) {
    return _currentSession?.guardProfile.hasPermission(permission) ?? false;
  }

  /// Check if current guard can access tenant
  bool canAccessTenant(String tenantId) {
    return _currentSession?.guardProfile.canAccessTenant(tenantId) ?? false;
  }

  /// Get RLS context for database queries
  Map<String, dynamic> get rlsContext {
    if (_currentSession == null) return {};

    return {
      'tenant_id': _currentSession!.tenantId,
      'guard_id': _currentSession!.guardProfile.id,
      'guard_role': _currentSession!.guardProfile.role,
    };
  }

  /// Validate session before critical operations
  bool validateSession() {
    if (_currentSession == null) return false;
    if (!_currentSession!.isValid()) {
      endSession();
      return false;
    }
    updateActivity();
    return true;
  }

  /// Clear all session data
  void clear() {
    _currentSession = null;
  }
}

/// Available permissions for guards
class GuardPermissions {
  static const String rfidVerification = 'rfid_verification';
  static const String guestManagement = 'guest_management';
  static const String deliveryTracking = 'delivery_tracking';
  static const String constructionPermits = 'construction_permits';
  static const String incidentReporting = 'incident_reporting';
  static const String villageRules = 'village_rules';
  static const String announcements = 'announcements';
  static const String emergencyResponse = 'emergency_response';
  static const String systemAdministration = 'system_administration';

  static const List<String> allPermissions = [
    rfidVerification,
    guestManagement,
    deliveryTracking,
    constructionPermits,
    incidentReporting,
    villageRules,
    announcements,
    emergencyResponse,
    systemAdministration,
  ];

  /// Get permissions by role
  static List<String> getPermissionsForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return allPermissions;
      case 'guard':
        return [
          rfidVerification,
          guestManagement,
          deliveryTracking,
          constructionPermits,
          incidentReporting,
          villageRules,
          announcements,
          emergencyResponse,
        ];
      default:
        return [
          rfidVerification,
          guestManagement,
          deliveryTracking,
        ];
    }
  }
}