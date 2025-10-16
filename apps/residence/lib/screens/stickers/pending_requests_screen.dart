import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../providers/sticker_provider.dart';
import '../../widgets/shared/error_widget.dart' as custom;
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/stickers/sticker_card.dart';

/// Pending sticker requests list screen
/// Shows all pending and approved sticker requests
class PendingRequestsScreen extends ConsumerStatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  ConsumerState<PendingRequestsScreen> createState() =>
      _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends ConsumerState<PendingRequestsScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stickerProvider);

    developer.log('Building pending requests screen', name: 'PendingRequests');
    developer.log('Loading state: ${state.isLoading}', name: 'PendingRequests');
    developer.log('Requests count: ${state.pendingRequests.length}', name: 'PendingRequests');
    developer.log('Selected filter: $_selectedFilter', name: 'PendingRequests');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticker Requests'),
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
    );
  }

  Widget _buildBody(StickerState state) {
    if (state.isLoading && state.pendingRequests.isEmpty) {
      return const LoadingWidget(message: 'Loading sticker requests...');
    }

    if (state.error != null && state.pendingRequests.isEmpty) {
      return custom.AppErrorWidget(
        message: state.error!,
        onRetry: () => _refreshData(),
      );
    }

    // Filter requests based on selected filter
    final filteredRequests = state.pendingRequests.where((request) {
      if (_selectedFilter == 'pending') {
        return request.isPending;
      } else if (_selectedFilter == 'approved') {
        return request.isApproved;
      }
      return true; // 'all'
    }).toList();

    developer.log('Filtered requests: ${filteredRequests.length}', name: 'PendingRequests');

    return Column(
      children: [
        // Filter chips
        _buildFilterChips(state),

        // Requests list
        if (filteredRequests.isEmpty)
          Expanded(child: _buildEmptyState())
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return StickerCard(
                    request: request,
                    onTap: () => _navigateToDetails(context, request.id),
                    onCancel: request.isPending
                        ? () => _showCancelConfirmation(context, request.id)
                        : null,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips(StickerState state) {
    final pendingCount =
        state.pendingRequests.where((r) => r.isPending).length;
    final approvedCount =
        state.pendingRequests.where((r) => r.isApproved).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: Text('All (${state.pendingRequests.length})'),
              selected: _selectedFilter == 'all',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = 'all');
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('Pending ($pendingCount)'),
              selected: _selectedFilter == 'pending',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = 'pending');
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('Approved ($approvedCount)'),
              selected: _selectedFilter == 'approved',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = 'approved');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String description;

    switch (_selectedFilter) {
      case 'pending':
        message = 'No Pending Requests';
        description = 'You have no sticker requests awaiting approval';
        break;
      case 'approved':
        message = 'No Approved Requests';
        description = 'You have no approved stickers ready for pickup';
        break;
      default:
        message = 'No Sticker Requests';
        description = 'You haven\'t requested any vehicle stickers yet';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    developer.log('Refreshing sticker data...', name: 'PendingRequests');
    await ref.read(stickerProvider.notifier).refreshData();
    developer.log('Sticker data refresh completed', name: 'PendingRequests');
  }

  void _navigateToDetails(BuildContext context, String requestId) {
    developer.log('Navigating to sticker details: $requestId', name: 'PendingRequests');
    context.push('/stickers/details/$requestId');
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    String requestId,
  ) async {
    developer.log('Showing cancel confirmation for request: $requestId', name: 'PendingRequests');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this sticker request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      developer.log('User confirmed cancellation of request: $requestId', name: 'PendingRequests');
      await _cancelRequest(context, requestId);
    } else {
      developer.log('User cancelled sticker request cancellation', name: 'PendingRequests');
    }
  }

  Future<void> _cancelRequest(BuildContext context, String requestId) async {
    developer.log('Cancelling sticker request: $requestId', name: 'PendingRequests');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await ref
        .read(stickerProvider.notifier)
        .cancelRequest(requestId: requestId);

    if (!context.mounted) return;

    // Dismiss loading indicator
    Navigator.of(context).pop();

    developer.log('Sticker request cancellation completed', name: 'PendingRequests');
    developer.log('Success: ${result.success}', name: 'PendingRequests');
    developer.log('Error: ${result.error}', name: 'PendingRequests');

    if (result.success) {
      developer.log('Sticker request cancelled successfully: $requestId', name: 'PendingRequests');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      developer.log('ERROR cancelling sticker request: ${result.error}', name: 'PendingRequests');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to cancel request'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _cancelRequest(context, requestId),
          ),
        ),
      );
    }
  }
}
