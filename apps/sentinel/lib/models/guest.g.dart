// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guest _$GuestFromJson(Map<String, dynamic> json) => Guest(
  id: json['id'] as String,
  tenantId: json['tenant_id'] as String,
  householdId: json['household_id'] as String,
  guestName: json['guest_name'] as String,
  phoneNumber: json['phone_number'] as String,
  purpose: json['purpose'] as String,
  scheduledDate: DateTime.parse(json['scheduled_date'] as String),
  expectedArrival: json['expected_arrival'] as String,
  expectedDeparture: json['expected_departure'] as String,
  status: $enumDecode(_$GuestStatusEnumMap, json['status']),
  vehicleInfo: json['vehicle_info'] as String?,
  notes: json['notes'] as String?,
  approvedByGuardId: json['approved_by_guard_id'] as String?,
  actualArrival: json['actual_arrival'] == null
      ? null
      : DateTime.parse(json['actual_arrival'] as String),
  actualDeparture: json['actual_departure'] == null
      ? null
      : DateTime.parse(json['actual_departure'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GuestToJson(Guest instance) => <String, dynamic>{
  'id': instance.id,
  'tenant_id': instance.tenantId,
  'household_id': instance.householdId,
  'guest_name': instance.guestName,
  'phone_number': instance.phoneNumber,
  'purpose': instance.purpose,
  'scheduled_date': instance.scheduledDate.toIso8601String(),
  'expected_arrival': instance.expectedArrival,
  'expected_departure': instance.expectedDeparture,
  'status': _$GuestStatusEnumMap[instance.status]!,
  'vehicle_info': instance.vehicleInfo,
  'notes': instance.notes,
  'approved_by_guard_id': instance.approvedByGuardId,
  'actual_arrival': instance.actualArrival?.toIso8601String(),
  'actual_departure': instance.actualDeparture?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$GuestStatusEnumMap = {
  GuestStatus.pending: 'pending',
  GuestStatus.checkedIn: 'checked_in',
  GuestStatus.checkedOut: 'checked_out',
  GuestStatus.cancelled: 'cancelled',
};
