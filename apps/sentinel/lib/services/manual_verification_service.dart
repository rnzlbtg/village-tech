import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/guard.dart';
import '../models/rfid_sticker.dart';
import '../models/entry_log.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';
import '../services/entry_service.dart';

/// Manual search result
class ManualSearchResult {
  final String id;
  final String name;
  final String address;
  final String? vehicleInfo;
  final String? rfidCode;
  final String? residentId;
  final DateTime lastEntry;
  final String? householdId;
  final Map<String, dynamic>? additionalInfo;

  const ManualSearchResult({
    required this.id,
    required this.name,
    required this.address,
    this.vehicleInfo,
    this.rfidCode,
    this.residentId,
    required this.lastEntry,
    this.householdId,
    this.additionalInfo,
  });

  factory ManualSearchResult.fromJson(Map<String, dynamic> json) {
    return ManualSearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      vehicleInfo: json['vehicle_info'] as String?,
      rfidCode: json['rfid_code'] as String?,
      residentId: json['resident_id'] as String?,
      lastEntry: DateTime.parse(json['last_entry'] as String),
      householdId: json['household_id'] as String?,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'vehicle_info': vehicleInfo,
      'rfid_code': rfidCode,
      'resident_id': residentId,
      'last_entry': lastEntry.toIso8601String(),
      'household_id': householdId,
      'additional_info': additionalInfo,
    };
  }
}

/// Manual verification service
class ManualVerificationService {
  final SupabaseService _supabaseService;
  final OfflineCacheService _cacheService;
  final EntryService _entryService;

  Guard? _currentGuard;
  String? _currentTenantId;

  ManualVerificationService({
    required SupabaseService supabaseService,
    required OfflineCacheService cacheService,
    required EntryService entryService,
  }) : _supabaseService = supabaseService,
       _cacheService = cacheService,
       _entryService = entryService;

  /// Set current guard context
  void setCurrentGuard(Guard guard, String tenantId) {
    _currentGuard = guard;
    _currentTenantId = tenantId;
    _entryService.setCurrentGuard(guard, tenantId);
  }

  /// Search residents by various criteria
  Future<List<ManualSearchResult>> searchResidents({
    required String query,
    String? householdId,
    bool includeOnlyActive = true,
    int limit = 20,
  }) async {
    if (_currentGuard == null || _currentTenantId == null) {
      throw Exception('Guard not authenticated');
    }

    try {
      // Try online search first
      if (_supabaseService.isInitialized) {
        final results = await _searchResidentsOnline(
          query: query,
          householdId: householdId,
          includeOnlyActive: includeOnlyActive,
          limit: limit,
        );
        if (results.isNotEmpty) {
          return results;
        }
      }

      // Fallback to offline/mock search
      return _searchResidentsOffline(query, limit);
    } catch (e) {
      debugPrint('Error searching residents: $e');
      return _searchResidentsOffline(query, limit);
    }
  }

  /// Search residents online (mock implementation)
  Future<List<ManualSearchResult>> _searchResidentsOnline({
    required String query,
    String? householdId,
    bool includeOnlyActive = true,
    int limit = 20,
  }) async {
    // TODO: Implement actual Supabase search
    // For now, return mock results that match the query
    final mockResults = _generateMockResults();

    return mockResults.where((result) {
      bool matches = result.name.toLowerCase().contains(query.toLowerCase()) ||
          result.address.toLowerCase().contains(query.toLowerCase());

      if (householdId != null) {
        matches = matches && result.householdId == householdId;
      }

      return matches;
    }).take(limit).toList();
  }

