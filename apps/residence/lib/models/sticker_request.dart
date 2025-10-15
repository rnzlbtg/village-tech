/// Sticker request model
/// Represents a vehicle sticker request from household head
class StickerRequest {
  final String id;
  final String householdId;
  final String requestedBy;
  final String ownerType; // 'household_member' or 'beneficial_user'
  final String ownerId;
  final String vehiclePlate;
  final String? vehicleMake;
  final String? vehicleColor;
  final String status; // 'pending', 'approved', 'distributed', 'rejected'
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? distributedAt;
  final String? signature;
  final String? rejectionReason;
  final DateTime createdAt;

  // Optional joined data
  final String? ownerName;

  StickerRequest({
    required this.id,
    required this.householdId,
    required this.requestedBy,
    required this.ownerType,
    required this.ownerId,
    required this.vehiclePlate,
    this.vehicleMake,
    this.vehicleColor,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.approvedBy,
    this.distributedAt,
    this.signature,
    this.rejectionReason,
    required this.createdAt,
    this.ownerName,
  });

  /// Create from JSON
  factory StickerRequest.fromJson(Map<String, dynamic> json) {
    return StickerRequest(
      id: json['id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      requestedBy: json['household_id']?.toString() ?? '', // Use household_id as requested_by since we don't have separate field
      ownerType: 'household_member', // Default since we don't have owner_type field
      ownerId: json['household_id']?.toString() ?? '', // Use household_id as owner_id since we don't have separate field
      vehiclePlate: json['vehicle_plate_number'] as String? ?? json['vehicle_plate'] as String? ?? '',
      vehicleMake: json['vehicle_make'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      status: json['request_status'] as String? ?? json['status'] as String? ?? 'pending',
      requestedAt: DateTime.parse(json['requested_at'] as String),
      approvedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      approvedBy: json['reviewed_by']?.toString(),
      distributedAt: json['distributed_at'] != null
          ? DateTime.parse(json['distributed_at'] as String)
          : null,
      signature: json['recipient_signature_url'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerName: json['owner_name'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'requested_by': requestedBy,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'vehicle_plate': vehiclePlate,
      'vehicle_make': vehicleMake,
      'vehicle_color': vehicleColor,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'distributed_at': distributedAt?.toIso8601String(),
      'signature': signature,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      if (ownerName != null) 'owner_name': ownerName,
    };
  }

  /// Copy with method
  StickerRequest copyWith({
    String? id,
    String? householdId,
    String? requestedBy,
    String? ownerType,
    String? ownerId,
    String? vehiclePlate,
    String? vehicleMake,
    String? vehicleColor,
    String? status,
    DateTime? requestedAt,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? distributedAt,
    String? signature,
    String? rejectionReason,
    DateTime? createdAt,
    String? ownerName,
  }) {
    return StickerRequest(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      requestedBy: requestedBy ?? this.requestedBy,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      distributedAt: distributedAt ?? this.distributedAt,
      signature: signature ?? this.signature,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  /// Get status display name
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved - Ready for Pickup';
      case 'distributed':
        return 'Distributed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Check if request is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if request is approved
  bool get isApproved => status.toLowerCase() == 'approved';

  /// Check if request is distributed
  bool get isDistributed => status.toLowerCase() == 'distributed';

  /// Check if request is rejected
  bool get isRejected => status.toLowerCase() == 'rejected';

  @override
  String toString() {
    return 'StickerRequest(id: $id, vehiclePlate: $vehiclePlate, status: $status)';
  }
}

/// Sticker request status types
class StickerRequestStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String distributed = 'distributed';
  static const String rejected = 'rejected';

  static const List<String> all = [
    pending,
    approved,
    distributed,
    rejected,
  ];
}

/// Owner types for sticker requests
class OwnerType {
  static const String householdMember = 'household_member';
  static const String beneficialUser = 'beneficial_user';

  static const List<String> all = [
    householdMember,
    beneficialUser,
  ];

  static const Map<String, String> displayNames = {
    householdMember: 'Household Member',
    beneficialUser: 'Beneficial User',
  };
}
