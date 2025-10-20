// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guard _$GuardFromJson(Map<String, dynamic> json) => Guard(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  role: $enumDecode(_$GuardRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
  employeeId: json['employeeId'] as String?,
  isActive: json['isActive'] as bool,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GuardToJson(Guard instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'email': instance.email,
  'fullName': instance.fullName,
  'role': _$GuardRoleEnumMap[instance.role]!,
  'phone': instance.phone,
  'employeeId': instance.employeeId,
  'isActive': instance.isActive,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$GuardRoleEnumMap = {
  GuardRole.headGuard: 'head_guard',
  GuardRole.guardOfficer: 'guard_officer',
  GuardRole.guardTrainee: 'guard_trainee',
};
