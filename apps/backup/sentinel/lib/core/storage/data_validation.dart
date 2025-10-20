import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

/// Data validation and integrity checking utilities
/// Provides validation for local database records and data integrity verification
class DataValidation {
  DataValidation._();
  static final DataValidation _instance = DataValidation._();
  static DataValidation get instance => _instance;

  final Logger _logger = Logger();

  // =============== Data Type Validators ===============

  /// Validate email format
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format (Philippines)
  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Remove spaces, dashes, and parentheses
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for Philippine mobile number format (09XX-XXX-XXXX or +639XX-XXX-XXXX)
    final phoneRegex = RegExp(r'^(09\d{9}|\+639\d{9})$');

    return phoneRegex.hasMatch(cleanNumber);
  }

  /// Validate RFID sticker code format
  bool isValidRfidCode(String code) {
    if (code.isEmpty) return false;

    // RFID codes should be alphanumeric, 8-16 characters
    final rfidRegex = RegExp(r'^[A-Za-z0-9]{8,16}$');

    return rfidRegex.hasMatch(code);
  }

  /// Validate QR code format
  bool isValidQrCode(String qrCode) {
    if (qrCode.isEmpty) return false;

    // Basic validation - QR codes should contain at least 10 characters
    // and be in a valid format (base64 or similar)
    return qrCode.length >= 10;
  }

  /// Validate vehicle plate number format (Philippines)
  bool isValidVehiclePlate(String plate) {
    if (plate.isEmpty) return false;

    // Philippine plate format validation (simplified)
    final plateRegex = RegExp(r'^[A-Za-z]{2,3}\s?\d{3,4}$');

    return plateRegex.hasMatch(plate);
  }

  /// Validate person name
  bool isValidPersonName(String name) {
    if (name.isEmpty || name.length > 100) return false;

    // Allow letters, spaces, hyphens, and periods
    final nameRegex = RegExp(r'^[A-Za-z\s\-\.\']+$');

    return nameRegex.hasMatch(name);
  }

  /// Validate tenant ID format
  bool isValidTenantId(String tenantId) {
    if (tenantId.isEmpty) return false;

    // UUID format validation (simplified)
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    return uuidRegex.hasMatch(tenantId);
  }

  /// Validate guard ID format
  bool isValidGuardId(String guardId) {
    if (guardId.isEmpty) return false;

    // Similar to UUID validation for consistency
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    return uuidRegex.hasMatch(guardId);
  }

  // =============== Business Logic Validators ===============

  /// Validate entry log data
  ValidationResult validateEntryLog({
    required String tenantId,
    required String guardId,
    required String personName,
    required String accessType,
    required String verificationMethod,
    required String verificationResult,
    String? rfidCode,
    String? qrCode,
    String? vehiclePlate,
    String? destinationUnit,
  }) {
    final errors = <String>[];

    // Required field validations
    if (!isValidTenantId(tenantId)) {
      errors.add('Invalid tenant ID format');
    }

    if (!isValidGuardId(guardId)) {
      errors.add('Invalid guard ID format');
    }

    if (!isValidPersonName(personName)) {
      errors.add('Invalid person name format');
    }

    // Access type validation
    if (!['entry', 'exit'].contains(accessType)) {
      errors.add('Invalid access type. Must be "entry" or "exit"');
    }

    // Verification method validation
    if (!['rfid', 'nfc', 'qr', 'manual', 'face', 'fingerprint'].contains(verificationMethod)) {
      errors.add('Invalid verification method');
    }

    // Verification result validation
    if (!['granted', 'denied', 'pending'].contains(verificationResult)) {
      errors.add('Invalid verification result');
    }

    // Conditional validations
    if (verificationMethod == 'rfid' && (rfidCode == null || !isValidRfidCode(rfidCode!))) {
      errors.add('Invalid or missing RFID code for RFID verification');
    }

    if (verificationMethod == 'qr' && (qrCode == null || !isValidQrCode(qrCode!))) {
      errors.add('Invalid or missing QR code for QR verification');
    }

    if (vehiclePlate != null && !isValidVehiclePlate(vehiclePlate)) {
      errors.add('Invalid vehicle plate format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate guest registration data
  ValidationResult validateGuestRegistration({
    required String tenantId,
    required String hostName,
    required String guestName,
    required DateTime expectedArrival,
    required DateTime expectedDeparture,
    String? guestContact,
    String? visitPurpose,
    String? qrCode,
  }) {
    final errors = <String>[];

    // Required field validations
    if (!isValidTenantId(tenantId)) {
      errors.add('Invalid tenant ID format');
    }

    if (!isValidPersonName(hostName)) {
      errors.add('Invalid host name format');
    }

    if (!isValidPersonName(guestName)) {
      errors.add('Invalid guest name format');
    }

    // Date validations
    if (expectedDeparture.isBefore(expectedArrival)) {
      errors.add('Expected departure must be after expected arrival');
    }

    if (expectedArrival.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors.add('Expected arrival cannot be more than 1 day in the past');
    }

    if (expectedDeparture.isAfter(DateTime.now().add(const Duration(days: 30)))) {
      errors.add('Expected departure cannot be more than 30 days in the future');
    }

    // Optional field validations
    if (guestContact != null && !isValidPhoneNumber(guestContact)) {
      errors.add('Invalid guest contact phone number');
    }

    if (qrCode != null && !isValidQrCode(qrCode)) {
      errors.add('Invalid QR code format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate delivery log data
  ValidationResult validateDeliveryLog({
    required String tenantId,
    required String guardId,
    required String providerName,
    required String recipientName,
    String? providerType,
    String? trackingNumber,
    String? vehicleInfo,
  }) {
    final errors = <String>[];

    // Required field validations
    if (!isValidTenantId(tenantId)) {
      errors.add('Invalid tenant ID format');
    }

    if (!isValidGuardId(guardId)) {
      errors.add('Invalid guard ID format');
    }

    if (providerName.isEmpty || providerName.length > 100) {
      errors.add('Invalid provider name');
    }

    if (!isValidPersonName(recipientName)) {
      errors.add('Invalid recipient name format');
    }

    // Provider type validation
    if (providerType != null && !['delivery', 'service', 'maintenance', 'food', 'package', 'other'].contains(providerType)) {
      errors.add('Invalid provider type');
    }

    // Optional field validations
    if (vehicleInfo != null && !isValidVehiclePlate(vehicleInfo)) {
      errors.add('Invalid vehicle information/plate format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate incident report data
  ValidationResult validateIncidentReport({
    required String tenantId,
    required String guardId,
    required String incidentType,
    required String severity,
    required String title,
    required String description,
  }) {
    final errors = <String>[];

    // Required field validations
    if (!isValidTenantId(tenantId)) {
      errors.add('Invalid tenant ID format');
    }

    if (!isValidGuardId(guardId)) {
      errors.add('Invalid guard ID format');
    }

    // Incident type validation
    if (!['security_breach', 'theft', 'vandalism', 'accident', 'disturbance', 'unauthorized_access', 'suspicious_activity', 'other'].contains(incidentType)) {
      errors.add('Invalid incident type');
    }

    // Severity validation
    if (!['low', 'medium', 'high', 'critical'].contains(severity)) {
      errors.add('Invalid severity level');
    }

    // Text field validations
    if (title.isEmpty || title.length > 200) {
      errors.add('Title must be between 1 and 200 characters');
    }

    if (description.isEmpty || description.length > 2000) {
      errors.add('Description must be between 1 and 2000 characters');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // =============== Data Integrity Checks ===============

  /// Generate hash for data integrity verification
  String generateDataHash(Map<String, dynamic> data) {
    try {
      // Sort keys to ensure consistent hash generation
      final sortedData = Map.fromEntries(
        data.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );

      final jsonString = jsonEncode(sortedData);
      final bytes = utf8.encode(jsonString);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      _logger.e('Failed to generate data hash: $e');
      return '';
    }
  }

  /// Verify data integrity using hash comparison
  bool verifyDataIntegrity(Map<String, dynamic> data, String expectedHash) {
    try {
      final actualHash = generateDataHash(data);
      return actualHash == expectedHash;
    } catch (e) {
      _logger.e('Failed to verify data integrity: $e');
      return false;
    }
  }

  /// Validate database record integrity
  bool validateRecordIntegrity(dynamic record, {String? recordHash}) {
    if (recordHash == null) {
      _logger.w('No hash provided for integrity check');
      return true; // Skip integrity check if no hash provided
    }

    try {
      // Convert record to map for hash generation
      final recordMap = _recordToMap(record);
      return verifyDataIntegrity(recordMap, recordHash);
    } catch (e) {
      _logger.e('Failed to validate record integrity: $e');
      return false;
    }
  }

  /// Convert database record to map for hashing
  Map<String, dynamic> _recordToMap(dynamic record) {
    // This is a simplified implementation
    // In practice, you might need to handle different record types
    if (record is Map) {
      return Map<String, dynamic>.from(record);
    }

    // For Drift data classes, you would typically implement a toMap() method
    // or use reflection to extract field values

    try {
      // Try to convert using toString() and parse as JSON if possible
      final jsonString = record.toString();
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      _logger.e('Failed to convert record to map: $e');
      return {'error': 'Failed to convert record'};
    }
  }

  // =============== Validation Utilities ===============

  /// Check if string contains SQL injection patterns
  bool containsSqlInjection(String input) {
    if (input.isEmpty) return false;

    final sqlPatterns = [
      r"('|(\\-\\-)|(;)|(\\||)|(\\*|))",
      r"(\\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\\b)",
      r"(\\b(OR|AND)\\s+\\d+\\s*=\\s*\\d+)",
      r"(\\b(OR|AND)\\s+'[^']*'\\s*=\\s*'[^']*')",
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Sanitize string input by removing potentially dangerous characters
  String sanitizeString(String input) {
    if (input.isEmpty) return input;

    // Remove SQL injection patterns
    if (containsSqlInjection(input)) {
      _logger.w('Potential SQL injection detected and sanitized: $input');
    }

    // Remove dangerous characters but keep safe ones
    return input
        .replaceAll(RegExp(r"[;'\"]"), '')
        .replaceAll(RegExp(r"\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b", caseSensitive: false), "")
        .trim();
  }

  /// Validate and sanitize database query parameters
  Map<String, dynamic> validateAndSanitizeParameters(Map<String, dynamic> parameters) {
    final sanitizedParameters = <String, dynamic>{};

    for (final entry in parameters.entries) {
      final key = sanitizeString(entry.key);
      dynamic value = entry.value;

      if (value is String) {
        value = sanitizeString(value);
      }

      // Only add sanitized parameters that are still valid
      if (key.isNotEmpty && value != null) {
        sanitizedParameters[key] = value;
      }
    }

    return sanitizedParameters;
  }

  /// Validate data size limits
  bool validateDataSize(dynamic data, int maxSizeInBytes) {
    try {
      final serializedData = jsonEncode(data);
      final size = utf8.encode(serializedData).length;

      return size <= maxSizeInBytes;
    } catch (e) {
      _logger.e('Failed to validate data size: $e');
      return false;
    }
  }

  /// Get validation summary statistics
  Map<String, dynamic> getValidationStats() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'validationRules': {
        'email': 'Regex-based email validation',
        'phone': 'Philippine mobile number format (09XXX or +639XXX)',
        'rfid': '8-16 alphanumeric characters',
        'qrCode': 'Minimum 10 characters, base64 format preferred',
        'vehiclePlate': 'Philippine plate format (ABC 1234)',
        'personName': '1-100 characters, letters and basic punctuation only',
        'tenantId': 'UUID format',
        'guardId': 'UUID format',
      },
      'integrityChecks': {
        'dataHash': 'SHA-256 hash generation',
        'recordIntegrity': 'Hash-based verification',
        'sqlInjection': 'Pattern-based detection and sanitization',
        'dataSize': 'Configurable size limit validation',
      },
    };
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  /// Get first error message
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Get all error messages as string
  String get errorsString => errors.join('; ');

  /// Get all warning messages as string
  String get warningsString => warnings.join('; ');

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
  }
}

/// Validation exception
class ValidationException implements Exception {
  const ValidationException(this.message, {this.errors = const []});

  final String message;
  final List<String> errors;

  @override
  String toString() => 'ValidationException: $message${errors.isNotEmpty ? ' - ${errors.join(", ")}' : ""}';
}