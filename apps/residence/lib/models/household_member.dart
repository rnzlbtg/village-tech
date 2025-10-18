/// Household member model
/// Represents a family member or resident living in the residence
class HouseholdMember {
  final String id;
  final String householdId;
  final String fullName;
  final String relationship; // 'head', 'spouse', 'child', 'parent', 'other'
  final String? contactNumber;
  final String? email;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  HouseholdMember({
    required this.id,
    required this.householdId,
    required this.fullName,
    required this.relationship,
    this.contactNumber,
    this.email,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    // Combine first_name and last_name to create full_name
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final fullName = firstName.isEmpty ? (json['full_name'] as String? ?? '') :
                     lastName.isEmpty ? firstName : '$firstName $lastName';

    return HouseholdMember(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      fullName: fullName,
      relationship: json['relationship'] as String,
      contactNumber: json['phone_number'] as String? ?? json['contact_number'] as String?,
      email: json['email'] as String?,
      birthDate: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : (json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null),
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
      'relationship': relationship,
      'contact_number': contactNumber,
      'email': email,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for updating fields
  HouseholdMember copyWith({
    String? id,
    String? householdId,
    String? fullName,
    String? relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get relationship display name
  String get relationshipDisplay {
    return RelationshipType.displayNames[relationship.toLowerCase()] ?? relationship;
  }

  /// Get age from birth date
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'HouseholdMember(id: $id, fullName: $fullName, relationship: $relationship)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HouseholdMember &&
        other.id == id &&
        other.householdId == householdId &&
        other.fullName == fullName &&
        other.relationship == relationship &&
        other.contactNumber == contactNumber &&
        other.email == email &&
        other.birthDate == birthDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      householdId,
      fullName,
      relationship,
      contactNumber,
      email,
      birthDate,
    );
  }
}

/// Relationship types for household members
class RelationshipType {
  static const String head = 'head';
  static const String spouse = 'spouse';
  static const String child = 'child';
  static const String parent = 'parent';
  static const String sibling = 'sibling';
  static const String relative = 'relative';
  static const String helper = 'helper';
  static const String tenant = 'tenant';

  static const List<String> all = [
    head,
    spouse,
    child,
    parent,
    sibling,
    relative,
    helper,
    tenant,
  ];

  static const Map<String, String> displayNames = {
    head: 'Household Head',
    spouse: 'Spouse',
    child: 'Child',
    parent: 'Parent',
    sibling: 'Sibling',
    relative: 'Relative',
    helper: 'Helper',
    tenant: 'Tenant',
  };
}
