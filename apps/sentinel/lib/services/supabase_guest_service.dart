import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guest.dart';

/// Service for managing guest data with Supabase backend
class SupabaseGuestService {
  final SupabaseClient _supabase;
  final String _tableName = 'guests';

  SupabaseGuestService(this._supabase);

  /// Get all guests for the current tenant
  Future<List<Guest>> getGuests() async {
    try {
      // DEBUG: Print authentication details
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        print('🔍 DEBUG: Current User Info:');
        print('   User ID: ${currentUser.id}');
        print('   Email: ${currentUser.email}');
        print('   User Metadata: ${currentUser.userMetadata}');
        print('   Tenant ID from JWT: ${currentUser.userMetadata?['tenant_id']}');
      } else {
        print('🔍 DEBUG: No authenticated user found!');
      }

      // Use the guest_dashboard view for better debugging and performance
      print('🔍 DEBUG: Querying guest_dashboard view...');
      final response = await _supabase
          .from('guest_dashboard')
          .select('*')
          .order('visit_start', ascending: false);

      print('🔍 DEBUG: Guest dashboard query returned ${response.length} results');
      if (response.isNotEmpty) {
        final firstGuest = response.first;
        print('🔍 DEBUG: First guest - ${firstGuest['guest_name']} (tenant: ${firstGuest['tenant_id']})');
      }

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('🔍 DEBUG: Guest dashboard view failed: $e');

      // Fallback to direct table query if view fails
      try {
        print('🔍 DEBUG: Trying direct table query...');
        final response = await _supabase
            .from(_tableName)
            .select('*')
            .order('created_at', ascending: false);

        print('🔍 DEBUG: Direct table query returned ${response.length} results');
        if (response.isNotEmpty) {
          final firstGuest = response.first;
          print('🔍 DEBUG: First guest from direct query - ${firstGuest['guest_name']} (tenant: ${firstGuest['tenant_id']})');
        }

        return (response as List)
            .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
            .toList();
      } catch (fallbackError) {
        print('🔍 DEBUG: Both queries failed!');
        print('   View error: $e');
        print('   Direct error: $fallbackError');
        throw Exception('Failed to fetch guests: $e (fallback error: $fallbackError)');
      }
    }
  }

  /// Get guests by status
  Future<List<Guest>> getGuestsByStatus(GuestStatus status) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('status', _mapStatusToDb(status))
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch guests by status: $e');
    }
  }

  /// Get guests for a specific household
  Future<List<Guest>> getGuestsByHousehold(String householdId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('household_id', householdId)
          .order('visit_start', ascending: true);

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch household guests: $e');
    }
  }

  /// Get today's guests
  Future<List<Guest>> getTodayGuests() async {
    try {
      print('🔍 DEBUG: getTodayGuests() method called!');

      // DEBUG: Print authentication details
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        print('🔍 DEBUG: getTodayGuests - Current User Info:');
        print('   User ID: ${currentUser.id}');
        print('   Email: ${currentUser.email}');
        print('   User Metadata: ${currentUser.userMetadata}');
        print('   Tenant ID from JWT: ${currentUser.userMetadata?['tenant_id']}');
        print('   App Metadata: ${currentUser.appMetadata}');
        print('   Tenant ID from App Metadata: ${currentUser.appMetadata?['tenant_id']}');
      } else {
        print('🔍 DEBUG: getTodayGuests - No authenticated user found!');
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      print('🔍 DEBUG: getTodayGuests - Query params:');
      print('   Today: $today');
      print('   Start of day: $startOfDay');
      print('   End of day: $endOfDay');
      print('   Start ISO: ${startOfDay.toIso8601String()}');
      print('   End ISO: ${endOfDay.toIso8601String()}');

      print('🔍 DEBUG: getTodayGuests - Querying guests table...');
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .gte('visit_start', startOfDay.toIso8601String())
          .lt('visit_start', endOfDay.toIso8601String())
          .order('visit_start', ascending: true);

      print('🔍 DEBUG: getTodayGuests - Query returned ${response.length} results');

      // Also try a broader query to see if any guests exist
      print('🔍 DEBUG: getTodayGuests - Testing broader query...');
      final allGuestsResponse = await _supabase
          .from(_tableName)
          .select('id, guest_name, tenant_id, visit_start')
          .limit(5);

      print('🔍 DEBUG: getTodayGuests - Broad query returned ${allGuestsResponse.length} results');
      for (var guest in allGuestsResponse) {
        print('   - ${guest['guest_name']} (tenant: ${guest['tenant_id']}, visit: ${guest['visit_start']})');
      }

      // Test raw SQL to check RLS access
      print('🔍 DEBUG: getTodayGuests - Testing RLS access function...');
      try {
        final rawResult = await _supabase.rpc('test_guest_access');
        print('🔍 DEBUG: RLS access test result: $rawResult');
      } catch (rawError) {
        print('🔍 DEBUG: RLS access test failed: $rawError');
      }

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('🔍 DEBUG: getTodayGuests - ERROR: $e');
      throw Exception('Failed to fetch today\'s guests: $e');
    }
  }

  /// Get active guests (scheduled or checked in)
  Future<List<Guest>> getActiveGuests() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .or('status.eq.scheduled,status.eq.checked_in')
          .order('visit_start', ascending: true);

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active guests: $e');
    }
  }

  /// Search guests by name or phone number
  Future<List<Guest>> searchGuests(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .or('guest_name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search guests: $e');
    }
  }

  /// Get a single guest by ID
  Future<Guest?> getGuestById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch guest: $e');
    }
  }

  /// Create a new guest
  Future<Guest> createGuest(Guest guest) async {
    try {
      final guestData = _mapGuestToSupabase(guest);

      final response = await _supabase
          .from(_tableName)
          .insert(guestData)
          .select()
          .single();

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create guest: $e');
    }
  }

  /// Update an existing guest
  Future<Guest> updateGuest(Guest guest) async {
    try {
      final guestData = _mapGuestToSupabase(guest);

      final response = await _supabase
          .from(_tableName)
          .update(guestData)
          .eq('id', guest.id)
          .select()
          .single();

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update guest: $e');
    }
  }

  /// Check in a guest
  Future<Guest> checkInGuest(
    String guestId, {
    DateTime? actualCheckIn,
    String? verificationMethod,
    double? temperatureCelsius,
    String? guardNotes,
  }) async {
    try {
      final updateData = {
        'status': 'checked_in',
        'check_in_time': (actualCheckIn ?? DateTime.now()).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (verificationMethod != null) {
        updateData['verification_method'] = verificationMethod;
      }
      if (temperatureCelsius != null) {
        updateData['temperature_celsius'] = temperatureCelsius.toString();
      }
      if (guardNotes != null) {
        updateData['notes'] = guardNotes;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', guestId)
          .select()
          .single();

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to check in guest: $e');
    }
  }

  /// Check out a guest
  Future<Guest> checkOutGuest(
    String guestId, {
    DateTime? actualCheckOut,
    String? guardNotes,
  }) async {
    try {
      final updateData = {
        'status': 'checked_out',
        'check_out_time': (actualCheckOut ?? DateTime.now()).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (guardNotes != null) {
        updateData['notes'] = guardNotes;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', guestId)
          .select()
          .single();

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to check out guest: $e');
    }
  }

  /// Cancel a guest registration
  Future<Guest> cancelGuest(String guestId, {String? reason}) async {
    try {
      final updateData = {
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (reason != null) {
        updateData['notes'] = reason;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', guestId)
          .select()
          .single();

      return _mapGuestFromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to cancel guest: $e');
    }
  }

  /// Delete a guest
  Future<void> deleteGuest(String guestId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', guestId);
    } catch (e) {
      throw Exception('Failed to delete guest: $e');
    }
  }

  /// Get guest statistics
  Future<Map<String, int>> getGuestStatistics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from(_tableName)
          .select('status')
          .gte('visit_start', startOfDay.toIso8601String())
          .lt('visit_start', endOfDay.toIso8601String());

      final stats = <String, int>{
        'scheduled': 0,
        'checked_in': 0,
        'checked_out': 0,
        'cancelled': 0,
        'total': 0,
      };

      for (final guest in response as List) {
        final status = guest['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
        stats['total'] = (stats['total'] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch guest statistics: $e');
    }
  }

  /// Map Guest model to Supabase format
  Map<String, dynamic> _mapGuestToSupabase(Guest guest) {
    final json = guest.toJson();
    // Add visit_end field (using same date as visit_start for now)
    json['visit_end'] = guest.scheduledDate.toIso8601String();
    return json;
  }

  /// Map Supabase response to Guest model
  Guest _mapGuestFromSupabase(Map<String, dynamic> json) {
    try {
      print('🔍 DEBUG: _mapGuestFromSupabase - Mapping guest data:');
      print('   Raw JSON: $json');

      // Handle nullable fields that might be missing or null
      final sanitizedJson = Map<String, dynamic>.from(json);

      // Ensure required fields are not null
      sanitizedJson['guest_name'] = json['guest_name']?.toString() ?? 'Unknown Guest';
      sanitizedJson['phone_number'] = json['phone_number']?.toString() ?? '';
      sanitizedJson['purpose'] = json['purpose']?.toString() ?? 'Visit';

      print('   Sanitized JSON: $sanitizedJson');

      final guest = Guest.fromJson(sanitizedJson);
      print('   Mapped guest: ${guest.guestName} (${guest.id})');

      return guest;
    } catch (e) {
      print('🔍 DEBUG: _mapGuestFromSupabase - ERROR: $e');
      print('   Problematic JSON: $json');
      rethrow;
    }
  }

  /// Map GuestStatus enum to database status string
  String _mapStatusToDb(GuestStatus status) {
    switch (status) {
      case GuestStatus.expected:
        return 'scheduled';
      case GuestStatus.checkedIn:
        return 'checked_in';
      case GuestStatus.checkedOut:
        return 'checked_out';
      case GuestStatus.cancelled:
        return 'cancelled';
    }
  }

  
  /// Stream guests by status for real-time updates
  Stream<List<Guest>> streamGuestsByStatus(GuestStatus status) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('status', _mapStatusToDb(status))
        .order('created_at', ascending: false)
        .map((event) {
          return (event as List)
              .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
              .toList();
        });
  }

  /// Stream all guests for real-time updates
  Stream<List<Guest>> streamAllGuests() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((event) {
          return (event as List)
              .map((json) => _mapGuestFromSupabase(json as Map<String, dynamic>))
              .toList();
        });
  }

  /// Debug method to check user authentication and tenant access
  Future<Map<String, dynamic>> debugUserAccess() async {
    try {
      print('🔍 DEBUG: Starting user access debug check...');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('🔍 DEBUG: No authenticated user found in debug method!');
        return {'error': 'No authenticated user'};
      }

      print('🔍 DEBUG: Found authenticated user:');
      print('   User ID: ${currentUser.id}');
      print('   Email: ${currentUser.email}');
      print('   User Metadata: ${currentUser.userMetadata}');

      // Get user metadata
      final userMetadata = currentUser.userMetadata ?? {};
      final tenantId = userMetadata['tenant_id'] as String?;

      print('🔍 DEBUG: Extracted tenant_id: $tenantId');

      // Test direct table access
      List<dynamic> directResult = [];
      List<dynamic> viewResult = [];
      String? directError;
      String? viewError;

      try {
        directResult = await _supabase
            .from(_tableName)
            .select('id, guest_name, tenant_id')
            .limit(5);
      } catch (e) {
        directError = e.toString();
      }

      try {
        viewResult = await _supabase
            .from('guest_dashboard')
            .select('id, guest_name, tenant_id')
            .limit(5);
      } catch (e) {
        viewError = e.toString();
      }

      return {
        'userId': currentUser.id,
        'email': currentUser.email,
        'tenantId': tenantId,
        'userMetadata': userMetadata,
        'directTableAccess': {
          'success': directError == null,
          'count': directResult.length,
          'data': directResult,
          'error': directError,
        },
        'viewAccess': {
          'success': viewError == null,
          'count': viewResult.length,
          'data': viewResult,
          'error': viewError,
        },
      };
    } catch (e) {
      return {'error': 'Debug check failed: $e'};
    }
  }
}