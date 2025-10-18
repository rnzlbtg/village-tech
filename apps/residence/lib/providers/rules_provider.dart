import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/village_rule.dart';
import '../services/village_rules_service.dart';

/// Rules state
class RulesState {
  final List<VillageRule> rules;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedCategory;

  RulesState({
    this.rules = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
  });

  RulesState copyWith({
    List<VillageRule>? rules,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return RulesState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  /// Get rules filtered by selected category
  List<VillageRule> get filteredRules {
    if (selectedCategory == null || selectedCategory == 'all') {
      return rules;
    }
    return rules.where((rule) => rule.ruleCategory == selectedCategory).toList();
  }

  /// Get rules by category
  List<VillageRule> getRulesByCategory(String category) {
    return rules.where((rule) => rule.ruleCategory == category).toList();
  }

  /// Get general rules
  List<VillageRule> get generalRules {
    return getRulesByCategory(RuleCategory.general);
  }

  /// Get parking rules
  List<VillageRule> get parkingRules {
    return getRulesByCategory(RuleCategory.parking);
  }

  /// Get noise rules
  List<VillageRule> get noiseRules {
    return getRulesByCategory(RuleCategory.noise);
  }

  /// Get construction rules
  List<VillageRule> get constructionRules {
    return getRulesByCategory(RuleCategory.construction);
  }

  /// Get curfew rule
  VillageRule? get curfewRule {
    try {
      return rules.firstWhere((rule) => rule.isCurfew);
    } catch (e) {
      return null;
    }
  }

  /// Get all available categories from rules
  List<String> get availableCategories {
    final categories = rules.map((rule) => rule.ruleCategory).toSet().toList();
    categories.sort();
    return ['all', ...categories];
  }
}

/// Rules provider
class RulesNotifier extends StateNotifier<RulesState> {
  final VillageRulesService _service = VillageRulesService.instance;

  RulesNotifier() : super(RulesState()) {
    refreshRules();
  }

  /// Refresh all rules
  Future<void> refreshRules() async {
    developer.log('🔄 Starting refreshRules...', name: 'RulesProvider');
    state = state.copyWith(isLoading: true, errorMessage: null);
    developer.log('📊 State set to loading', name: 'RulesProvider');

    final result = await _service.fetchVillageRules();
    developer.log('📊 Service result: success=${result.isSuccess}, error=${result.error}', name: 'RulesProvider');

    if (result.isSuccess) {
      final rules = result.data!;
      developer.log('✅ Successfully fetched ${rules.length} rules', name: 'RulesProvider');
      state = state.copyWith(
        rules: rules,
        isLoading: false,
      );
      developer.log('📊 State updated with ${state.rules.length} rules', name: 'RulesProvider');
      developer.log('📊 General rules: ${state.generalRules.length}', name: 'RulesProvider');
      developer.log('📊 Parking rules: ${state.parkingRules.length}', name: 'RulesProvider');
      developer.log('📊 Noise rules: ${state.noiseRules.length}', name: 'RulesProvider');
      developer.log('📊 Construction rules: ${state.constructionRules.length}', name: 'RulesProvider');
      developer.log('📊 Curfew rules: ${state.curfewRule != null ? 1 : 0}', name: 'RulesProvider');
    } else {
      developer.log('❌ Service failed with error: ${result.error}', name: 'RulesProvider');
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      developer.log('📊 State updated with error: ${state.errorMessage}', name: 'RulesProvider');
    }
  }

  /// Filter rules by category
  void filterByCategory(String? category) {
    developer.log('🏷️ Filtering rules by category: $category', name: 'RulesProvider');
    state = state.copyWith(selectedCategory: category);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get rules by specific category (for targeted refresh)
  Future<void> refreshRulesByCategory(String category) async {
    developer.log('🔄 Refreshing rules for category: $category', name: 'RulesProvider');

    final result = await _service.fetchRulesByCategory(category);
    if (result.isSuccess) {
      final categoryRules = result.data!;
      developer.log('✅ Successfully fetched ${categoryRules.length} rules for category $category', name: 'RulesProvider');

      // Remove existing rules for this category and add new ones
      final updatedRules = state.rules
          .where((rule) => rule.ruleCategory != category)
          .toList()
        ..addAll(categoryRules);

      state = state.copyWith(rules: updatedRules);
    } else {
      developer.log('❌ Failed to refresh rules for category $category: ${result.error}', name: 'RulesProvider');
      state = state.copyWith(errorMessage: result.error);
    }
  }
}

/// Rules state provider
final rulesProvider =
    StateNotifierProvider<RulesNotifier, RulesState>((ref) {
  return RulesNotifier();
});

/// Selected category provider
final selectedCategoryProvider = StateProvider<String?>((ref) => 'all');