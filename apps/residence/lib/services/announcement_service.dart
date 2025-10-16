import 'dart:developer' as developer;
import '../models/announcement.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';

/// Announcement service
/// Handles fetching announcements from admin
class AnnouncementService {
  static AnnouncementService? _instance;

  AnnouncementService._();

  /// Singleton instance
  static AnnouncementService get instance {
    _instance ??= AnnouncementService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Get tenant ID for current user via household relationship
  Future<String> _getTenantId() async {
    try {
      developer.log('🏠 Getting tenant ID via household relationship...', name: 'AnnouncementService');

      final householdId = await SupabaseService.instance.getHouseholdId();
      developer.log('🏠 Retrieved householdId: $householdId', name: 'AnnouncementService');

      if (householdId == null) {
        developer.log('❌ Household ID is null', name: 'AnnouncementService');
        throw Exception('Household ID is null');
      }

      developer.log('🔍 Querying household data for tenant...', name: 'AnnouncementService');
      final data = await _supabase
          .from('households')
          .select('residence_units(property_id, properties(tenant_id))')
          .eq('id', householdId)
          .single();

      developer.log('📊 Household query result: $data', name: 'AnnouncementService');

      final residenceUnits = data['residence_units'];
      if (residenceUnits == null) {
        developer.log('❌ No residence_units found for household', name: 'AnnouncementService');
        throw Exception('No residence unit assigned to household');
      }

      final properties = residenceUnits['properties'];
      if (properties == null) {
        developer.log('❌ No properties found for residence unit', name: 'AnnouncementService');
        throw Exception('No property assigned to residence unit');
      }

      final tenantId = properties['tenant_id'] as String;
      developer.log('✅ Tenant ID found: $tenantId', name: 'AnnouncementService');
      return tenantId;
    } catch (e, stackTrace) {
      developer.log('❌ ERROR getting tenant ID: $e', name: 'AnnouncementService', error: e, stackTrace: stackTrace);
      developer.log('❌ Error type: ${e.runtimeType}', name: 'AnnouncementService');
      throw Exception('Failed to get tenant ID: $e');
    }
  }

  /// Fetch all announcements for tenant
  Future<ApiResult<List<Announcement>>> fetchAnnouncements() async {
    try {
      developer.log('🔍 Starting fetchAnnouncements...', name: 'AnnouncementService');

      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        developer.log('❌ User not authenticated', name: 'AnnouncementService');
        return ApiResult.failure('User not authenticated');
      }
      developer.log('✅ User authenticated: ${user.id}', name: 'AnnouncementService');

      final tenantId = await _getTenantId();
      developer.log('✅ Retrieved tenantId: $tenantId', name: 'AnnouncementService');

      developer.log('📡 Querying announcements table...', name: 'AnnouncementService');
      final data = await _supabase
          .from('announcements')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      developer.log('📊 Raw query result type: ${data.runtimeType}', name: 'AnnouncementService');
      developer.log('📊 Raw query result: $data', name: 'AnnouncementService');

      if (data == null) {
        developer.log('❌ Query returned null', name: 'AnnouncementService');
        return ApiResult.failure('Query returned null');
      }

      final announcements =
          (data as List).map((json) {
            developer.log('📝 Processing announcement: $json', name: 'AnnouncementService');
            return Announcement.fromJson(json);
          }).toList();

      developer.log('✅ Successfully processed ${announcements.length} announcements', name: 'AnnouncementService');
      return ApiResult.success(announcements);
    } catch (e, stackTrace) {
      developer.log('❌ ERROR fetching announcements: $e', name: 'AnnouncementService', error: e, stackTrace: stackTrace);
      developer.log('❌ Error type: ${e.runtimeType}', name: 'AnnouncementService');
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch announcements by priority
  Future<ApiResult<List<Announcement>>> fetchAnnouncementsByPriority(
    String priority,
  ) async {
    try {
      final tenantId = await _getTenantId();

      final data = await _supabase
          .from('announcements')
          .select()
          .eq('tenant_id', tenantId)
          .eq('priority', priority)
          .order('created_at', ascending: false);

      final announcements =
          (data as List).map((json) => Announcement.fromJson(json)).toList();

      return ApiResult.success(announcements);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch high priority announcements
  Future<ApiResult<List<Announcement>>> fetchHighPriorityAnnouncements() async {
    try {
      developer.log('🔴 Starting fetchHighPriorityAnnouncements...', name: 'AnnouncementService');

      final tenantId = await _getTenantId();
      developer.log('✅ Retrieved tenantId for high priority: $tenantId', name: 'AnnouncementService');

      developer.log('📡 Querying high priority announcements...', name: 'AnnouncementService');
      final data = await _supabase
          .from('announcements')
          .select()
          .eq('tenant_id', tenantId)
          .inFilter('priority', [AnnouncementPriority.high, AnnouncementPriority.urgent])
          .order('created_at', ascending: false)
          .limit(10);

      developer.log('📊 High priority query result: $data', name: 'AnnouncementService');

      final announcements =
          (data as List).map((json) => Announcement.fromJson(json)).toList();

      developer.log('✅ Found ${announcements.length} high priority announcements', name: 'AnnouncementService');
      return ApiResult.success(announcements);
    } catch (e, stackTrace) {
      developer.log('❌ ERROR fetching high priority announcements: $e', name: 'AnnouncementService', error: e, stackTrace: stackTrace);
      return ApiResult.failure(e.toString());
    }
  }
}