  /// Search residents offline (mock implementation)
  List<ManualSearchResult> _searchResidentsOffline(String query, int limit) {
    final mockResults = _generateMockResults();

    return mockResults.where((result) {
      return result.name.toLowerCase().contains(query.toLowerCase()) ||
          result.address.toLowerCase().contains(query.toLowerCase()) ||
          (result.vehicleInfo?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).take(limit).toList();
  }

  /// Generate mock search results for demonstration
  List<ManualSearchResult> _generateMockResults() {
    final now = DateTime.now();

    return [
      ManualSearchResult(
        id: '1',
        name: 'John Smith',
        address: '123 Main Street, Unit 4A',
        vehicleInfo: 'Toyota Camry - ABC 1234',
        rfidCode: 'RF001234',
        residentId: 'RES001',
        lastEntry: now.subtract(const Duration(hours: 2)),
        householdId: 'HH001',
        additionalInfo: {
          'phone': '+1-555-0123',
          'email': 'john.smith@email.com',
          'members': 4,
        },
      ),
      ManualSearchResult(
        id: '2',
        name: 'Jane Doe',
        address: '123 Main Street, Unit 2B',
        vehicleInfo: 'Honda Civic - XYZ 5678',
        rfidCode: 'RF005678',
        residentId: 'RES002',
        lastEntry: now.subtract(const Duration(days: 1)),
        householdId: 'HH002',
        additionalInfo: {
          'phone': '+1-555-0456',
          'email': 'jane.doe@email.com',
          'members': 2,
        },
      ),
      ManualSearchResult(
        id: '3',
        name: 'Robert Johnson',
        address: '456 Oak Avenue, House 15',
        vehicleInfo: 'Ford Explorer - DEF 9012',
        rfidCode: 'RF009012',
        residentId: 'RES003',
        lastEntry: now.subtract(const Duration(hours: 6)),
        householdId: 'HH003',
        additionalInfo: {
          'phone': '+1-555-0789',
          'email': 'robert.j@email.com',
          'members': 5,
        },
      ),
      ManualSearchResult(
        id: '4',
        name: 'Maria Garcia',
        address: '789 Pine Road, Unit 7C',
        vehicleInfo: 'Nissan Altima - GHI 3456',
        rfidCode: 'RF003456',
        residentId: 'RES004',
        lastEntry: now.subtract(const Duration(hours: 1)),
        householdId: 'HH004',
        additionalInfo: {
          'phone': '+1-555-0234',
          'email': 'maria.g@email.com',
          'members': 3,
        },
      ),
      ManualSearchResult(
        id: '5',
        name: 'David Wilson',
        address: '321 Elm Street, Unit 1A',
        vehicleInfo: 'BMW X5 - JKL 7890',
        rfidCode: 'RF007890',
        residentId: 'RES005',
        lastEntry: now.subtract(const Duration(minutes: 30)),
        householdId: 'HH005',
        additionalInfo: {
          'phone': '+1-555-0567',
          'email': 'david.w@email.com',
          'members': 2,
        },
      ),
    ];
  }

  /// Verify resident manually
  Future<ManualVerificationResult> verifyResident({
    required ManualSearchResult resident,
    required String destination,
    String? purpose,
    String? verificationMethod = 'phone_call',
    String? notes,
  }) async {
    if (_currentGuard == null || _currentTenantId == null) {
      return ManualVerificationResult.error('Guard not authenticated');
    }

    try {
      // Create entry log for manually verified resident
      final entryResult = await _entryService.createGuestEntry(
        guestName: resident.name,
        destination: destination,
        householdId: resident.householdId ?? '',
        guestId: resident.residentId,
        vehicleInfo: resident.vehicleInfo,
        purpose: purpose ?? 'Manual verification',
        notes: 'Verified manually by guard${notes != null ? ': $notes' : ''}',
      );

      if (entryResult.success) {
        return ManualVerificationResult.success(
          entryLog: entryResult.entryLog!,
          message: 'Resident verified and entry logged successfully',
        );
      } else {
        return ManualVerificationResult.error(
          entryResult.error ?? 'Failed to log entry',
        );
      }
    } catch (e) {
      return ManualVerificationResult.error('Verification error: $e');
    }
  }

  /// Get resident by RFID code
  Future<ManualSearchResult?> getResidentByRfidCode(String rfidCode) async {
    try {
      // First, try to find RFID sticker
      final sticker = await _entryService.findStickerByCode(rfidCode);

      if (sticker != null) {
        // Find resident associated with this sticker
        final searchResults = await searchResidents(
          query: sticker.residentId,
          limit: 1,
        );

        if (searchResults.isNotEmpty) {
          return searchResults.first;
        }
      }

      // If no sticker found or no resident association, search by RFID code
      final searchResults = await searchResidents(
        query: rfidCode,
        limit: 1,
      );

      return searchResults.isNotEmpty ? searchResults.first : null;
    } catch (e) {
      debugPrint('Error getting resident by RFID code: $e');
      return null;
    }
  }

  /// Get recent entries for verification history
  Future<List<EntryLog>> getRecentEntries({int limit = 10}) async {
    if (_currentTenantId == null) return [];

    try {
      return await _entryService.getTodayEntries(limit: limit);
    } catch (e) {
      debugPrint('Error getting recent entries: $e');
      return [];
    }
  }

  /// Get household members
  Future<List<ManualSearchResult>> getHouseholdMembers(String householdId) async {
    try {
      return await searchResidents(
        query: '',
        householdId: householdId,
        limit: 10,
      );
    } catch (e) {
      debugPrint('Error getting household members: $e');
      return [];
    }
  }

  /// Search by phone number
  Future<List<ManualSearchResult>> searchByPhone(String phoneNumber) async {
    try {
      // Search through all residents for matching phone numbers
      final allResidents = await searchResidents(query: '', limit: 100);

      return allResidents.where((resident) {
        final phone = resident.additionalInfo?['phone'] as String?;
        return phone?.contains(phoneNumber) ?? false;
      }).toList();
    } catch (e) {
      debugPrint('Error searching by phone: $e');
      return [];
    }
  }

  /// Get verification statistics
  Future<Map<String, dynamic>> getVerificationStatistics() async {
    try {
      final recentEntries = await getRecentEntries(limit: 100);
      final todayEntries = await _entryService.getTodayEntries();

      final manualVerifications = todayEntries
          .where((e) => e.verificationMethod == VerificationMethod.manual)
          .length;

      final phoneVerifications = todayEntries
          .where((e) => e.verificationMethod == VerificationMethod.phoneCall)
          .length;

      final todayTotal = todayEntries.length;

      return {
        'totalToday': todayTotal,
        'manualVerifications': manualVerifications,
        'phoneVerifications': phoneVerifications,
        'rfidVerifications': todayTotal - manualVerifications - phoneVerifications,
        'recentCount': recentEntries.length,
        'verificationMethods': {
          'rfid': todayTotal - manualVerifications - phoneVerifications,
          'manual': manualVerifications,
          'phone_call': phoneVerifications,
          'permit': 0, // TODO: Add when construction permits are implemented
        },
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalToday': 0,
        'manualVerifications': 0,
        'phoneVerifications': 0,
        'rfidVerifications': 0,
        'recentCount': 0,
        'verificationMethods': {},
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Validate search query
  bool validateSearchQuery(String query) {
    if (query.trim().isEmpty) return false;
    if (query.trim().length < 2) return false;
    if (query.trim().length > 100) return false;

    // Basic validation - no special characters that might cause issues
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-#,.]+$');
    return validPattern.hasMatch(query);
  }

  /// Format resident name for display
  String formatResidentName(String name) {
    // Basic name formatting
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Format address for display
  String formatAddress(String address) {
    return address.trim();
  }

  /// Check if resident entry should be verified (business rules)
  bool shouldVerifyResident(ManualSearchResult resident) {
    final now = DateTime.now();
    final timeSinceLastEntry = now.difference(resident.lastEntry);

    // Don't verify if entry was very recent (within 5 minutes)
    if (timeSinceLastEntry.inMinutes < 5) {
      return false;
    }

    // Always verify manual entries
    return true;
  }

  /// Get suggested verification method based on context
  VerificationMethod getSuggestedVerificationMethod({
    bool hasRfid = false,
    bool hasPhoneContact = true,
    bool isAfterHours = false,
  }) {
    // Priority order for verification methods
    if (hasRfid) {
      return VerificationMethod.rfid;
    } else if (hasPhoneContact && !isAfterHours) {
      return VerificationMethod.phoneCall;
    } else {
      return VerificationMethod.manual;
    }
  }
}

/// Manual verification result
class ManualVerificationResult {
  final bool success;
  final EntryLog? entryLog;
  final String? error;
  final String? message;

  const ManualVerificationResult({
    required this.success,
    this.entryLog,
    this.error,
    this.message,
  });

  factory ManualVerificationResult.success({
    required EntryLog entryLog,
    String? message,
  }) {
    return ManualVerificationResult(
      success: true,
      entryLog: entryLog,
      message: message,
    );
  }

  factory ManualVerificationResult.error(String error, {String? message}) {
    return ManualVerificationResult(
      success: false,
      error: error,
      message: message,
    );
  }
}