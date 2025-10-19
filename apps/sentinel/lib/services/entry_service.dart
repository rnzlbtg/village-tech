import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/entry_log.dart';
import '../models/rfid_sticker.dart';
import '../models/guard.dart';
import '../models/guard_session.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';
import '../utils/constants.dart';

/// Entry logging result
class EntryLogResult {
  final bool success;
  final EntryLog? entryLog;
  final String? error;
  final String? message;

  const EntryLogResult({
    required this.success,
    this.entryLog,
    this.error,
    this.message,
  });

  factory EntryLogResult.success(EntryLog entryLog, {String? message}) {
    return EntryLogResult(
      success: true,
      entryLog: entryLog,
      message: message,
    );
  }

  factory EntryLogResult.error(String error, {String? message}) {
    return EntryLogResult(
      success: false,
      error: error,
      message: message,
    );
  }
}

/// Entry verification result
class EntryVerificationResult {
  final bool allowed;
  final String? reason;
  final RfidSticker? sticker;
  final Map<String, dynamic>? additionalData;

  const EntryVerificationResult({
    required this.allowed,
    this.reason,
    this.sticker,
    this.additionalData,
  });

  factory EntryVerificationResult.allowed({
    String? reason,
    RfidSticker? sticker,
    Map<String, dynamic>? additionalData,
  }) {
    return EntryVerificationResult(
      allowed: true,
      reason: reason,
      sticker: sticker,
      additionalData: additionalData,
    );
  }

  factory EntryVerificationResult.denied(String reason, {Map<String, dynamic>? additionalData}) {
    return EntryVerificationResult(
      allowed: false,
      reason: reason,
      additionalData: additionalData,
    );
  }
}

/// Entry logging service
class EntryService {
  final SupabaseService _supabaseService;
  final OfflineCacheService _cacheService;

  Guard? _currentGuard;
  String? _currentTenantId;

  EntryService({
    required SupabaseService supabaseService,
    required OfflineCacheService cacheService,
  }) : _supabaseService = supabaseService,
       _cacheService = cacheService;

  /// Set current guard context
  void setCurrentGuard(Guard guard, String tenantId) {
    _currentGuard = guard;
    _currentTenantId = tenantId;
  }

  /// Clear current guard context
  void clearCurrentGuard() {
    _currentGuard = null;
    _currentTenantId = null;
  }

  /// Verify RFID sticker for entry
  Future<EntryVerificationResult> verifyRfidEntry(String rfidCode) async {
    if (_currentGuard == null || _currentTenantId == null) {
      return EntryVerificationResult.denied('Guard not authenticated');
    }

    try {
      // Find sticker (offline first, then online)
      final sticker = await findStickerByCode(rfidCode);

      if (sticker == null) {
        return EntryVerificationResult.denied(
          'RFID sticker not found or inactive',
          additionalData: {'rfidCode': rfidCode},
        );
      }

      // Check if sticker is valid
      if (!sticker.isValid) {
        String reason;
        if (sticker.isExpired) {
          reason = 'RFID sticker expired on ${sticker.expiresAt}';
        } else if (sticker.status == RfidStatus.disabled) {
          reason = 'RFID sticker has been disabled';
        } else if (sticker.status == RfidStatus.lost) {
          reason = 'RFID sticker reported as lost';
        } else {
          reason = 'RFID sticker is not active';
        }

        return EntryVerificationResult.denied(
          reason,
          additionalData: {
            'sticker': sticker.toJson(),
            'status': sticker.status.toString(),
          },
        );
      }

      // Additional checks can be added here
      // - Check for duplicate entries
      // - Check time-based restrictions
      // - Check guard permissions

      return EntryVerificationResult.allowed(
        reason: 'RFID sticker verified successfully',
        sticker: sticker,
        additionalData: {
          'sticker': sticker.toJson(),
          'verifiedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return EntryVerificationResult.denied('Verification error: $e');
    }
  }

  /// Create entry log for resident entry
  Future<EntryLogResult> createResidentEntry({
    required RfidSticker sticker,
    required String destination,
    String? purpose,
    String? notes,
  }) async {
    if (_currentGuard == null || _currentTenantId == null) {
      return EntryLogResult.error('Guard not authenticated');
    }

    try {
      final entryLog = EntryLog.create(
        tenantId: _currentTenantId!,
        guardId: _currentGuard!.id,
        entryType: EntryType.resident,
        personName: 'Resident', // Will be updated with actual resident name
        vehicleInfo: sticker.vehicleInfo,
        rfidStickerId: sticker.id,
        destination: destination,
        purpose: purpose ?? 'Resident entry',
        verificationMethod: VerificationMethod.rfid,
        verificationStatus: VerificationStatus.verified,
        notes: notes,
        synced: false, // Will be synced when created online
      );

      // Try to create online first
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService.createEntryLog(entryLog);
        if (response.success && response.data != null) {
          // Cache the created entry
          await _cacheEntryLog(response.data!);

          return EntryLogResult.success(
            response.data!,
            message: 'Entry logged successfully online',
          );
        }
      }

      // Fallback to offline storage
      await _cacheEntryLog(entryLog);
      await _addPendingSyncOperation(entryLog);

      return EntryLogResult.success(
        entryLog,
        message: 'Entry logged successfully (offline)',
      );
    } catch (e) {
      return EntryLogResult.error('Failed to create entry log: $e');
    }
  }

  /// Create entry log for guest entry
  Future<EntryLogResult> createGuestEntry({
    required String guestName,
    required String destination,
    required String householdId,
    String? guestId,
    String? vehicleInfo,
    String? purpose,
    String? notes,
  }) async {
    if (_currentGuard == null || _currentTenantId == null) {
      return EntryLogResult.error('Guard not authenticated');
    }

    try {
      final entryLog = EntryLog.create(
        tenantId: _currentTenantId!,
        guardId: _currentGuard!.id,
        entryType: EntryType.guest,
        personName: guestName,
        vehicleInfo: vehicleInfo,
        guestId: guestId,
        destination: destination,
        purpose: purpose ?? 'Guest visit',
        verificationMethod: VerificationMethod.manual,
        verificationStatus: VerificationStatus.verified,
        notes: notes,
        synced: false,
      );

      // Try online first
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService.createEntryLog(entryLog);
        if (response.success && response.data != null) {
          await _cacheEntryLog(response.data!);
          return EntryLogResult.success(
            response.data!,
            message: 'Guest entry logged successfully online',
          );
        }
      }

      // Fallback to offline
      await _cacheEntryLog(entryLog);
      await _addPendingSyncOperation(entryLog);

      return EntryLogResult.success(
        entryLog,
        message: 'Guest entry logged successfully (offline)',
      );
    } catch (e) {
      return EntryLogResult.error('Failed to create guest entry: $e');
    }
  }

