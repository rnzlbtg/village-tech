import '../entities/rfid_sticker.dart';
import '../entities/entry_log.dart';
import '../repositories/rfid_repository.dart';

/// Validate RFID Use Case
/// Handles the business logic for validating RFID stickers and creating entry logs
///
/// This use case implements the core RFID verification workflow:
/// 1. Validate the RFID sticker against backend
/// 2. Check expiration and status
/// 3. Create appropriate entry log
/// 4. Handle offline scenarios gracefully
class ValidateRfidUseCase {
  ValidateRfidUseCase(this._repository);

  final RfidRepository _repository;

  /// Validate an RFID sticker and create an entry log
  ///
  /// [params] - Parameters for RFID validation
  ///
  /// Returns [ValidateRfidResult] with validation outcome and entry log
  ///
  /// Throws [ValidationException] when validation encounters critical errors
  /// Throws [NetworkException] when network connectivity fails completely
  /// Throws [DatabaseException] when local database operations fail
  Future<ValidateRfidResult> execute(ValidateRfidParams params) async {
    try {
      // Step 1: Validate RFID sticker
      final validationResult = await _repository.validateRfidSticker(
        params.stickerCode,
        params.tenantId,
      );

      // Step 2: Create entry log based on validation result
      final entryLog = await _createEntryLog(
        params,
        validationResult,
      );

      // Step 3: Log the entry (offline-first)
      final loggedEntry = await _repository.logRfidEntry(
        entryLog,
        isOffline: params.isOffline,
      );

      // Step 4: Return combined result
      return ValidateRfidResult(
        validation: validationResult,
        entryLog: loggedEntry,
        timestamp: DateTime.now(),
        success: validationResult.isValid,
      );

    } catch (e) {
      // Handle validation failures and create failure result
      final errorEntryLog = await _createFailureEntryLog(
        params,
        e.toString(),
      );

      return ValidateRfidResult(
        validation: RfidStickerValidationResult(
          isValid: false,
          reason: e.toString(),
        ),
        entryLog: await _repository.logRfidEntry(
          errorEntryLog,
          isOffline: true, // Always log failures locally
        ),
        timestamp: DateTime.now(),
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Batch validate multiple RFID stickers
  ///
  /// [stickerCodes] - List of sticker codes to validate
  /// [tenantId] - Tenant ID for multi-tenant isolation
  /// [guardId] - ID of the guard performing validation
  ///
  /// Returns a map of sticker code to validation result
  Future<Map<String, ValidateRfidResult>> batchValidate(
    List<String> stickerCodes,
    String tenantId,
    String guardId,
  ) async {
    final results = <String, ValidateRfidResult>{};

    for (final stickerCode in stickerCodes) {
      try {
        final params = ValidateRfidParams(
          stickerCode: stickerCode,
          tenantId: tenantId,
          guardId: guardId,
        );
        results[stickerCode] = await execute(params);
      } catch (e) {
        results[stickerCode] = ValidateRfidResult(
          validation: RfidStickerValidationResult(
            isValid: false,
            reason: e.toString(),
          ),
          entryLog: null,
          timestamp: DateTime.now(),
          success: false,
          error: e.toString(),
        );
      }
    }

    return results;
  }

  /// Check if RFID validation is available
  ///
  /// Returns true if the system can perform RFID validation
  Future<bool> isValidationAvailable() async {
    try {
      // This could check network connectivity, cache status, etc.
      final syncStatus = await _repository.getSyncQueueStatus();
      return syncStatus.totalItems < 1000; // Example threshold
    } catch (e) {
      return false;
    }
  }

  /// Get validation statistics for reporting
  ///
  /// [tenantId] - Tenant ID for multi-tenant isolation
  /// [startDate] - Optional start date for statistics
  /// [endDate] - Optional end date for statistics
  ///
  /// Returns validation statistics
  Future<ValidationStatistics> getValidationStatistics({
    required String tenantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final entryLogs = await _repository.getEntryLogs(
        filters: EntryLogFilters(
          entryType: EntryType.resident,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      final totalValidations = entryLogs.length;
      final grantedEntries = entryLogs.where((log) => log.isGranted).length;
      final deniedEntries = entryLogs.where((log) => log.isDenied).length;
      final rfidValidations = entryLogs
          .where((log) => log.verificationMethod == VerificationMethod.rfid)
          .length;

      return ValidationStatistics(
        totalValidations: totalValidations,
        grantedEntries: grantedEntries,
        deniedEntries: deniedEntries,
        rfidValidations: rfidValidations,
        grantRate: totalValidations > 0 ? (grantedEntries / totalValidations) * 100 : 0.0,
        period: ValidationPeriod(
          startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          endDate: endDate ?? DateTime.now(),
        ),
      );
    } catch (e) {
      return ValidationStatistics(
        totalValidations: 0,
        grantedEntries: 0,
        deniedEntries: 0,
        rfidValidations: 0,
        grantRate: 0.0,
        period: ValidationPeriod(
          startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          endDate: endDate ?? DateTime.now(),
        ),
        error: e.toString(),
      );
    }
  }

  /// Create entry log based on validation result
  Future<EntryLog> _createEntryLog(
    ValidateRfidParams params,
    RfidStickerValidationResult validation,
  ) async {
    return EntryLog(
      id: '', // Will be assigned by repository
      tenantId: params.tenantId,
      guardId: params.guardId,
      entryType: EntryType.resident,
      timestamp: DateTime.now(),
      verificationMethod: VerificationMethod.rfid,
      verificationStatus: validation.isValid
          ? VerificationStatus.granted
          : VerificationStatus.denied,
      vehicleInfo: validation.sticker != null
          ? {
              'plate': validation.sticker!.vehiclePlate,
              'make': validation.sticker!.vehicleMake,
              'sticker_code': validation.sticker!.stickerCode,
            }
          : null,
      personInfo: validation.householdInfo != null
        ? Map.fromEntries(
            validation.householdInfo!.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value!)),
          )
        : null,
      denialReason: validation.reason,
      notes: validation.isValid ? 'RFID validation successful' : 'RFID validation failed',
    );
  }

  /// Create failure entry log for error cases
  Future<EntryLog> _createFailureEntryLog(
    ValidateRfidParams params,
    String error,
  ) async {
    return EntryLog(
      id: '', // Will be assigned by repository
      tenantId: params.tenantId,
      guardId: params.guardId,
      entryType: EntryType.resident,
      timestamp: DateTime.now(),
      verificationMethod: VerificationMethod.rfid,
      verificationStatus: VerificationStatus.denied,
      vehicleInfo: {'sticker_code': params.stickerCode},
      denialReason: error,
      notes: 'RFID validation error',
      synced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Parameters for RFID validation
class ValidateRfidParams {
  const ValidateRfidParams({
    required this.stickerCode,
    required this.tenantId,
    required this.guardId,
    this.isOffline = false,
    this.vehicleInfo,
    this.personInfo,
  });

  /// RFID sticker code to validate
  final String stickerCode;

  /// Tenant ID for multi-tenant isolation
  final String tenantId;

  /// ID of the guard performing validation
  final String guardId;

  /// Whether validation is happening offline
  final bool isOffline;

  /// Additional vehicle information
  final Map<String, String>? vehicleInfo;

  /// Additional person information
  final Map<String, String>? personInfo;
}

/// Result of RFID validation with entry log
class ValidateRfidResult {
  const ValidateRfidResult({
    required this.validation,
    required this.entryLog,
    required this.timestamp,
    required this.success,
    this.error,
  });

  /// RFID sticker validation result
  final RfidStickerValidationResult validation;

  /// Entry log that was created
  final EntryLog? entryLog;

  /// Timestamp of the validation
  final DateTime timestamp;

  /// Whether the validation was successful
  final bool success;

  /// Error message if validation failed
  final String? error;

  /// Whether entry was granted
  bool get isEntryGranted => validation.isValid;

  /// Sticker information if available
  RfidSticker? get sticker => validation.sticker;

  /// Reason for validation result
  String? get reason => validation.reason;

  @override
  String toString() {
    return 'ValidateRfidResult('
        'success: $success, '
        'isValid: $isEntryGranted, '
        'sticker: ${sticker?.stickerCode ?? "null"}, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Validation statistics for reporting
class ValidationStatistics {
  const ValidationStatistics({
    required this.totalValidations,
    required this.grantedEntries,
    required this.deniedEntries,
    required this.rfidValidations,
    required this.grantRate,
    required this.period,
    this.error,
  });

  /// Total number of validations performed
  final int totalValidations;

  /// Number of entries that were granted
  final int grantedEntries;

  /// Number of entries that were denied
  final int deniedEntries;

  /// Number of RFID validations performed
  final int rfidValidations;

  /// Percentage of entries that were granted
  final double grantRate;

  /// Time period for these statistics
  final ValidationPeriod period;

  /// Error if statistics couldn't be retrieved
  final String? error;

  /// Whether statistics are available
  bool get isAvailable => error == null;

  @override
  String toString() {
    return 'ValidationStatistics('
        'total: $totalValidations, '
        'granted: $grantedEntries (${grantRate.toStringAsFixed(1)}%), '
        'denied: $deniedEntries, '
        'rfid: $rfidValidations'
        ')';
  }
}

/// Validation period for statistics
class ValidationPeriod {
  const ValidationPeriod({
    required this.startDate,
    required this.endDate,
  });

  /// Start date of the period
  final DateTime startDate;

  /// End date of the period
  final DateTime endDate;

  /// Duration of the period
  Duration get duration => endDate.difference(startDate);

  @override
  String toString() {
    return 'ValidationPeriod(${startDate.toIso8601String()} to ${endDate.toIso8601String()})';
  }
}