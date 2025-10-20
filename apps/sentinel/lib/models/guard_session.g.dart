// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuardSession _$GuardSessionFromJson(Map<String, dynamic> json) => GuardSession(
  id: json['id'] as String,
  guardId: json['guardId'] as String,
  tenantId: json['tenantId'] as String,
  loginTime: DateTime.parse(json['loginTime'] as String),
  logoutTime: json['logoutTime'] == null
      ? null
      : DateTime.parse(json['logoutTime'] as String),
  deviceInfo: json['deviceInfo'] as String?,
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
  isActive: json['isActive'] as bool,
  sessionTokenHash: json['sessionTokenHash'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GuardSessionToJson(GuardSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guardId': instance.guardId,
      'tenantId': instance.tenantId,
      'loginTime': instance.loginTime.toIso8601String(),
      'logoutTime': instance.logoutTime?.toIso8601String(),
      'deviceInfo': instance.deviceInfo,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'isActive': instance.isActive,
      'sessionTokenHash': instance.sessionTokenHash,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
