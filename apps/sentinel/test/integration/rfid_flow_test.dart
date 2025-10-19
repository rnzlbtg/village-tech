import 'package:flutter_test/flutter_test.dart';

import 'package:sentinel/models/rfid_sticker.dart';
import 'package:sentinel/models/entry_log.dart';
import 'package:sentinel/models/rfid_scan_metric.dart';
import 'package:sentinel/services/rfid_error_handler.dart';

/// Integration tests for RFID flow
///
/// Tests the core RFID scanning workflow including:
/// - Data models and validation
/// - Error handling
/// - Performance targets
void main() {
  group('RFID Data Models', () {
    test('should create valid RFID sticker', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final sticker = RfidSticker(
        id: 'test-sticker-id',
        tenantId: 'test-tenant-id',
        stickerCode: 'RF123456789',
        residentId: 'test-resident-id',
        status: RfidStatus.active,
        issuedAt: now.subtract(const Duration(days: 30)),
        expiresAt: now.add(const Duration(days: 335)),
        vehicleInfo: 'Toyota Camry - ABC 1234',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      );

      // Assert
      expect(sticker.id, 'test-sticker-id');
      expect(sticker.stickerCode, 'RF123456789');
      expect(sticker.status, RfidStatus.active);
      expect(sticker.isValid, true);
      expect(sticker.isExpired, false);
      expect(sticker.isExpiringSoon, false);
      expect(sticker.vehicleInfo, 'Toyota Camry - ABC 1234');
    });

    test('should handle expired RFID sticker', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final sticker = RfidSticker(
        id: 'expired-sticker-id',
        tenantId: 'test-tenant-id',
        stickerCode: 'RF000000000',
        residentId: 'test-resident-id',
        status: RfidStatus.active,
        issuedAt: now.subtract(const Duration(days: 400)),
        expiresAt: now.subtract(const Duration(days: 50)),
        vehicleInfo: 'Honda Civic - XYZ 5678',
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now,
      );

      // Assert
      expect(sticker.isExpired, true);
      expect(sticker.isValid, false);
      expect(sticker.statusDisplayText, 'Expired');
    });

    test('should handle soon-to-expire RFID sticker', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final sticker = RfidSticker(
        id: 'expiring-soon-sticker-id',
        tenantId: 'test-tenant-id',
        stickerCode: 'RF111111111',
        residentId: 'test-resident-id',
        status: RfidStatus.active,
        issuedAt: now.subtract(const Duration(days: 350)),
        expiresAt: now.add(const Duration(days: 15)),
        vehicleInfo: 'Nissan Altima - GHI 9012',
        createdAt: now.subtract(const Duration(days: 350)),
        updatedAt: now,
      );

      // Assert
      expect(sticker.isExpiringSoon, true);
      expect(sticker.isValid, true);
      expect(sticker.daysUntilExpiration, 15);
    });

    test('should create RFID scan metric', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(seconds: 3));

      // Act
      final metric = RfidScanMetric.successful(
        rfidCode: 'RF123456789',
        startTime: startTime,
        endTime: endTime,
        scanMethod: 'nfc',
        additionalData: {
          'device': 'test-device',
          'location': 'gate-1',
        },
      );

      // Assert
      expect(metric.rfidCode, 'RF123456789');
      expect(metric.successful, true);
      expect(metric.scanDuration.inSeconds, 3);
      expect(metric.meetsPerformanceTarget, true);
      expect(metric.hasPerformanceIssue, false);
      expect(metric.scanMethod, 'nfc');
    });

    test('should detect performance issues in scan metric', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(seconds: 7));

      // Act
      final metric = RfidScanMetric.successful(
        rfidCode: 'RF000000000',
        startTime: startTime,
        endTime: endTime,
        scanMethod: 'nfc',
      );

      // Assert
      expect(metric.scanDuration.inSeconds, 7);
      expect(metric.meetsPerformanceTarget, false);
      expect(metric.hasCriticalPerformanceIssue, true);
      expect(metric.hasPerformanceWarning, false);
    });

    test('should create entry log with RFID data', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final entryLog = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.resident,
        personName: 'John Doe',
        destination: 'Unit 101',
        verificationMethod: VerificationMethod.rfid,
        verificationStatus: VerificationStatus.verified,
        rfidStickerId: 'test-sticker-id',
        vehicleInfo: 'Toyota Camry - ABC 1234',
      );

      // Assert
      expect(entryLog.id, isNotEmpty);
      expect(entryLog.tenantId, 'test-tenant-id');
      expect(entryLog.entryType, EntryType.resident);
      expect(entryLog.personName, 'John Doe');
      expect(entryLog.destination, 'Unit 101');
      expect(entryLog.verificationMethod, VerificationMethod.rfid);
      expect(entryLog.verificationStatus, VerificationStatus.verified);
      expect(entryLog.isActive, true);
      expect(entryLog.rfidStickerId, 'test-sticker-id');
    });

    test('should serialize and deserialize RFID sticker', () {
      // Arrange
      final originalSticker = _createTestRfidSticker();

      // Act
      final json = originalSticker.toJson();
      final deserializedSticker = RfidSticker.fromJson(json);

      // Assert
      expect(deserializedSticker.id, originalSticker.id);
      expect(deserializedSticker.stickerCode, originalSticker.stickerCode);
      expect(deserializedSticker.status, originalSticker.status);
      expect(deserializedSticker.vehicleInfo, originalSticker.vehicleInfo);
    });

    test('should calculate duration on site after exit', () {
      // Arrange
      final entryTime = DateTime.now().subtract(const Duration(hours: 2));
      final exitTime = DateTime.now();

      final entryLog = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.guest,
        personName: 'Jane Smith',
        destination: 'Unit 201',
        verificationMethod: VerificationMethod.manual,
        verificationStatus: VerificationStatus.verified,
      );

      // Act
      final updatedLog = entryLog.copyWith(entryTime: entryTime);
      final finalLog = updatedLog.recordExit();

      // Assert
      expect(finalLog.exitTime, isNotNull);
      expect(finalLog.durationOnSite, isNotNull);
      expect(finalLog.durationOnSite!.inHours, equals(2));
      expect(finalLog.isActive, false);
    });
  });

  group('Error Handling', () {
    test('should classify error severity correctly', () {
      // Arrange
      final errorHandler = RfidErrorHandler(
        performanceService: _createMockPerformanceService(),
      );

      // Act & Assert - NFC Not Available should be critical
      final nfcError = errorHandler.handleNfcUnavailable();
      expect(nfcError.severity, ErrorSeverity.critical);
      expect(nfcError.canRetry, false);

      // Act & Assert - Permission Denied should be high
      final permissionError = errorHandler.handleNfcPermissionDenied();
      expect(permissionError.severity, ErrorSeverity.high);
      expect(permissionError.canRetry, true);

      // Act & Assert - Timeout should be medium
      final timeoutError = errorHandler.handleScanTimeout(
        timeoutDuration: const Duration(seconds: 5),
      );
      expect(timeoutError.severity, ErrorSeverity.medium);
      expect(timeoutError.canRetry, true);
    });

    test('should generate appropriate user messages', () {
      // Arrange
      final errorHandler = RfidErrorHandler(
        performanceService: _createMockPerformanceService(),
      );

      // Act & Assert
      final nfcError = errorHandler.handleNfcUnavailable();
      expect(nfcError.userMessage, contains('NFC is not available'));

      final timeoutError = errorHandler.handleScanTimeout(
        timeoutDuration: const Duration(seconds: 5),
      );
      expect(timeoutError.userMessage, contains('Scan timed out'));

      final stickerNotFound = errorHandler.handleStickerNotFound(
        rfidCode: 'RF000000000',
      );
      expect(stickerNotFound.userMessage, contains('not found'));
    });

    test('should track error statistics', () {
      // Arrange
      final errorHandler = RfidErrorHandler(
        performanceService: _createMockPerformanceService(),
      );

      // Act
      errorHandler.handleNfcUnavailable();
      errorHandler.handleNfcUnavailable();
      errorHandler.handleScanTimeout(timeoutDuration: const Duration(seconds: 3));

      final stats = errorHandler.getErrorStatistics();

      // Assert
      expect(stats['totalErrors24h'], 3);
      expect(stats['uniqueErrorTypes'], 2);
      expect(stats['errorsByCode']['NFC_NOT_AVAILABLE'], 2);
      expect(stats['errorsByCode']['NFC_TIMEOUT'], 1);
    });

    test('should assess system health correctly', () {
      // Arrange
      final errorHandler = RfidErrorHandler(
        performanceService: _createMockPerformanceService(),
      );

      // Act & Assert - Healthy state
      expect(errorHandler.getSystemHealth(), RfidSystemHealth.healthy);

      // Simulate multiple errors
      for (int i = 0; i < 5; i++) {
        errorHandler.handleScanTimeout(timeoutDuration: const Duration(seconds: 1));
      }

      // Should still be healthy (under threshold)
      expect(errorHandler.getSystemHealth(), RfidSystemHealth.healthy);

      // Simulate many more errors
      for (int i = 0; i < 10; i++) {
        errorHandler.handleScanTimeout(timeoutDuration: const Duration(seconds: 1));
      }

      // Should be warning (between 5-20 errors per hour)
      expect(errorHandler.getSystemHealth(), RfidSystemHealth.warning);
    });
  });

  group('Performance Targets', () {
    test('should enforce 5-second scan time target', () {
      // Arrange
      final performanceService = _createMockPerformanceService();

      // Act & Assert
      expect(performanceService.meetsPerformanceTarget(const Duration(seconds: 3)), true);
      expect(performanceService.meetsPerformanceTarget(const Duration(seconds: 4)), true);
      expect(performanceService.meetsPerformanceTarget(const Duration(seconds: 5)), false);
      expect(performanceService.meetsPerformanceTarget(const Duration(seconds: 6)), false);
    });

    test('should validate entry data', () {
      // Arrange
      final validEntryLog = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.resident,
        personName: 'Valid Name',
        destination: 'Valid Destination',
        verificationMethod: VerificationMethod.rfid,
        verificationStatus: VerificationStatus.verified,
      );

      // Act & Assert
      expect(validEntryLog.isValidData(), true);

      // Test invalid data
      final invalidEntryLog = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.resident,
        personName: 'A', // Too short
        destination: 'Valid Destination',
        verificationMethod: VerificationMethod.rfid,
        verificationStatus: VerificationStatus.verified,
      );

      expect(invalidEntryLog.isValidData(), false);
    });

    test('should calculate risk levels correctly', () {
      // Arrange
      final deniedEntry = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.guest,
        personName: 'Test Person',
        destination: 'Test Destination',
        verificationMethod: VerificationMethod.manual,
        verificationStatus: VerificationStatus.denied,
      );

      final verifiedEntry = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.resident,
        personName: 'Test Person',
        destination: 'Test Destination',
        verificationMethod: VerificationMethod.rfid,
        verificationStatus: VerificationStatus.verified,
      );

      final constructionEntry = EntryLog.create(
        tenantId: 'test-tenant-id',
        guardId: 'test-guard-id',
        entryType: EntryType.construction,
        personName: 'Test Person',
        destination: 'Test Destination',
        verificationMethod: VerificationMethod.manual,
        verificationStatus: VerificationStatus.verified,
      );

      // Act & Assert
      expect(deniedEntry.getRiskLevel(), EntryRiskLevel.high);
      expect(verifiedEntry.getRiskLevel(), EntryRiskLevel.low);
      expect(constructionEntry.getRiskLevel(), EntryRiskLevel.medium);
    });
  });
}

// Helper functions

RfidSticker _createTestRfidSticker() {
  final now = DateTime.now();
  return RfidSticker(
    id: 'test-sticker-id',
    tenantId: 'test-tenant-id',
    stickerCode: 'RF123456789',
    residentId: 'test-resident-id',
    status: RfidStatus.active,
    issuedAt: now.subtract(const Duration(days: 30)),
    expiresAt: now.add(const Duration(days: 335)),
    vehicleInfo: 'Toyota Camry - ABC 1234',
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now,
  );
}

RfidPerformanceService _createMockPerformanceService() {
  // This is a simple mock implementation for testing
  // In a real scenario, you would use a proper mocking framework
  return RfidPerformanceService(
    supabaseService: _createMockSupabaseService(),
    cacheService: _createMockCacheService(),
  );
}

// Simple mock implementations for testing
class _MockSupabaseService {
  // Mock implementation placeholder
}

class _MockCacheService {
  // Mock implementation placeholder
}