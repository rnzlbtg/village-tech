import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'guard.g.dart';

/// Guard model for gate security personnel with authentication and roles
@JsonSerializable()
class Guard {
  final String id;
  final String tenantId;
  final String email;
  final String fullName;
  final GuardRole role;
  final String? phone;
  final String? employeeId;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Guard({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.employeeId,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new guard with generated ID and timestamps
  factory Guard.create({
    required String tenantId,
    required String email,
    required String fullName,
    required GuardRole role,
    String? phone,
    String? employeeId,
  }) {
    final now = DateTime.now();
    return Guard(
      id: const Uuid().v4(),
      tenantId: tenantId,
      email: email,
      fullName: fullName,
      role: role,
      phone: phone,
      employeeId: employeeId,
      isActive: true,
      lastLoginAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create guard from JSON
  factory Guard.fromJson(Map<String, dynamic> json) => _$GuardFromJson(json);

  /// Convert guard to JSON
  Map<String, dynamic> toJson() => _$GuardToJson(this);

  /// Create a copy with updated fields
  Guard copyWith({
    String? id,
    String? tenantId,
    String? email,
    String? fullName,
    GuardRole? role,
    String? phone,
    String? employeeId,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guard(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Update last login time
  Guard updateLastLogin() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Deactivate guard (employment termination)
  Guard deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Activate guard (employment start/reactivation)
  Guard activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if guard has administrative privileges
  bool get hasAdminPrivileges => role == GuardRole.headGuard;

  /// Check if guard can perform basic operations
  bool get canPerformBasicOperations => role.index <= GuardRole.guardOfficer.index;

  /// Check if guard needs supervision
  bool get needsSupervision => role == GuardRole.guardTrainee;

  /// Validate guard data
  bool isValid() {
    return _validateEmail(email) &&
        _validateName(fullName) &&
        _validatePhone(phone) &&
        _validateEmployeeId(employeeId);
  }

  bool _validateEmail(String email) {
    return email.isNotEmpty && email.contains('@') && email.contains('.');
  }

  bool _validateName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 100;
  }

  bool _validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return true; // Phone is optional
    // Basic phone validation - can be enhanced with regex
    return phone.length >= 10 && phone.length <= 20;
  }

  bool _validateEmployeeId(String? employeeId) {
    if (employeeId == null || employeeId.isEmpty) return false; // Required
    return employeeId.trim().length >= 2 && employeeId.trim().length <= 50;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Guard(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }
}

/// Guard role enumeration
enum GuardRole {
  @JsonValue('head_guard')
  headGuard('Head Guard', 'Full administrative access'),
  @JsonValue('guard_officer')
  guardOfficer('Guard Officer', 'Limited operational access'),
  @JsonValue('guard_trainee')
  guardTrainee('Guard Trainee', 'Supervised access only');

  const GuardRole(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get role from string value
  static GuardRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'head_guard':
        return GuardRole.headGuard;
      case 'guard_officer':
        return GuardRole.guardOfficer;
      case 'guard_trainee':
        return GuardRole.guardTrainee;
      default:
        throw ArgumentError('Invalid GuardRole: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case GuardRole.headGuard:
        return 'head_guard';
      case GuardRole.guardOfficer:
        return 'guard_officer';
      case GuardRole.guardTrainee:
        return 'guard_trainee';
    }
  }
}

/// Guard permissions based on role
class GuardPermissions {
  static bool canManageGuests(GuardRole role) {
    return role.index <= GuardRole.guardOfficer.index;
  }

  static bool canManageDeliveries(GuardRole role) {
    return role.index <= GuardRole.guardOfficer.index;
  }

  static bool canManageConstruction(GuardRole role) {
    return role.index <= GuardRole.guardOfficer.index;
  }

  static bool canReportIncidents(GuardRole role) {
    return true; // All guards can report incidents
  }

  static bool canViewRules(GuardRole role) {
    return true; // All guards can view rules
  }

  static bool canManageGuards(GuardRole role) {
    return role == GuardRole.headGuard;
  }

  static bool canViewAnalytics(GuardRole role) {
    return role == GuardRole.headGuard;
  }

  static bool canApproveHighRiskEntries(GuardRole role) {
    return role == GuardRole.headGuard;
  }
}

/// Guard validation errors
enum GuardValidationError {
  emailInvalid,
  nameInvalid,
  phoneInvalid,
  employeeIdInvalid,
  roleInvalid,
  tenantIdInvalid,
}

/// Guard validation result
class GuardValidationResult {
  final bool isValid;
  final List<GuardValidationError> errors;

  const GuardValidationResult(this.isValid, this.errors);

  factory GuardValidationResult.success() {
    return const GuardValidationResult(true, []);
  }

  factory GuardValidationResult.failure(List<GuardValidationError> errors) {
    return GuardValidationResult(false, errors);
  }
}