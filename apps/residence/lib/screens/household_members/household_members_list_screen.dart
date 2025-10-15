import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/household_member.dart';
import '../../providers/household_provider.dart';
import '../../widgets/household_members/household_member_card.dart';
import '../../widgets/shared/error_widget.dart' as custom;
import '../../widgets/shared/loading_widget.dart';

/// Household members list screen
/// Displays all household members with pull-to-refresh and offline indicator
class HouseholdMembersListScreen extends ConsumerStatefulWidget {
  const HouseholdMembersListScreen({super.key});

  @override
  ConsumerState<HouseholdMembersListScreen> createState() =>
      _HouseholdMembersListScreenState();
}

class _HouseholdMembersListScreenState
    extends ConsumerState<HouseholdMembersListScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Members'),
        actions: [
          if (state.isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Chip(
                  label: Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMember(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildBody(HouseholdMembersState state) {
    if (state.isLoading && state.members.isEmpty) {
      return const LoadingWidget(message: 'Loading household members...');
    }

    if (state.error != null && state.members.isEmpty) {
      return custom.AppErrorWidget(
        message: state.error!,
        onRetry: () => _refreshMembers(),
      );
    }

    if (state.members.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshMembers,
      child: Column(
        children: [
          if (state.error != null && state.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.members.length,
              itemBuilder: (context, index) {
                final member = state.members[index];
                return HouseholdMemberCard(
                  member: member,
                  onTap: () => _navigateToEditMember(context, member),
                  onDelete: () => _showDeleteConfirmation(context, member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Household Members',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first household member to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddMember(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshMembers() async {
    await ref.read(householdMembersProvider.notifier).refreshMembers();
  }

  void _navigateToAddMember(BuildContext context) {
    context.push('/household-members/add').then((_) => _refreshMembers());
  }

  void _navigateToEditMember(BuildContext context, HouseholdMember member) {
    context
        .push('/household-members/edit/${member.id}')
        .then((_) => _refreshMembers());
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    HouseholdMember member,
  ) async {
    // Check if member has active stickers
    final hasStickers = await ref
        .read(householdMembersProvider.notifier)
        .hasActiveStickers(memberId: member.id);

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Household Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove ${member.fullName}?'),
            if (hasStickers.success && hasStickers.data == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This member has active stickers. Removing them will deactivate all associated stickers.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteMember(context, member);
    }
  }

  Future<void> _deleteMember(
    BuildContext context,
    HouseholdMember member,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await ref
        .read(householdMembersProvider.notifier)
        .removeMember(memberId: member.id);

    if (!context.mounted) return;

    // Dismiss loading indicator
    Navigator.of(context).pop();

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.fullName} removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to remove member'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _deleteMember(context, member),
          ),
        ),
      );
    }
  }
}
