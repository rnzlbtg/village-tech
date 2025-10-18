/// Beneficial user model
/// Represents a non-resident individual with vehicle access privileges
class BeneficialUser {
  final String id;
  final String householdId;
  final String fullName;
  final String contactNumber;
  final String? email;
  final String relationship; // 'helper', 'family', 'friend'
  final String? idPhotoUrl;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  BeneficialUser({
    required this.id,
    required this.householdId,
    required this.fullName,
    required this.contactNumber,
    this.email,
    required this.relationship,
    this.idPhotoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory BeneficialUser.fromJson(Map<String, dynamic> json) {
    return BeneficialUser(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      fullName: json['full_name'] as String,
      contactNumber: json['contact_number'] as String,
      email: json['email'] as String?,
      relationship: json['relationship'] as String,
      idPhotoUrl: json['id_photo_url'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'full_name': fullName,
      'contact_number': contactNumber,
      'email': email,
      'relationship': relationship,
      'id_photo_url': idPhotoUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  BeneficialUser copyWith({
    String? id,
    String? householdId,
    String? fullName,
    String? contactNumber,
    String? email,
    String? relationship,
    String? idPhotoUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeneficialUser(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      fullName: fullName ?? this.fullName,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      idPhotoUrl: idPhotoUrl ?? this.idPhotoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get relationship display name
  String get relationshipDisplay {
    switch (relationship.toLowerCase()) {
      case 'helper':
        return 'Helper';
      case 'family':
        return 'Family';
      case 'friend':
        return 'Friend';
      default:
        return relationship;
    }
  }

  /// Check if user is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if user is inactive
  bool get isInactive => status.toLowerCase() == 'inactive';

  /// Check if user has photo
  bool get hasPhoto => idPhotoUrl != null && idPhotoUrl!.isNotEmpty;

  /// Get initials from full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'N/A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  String toString() {
    return 'BeneficialUser(id: $id, fullName: $fullName, relationship: $relationship, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BeneficialUser &&
        other.id == id &&
        other.householdId == householdId &&
        other.fullName == fullName &&
        other.contactNumber == contactNumber &&
        other.email == email &&
        other.relationship == relationship &&
        other.idPhotoUrl == idPhotoUrl &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      householdId,
      fullName,
      contactNumber,
      email,
      relationship,
      idPhotoUrl,
      status,
    );
  }
}

/// Relationship types for beneficial users
class BeneficialUserRelationship {
  static const String helper = 'helper';
  static const String family = 'family';
  static const String friend = 'friend';

  static const List<String> all = [
    helper,
    family,
    friend,
  ];

  static const Map<String, String> displayNames = {
    helper: 'Helper',
    family: 'Family',
    friend: 'Friend',
  };
}

/// Status types for beneficial users
class BeneficialUserStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const List<String> all = [
    active,
    inactive,
  ];
}
