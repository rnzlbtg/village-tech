import 'package:json_annotation/json_annotation.dart';
import 'package:sentinel/core/storage/tables.dart';

part 'rfid_sticker_model.g.dart';

/// RFID sticker model for JSON serialization and data transfer
/// Represents a vehicle RFID sticker for resident verification
@JsonSerializable()
class RfidStickerModel {
  const RfidStickerModel({
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

  /// Convert from database entity to model
  factory RfidStickerModel.fromDatabase(RfidSticker sticker) {
    return RfidStickerModel(
      id: sticker.id,
      tenantId: sticker.tenantId,
      stickerCode: sticker.stickerCode,
      householdId: sticker.householdId,
      vehiclePlate: sticker.vehiclePlate,
      vehicleMake: sticker.vehicleMake,
      status: sticker.status,
      issuedDate: sticker.issuedDate,
      expiryDate: sticker.expiryDate,
      createdAt: sticker.createdAt,
      updatedAt: sticker.updatedAt,
    );
  }

  /// Convert from model to database entity
  RfidSticker toDatabase() {
    return RfidSticker(
      id: id,
      tenantId: tenantId,
      stickerCode: stickerCode,
      householdId: householdId,
      vehiclePlate: vehiclePlate,
      vehicleMake: vehicleMake,
      status: status,
      issuedDate: issuedDate,
      expiryDate: expiryDate,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  final String id;
  final String tenantId;
  final String stickerCode;
  final String householdId;
  final String vehiclePlate;
  final String? vehicleMake;
  final String status;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Check if sticker is expired
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(expiryDate);
  }

  /// Check if sticker is active
  bool get isActive {
    return status.toLowerCase() == 'active' && !isExpired;
  }

  /// Check if sticker is in a valid state
  bool get isValid {
    return id.isNotEmpty &&
        tenantId.isNotEmpty &&
        stickerCode.isNotEmpty &&
        householdId.isNotEmpty &&
        vehiclePlate.isNotEmpty &&
        status.isNotEmpty;
  }

  /// Get days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  /// Get expiry status description
  String get expiryStatus {
    if (isExpired) return 'Expired';
    if (daysUntilExpiry <= 7) return 'Expires Soon';
    return 'Valid';
  }

  /// Create copy with updated values
  RfidStickerModel copyWith({
    String? id,
    String? tenantId,
    String? stickerCode,
    String? householdId,
    String? vehiclePlate,
    String? vehicleMake,
    String? status,
    DateTime? issuedDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RfidStickerModel(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RfidStickerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RfidStickerModel(id: $id, stickerCode: $stickerCode, status: $status, '
        'vehiclePlate: $vehiclePlate, expires: $expiryDate)';
  }
}

/// RFID sticker status enum
enum RfidStickerStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('lost')
  lost;

  String get displayName {
    switch (this) {
      case RfidStickerStatus.active:
        return 'Active';
      case RfidStickerStatus.expired:
        return 'Expired';
      case RfidStickerStatus.revoked:
        return 'Revoked';
      case RfidStickerStatus.lost:
        return 'Lost';
    }
  }

  String get description {
    switch (this) {
      case RfidStickerStatus.active:
        return 'Sticker is valid and can be used for access';
      case RfidStickerStatus.expired:
        return 'Sticker has expired and needs renewal';
      case RfidStickerStatus.revoked:
        return 'Sticker has been revoked by administration';
      case RfidStickerStatus.lost:
        return 'Sticker has been reported as lost';
    }
  }
}

/// Extension for easy status checking
extension RfidStickerModelExtension on RfidStickerModel {
  /// Get status as enum
  RfidStickerStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'active':
        return RfidStickerStatus.active;
      case 'expired':
        return RfidStickerStatus.expired;
      case 'revoked':
        return RfidStickerStatus.revoked;
      case 'lost':
        return RfidStickerStatus.lost;
      default:
        return RfidStickerStatus.active; // Default to active
    }
  }

  /// Check if status can be changed to new status
  bool canChangeStatusTo(RfidStickerStatus newStatus) {
    switch (statusEnum) {
      case RfidStickerStatus.active:
        return newStatus != RfidStickerStatus.active;
      case RfidStickerStatus.expired:
      case RfidStickerStatus.revoked:
      case RfidStickerStatus.lost:
        // Can reactivate expired stickers with admin approval
        return newStatus == RfidStickerStatus.active;
    }
  }

  /// Get formatted vehicle information
  String get formattedVehicleInfo {
    if (vehicleMake != null && vehicleMake!.isNotEmpty) {
      return '$vehicleMake - $vehiclePlate';
    }
    return vehiclePlate;
  }

  /// Validate model data
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('ID is required');
    if (tenantId.isEmpty) errors.add('Tenant ID is required');
    if (stickerCode.isEmpty) errors.add('Sticker code is required');
    if (householdId.isEmpty) errors.add('Household ID is required');
    if (vehiclePlate.isEmpty) errors.add('Vehicle plate is required');
    if (status.isEmpty) errors.add('Status is required');

    if (issuedDate.isAfter(expiryDate)) {
      errors.add('Issue date cannot be after expiry date');
    }

    return errors;
  }
}