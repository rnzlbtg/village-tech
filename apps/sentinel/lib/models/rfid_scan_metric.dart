import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'rfid_scan_metric.g.dart';

/// RFID Scan Performance Metric
///
/// Records individual RFID scan attempts with timing, success status,
/// and error information for performance monitoring and analytics.
@HiveType(typeId: 12)
@JsonSerializable()
class RfidScanMetric extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'rfid_code')
  final String rfidCode;

  @HiveField(2)
  @JsonKey(name: 'scan_start_time')
  final DateTime scanStartTime;

  @HiveField(3)
  @JsonKey(name: 'scan_end_time')
  final DateTime scanEndTime;

  @HiveField(4)
  @JsonKey(name: 'successful')
  final bool successful;

  @HiveField(5)
  @JsonKey(name: 'scan_method')
  final String scanMethod;

  @HiveField(6)
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  @HiveField(7)
  @JsonKey(name: 'error_code')
  final String? errorCode;

  @HiveField(8)
  @JsonKey(name: 'additional_data')
  final Map<String, dynamic>? additionalData;

  @HiveField(9)
  @JsonKey(name: 'device_info')
  final Map<String, dynamic>? deviceInfo;

  @HiveField(10)
  @JsonKey(name: 'location_data')
  final Map<String, dynamic>? locationData;

  @HiveField(11)
  @JsonKey(name: 'network_info')
  final Map<String, dynamic>? networkInfo;

  @HiveField(12)
  @JsonKey(name: 'retry_count')
  final int retryCount;

  @HiveField(13)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RfidScanMetric({
    required this.id,
    required this.rfidCode,
    required this.scanStartTime,
    required this.scanEndTime,
    required this.successful,
    required this.scanMethod,
    this.errorMessage,
    this.errorCode,
    this.additionalData,
    this.deviceInfo,
    this.locationData,
    this.networkInfo,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calculate scan duration
  Duration get scanDuration => scanEndTime.difference(scanStartTime);

  /// Check if scan meets performance target (<5 seconds)
  bool get meetsPerformanceTarget => scanDuration.inSeconds < 5;

  /// Check if scan has performance warning (4-6 seconds)
  bool get hasPerformanceWarning =>
      scanDuration.inSeconds >= 4 && scanDuration.inSeconds < 6;

  /// Check if scan has critical performance issue (>6 seconds)
  bool get hasCriticalPerformanceIssue => scanDuration.inSeconds >= 6;

  /// Create a copy with updated values
  RfidScanMetric copyWith({
    String? id,
    String? rfidCode,
    DateTime? scanStartTime,
    DateTime? scanEndTime,
    bool? successful,
    String? scanMethod,
    String? errorMessage,
    String? errorCode,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? networkInfo,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return RfidScanMetric(
      id: id ?? this.id,
      rfidCode: rfidCode ?? this.rfidCode,
      scanStartTime: scanStartTime ?? this.scanStartTime,
      scanEndTime: scanEndTime ?? this.scanEndTime,
      successful: successful ?? this.successful,
      scanMethod: scanMethod ?? this.scanMethod,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      additionalData: additionalData ?? this.additionalData,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      locationData: locationData ?? this.locationData,
      networkInfo: networkInfo ?? this.networkInfo,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create metric for successful scan
  factory RfidScanMetric.successful({
    required String rfidCode,
    required DateTime startTime,
    required DateTime endTime,
    required String scanMethod,
    String? id,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? networkInfo,
    int retryCount = 0,
  }) {
    return RfidScanMetric(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      rfidCode: rfidCode,
      scanStartTime: startTime,
      scanEndTime: endTime,
      successful: true,
      scanMethod: scanMethod,
      additionalData: additionalData,
      deviceInfo: deviceInfo,
      locationData: locationData,
      networkInfo: networkInfo,
      retryCount: retryCount,
    );
  }

  /// Create metric for failed scan
  factory RfidScanMetric.failed({
    required String rfidCode,
    required DateTime startTime,
    required DateTime endTime,
    required String scanMethod,
    required String errorMessage,
    String? errorCode,
    String? id,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? networkInfo,
    int retryCount = 0,
  }) {
    return RfidScanMetric(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      rfidCode: rfidCode,
      scanStartTime: startTime,
      scanEndTime: endTime,
      successful: false,
      scanMethod: scanMethod,
      errorMessage: errorMessage,
      errorCode: errorCode,
      additionalData: additionalData,
      deviceInfo: deviceInfo,
      locationData: locationData,
      networkInfo: networkInfo,
      retryCount: retryCount,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$RfidScanMetricToJson(this);

  /// Create from JSON
  factory RfidScanMetric.fromJson(Map<String, dynamic> json) =>
      _$RfidScanMetricFromJson(json);

  @override
  String toString() {
    return 'RfidScanMetric('
        'id: $id, '
        'rfidCode: $rfidCode, '
        'scanDuration: ${scanDuration.inMilliseconds}ms, '
        'successful: $successful, '
        'scanMethod: $scanMethod, '
        'errorCode: $errorCode'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RfidScanMetric && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Convert to a summary for display
  Map<String, dynamic> toSummary() {
    return {
      'id': id,
      'rfidCode': rfidCode,
      'scanDurationMs': scanDuration.inMilliseconds,
      'successful': successful,
      'scanMethod': scanMethod,
      'meetsTarget': meetsPerformanceTarget,
      'hasWarning': hasPerformanceWarning,
      'hasCriticalIssue': hasCriticalPerformanceIssue,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'retryCount': retryCount,
      'timestamp': scanEndTime.toIso8601String(),
    };
  }
}

/// RFID scan method types
class RfidScanMethod {
  static const String nfc = 'nfc';
  static const String bluetooth = 'bluetooth';
  static const String manual = 'manual';
  static const String qrCode = 'qr_code';
  static const String barcode = 'barcode';

  static const List<String> allMethods = [
    nfc,
    bluetooth,
    manual,
    qrCode,
    barcode,
  ];
}

/// Common RFID error codes
class RfidErrorCodes {
  static const String stickerNotFound = 'STICKER_NOT_FOUND';
  static const String stickerExpired = 'STICKER_EXPIRED';
  static const String stickerDisabled = 'STICKER_DISABLED';
  static const String stickerLost = 'STICKER_LOST';
  static const String nfcNotAvailable = 'NFC_NOT_AVAILABLE';
  static const String nfcPermissionDenied = 'NFC_PERMISSION_DENIED';
  static const String nfcTimeout = 'NFC_TIMEOUT';
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String invalidFormat = 'INVALID_FORMAT';
  static const String unknownError = 'UNKNOWN_ERROR';

  static const List<String> allErrorCodes = [
    stickerNotFound,
    stickerExpired,
    stickerDisabled,
    stickerLost,
    nfcNotAvailable,
    nfcPermissionDenied,
    nfcTimeout,
    networkError,
    serverError,
    invalidFormat,
    unknownError,
  ];

  /// Get human-readable error message
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case stickerNotFound:
        return 'RFID sticker not found in system';
      case stickerExpired:
        return 'RFID sticker has expired';
      case stickerDisabled:
        return 'RFID sticker has been disabled';
      case stickerLost:
        return 'RFID sticker reported as lost';
      case nfcNotAvailable:
        return 'NFC not available on this device';
      case nfcPermissionDenied:
        return 'NFC permission denied';
      case nfcTimeout:
        return 'NFC scan timeout';
      case networkError:
        return 'Network connection error';
      case serverError:
        return 'Server error occurred';
      case invalidFormat:
        return 'Invalid RFID format';
      case unknownError:
      default:
        return 'Unknown error occurred';
    }
  }
}