  /// Record exit for existing entry
  Future<EntryLogResult> recordEntryExit({
    required String entryLogId,
    String? notes,
  }) async {
    if (_currentGuard == null || _currentTenantId == null) {
      return EntryLogResult.error('Guard not authenticated');
    }

    try {
      // Find the entry log
      final existingEntry = await _findEntryLogById(entryLogId);
      if (existingEntry == null) {
        return EntryLogResult.error('Entry log not found');
      }

      // Record exit
      final updatedEntry = existingEntry.recordExit(notes: notes);

      // Try online first
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService.updateEntryLog(updatedEntry);
        if (response.success && response.data != null) {
          await _cacheEntryLog(response.data!);
          return EntryLogResult.success(
            response.data!,
            message: 'Exit recorded successfully online',
          );
        }
      }

      // Fallback to offline
      await _cacheEntryLog(updatedEntry);
      await _addPendingSyncOperation(updatedEntry);

      return EntryLogResult.success(
        updatedEntry,
        message: 'Exit recorded successfully (offline)',
      );
    } catch (e) {
      return EntryLogResult.error('Failed to record exit: $e');
    }
  }

  /// Get today's entries
  Future<List<EntryLog>> getTodayEntries({
    String? entryType,
    String? verificationStatus,
    int limit = 100,
  }) async {
    if (_currentTenantId == null) return [];

    try {
      // Try cache first
      final cachedEntries = await _cacheService.getCachedTodayEntries();
      if (cachedEntries != null) {
        return _filterEntries(cachedEntries, entryType, verificationStatus);
      }

      // Try online
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService.getTodayEntries(
          entryType: entryType,
          verificationStatus: verificationStatus,
          limit: limit,
        );

        if (response.success && response.data != null) {
          await _cacheService.cacheTodayEntries(response.data!);
          return response.data!;
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error getting today\'s entries: $e');
      return [];
    }
  }

  /// Get active entries (no exit time)
  Future<List<EntryLog>> getActiveEntries() async {
    if (_currentTenantId == null) return [];

    try {
      final todayEntries = await getTodayEntries();
      return todayEntries.where((entry) => entry.isActive).toList();
    } catch (e) {
      debugPrint('Error getting active entries: $e');
      return [];
    }
  }

  /// Get entry statistics
  Future<Map<String, dynamic>> getEntryStatistics() async {
    try {
      final todayEntries = await getTodayEntries();
      final activeEntries = todayEntries.where((e) => e.isActive).toList();

      final entriesByType = <String, int>{};
      final entriesByStatus = <String, int>{};

      for (final entry in todayEntries) {
        // Count by type
        final type = entry.entryType.toString();
        entriesByType[type] = (entriesByType[type] ?? 0) + 1;

        // Count by status
        final status = entry.verificationStatus.toString();
        entriesByStatus[status] = (entriesByStatus[status] ?? 0) + 1;
      }

      return {
        'totalToday': todayEntries.length,
        'activeNow': activeEntries.length,
        'entriesByType': entriesByType,
        'entriesByStatus': entriesByStatus,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalToday': 0,
        'activeNow': 0,
        'entriesByType': <String, int>{},
        'entriesByStatus': <String, int>{},
      };
    }
  }

  /// Find RFID sticker by code (offline first, then online)
  Future<RfidSticker?> findStickerByCode(String rfidCode) async {
    try {
      // Try cache first
      final cachedSticker = await _cacheService.findRfidStickerByCode(rfidCode);
      if (cachedSticker != null && cachedSticker.isValid) {
        return cachedSticker;
      }

      // Try online if available
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService.verifyRfidSticker(rfidCode);
        if (response.success && response.data != null) {
          // Cache the result
          await _cacheSticker(response.data!);
          return response.data!;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error finding sticker by code: $e');
      return null;
    }
  }

  /// Find entry log by ID
  Future<EntryLog?> _findEntryLogById(String entryLogId) async {
    try {
      // Try cache first
      final cachedEntries = await _cacheService.getCachedEntryLogs();
      if (cachedEntries != null) {
        final entry = cachedEntries.firstWhere(
          (e) => e.id == entryLogId,
          orElse: () => EntryLog.create(
            tenantId: _currentTenantId!,
            guardId: _currentGuard!.id,
            entryType: EntryType.resident,
            personName: '',
            destination: '',
            verificationMethod: VerificationMethod.manual,
            verificationStatus: VerificationStatus.pending,
          ),
        );
        if (entry.id != entryLogId) return entry;
      }

      // Try online
      if (_supabaseService.isInitialized) {
        // TODO: Implement get entry by ID in SupabaseService
        // For now, return null
        return null;
      }

      return null;
    } catch (e) {
      debugPrint('Error finding entry log by ID: $e');
      return null;
    }
  }

  /// Cache entry log
  Future<void> _cacheEntryLog(EntryLog entryLog) async {
    try {
      // Get existing entries
      final existingEntries = await _cacheService.getCachedEntryLogs() ?? [];

      // Update or add the entry
      final updatedEntries = <EntryLog>[...existingEntries];
      final existingIndex = updatedEntries.indexWhere((e) => e.id == entryLog.id);

      if (existingIndex >= 0) {
        updatedEntries[existingIndex] = entryLog;
      } else {
        updatedEntries.add(entryLog);
      }

      // Limit to recent entries
      if (updatedEntries.length > 1000) {
        updatedEntries.removeRange(0, updatedEntries.length - 1000);
      }

      await _cacheService.cacheEntryLogs(updatedEntries);
    } catch (e) {
      debugPrint('Error caching entry log: $e');
    }
  }

  /// Cache RFID sticker
  Future<void> _cacheSticker(RfidSticker sticker) async {
    try {
      final existingStickers = await _cacheService.getCachedRfidStickers() ?? [];

      final updatedStickers = <RfidSticker>[...existingStickers];
      final existingIndex = updatedStickers.indexWhere((s) => s.id == sticker.id);

      if (existingIndex >= 0) {
        updatedStickers[existingIndex] = sticker;
      } else {
        updatedStickers.add(sticker);
      }

      await _cacheService.cacheRfidStickers(updatedStickers);
    } catch (e) {
      debugPrint('Error caching sticker: $e');
    }
  }

  /// Add pending sync operation
  Future<void> _addPendingSyncOperation(EntryLog entryLog) async {
    try {
      final operation = {
        'id': Uuid().v4(),
        'operation': 'CREATE',
        'entity_type': 'entry_log',
        'entity_id': entryLog.id,
        'payload': entryLog.toJson(),
        'priority': 'normal',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _cacheService.addPendingSyncOperation(operation);
    } catch (e) {
      debugPrint('Error adding pending sync operation: $e');
    }
  }

  /// Filter entries by type and status
  List<EntryLog> _filterEntries(
    List<EntryLog> entries,
    String? entryType,
    String? verificationStatus,
  ) {
    var filtered = entries;

    if (entryType != null) {
      filtered = filtered.where((e) => e.entryType.toString() == entryType).toList();
    }

    if (verificationStatus != null) {
      filtered = filtered.where((e) => e.verificationStatus.toString() == verificationStatus).toList();
    }

    return filtered;
  }

  /// Validate entry data
  bool validateEntryData({
    required String personName,
    required String destination,
    String? notes,
  }) {
    // Validate person name
    if (personName.trim().isEmpty || personName.trim().length < 2) {
      return false;
    }
    if (personName.trim().length > 100) {
      return false;
    }

    // Validate destination
    if (destination.trim().isEmpty || destination.trim().length < 2) {
      return false;
    }
    if (destination.trim().length > 200) {
      return false;
    }

    // Validate notes (optional)
    if (notes != null && notes.trim().length > 1000) {
      return false;
    }

    return true;
  }
}