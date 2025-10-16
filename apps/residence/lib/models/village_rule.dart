/// Village rule model
class VillageRule {
  final String id;
  final String tenantId;
  final String ruleCategory;
  final String title;
  final String description;
  final DateTime? curfewStartTime;
  final DateTime? curfewEndTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VillageRule({
    required this.id,
    required this.tenantId,
    required this.ruleCategory,
    required this.title,
    required this.description,
    this.curfewStartTime,
    this.curfewEndTime,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory VillageRule.fromJson(Map<String, dynamic> json) {
    return VillageRule(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      ruleCategory: json['rule_category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      curfewStartTime: json['curfew_start_time'] != null
          ? DateTime.parse(json['curfew_start_time'] as String)
          : null,
      curfewEndTime: json['curfew_end_time'] != null
          ? DateTime.parse(json['curfew_end_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'rule_category': ruleCategory,
      'title': title,
      'description': description,
      'curfew_start_time': curfewStartTime?.toIso8601String(),
      'curfew_end_time': curfewEndTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  VillageRule copyWith({
    String? id,
    String? tenantId,
    String? ruleCategory,
    String? title,
    String? description,
    DateTime? curfewStartTime,
    DateTime? curfewEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VillageRule(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      ruleCategory: ruleCategory ?? this.ruleCategory,
      title: title ?? this.title,
      description: description ?? this.description,
      curfewStartTime: curfewStartTime ?? this.curfewStartTime,
      curfewEndTime: curfewEndTime ?? this.curfewEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Rule category display name
  String get ruleCategoryDisplay {
    switch (ruleCategory.toLowerCase()) {
      case 'general':
        return 'General';
      case 'parking':
        return 'Parking';
      case 'noise':
        return 'Noise';
      case 'construction':
        return 'Construction';
      case 'curfew':
        return 'Curfew';
      default:
        return ruleCategory;
    }
  }

  /// Check if rule is general
  bool get isGeneral => ruleCategory.toLowerCase() == 'general';

  /// Check if rule is parking
  bool get isParking => ruleCategory.toLowerCase() == 'parking';

  /// Check if rule is noise
  bool get isNoise => ruleCategory.toLowerCase() == 'noise';

  /// Check if rule is construction
  bool get isConstruction => ruleCategory.toLowerCase() == 'construction';

  /// Check if rule is curfew
  bool get isCurfew => ruleCategory.toLowerCase() == 'curfew';

  /// Check if has curfew times
  bool get hasCurfewTimes =>
      curfewStartTime != null && curfewEndTime != null;

  /// Get curfew time display
  String? get curfewTimeDisplay {
    if (!hasCurfewTimes) return null;
    return '${_formatTime(curfewStartTime!)} - ${_formatTime(curfewEndTime!)}';
  }

  /// Format time
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Village rule category constants
class RuleCategory {
  static const String general = 'general';
  static const String parking = 'parking';
  static const String noise = 'noise';
  static const String construction = 'construction';
  static const String curfew = 'curfew';

  static const List<String> all = [
    general,
    parking,
    noise,
    construction,
    curfew,
  ];

  static const Map<String, String> displayNames = {
    general: 'General',
    parking: 'Parking',
    noise: 'Noise',
    construction: 'Construction',
    curfew: 'Curfew',
  };
}
