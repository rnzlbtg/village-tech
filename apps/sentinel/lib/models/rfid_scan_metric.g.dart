// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_scan_metric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RfidScanMetric _$RfidScanMetricFromJson(Map<String, dynamic> json) =>
    RfidScanMetric(
      id: json['id'] as String,
      rfidCode: json['rfid_code'] as String,
      scanStartTime: DateTime.parse(json['scan_start_time'] as String),
      scanEndTime: DateTime.parse(json['scan_end_time'] as String),
      successful: json['successful'] as bool,
      scanMethod: json['scan_method'] as String,
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      locationData: json['location_data'] as Map<String, dynamic>?,
      networkInfo: json['network_info'] as Map<String, dynamic>?,
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RfidScanMetricToJson(RfidScanMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rfid_code': instance.rfidCode,
      'scan_start_time': instance.scanStartTime.toIso8601String(),
      'scan_end_time': instance.scanEndTime.toIso8601String(),
      'successful': instance.successful,
      'scan_method': instance.scanMethod,
      'error_message': instance.errorMessage,
      'error_code': instance.errorCode,
      'additional_data': instance.additionalData,
      'device_info': instance.deviceInfo,
      'location_data': instance.locationData,
      'network_info': instance.networkInfo,
      'retry_count': instance.retryCount,
      'created_at': instance.createdAt.toIso8601String(),
    };
