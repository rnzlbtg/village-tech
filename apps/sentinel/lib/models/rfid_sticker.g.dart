// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_sticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RfidSticker _$RfidStickerFromJson(Map<String, dynamic> json) => RfidSticker(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  stickerCode: json['stickerCode'] as String,
  residentId: json['residentId'] as String,
  vehicleInfo: json['vehicleInfo'] as String?,
  licensePlate: json['licensePlate'] as String?,
  status: $enumDecode(_$RfidStatusEnumMap, json['status']),
  issuedAt: DateTime.parse(json['issuedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
  issuedByGuardId: json['issuedByGuardId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RfidStickerToJson(RfidSticker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'stickerCode': instance.stickerCode,
      'residentId': instance.residentId,
      'vehicleInfo': instance.vehicleInfo,
      'licensePlate': instance.licensePlate,
      'status': _$RfidStatusEnumMap[instance.status]!,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'issuedByGuardId': instance.issuedByGuardId,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RfidStatusEnumMap = {
  RfidStatus.active: 'active',
  RfidStatus.expired: 'expired',
  RfidStatus.disabled: 'disabled',
  RfidStatus.lost: 'lost',
};
