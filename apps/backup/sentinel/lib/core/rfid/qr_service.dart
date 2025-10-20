import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../storage/data_validation.dart';

/// QR Code Service for Sentinel App
/// Handles QR code scanning, generation, and validation
/// Supports guest registration, manual entry, and various QR code formats
class QrCodeService {
  QrCodeService._();
  static final QrCodeService _instance = QrCodeService._();
  static QrCodeService get instance => _instance;

  final Logger _logger = Logger();
  final ImagePicker _imagePicker = ImagePicker();

  // Event streams
  final StreamController<QrScanResult> _scanResultsController =
      StreamController<QrScanResult>.broadcast();
  final StreamController<QrStatus> _statusController =
      StreamController<QrStatus>.broadcast();

  /// Get QR scan results stream
  Stream<QrScanResult> get scanResults => _scanResultsController.stream;

  /// Get QR status stream
  Stream<QrStatus> get statusStream => _statusController.stream;

  /// Initialize QR service
  Future<bool> initialize() async {
    try {
      _logger.i('Initializing QR code service...');

      // Check camera availability
      if (Platform.isAndroid || Platform.isIOS) {
        _statusController.add(QrStatus.ready);
        _logger.i('QR code service initialized successfully');
        return true;
      } else {
        _logger.w('QR code scanning not supported on this platform');
        _statusController.add(QrStatus.unsupported);
        return false;
      }
    } catch (e) {
      _logger.e('Failed to initialize QR service: $e');
      _statusController.add(QrStatus.error(e.toString()));
      return false;
    }
  }

  /// Start QR code scanning from camera
  Future<QrScanResult> scanFromCamera({
    Duration? timeout,
    bool flashOnStart = false,
  }) async {
    try {
      _statusController.add(QrStatus.scanning);

      final completer = Completer<QrScanResult>();
      BarcodeCapture? lastCapture;

      // Set timeout
      final scanTimeout = timeout ?? const Duration(seconds: 30);
      Timer(scanTimeout, () {
        if (!completer.isCompleted) {
          completer.complete(QrScanResult.error('Scan timeout'));
          _statusController.add(QrStatus.timeout);
        }
      });

      // Note: This would be integrated with a UI that shows the camera
      // For now, we'll simulate the scan result
      // In a real implementation, this would connect to mobile_scanner

      _logger.w('QR camera scanning requires UI integration');
      return QrScanResult.error('Camera scanning requires UI integration');

    } catch (e) {
      _logger.e('Error scanning QR from camera: $e');
      _statusController.add(QrStatus.error(e.toString()));
      return QrScanResult.error('Camera scan failed: $e');
    }
  }

