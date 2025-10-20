// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntryLog _$EntryLogFromJson(Map<String, dynamic> json) => EntryLog(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  guardId: json['guardId'] as String,
  entryType: $enumDecode(_$EntryTypeEnumMap, json['entryType']),
  personName: json['personName'] as String,
  vehicleInfo: json['vehicleInfo'] as String?,
  rfidStickerId: json['rfidStickerId'] as String?,
  guestId: json['guestId'] as String?,
  deliveryId: json['deliveryId'] as String?,
  constructionPermitId: json['constructionPermitId'] as String?,
  destination: json['destination'] as String,
  purpose: json['purpose'] as String?,
  verificationMethod: $enumDecode(
    _$VerificationMethodEnumMap,
    json['verificationMethod'],
  ),
  verificationStatus: $enumDecode(
    _$VerificationStatusEnumMap,
    json['verificationStatus'],
  ),
  entryTime: DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  durationOnSite: json['durationOnSite'] == null
      ? null
      : Duration(microseconds: (json['durationOnSite'] as num).toInt()),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  synced: json['synced'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EntryLogToJson(EntryLog instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'guardId': instance.guardId,
  'entryType': _$EntryTypeEnumMap[instance.entryType]!,
  'personName': instance.personName,
  'vehicleInfo': instance.vehicleInfo,
  'rfidStickerId': instance.rfidStickerId,
  'guestId': instance.guestId,
  'deliveryId': instance.deliveryId,
  'constructionPermitId': instance.constructionPermitId,
  'destination': instance.destination,
  'purpose': instance.purpose,
  'verificationMethod':
      _$VerificationMethodEnumMap[instance.verificationMethod]!,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'entryTime': instance.entryTime.toIso8601String(),
  'exitTime': instance.exitTime?.toIso8601String(),
  'durationOnSite': instance.durationOnSite?.inMicroseconds,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'synced': instance.synced,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$EntryTypeEnumMap = {
  EntryType.resident: 'resident',
  EntryType.guest: 'guest',
  EntryType.delivery: 'delivery',
  EntryType.construction: 'construction',
  EntryType.other: 'other',
};

const _$VerificationMethodEnumMap = {
  VerificationMethod.rfid: 'rfid',
  VerificationMethod.manual: 'manual',
  VerificationMethod.phoneCall: 'phone_call',
  VerificationMethod.permit: 'permit',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.verified: 'verified',
  VerificationStatus.pending: 'pending',
  VerificationStatus.denied: 'denied',
};
