import '../models/village_rule.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';

/// Village rules service
/// Handles fetching village rules and regulations
class VillageRulesService {
  static VillageRulesService? _instance;

  VillageRulesService._();

  /// Singleton instance
  static VillageRulesService get instance {
    _instance ??= VillageRulesService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Fetch all village rules for tenant
  Future<ApiResult<List<VillageRule>>> fetchVillageRules() async {
    try {
      final tenantId = SupabaseService.instance.tenantId;
      if (tenantId == null) {
        return ApiResult.failure('Tenant ID not found');
      }

      final data = await _supabase
          .from('village_rules')
          .select()
          .eq('tenant_id', tenantId)
          .order('rule_category', ascending: true)
          .order('created_at', ascending: true);

      final rules =
          (data as List).map((json) => VillageRule.fromJson(json)).toList();

      return ApiResult.success(rules);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch village rules by category
  Future<ApiResult<List<VillageRule>>> fetchRulesByCategory(
    String category,
  ) async {
    try {
      final tenantId = SupabaseService.instance.tenantId;
      if (tenantId == null) {
        return ApiResult.failure('Tenant ID not found');
      }

      final data = await _supabase
          .from('village_rules')
          .select()
          .eq('tenant_id', tenantId)
          .eq('rule_category', category)
          .order('created_at', ascending: true);

      final rules =
          (data as List).map((json) => VillageRule.fromJson(json)).toList();

      return ApiResult.success(rules);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch curfew rules
  Future<ApiResult<VillageRule?>> fetchCurfewRule() async {
    try {
      final tenantId = SupabaseService.instance.tenantId;
      if (tenantId == null) {
        return ApiResult.failure('Tenant ID not found');
      }

      final data = await _supabase
          .from('village_rules')
          .select()
          .eq('tenant_id', tenantId)
          .eq('rule_category', RuleCategory.curfew)
          .maybeSingle();

      if (data == null) {
        return ApiResult.success(null);
      }

      final rule = VillageRule.fromJson(data);

      return ApiResult.success(rule);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
