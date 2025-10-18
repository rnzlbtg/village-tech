import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/construction_permit_request.dart';
import '../../providers/permit_provider.dart';
import '../../widgets/permits/permit_card.dart';

/// Construction permits list screen with status filter
class PermitsListScreen extends ConsumerStatefulWidget {
  const PermitsListScreen({super.key});

  @override
  ConsumerState<PermitsListScreen> createState() => _PermitsListScreenState();
}

class _PermitsListScreenState extends ConsumerState<PermitsListScreen> {
  String _selectedFilter = 'all'; // all, pending, approved, completed

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permitProvider);
    final notifier = ref.read(permitProvider.notifier);

    // Filter permits based on selected filter
    final filteredPermits = _filterPermits(state.permits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Permits'),
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(state),
          const Divider(height: 1),

          // Permits list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refreshPermits(),
              child: state.isLoading && state.permits.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPermits.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredPermits.length,
                          itemBuilder: (context, index) {
                            final permit = filteredPermits[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PermitCard(
                                permit: permit,
                                onTap: () => _navigateToDetails(permit.id),
                                onCancel: permit.isPending
                                    ? () => _confirmCancel(permit)
                                    : null,
                                onMarkCompleted: permit.isApproved
                                    ? () => _markCompleted(permit.id)
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSubmit,
        icon: const Icon(Icons.add),
        label: const Text('Submit Permit'),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(PermitState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All (${state.permits.length})',
              value: 'all',
              selected: _selectedFilter == 'all',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Pending (${state.pendingCount})',
              value: 'pending',
              selected: _selectedFilter == 'pending',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Approved (${state.approvedCount})',
              value: 'approved',
              selected: _selectedFilter == 'approved',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Completed (${state.completedCount})',
              value: 'completed',
              selected: _selectedFilter == 'completed',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Rejected (${state.rejectedCount})',
              value: 'rejected',
              selected: _selectedFilter == 'rejected',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Cancelled (${state.cancelledCount})',
              value: 'cancelled',
              selected: _selectedFilter == 'cancelled',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'On Hold (${state.onHoldCount})',
              value: 'on_hold',
              selected: _selectedFilter == 'on_hold',
            ),
          ],
        ),
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

  /// Filter permits based on selected filter
  List<ConstructionPermitRequest> _filterPermits(
      List<ConstructionPermitRequest> permits) {
    switch (_selectedFilter) {
      case 'pending':
        return permits.where((p) => p.isPending).toList();
      case 'approved':
        return permits.where((p) => p.isApproved).toList();
      case 'completed':
        return permits.where((p) => p.isCompleted).toList();
      case 'rejected':
        return permits.where((p) => p.isRejected).toList();
      case 'cancelled':
        return permits.where((p) => p.isCancelled).toList();
      case 'on_hold':
        return permits.where((p) => p.isOnHold).toList();
      default:
        return permits;
    }
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No permit requests yet'
                : 'No $_selectedFilter permits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Submit a construction permit request to get started'
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

  /// Navigate to submit screen
  void _navigateToSubmit() {
    context.push('/permits/submit');
  }

  /// Navigate to details screen
  void _navigateToDetails(String permitId) {
    context.push('/permits/details/$permitId');
  }

  /// Mark permit as completed
  Future<void> _markCompleted(String permitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
          'Are you sure the construction project is completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(permitProvider.notifier);
      final success = await notifier.markAsCompleted(permitId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permit marked as completed')),
        );
      } else {
        final errorMessage = ref.read(permitProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }

  /// Confirm cancel permit
  Future<void> _confirmCancel(ConstructionPermitRequest permit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Permit Request'),
        content: Text(
          'Are you sure you want to cancel the ${permit.projectTypeDisplay} permit request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(permitProvider.notifier);
      final success = await notifier.cancelPermit(permit.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permit request cancelled')),
        );
      } else {
        final errorMessage = ref.read(permitProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }
}
