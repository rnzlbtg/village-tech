// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuardProfile _$GuardProfileFromJson(Map<String, dynamic> json) => GuardProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      tenantId: json['tenantId'] as String,
      role: json['role'] as String,
      assignedGate: json['assignedGate'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      badgeNumber: json['badgeNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GuardProfileToJson(GuardProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'tenantId': instance.tenantId,
      'role': instance.role,
      'assignedGate': instance.assignedGate,
      'phoneNumber': instance.phoneNumber,
      'badgeNumber': instance.badgeNumber,
      'isActive': instance.isActive,
      'permissions': instance.permissions,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
