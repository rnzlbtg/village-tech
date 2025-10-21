import '../models/guest.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';
import 'offline_cache_service.dart';

/// Guest service
/// Handles CRUD operations for scheduled guests
class GuestService {
  static GuestService? _instance;

  GuestService._();

  /// Singleton instance
  static GuestService get instance {
    _instance ??= GuestService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;
  final _cacheService = OfflineCacheService.instance;

  static const _cacheKey = 'scheduled_guests';

  /// Schedule a guest visit
  Future<ApiResult<Guest>> scheduleGuest({
    required String guestName,
    String? contactNumber,
    required String visitType,
    required DateTime visitStart,
    required DateTime visitEnd,
    String? purpose,
    String? vehiclePlate,
  }) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final tenantId = SupabaseService.instance.tenantId;
      if (tenantId == null) {
        return ApiResult.failure('Tenant ID not found');
      }

      // Validation
      if (visitStart.isAfter(visitEnd)) {
        return ApiResult.failure('Visit start must be before visit end');
      }

      if (visitStart.isBefore(DateTime.now())) {
        return ApiResult.failure('Visit start cannot be in the past');
      }

      if (visitType == GuestVisitType.multiDay) {
        final duration = visitEnd.difference(visitStart).inDays;
        if (duration > 30) {
          return ApiResult.failure('Multi-day visits cannot exceed 30 days');
        }
      }

      final data = await _supabase.from('guests').insert({
        'tenant_id': tenantId,
        'household_id': householdId,
        'guest_name': guestName,
        'contact_number': contactNumber,
        'visit_type': visitType,
        'visit_start': visitStart.toIso8601String(),
        'visit_end': visitEnd.toIso8601String(),
        'purpose': purpose,
        'vehicle_plate': vehiclePlate,
        'status': GuestStatus.scheduled,
      }).select().single();

      final guest = Guest.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(guest);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Update guest schedule
  Future<ApiResult<Guest>> updateGuestSchedule({
    required String guestId,
    String? guestName,
    String? contactNumber,
    String? visitType,
    DateTime? visitStart,
    DateTime? visitEnd,
    String? purpose,
    String? vehiclePlate,
  }) async {
    try {
      // Validation if dates are being updated
      if (visitStart != null && visitEnd != null) {
        if (visitStart.isAfter(visitEnd)) {
          return ApiResult.failure('Visit start must be before visit end');
        }

        if (visitStart.isBefore(DateTime.now())) {
          return ApiResult.failure('Visit start cannot be in the past');
        }
      }

      final updateData = <String, dynamic>{};
      if (guestName != null) updateData['guest_name'] = guestName;
      if (contactNumber != null) updateData['contact_number'] = contactNumber;
      if (visitType != null) updateData['visit_type'] = visitType;
      if (visitStart != null) {
        updateData['visit_start'] = visitStart.toIso8601String();
      }
      if (visitEnd != null) updateData['visit_end'] = visitEnd.toIso8601String();
      if (purpose != null) updateData['purpose'] = purpose;
      if (vehiclePlate != null) updateData['vehicle_plate'] = vehiclePlate;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('guests')
          .update(updateData)
          .eq('id', guestId)
          .select()
          .single();

      final guest = Guest.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(guest);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Cancel guest visit
  Future<ApiResult<void>> cancelGuestVisit(String guestId) async {
    try {
      await _supabase
          .from('guests')
          .update({
            'status': GuestStatus.cancelled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', guestId);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch scheduled guests for household
  Future<ApiResult<List<Guest>>> fetchScheduledGuests() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('guests')
          .select()
          .eq('household_id', householdId)
          .order('visit_start', ascending: true);

      final guests =
          (data as List).map((json) => Guest.fromJson(json)).toList();

      // Cache the results
      await _cacheService.put(_cacheKey, data);

      return ApiResult.success(guests);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch guests from cache
  Future<List<Guest>?> fetchGuestsFromCache() async {
    try {
      final cached = await _cacheService.get(_cacheKey);
      if (cached == null) return null;

      final guests =
          (cached as List).map((json) => Guest.fromJson(json)).toList();
      return guests;
    } catch (e) {
      return null;
    }
  }

  /// Fetch upcoming guests (scheduled and visit start is in the future)
  Future<ApiResult<List<Guest>>> fetchUpcomingGuests() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final now = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('guests')
          .select()
          .eq('household_id', householdId)
          .eq('status', GuestStatus.scheduled)
          .gt('visit_start', now)
          .order('visit_start', ascending: true);

      final guests =
          (data as List).map((json) => Guest.fromJson(json)).toList();

      return ApiResult.success(guests);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch active guests (currently within visit window)
  Future<ApiResult<List<Guest>>> fetchActiveGuests() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final now = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('guests')
          .select()
          .eq('household_id', householdId)
          .inFilter('status', [GuestStatus.scheduled, GuestStatus.checkedIn])
          .lte('visit_start', now)
          .gte('visit_end', now)
          .order('visit_start', ascending: true);

      final guests =
          (data as List).map((json) => Guest.fromJson(json)).toList();

      return ApiResult.success(guests);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch past guests (visit end is in the past or checked out)
  Future<ApiResult<List<Guest>>> fetchPastGuests() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final now = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('guests')
          .select()
          .eq('household_id', householdId)
          .or('status.eq.${GuestStatus.checkedOut},visit_end.lt.$now')
          .order('visit_start', ascending: false)
          .limit(50); // Limit past guests to most recent 50

      final guests =
          (data as List).map((json) => Guest.fromJson(json)).toList();

      return ApiResult.success(guests);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch guests by status
  Future<ApiResult<List<Guest>>> fetchGuestsByStatus(String status) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('guests')
          .select()
          .eq('household_id', householdId)
          .eq('status', status)
          .order('visit_start', ascending: true);

      final guests =
          (data as List).map((json) => Guest.fromJson(json)).toList();

      return ApiResult.success(guests);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Check in guest
  Future<ApiResult<Guest>> checkInGuest(String guestId) async {
    try {
      final data = await _supabase
          .from('guests')
          .update({
            'status': GuestStatus.checkedIn,
            'check_in_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', guestId)
          .select()
          .single();

      final guest = Guest.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(guest);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Check out guest
  Future<ApiResult<Guest>> checkOutGuest(String guestId) async {
    try {
      final data = await _supabase
          .from('guests')
          .update({
            'status': GuestStatus.checkedOut,
            'check_out_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', guestId)
          .select()
          .single();

      final guest = Guest.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(guest);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
