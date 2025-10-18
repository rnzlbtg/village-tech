import '../models/construction_permit_request.dart';
import '../models/payment_log.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';
import 'dart:developer' as developer;

/// Permit service
/// Handles CRUD operations for construction permit requests
class PermitService {
  static PermitService? _instance;

  PermitService._();

  /// Singleton instance
  static PermitService get instance {
    _instance ??= PermitService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Submit construction permit request
  Future<ApiResult<ConstructionPermitRequest>> submitConstructionPermit({
    required String projectType,
    required String description,
    required String contractorName,
    required String contractorContact,
    required DateTime startDate,
    required DateTime endDate,
    required int estimatedWorkers,
    List<String>? authorizedWorkers,
  }) async {
    try {
      developer.log('Starting permit submission...', name: 'PermitService');

      final householdId = await SupabaseService.instance.getHouseholdId();
      developer.log('Household ID: $householdId', name: 'PermitService');

      if (householdId == null) {
        developer.log('ERROR: Household ID not found', name: 'PermitService');
        return ApiResult.failure('Household ID not found');
      }

      // Validation
      if (startDate.isAfter(endDate)) {
        return ApiResult.failure('Start date must be before end date');
      }

      if (startDate.isBefore(DateTime.now())) {
        return ApiResult.failure('Start date cannot be in the past');
      }

      final duration = endDate.difference(startDate).inDays;
      if (duration > 365) {
        return ApiResult.failure('Project duration cannot exceed 365 days');
      }

      if (estimatedWorkers <= 0) {
        return ApiResult.failure('Estimated workers must be greater than 0');
      }

      // Get tenant_id from household
      developer.log('Fetching tenant_id for household...', name: 'PermitService');
      final householdData = await _supabase
          .from('households')
          .select('residence_units(property_id, properties(tenant_id))')
          .eq('id', householdId)
          .single();

      final tenantId = householdData['residence_units']['properties']['tenant_id'] as String;
      developer.log('Tenant ID: $tenantId', name: 'PermitService');

      developer.log('Submitting to construction_permits table...', name: 'PermitService');
      developer.log('Data: householdId=$householdId, projectType=$projectType', name: 'PermitService');
      developer.log('Authorized workers: $authorizedWorkers', name: 'PermitService');

      // Prepare authorized workers as JSONB array
      final workersJson = authorizedWorkers?.map((name) => {'name': name}).toList();

      final data = await _supabase.from('construction_permits').insert({
        'tenant_id': tenantId,
        'household_id': householdId,
        'project_type': projectType,
        'project_description': description,
        'contractor_name': contractorName,
        'contractor_contact': contractorContact,
        'start_date': startDate.toIso8601String(),
        'estimated_end_date': endDate.toIso8601String(),
        'estimated_workers': estimatedWorkers,
        'permit_status': PermitStatus.pending,
        if (workersJson != null && workersJson.isNotEmpty)
          'authorized_workers': workersJson,
      }).select().single();

      developer.log('Permit submitted successfully: ${data['id']}', name: 'PermitService');

      final permit = ConstructionPermitRequest.fromJson(data);

      return ApiResult.success(permit);
    } catch (e) {
      developer.log('ERROR submitting permit: $e', name: 'PermitService');
      return ApiResult.failure(e.toString());
    }
  }

  /// Cancel permit request
  Future<ApiResult<void>> cancelPermitRequest(String permitId) async {
    try {
      developer.log('Cancelling permit request: $permitId', name: 'PermitService');

      await _supabase
          .from('construction_permits')
          .update({
            'permit_status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', permitId);

      developer.log('Permit cancelled successfully: $permitId', name: 'PermitService');

      return ApiResult.success(null);
    } catch (e) {
      developer.log('ERROR cancelling permit: $e', name: 'PermitService');
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch permit requests for household
  Future<ApiResult<List<ConstructionPermitRequest>>>
      fetchPermitRequests() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('construction_permits')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

      final permits = (data as List)
          .map((json) => ConstructionPermitRequest.fromJson(json))
          .toList();

      return ApiResult.success(permits);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch permit requests by status
  Future<ApiResult<List<ConstructionPermitRequest>>>
      fetchPermitRequestsByStatus(String status) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('construction_permits')
          .select()
          .eq('household_id', householdId)
          .eq('permit_status', status)
          .order('created_at', ascending: false);

      final permits = (data as List)
          .map((json) => ConstructionPermitRequest.fromJson(json))
          .toList();

      return ApiResult.success(permits);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch payment log for permit
  Future<ApiResult<PaymentLog?>> fetchPaymentLog(String permitId) async {
    try {
      final data = await _supabase
          .from('payment_logs')
          .select()
          .eq('permit_request_id', permitId)
          .maybeSingle();

      if (data == null) {
        return ApiResult.success(null);
      }

      final payment = PaymentLog.fromJson(data);

      return ApiResult.success(payment);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Mark permit as completed
  Future<ApiResult<ConstructionPermitRequest>> markAsCompleted(
    String permitId,
  ) async {
    try {
      final data = await _supabase
          .from('construction_permits')
          .update({
            'permit_status': PermitStatus.completed,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', permitId)
          .select()
          .single();

      final permit = ConstructionPermitRequest.fromJson(data);

      return ApiResult.success(permit);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
