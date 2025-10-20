import 'package:equatable/equatable.dart';

/// RFID Sticker Entity
/// Represents a vehicle RFID sticker for resident verification
///
/// This entity mirrors the rfid_stickers table in Supabase with all fields
/// from the data-model specification. It includes tenant isolation and
/// comprehensive vehicle and household information.
class RfidSticker extends Equatable {
  const RfidSticker({
    required this.id,
    required this.tenantId,
    required this.stickerCode,
    required this.householdId,
    required this.vehiclePlate,
    required this.status,
    required this.issuedDate,
    required this.expiryDate,
    this.vehicleMake,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique sticker identifier (UUID)
  final String id;

  /// Reference to tenant (community) for multi-tenant isolation
  final String tenantId;

  /// RFID sticker unique code (scanned from NFC tag)
  final String stickerCode;

  /// Reference to household that owns this sticker
  final String householdId;

  /// Registered vehicle plate number
  final String vehiclePlate;

  /// Vehicle make/model (optional)
  final String? vehicleMake;

  /// Sticker status: 'active', 'expired', 'revoked', 'lost'
  final RfidStickerStatus status;

  /// Date sticker was issued
  final DateTime issuedDate;

  /// Sticker expiration date
  final DateTime expiryDate;

  /// Record creation timestamp
  final DateTime? createdAt;

  /// Record update timestamp
  final DateTime? updatedAt;

  /// Whether this sticker is currently valid for entry
  bool get isValid {
    final now = DateTime.now();
    return status == RfidStickerStatus.active && expiryDate.isAfter(now);
  }

  /// Whether this sticker is expired
  bool get isExpired {
    return expiryDate.isBefore(DateTime.now());
  }

  /// Whether this sticker is inactive (expired, revoked, or lost)
  bool get isInactive {
    return status != RfidStickerStatus.active;
  }

  /// Days until expiration (negative if expired)
  int get daysUntilExpiration {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  /// Vehicle information for display
  Map<String, String?> get vehicleInfo => {
    'plate': vehiclePlate,
    'make': vehicleMake,
    'status': status.value,
  };

  @override
  List<Object?> get props => [
        id,
        tenantId,
        stickerCode,
        householdId,
        vehiclePlate,
        vehicleMake,
        status,
        issuedDate,
        expiryDate,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'RfidSticker('
        'id: $id, '
        'stickerCode: $stickerCode, '
        'vehiclePlate: $vehiclePlate, '
        'status: ${status.value}, '
        'isValid: $isValid'
        ')';
  }

  /// Create a copy with updated fields
  RfidSticker copyWith({
    String? id,
    String? tenantId,
    String? stickerCode,
    String? householdId,
    String? vehiclePlate,
    String? vehicleMake,
    RfidStickerStatus? status,
    DateTime? issuedDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RfidSticker(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      stickerCode: stickerCode ?? this.stickerCode,
      householdId: householdId ?? this.householdId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      status: status ?? this.status,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// RFID Sticker Status Enumeration
/// Matches the database constraint for rfid_stickers.status field
enum RfidStickerStatus {
  /// Sticker is valid and active for entry
  active('active'),

  /// Sticker has passed expiration date
  expired('expired'),

  /// Sticker has been manually revoked by admin
  revoked('revoked'),

  /// Sticker reported as lost/stolen
  lost('lost');

  const RfidStickerStatus(this.value);

  /// String value for database storage
  final String value;

  @override
  String toString() => value;
}

/// RFID Sticker Validation Result
/// Represents the outcome of an RFID sticker validation
class RfidStickerValidationResult extends Equatable {
  const RfidStickerValidationResult({
    required this.isValid,
    required this.sticker,
    this.reason,
    this.vehicleInfo,
    this.householdInfo,
  });

  /// Whether validation passed
  final bool isValid;

  /// The sticker that was validated (null if not found)
  final RfidSticker? sticker;

  /// Reason for validation failure (if applicable)
  final String? reason;

  /// Vehicle information for display
  final Map<String, String?>? vehicleInfo;

  /// Household information for display
  final Map<String, String?>? householdInfo;

  @override
  List<Object?> get props => [
        isValid,
        sticker,
        reason,
        vehicleInfo,
        householdInfo,
      ];

  @override
  String toString() {
    return 'RfidStickerValidationResult('
        'isValid: $isValid, '
        'sticker: $sticker, '
        'reason: $reason'
        ')';
  }
}

/// RFID Sticker Search Filters
/// Used for filtering and searching RFID stickers
class RfidStickerFilters extends Equatable {
  const RfidStickerFilters({
    this.status,
    this.householdId,
    this.vehiclePlate,
    this.expiredOnly = false,
    this.activeOnly = false,
  });

  /// Filter by sticker status
  final RfidStickerStatus? status;

  /// Filter by household ID
  final String? householdId;

  /// Filter by vehicle plate (partial match)
  final String? vehiclePlate;

  /// Show only expired stickers
  final bool expiredOnly;

  /// Show only active stickers
  final bool activeOnly;

  @override
  List<Object?> get props => [
        status,
        householdId,
        vehiclePlate,
        expiredOnly,
        activeOnly,
      ];

  /// Create a copy with updated filters
  RfidStickerFilters copyWith({
    RfidStickerStatus? status,
    String? householdId,
    String? vehiclePlate,
    bool? expiredOnly,
    bool? activeOnly,
  }) {
    return RfidStickerFilters(
      status: status ?? this.status,
      householdId: householdId ?? this.householdId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      expiredOnly: expiredOnly ?? this.expiredOnly,
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }
}