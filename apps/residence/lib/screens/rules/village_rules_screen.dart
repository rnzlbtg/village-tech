import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rules_provider.dart';
import '../../widgets/rules/rule_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';

/// Village Rules Screen
/// Displays all village rules with category filtering
class VillageRulesScreen extends ConsumerStatefulWidget {
  const VillageRulesScreen({super.key});

  @override
  ConsumerState<VillageRulesScreen> createState() => _VillageRulesScreenState();
}

class _VillageRulesScreenState extends ConsumerState<VillageRulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rulesState = ref.watch(rulesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Rules'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            final categories = ['all', 'general', 'parking', 'noise', 'construction', 'curfew'];
            ref.read(selectedCategoryProvider.notifier).state = categories[index];
          },
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'General', icon: Icon(Icons.info_outline)),
            Tab(text: 'Parking', icon: Icon(Icons.local_parking)),
            Tab(text: 'Noise', icon: Icon(Icons.volume_up)),
            Tab(text: 'Construction', icon: Icon(Icons.construction)),
            Tab(text: 'Curfew', icon: Icon(Icons.access_time)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(rulesProvider.notifier).refreshRules();
        },
        child: _buildBody(rulesState, selectedCategory),
      ),
    );
  }

  Widget _buildBody(rulesState, selectedCategory) {
    if (rulesState.isLoading && rulesState.rules.isEmpty) {
      return const LoadingWidget();
    }

    if (rulesState.errorMessage != null && rulesState.rules.isEmpty) {
      return AppErrorWidget(
        message: rulesState.errorMessage!,
        onRetry: () {
          ref.read(rulesProvider.notifier).refreshRules();
        },
      );
    }

    if (rulesState.rules.isEmpty) {
      return _buildEmptyState();
    }

    final filteredRules = selectedCategory == 'all' || selectedCategory == null
        ? rulesState.rules
        : rulesState.getRulesByCategory(selectedCategory);

    if (filteredRules.isEmpty) {
      return _buildNoRulesForCategory(selectedCategory);
    }

    // Show curfew rules prominently if on curfew tab
    if (selectedCategory == 'curfew' && rulesState.curfewRule != null) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 1,
              itemBuilder: (context, index) {
                return CurfewCard(
                  curfewRule: rulesState.curfewRule!,
                );
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRules.length,
      itemBuilder: (context, index) {
        final rule = filteredRules[index];
        return RuleCard(
          rule: rule,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Village Rules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your village administrator hasn\'t published any rules yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(rulesProvider.notifier).refreshRules();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRulesForCategory(String? category) {
    String categoryName = category ?? 'this category';
    String categoryDescription = '';
    IconData categoryIcon = Icons.info_outline;

    switch (category?.toLowerCase()) {
      case 'general':
        categoryDescription = 'general community guidelines';
        categoryIcon = Icons.info_outline;
        break;
      case 'parking':
        categoryDescription = 'parking regulations';
        categoryIcon = Icons.local_parking;
        break;
      case 'noise':
        categoryDescription = 'noise control rules';
        categoryIcon = Icons.volume_up;
        break;
      case 'construction':
        categoryDescription = 'construction guidelines';
        categoryIcon = Icons.construction;
        break;
      case 'curfew':
        categoryDescription = 'curfew hours';
        categoryIcon = Icons.access_time;
        break;
      default:
        categoryDescription = 'rules in this category';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            categoryIcon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${categoryName.capitalize()} Rules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No $categoryDescription have been published yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = 'all';
              _tabController.animateTo(0);
            },
            icon: const Icon(Icons.list),
            label: const Text('View All Rules'),
          ),
        ],
      ),
    );
  }
}

/// Extension method to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}