  /// Scan QR code from image gallery
  Future<QrScanResult> scanFromImage() async {
    try {
      _statusController.add(QrStatus.scanning);

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _statusController.add(QrStatus.cancelled);
        return QrScanResult.error('No image selected');
      }

      final imageBytes = await pickedFile.readAsBytes();
      final result = await _scanFromImageBytes(imageBytes);

      _statusController.add(QrStatus.ready);
      return result;

    } catch (e) {
      _logger.e('Error scanning QR from image: $e');
      _statusController.add(QrStatus.error(e.toString()));
      return QrScanResult.error('Image scan failed: $e');
    }
  }

  /// Scan QR code from image bytes
  Future<QrScanResult> _scanFromImageBytes(Uint8List imageBytes) async {
    try {
      // Use mobile_scanner's image analyzer
      final scanner = MobileScannerController();

      // Analyze the image for QR codes
      final captures = await scanner.analyzeImage(imageBytes);

      if (captures.isEmpty) {
        return QrScanResult.error('No QR code found in image');
      }

      // Process the first QR code found
      final capture = captures.first;
      final qrData = capture.rawValue;

      if (qrData.isEmpty) {
        return QrScanResult.error('Empty QR code data');
      }

      // Validate and process QR code data
      final validationResult = _validateQrCodeData(qrData);

      return QrScanResult(
        success: true,
        qrData: qrData,
        validationResult: validationResult,
        scanMethod: 'image_gallery',
        timestamp: DateTime.now(),
        format: capture.format ?? BarcodeFormat.qrCode,
      );

    } catch (e) {
      _logger.e('Error analyzing image for QR code: $e');
      return QrScanResult.error('Image analysis failed: $e');
    }
  }

  /// Validate QR code data
  QrValidationResult _validateQrCodeData(String qrData) {
    try {
      final cleanData = qrData.trim();

      if (cleanData.isEmpty) {
        return QrValidationResult(
          isValid: false,
          errors: ['QR code data is empty'],
        );
      }

      // Try to parse as JSON first
      try {
        final jsonData = jsonDecode(cleanData) as Map<String, dynamic>;
        return _validateJsonQrCode(jsonData);
      } catch (e) {
        // Not JSON, try other formats
        return _validateTextQrCode(cleanData);
      }

    } catch (e) {
      _logger.e('Error validating QR code data: $e');
      return QrValidationResult(
        isValid: false,
        errors: ['Validation error: $e'],
      );
    }
  }

  /// Validate JSON format QR code
  QrValidationResult _validateJsonQrCode(Map<String, dynamic> jsonData) {
    final errors = <String>[];
    final info = <String, dynamic>{};

    // Check for common QR code fields
    if (jsonData.containsKey('type')) {
      info['type'] = jsonData['type'];
    }

    // Guest registration QR code
    if (info['type'] == 'guest_registration') {
      if (!jsonData.containsKey('guestName') ||
          jsonData['guestName'].toString().trim().isEmpty) {
        errors.add('Guest name is required');
      }

      if (!jsonData.containsKey('hostName') ||
          jsonData['hostName'].toString().trim().isEmpty) {
        errors.add('Host name is required');
      }

      if (jsonData.containsKey('visitDate')) {
        final visitDate = DateTime.tryParse(jsonData['visitDate'] as String? ?? '');
        if (visitDate == null) {
          errors.add('Invalid visit date format');
        }
      }
    }

    // Access credential QR code
    if (info['type'] == 'access_credential') {
      if (!jsonData.containsKey('accessCode') ||
          jsonData['accessCode'].toString().trim().isEmpty) {
        errors.add('Access code is required');
      }

      if (!jsonData.containsKey('validUntil')) {
        errors.add('Valid until date is required');
      }
    }

    return QrValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      qrType: info['type'] as String?,
      data: jsonData,
    );
  }

  /// Validate text format QR code
  QrValidationResult _validateTextQrCode(String textData) {
    final validation = DataValidation.instance;

    // Check if it's a simple sticker code
    if (validation.isValidQrCode(textData)) {
      return QrValidationResult(
        isValid: true,
        qrType: 'sticker_code',
        data: {'code': textData},
      );
    }

    // Check if it's a URL
    if (textData.startsWith('http://') || textData.startsWith('https://')) {
      return QrValidationResult(
        isValid: true,
        qrType: 'url',
        data: {'url': textData},
      );
    }

    // Check if it's a phone number
    if (validation.isValidPhoneNumber(textData)) {
      return QrValidationResult(
        isValid: true,
        qrType: 'phone',
        data: {'phone': textData},
      );
    }

    // Check for common prefix patterns
    if (textData.startsWith('RFID-')) {
      return QrValidationResult(
        isValid: true,
        qrType: 'rfid_sticker',
        data: {'stickerCode': textData},
      );
    }

    if (textData.startsWith('GUEST-')) {
      return QrValidationResult(
        isValid: true,
        qrType: 'guest_access',
        data: {'guestCode': textData},
      );
    }

    return QrValidationResult(
      isValid: false,
      errors: ['Unrecognized QR code format'],
      qrType: 'unknown',
      data: {'rawText': textData},
    );
  }

  /// Generate QR code for guest registration
  Future<QrGenerationResult> generateGuestRegistrationQr({
    required String guestName,
    required String hostName,
    required String visitDate,
    required String visitPurpose,
    String? contactNumber,
    String? additionalInfo,
  }) async {
    try {
      final qrData = {
        'type': 'guest_registration',
        'guestName': guestName,
        'hostName': hostName,
        'visitDate': visitDate,
        'visitPurpose': visitPurpose,
        'contactNumber': contactNumber,
        'additionalInfo': additionalInfo,
        'generatedAt': DateTime.now().toIso8601String(),
        'generatedBy': 'sentinel_app',
      };

      final qrJson = jsonEncode(qrData);
      final qrImage = await QrPainter(
        data: qrJson,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ).toImageData(200.0);

      return QrGenerationResult(
        success: true,
        qrImage: qrImage,
        qrData: qrJson,
        qrType: 'guest_registration',
      );

    } catch (e) {
      _logger.e('Error generating guest registration QR: $e');
      return QrGenerationResult.error('QR generation failed: $e');
    }
  }

  /// Generate QR code for RFID sticker
  Future<QrGenerationResult> generateRfidStickerQr({
    required String stickerCode,
    required String householdId,
    required String holderName,
    String? holderType,
    DateTime? validUntil,
  }) async {
    try {
      final qrData = {
        'type': 'rfid_sticker',
        'stickerCode': stickerCode,
        'householdId': householdId,
        'holderName': holderName,
        'holderType': holderType ?? 'resident',
        'validUntil': validUntil?.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
        'generatedBy': 'sentinel_app',
      };

      final qrJson = jsonEncode(qrData);
      final qrImage = await QrPainter(
        data: qrJson,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ).toImageData(200.0);

      return QrGenerationResult(
        success: true,
        qrImage: qrImage,
        qrData: qrJson,
        qrType: 'rfid_sticker',
      );

    } catch (e) {
      _logger.e('Error generating RFID sticker QR: $e');
      return QrGenerationResult.error('QR generation failed: $e');
    }
  }

  /// Generate QR code for guest access
  Future<QrGenerationResult> generateGuestAccessQr({
    required String guestId,
    required String guestName,
    required String hostName,
    required String householdId,
    DateTime? validUntil,
    int? maxVisits,
  }) async {
    try {
      final qrData = {
        'type': 'guest_access',
        'guestId': guestId,
        'guestName': guestName,
        'hostName': hostName,
        'householdId': householdId,
        'validUntil': validUntil?.toIso8601String(),
        'maxVisits': maxVisits ?? 1,
        'generatedAt': DateTime.now().toIso8601String(),
        'generatedBy': 'sentinel_app',
      };

      final qrJson = jsonEncode(qrData);
      final qrImage = await QrPainter(
        data: qrJson,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ).toImageData(200.0);

      return QrGenerationResult(
        success: true,
        qrImage: qrImage,
        qrData: qrJson,
        qrType: 'guest_access',
      );

    } catch (e) {
      _logger.e('Error generating guest access QR: $e');
      return QrGenerationResult.error('QR generation failed: $e');
    }
  }

  /// Validate QR code string format
  bool isValidQrCode(String qrCode) {
    if (qrCode.trim().isEmpty) return false;

    // Basic length validation
    if (qrCode.length < 4 || qrCode.length > 2000) return false;

    // Check for common QR code patterns
    final patterns = [
      RegExp(r'^[A-Za-z0-9\-_]{4,}$'), // Alphanumeric with underscores/hyphens
      RegExp(r'^https?://'), // URLs
      RegExp(r'^\d{11,15}$'), // Phone numbers
      RegExp(r'^RFID-'), // RFID sticker format
      RegExp(r'^GUEST-'), // Guest access format
    ];

    return patterns.any((pattern) => pattern.hasMatch(qrCode));
  }

  /// Get QR code statistics
  Map<String, dynamic> getQrStats() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'supportedFormats': [
        'guest_registration',
        'rfid_sticker',
        'guest_access',
        'access_credential',
        'url',
        'phone',
        'sticker_code',
      ],
      'validationRules': {
        'minLength': 4,
        'maxLength': 2000,
        'allowedCharacters': 'Alphanumeric, underscore, hyphen',
        'specialFormats': ['RFID-', 'GUEST-', 'http://', 'https://'],
      },
    };
  }

  /// Dispose resources
  void dispose() {
    _scanResultsController.close();
    _statusController.close();
  }
}

