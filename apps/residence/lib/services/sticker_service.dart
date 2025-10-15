import '../models/rfid_sticker.dart';
import '../models/sticker_allocation.dart';
import '../models/sticker_request.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';
import 'dart:developer' as developer;

/// Sticker service
/// Handles sticker requests and allocation tracking
class StickerService {
  static StickerService? _instance;

  StickerService._();

  /// Singleton instance
  static StickerService get instance {
    _instance ??= StickerService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Get household ID for current user
  Future<String> _getHouseholdId() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = await _supabase
          .from('households')
          .select('id')
          .eq('household_head_id', userId)
          .single();

      return data['id'] as String;
    } catch (e) {
      throw Exception('Failed to get household ID: $e');
    }
  }

  /// Get tenant ID for current user via household relationship
  Future<String> _getTenantId() async {
    try {
      final householdId = await _getHouseholdId();
      developer.log('Getting tenant ID via household: $householdId', name: 'StickerService');

      final data = await _supabase
          .from('households')
          .select('residence_units(property_id, properties(tenant_id))')
          .eq('id', householdId)
          .single();

      final tenantId = data['residence_units']['properties']['tenant_id'] as String;
      developer.log('Tenant ID found: $tenantId', name: 'StickerService');
      return tenantId;
    } catch (e) {
      developer.log('ERROR getting tenant ID: $e', name: 'StickerService');
      throw Exception('Failed to get tenant ID: $e');
    }
  }

  /// Check sticker allocation
  Future<ApiResult<StickerAllocation>> checkAllocation() async {
    try {
      developer.log('Checking sticker allocation...', name: 'StickerService');

      final tenantId = await _getTenantId();
      final householdId = await _getHouseholdId();

      developer.log('Allocation check - Tenant ID: $tenantId, Household ID: $householdId', name: 'StickerService');

      // Get total allocation from active program
      developer.log('Fetching active sticker program...', name: 'StickerService');

      // First, let's check all sticker programs for this tenant
      developer.log('Checking ALL sticker programs for tenant: $tenantId', name: 'StickerService');
      final allProgramsData = await _supabase
          .from('sticker_programs')
          .select('id, program_name, program_year, stickers_per_household, is_active, start_date, end_date')
          .eq('tenant_id', tenantId);

      developer.log('Found ${allProgramsData.length} sticker programs for tenant', name: 'StickerService');
      for (final program in allProgramsData) {
        developer.log('Program: ${program['program_name']} (${program['program_year']}), Active: ${program['is_active']}, Stickers: ${program['stickers_per_household']}', name: 'StickerService');
      }

      // Now fetch only active ones
      final programData = await _supabase
          .from('sticker_programs')
          .select('stickers_per_household')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .maybeSingle();

      if (programData == null) {
        developer.log('No ACTIVE sticker program found for tenant: $tenantId', name: 'StickerService');

        // Try without the is_active filter to see what happens
        final anyProgramData = await _supabase
            .from('sticker_programs')
            .select('id, stickers_per_household, is_active')
            .eq('tenant_id', tenantId)
            .maybeSingle();

        if (anyProgramData != null) {
          developer.log('Found sticker program but is_active might be false: ${anyProgramData}', name: 'StickerService');
        } else {
          developer.log('No sticker programs found at all for tenant: $tenantId', name: 'StickerService');
        }

        return ApiResult.failure(
          'No active sticker program found',
          code: 'NO_PROGRAM',
        );
      }

      final total = programData['stickers_per_household'] as int;
      developer.log('Sticker program found - total allocation: $total', name: 'StickerService');

      // Get used stickers count (approved or distributed sticker requests)
      developer.log('Counting used stickers...', name: 'StickerService');
      final usedData = await _supabase
          .from('sticker_requests')
          .select('id')
          .eq('household_id', householdId)
          .inFilter('request_status', ['approved', 'distributed'])
          .count();

      final used = usedData.count;
      final available = total - used;

      developer.log('Allocation calculation - Total: $total, Used: $used, Available: $available', name: 'StickerService');

      final allocation = StickerAllocation(
        total: total,
        used: used,
        available: available,
      );

      return ApiResult.success(allocation);
    } catch (e) {
      return ApiResult.failure(
        'Failed to check allocation: ${e.toString()}',
        code: 'CHECK_ALLOCATION_ERROR',
      );
    }
  }

  /// Request sticker
  Future<ApiResult<StickerRequest>> requestSticker({
    required String ownerType,
    required String ownerId,
    required String vehiclePlate,
    String? vehicleMake,
    String? vehicleColor,
  }) async {
    try {
      // Check allocation first
      final allocationResult = await checkAllocation();
      if (!allocationResult.success || allocationResult.data == null) {
        return ApiResult.failure(
          allocationResult.error ?? 'Failed to check allocation',
          code: 'ALLOCATION_CHECK_FAILED',
        );
      }

      if (allocationResult.data!.available <= 0) {
        return ApiResult.failure(
          'Sticker allocation limit reached. You have used ${allocationResult.data!.used} of ${allocationResult.data!.total} stickers.',
          code: 'ALLOCATION_EXCEEDED',
        );
      }

      final householdId = await _getHouseholdId();
      final tenantId = await _getTenantId();
      final userId = _supabase.auth.currentUser!.id;

      // Get active program ID for the request
      developer.log('Getting active program ID for sticker request...', name: 'StickerService');
      final programData = await _supabase
          .from('sticker_programs')
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .single();

      final programId = programData['id']?.toString();
      developer.log('Program ID found: $programId', name: 'StickerService');

      final data = await _supabase.from('sticker_requests').insert({
        'tenant_id': tenantId,
        'household_id': householdId,
        'program_id': programId,
        'vehicle_plate_number': vehiclePlate.toUpperCase(),
        'vehicle_make': vehicleMake,
        'vehicle_color': vehicleColor,
        'request_status': 'pending',
      }).select().single();

      final request = StickerRequest.fromJson(data);
      return ApiResult.success(request);
    } catch (e) {
      return ApiResult.failure(
        'Failed to request sticker: ${e.toString()}',
        code: 'REQUEST_STICKER_ERROR',
      );
    }
  }

  /// Fetch pending sticker requests
  Future<ApiResult<List<StickerRequest>>> fetchPendingRequests() async {
    try {
      final householdId = await _getHouseholdId();

      final data = await _supabase
          .from('sticker_requests')
          .select()
          .eq('household_id', householdId)
          .inFilter('request_status', ['pending', 'approved'])
          .order('requested_at', ascending: false);

      final requests = (data as List)
          .map((json) => StickerRequest.fromJson(json))
          .toList();

      return ApiResult.success(requests);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch pending requests: ${e.toString()}',
        code: 'FETCH_REQUESTS_ERROR',
      );
    }
  }

  /// Fetch all sticker requests
  Future<ApiResult<List<StickerRequest>>> fetchAllRequests() async {
    try {
      final householdId = await _getHouseholdId();

      final data = await _supabase
          .from('sticker_requests')
          .select()
          .eq('household_id', householdId)
          .order('requested_at', ascending: false);

      final requests = (data as List)
          .map((json) => StickerRequest.fromJson(json))
          .toList();

      return ApiResult.success(requests);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch requests: ${e.toString()}',
        code: 'FETCH_REQUESTS_ERROR',
      );
    }
  }

  /// Fetch single sticker request
  Future<ApiResult<StickerRequest>> fetchStickerRequest({
    required String requestId,
  }) async {
    try {
      final data = await _supabase
          .from('sticker_requests')
          .select()
          .eq('id', requestId)
          .single();

      final request = StickerRequest.fromJson(data);
      return ApiResult.success(request);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch sticker request: ${e.toString()}',
        code: 'FETCH_REQUEST_ERROR',
      );
    }
  }

  /// Fetch active stickers (approved sticker requests)
  Future<ApiResult<List<RfidSticker>>> fetchActiveStickers() async {
    try {
      final householdId = await _getHouseholdId();
      final tenantId = await _getTenantId();

      final data = await _supabase
          .from('sticker_requests')
          .select()
          .eq('household_id', householdId)
          .inFilter('request_status', ['approved', 'distributed'])
          .order('requested_at', ascending: false);

      // Convert sticker requests to RfidSticker objects
      final stickers = <RfidSticker>[];
      for (final json in data as List) {
        // Since we don't have rfid_stickers table, we'll create placeholder RfidSticker objects
        // with available data from sticker_requests
        final sticker = RfidSticker(
          id: json['id'] as String,
          tenantId: tenantId,
          householdId: householdId,
          stickerCode: json['sticker_code'] as String? ?? 'PENDING',
          vehiclePlate: json['vehicle_plate_number'] as String,
          ownerType: 'household_member', // Default since we don't have this info
          ownerId: json['household_id'] as String, // Use household_id as placeholder
          issueDate: json['distributed_at'] != null
              ? DateTime.parse(json['distributed_at'] as String)
              : DateTime.parse(json['requested_at'] as String),
          expiryDate: null, // No expiry in sticker_requests table
          status: json['request_status'] == 'distributed' ? 'active' : 'pending',
          createdAt: DateTime.parse(json['created_at'] as String),
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.parse(json['created_at'] as String),
        );
        stickers.add(sticker);
      }

      return ApiResult.success(stickers);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch active stickers: ${e.toString()}',
        code: 'FETCH_STICKERS_ERROR',
      );
    }
  }

  /// Cancel sticker request (only if pending)
  Future<ApiResult<void>> cancelStickerRequest({
    required String requestId,
  }) async {
    try {
      // Check if request is pending
      final requestResult = await fetchStickerRequest(requestId: requestId);
      if (!requestResult.success || requestResult.data == null) {
        return ApiResult.failure(
          'Request not found',
          code: 'REQUEST_NOT_FOUND',
        );
      }

      if (requestResult.data!.status != 'pending') {
        return ApiResult.failure(
          'Only pending requests can be cancelled',
          code: 'INVALID_STATUS',
        );
      }

      await _supabase
          .from('sticker_requests')
          .delete()
          .eq('id', requestId);

      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        'Failed to cancel request: ${e.toString()}',
        code: 'CANCEL_REQUEST_ERROR',
      );
    }
  }
}
