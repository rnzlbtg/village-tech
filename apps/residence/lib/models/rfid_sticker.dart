/// RFID sticker model
/// Represents a physical RFID sticker assigned to a vehicle
class RfidSticker {
  final String id;
  final String tenantId;
  final String householdId;
  final String stickerCode;
  final String vehiclePlate;
  final String ownerType; // 'household_member' or 'beneficial_user'
  final String ownerId;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String status; // 'active', 'expired', 'lost', 'deactivated'
  final DateTime createdAt;
  final DateTime updatedAt;

  RfidSticker({
    required this.id,
    required this.tenantId,
    required this.householdId,
    required this.stickerCode,
    required this.vehiclePlate,
    required this.ownerType,
    required this.ownerId,
    required this.issueDate,
    this.expiryDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory RfidSticker.fromJson(Map<String, dynamic> json) {
    return RfidSticker(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      householdId: json['household_id'] as String,
      stickerCode: json['sticker_code'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      ownerType: json['owner_type'] as String,
      ownerId: json['owner_id'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'household_id': householdId,
      'sticker_code': stickerCode,
      'vehicle_plate': vehiclePlate,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get status display name
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'lost':
        return 'Lost/Reported';
      case 'deactivated':
        return 'Deactivated';
      default:
        return status;
    }
  }

  /// Check if sticker is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if sticker is expired
  bool get isExpired => status.toLowerCase() == 'expired';

  /// Check if sticker is lost
  bool get isLost => status.toLowerCase() == 'lost';

  /// Check if sticker is deactivated
  bool get isDeactivated => status.toLowerCase() == 'deactivated';

  /// Get days until expiry (null if no expiry date)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }

  /// Check if sticker is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days <= 30 && days > 0;
  }

  @override
  String toString() {
    return 'RfidSticker(code: $stickerCode, plate: $vehiclePlate, status: $status)';
  }
}

/// RFID sticker status types
class RfidStickerStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String lost = 'lost';
  static const String deactivated = 'deactivated';

  static const List<String> all = [
    active,
    expired,
    lost,
    deactivated,
  ];
}