/// QR code scan result
class QrScanResult {
  const QrScanResult({
    required this.success,
    this.qrData,
    this.validationResult,
    this.scanMethod = 'unknown',
    this.timestamp,
    this.format,
    this.error,
  });

  final bool success;
  final String? qrData;
  final QrValidationResult? validationResult;
  final String scanMethod;
  final DateTime? timestamp;
  final BarcodeFormat? format;
  final String? error;

  bool get hasError => error != null;

  factory QrScanResult.error(String error) {
    return QrScanResult(
      success: false,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'QrScanResult('
        'success: $success, '
        'qrData: $qrData, '
        'method: $scanMethod, '
        'error: $error)';
  }
}

/// QR code generation result
class QrGenerationResult {
  const QrGenerationResult({
    required this.success,
    this.qrImage,
    this.qrData,
    this.qrType,
    this.error,
  });

  final bool success;
  final Uint8List? qrImage;
  final String? qrData;
  final String? qrType;
  final String? error;

  bool get hasError => error != null;

  factory QrGenerationResult.error(String error) {
    return QrGenerationResult(success: false, error: error);
  }

  @override
  String toString() {
    return 'QrGenerationResult(success: $success, type: $qrType, error: $error)';
  }
}

/// QR code validation result
class QrValidationResult {
  const QrValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.qrType,
    this.data,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final String? qrType;
  final Map<String, dynamic>? data;

  String? get firstError => errors.isNotEmpty ? errors.first : null;
  String get errorsString => errors.join('; ');

  @override
  String toString() {
    return 'QrValidationResult(isValid: $isValid, type: $qrType, errors: $errors)';
  }
}

/// QR code status enum
enum QrStatus {
  uninitialized,
  ready,
  scanning,
  success,
  error,
  cancelled,
  timeout,
  unsupported,
}

/// QR code exception
class QrException implements Exception {
  const QrException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'QrException: $message${errorCode != null ? ' (Code: $errorCode)' : ""}';
}