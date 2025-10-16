import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/beneficial_user.dart';
import '../../providers/beneficial_user_provider.dart';
import '../../widgets/beneficial_users/beneficial_user_card.dart';

/// Beneficial users list screen with status filter
class BeneficialUsersListScreen extends ConsumerStatefulWidget {
  const BeneficialUsersListScreen({super.key});

  @override
  ConsumerState<BeneficialUsersListScreen> createState() =>
      _BeneficialUsersListScreenState();
}

class _BeneficialUsersListScreenState
    extends ConsumerState<BeneficialUsersListScreen> {
  String _selectedFilter = 'all'; // all, active, inactive

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficialUsersProvider);
    final notifier = ref.read(beneficialUsersProvider.notifier);

    // Filter users based on selected filter
    final filteredUsers = _filterUsers(state.users);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficial Users'),
        actions: [
          if (state.isOffline)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_off, size: 20),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(state),
          const Divider(height: 1),

          // User list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refreshUsers(),
              child: state.isLoading && state.users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BeneficialUserCard(
                                user: user,
                                onTap: () => _navigateToDetails(user),
                                onEdit: () => _navigateToEdit(user.id),
                                onDelete: () => _confirmDelete(context, user),
                                onToggleStatus: () => _toggleStatus(user.id),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(BeneficialUsersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All (${state.users.length})',
            value: 'all',
            selected: _selectedFilter == 'all',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Active (${state.activeCount})',
            value: 'active',
            selected: _selectedFilter == 'active',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Inactive (${state.inactiveCount})',
            value: 'inactive',
            selected: _selectedFilter == 'inactive',
          ),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool selected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
    );
  }

  /// Filter users based on selected filter
  List<BeneficialUser> _filterUsers(List<BeneficialUser> users) {
    switch (_selectedFilter) {
      case 'active':
        return users.where((user) => user.isActive).toList();
      case 'inactive':
        return users.where((user) => user.isInactive).toList();
      default:
        return users;
    }
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_disabled,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No beneficial users yet'
                : 'No $_selectedFilter users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Add beneficial users to grant access privileges'
                : 'Try changing the filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to add screen
  void _navigateToAdd() {
    context.push('/beneficial-users/add');
  }

  /// Navigate to edit screen
  void _navigateToEdit(String userId) {
    context.push('/beneficial-users/edit/$userId');
  }

  /// Navigate to details screen
  void _navigateToDetails(BeneficialUser user) {
    // TODO: Implement details screen in future phase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Details for ${user.fullName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Toggle user status
  Future<void> _toggleStatus(String userId) async {
    final notifier = ref.read(beneficialUsersProvider.notifier);
    final success = await notifier.toggleUserStatus(userId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated')),
      );
    } else {
      final errorMessage = ref.read(beneficialUsersProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  /// Confirm delete with cascade warning
  Future<void> _confirmDelete(BuildContext context, BeneficialUser user) async {
    final notifier = ref.read(beneficialUsersProvider.notifier);

    // Check for active stickers
    final hasStickers = await notifier.hasActiveStickers(user.id);

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Beneficial User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove ${user.fullName}?'),
            if (hasStickers) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This user has active vehicle stickers. They will be deactivated.',
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await notifier.removeUser(user.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beneficial user removed')),
        );
      } else {
        final errorMessage = ref.read(beneficialUsersProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }
}
