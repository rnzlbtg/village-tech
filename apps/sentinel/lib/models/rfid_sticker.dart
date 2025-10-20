import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'rfid_sticker.g.dart';

/// RFID Sticker model for vehicle access control
@JsonSerializable()
class RfidSticker {
  final String id;
  final String tenantId;
  final String stickerCode;
  final String residentId;
  final String? vehicleInfo;
  final String? licensePlate;
  final RfidStatus status;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? lastUsedAt;
  final String? issuedByGuardId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RfidSticker({
    required this.id,
    required this.tenantId,
    required this.stickerCode,
    required this.residentId,
    this.vehicleInfo,
    this.licensePlate,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    this.lastUsedAt,
    this.issuedByGuardId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new RFID sticker with generated ID and timestamps
  factory RfidSticker.create({
    required String tenantId,
    required String stickerCode,
    required String residentId,
    String? vehicleInfo,
    String? licensePlate,
    required DateTime expiresAt,
    String? issuedByGuardId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return RfidSticker(
      id: const Uuid().v4(),
      tenantId: tenantId,
      stickerCode: stickerCode,
      residentId: residentId,
      vehicleInfo: vehicleInfo,
      licensePlate: licensePlate,
      status: RfidStatus.active,
      issuedAt: now,
      expiresAt: expiresAt,
      lastUsedAt: null,
      issuedByGuardId: issuedByGuardId,
      metadata: metadata ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create RFID sticker from JSON
  factory RfidSticker.fromJson(Map<String, dynamic> json) => _$RfidStickerFromJson(json);

  /// Convert RFID sticker to JSON
  Map<String, dynamic> toJson() => _$RfidStickerToJson(this);

  /// Create a copy with updated fields
  RfidSticker copyWith({
    String? id,
    String? tenantId,
    String? stickerCode,
    String? residentId,
    String? vehicleInfo,
    String? licensePlate,
    RfidStatus? status,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    String? issuedByGuardId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RfidSticker(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      stickerCode: stickerCode ?? this.stickerCode,
      residentId: residentId ?? this.residentId,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      licensePlate: licensePlate ?? this.licensePlate,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      issuedByGuardId: issuedByGuardId ?? this.issuedByGuardId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Update last used time
  RfidSticker updateLastUsed() {
    return copyWith(
      lastUsedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Deactivate sticker (lost/stolen)
  RfidSticker deactivate({String? reason}) {
    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    if (reason != null) {
      updatedMetadata['deactivation_reason'] = reason;
    }
    updatedMetadata['deactivated_at'] = DateTime.now().toIso8601String();

    return copyWith(
      status: RfidStatus.disabled,
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark sticker as lost
  RfidSticker markAsLost({String? reportedBy}) {
    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    updatedMetadata['lost_at'] = DateTime.now().toIso8601String();
    if (reportedBy != null) {
      updatedMetadata['lost_reported_by'] = reportedBy;
    }

    return copyWith(
      status: RfidStatus.lost,
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Reactivate sticker
  RfidSticker reactivate() {
    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    updatedMetadata.remove('deactivation_reason');
    updatedMetadata.remove('deactivated_at');
    updatedMetadata.remove('lost_at');
    updatedMetadata.remove('lost_reported_by');
    updatedMetadata['reactivated_at'] = DateTime.now().toIso8601String();

    return copyWith(
      status: RfidStatus.active,
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Update expiration date
  RfidSticker updateExpiration(DateTime newExpiresAt) {
    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    updatedMetadata['expiration_updates'] = [
      ...(updatedMetadata['expiration_updates'] as List<dynamic>? ?? []),
      {
        'old_expires_at': expiresAt.toIso8601String(),
        'new_expires_at': newExpiresAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }
    ];

    return copyWith(
      expiresAt: newExpiresAt,
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if sticker is currently valid
  bool get isValid => status == RfidStatus.active && !isExpired;

  /// Check if sticker is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if sticker is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiresAt.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  /// Get days until expiration
  int get daysUntilExpiration {
    final now = DateTime.now();
    if (isExpired) return 0;
    return expiresAt.difference(now).inDays;
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case RfidStatus.active:
        if (isExpired) return 'Expired';
        if (isExpiringSoon) return 'Expiring Soon';
        return 'Active';
      case RfidStatus.expired:
        return 'Expired';
      case RfidStatus.disabled:
        return 'Disabled';
      case RfidStatus.lost:
        return 'Lost';
    }
  }

  /// Validate RFID sticker data
  bool isValidData() {
    return _validateStickerCode(stickerCode) &&
        _validateResidentId(residentId) &&
        _validateVehicleInfo(vehicleInfo) &&
        _validateLicensePlate(licensePlate) &&
        _validateExpirationDate(expiresAt);
  }

  bool _validateStickerCode(String code) {
    return code.trim().isNotEmpty && code.trim().length >= 4 && code.trim().length <= 50;
  }

  bool _validateResidentId(String id) {
    return id.trim().isNotEmpty;
  }

  bool _validateVehicleInfo(String? info) {
    if (info == null || info.trim().isEmpty) return true; // Optional
    return info.trim().length <= 200;
  }

  bool _validateLicensePlate(String? plate) {
    if (plate == null || plate.trim().isEmpty) return true; // Optional
    return plate.trim().length >= 2 && plate.trim().length <= 20;
  }

  bool _validateExpirationDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RfidSticker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RfidSticker(id: $id, stickerCode: $stickerCode, status: $status, expiresAt: $expiresAt)';
  }
}

/// RFID sticker status enumeration
enum RfidStatus {
  @JsonValue('active')
  active('Active', 'Sticker is valid and can be used'),
  @JsonValue('expired')
  expired('Expired', 'Sticker has expired and cannot be used'),
  @JsonValue('disabled')
  disabled('Disabled', 'Sticker has been manually disabled'),
  @JsonValue('lost')
  lost('Lost', 'Sticker has been reported as lost');

  const RfidStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get status from string value
  static RfidStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return RfidStatus.active;
      case 'expired':
        return RfidStatus.expired;
      case 'disabled':
        return RfidStatus.disabled;
      case 'lost':
        return RfidStatus.lost;
      default:
        throw ArgumentError('Invalid RfidStatus: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case RfidStatus.active:
        return 'active';
      case RfidStatus.expired:
        return 'expired';
      case RfidStatus.disabled:
        return 'disabled';
      case RfidStatus.lost:
        return 'lost';
    }
  }
}

/// RFID validation errors
enum RfidValidationError {
  stickerCodeInvalid,
  residentIdInvalid,
  vehicleInfoInvalid,
  licensePlateInvalid,
  expirationDateInvalid,
  alreadyIssued,
  expired,
}

/// RFID validation result
class RfidValidationResult {
  final bool isValid;
  final List<RfidValidationError> errors;
  final String? message;

  const RfidValidationResult(this.isValid, this.errors, [this.message]);

  factory RfidValidationResult.success() {
    return const RfidValidationResult(true, []);
  }

  factory RfidValidationResult.failure(List<RfidValidationError> errors, [String? message]) {
    return RfidValidationResult(false, errors, message);
  }
}