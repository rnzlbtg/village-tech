import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../providers/sticker_provider.dart';
import '../../widgets/shared/error_widget.dart' as custom;
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/stickers/sticker_card.dart';
import 'dart:math' as math;

/// Sticker allocation dashboard screen
/// Shows allocation status, pending requests, and active stickers
class StickerAllocationScreen extends ConsumerStatefulWidget {
  const StickerAllocationScreen({super.key});

  @override
  ConsumerState<StickerAllocationScreen> createState() =>
      _StickerAllocationScreenState();
}

class _StickerAllocationScreenState
    extends ConsumerState<StickerAllocationScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stickerProvider);

    developer.log('Building sticker allocation screen', name: 'StickerAllocation');
    developer.log('Loading state: ${state.isLoading}', name: 'StickerAllocation');
    developer.log('Has allocation: ${state.allocation != null}', name: 'StickerAllocation');
    developer.log('Pending requests: ${state.pendingRequests.length}', name: 'StickerAllocation');
    developer.log('Active stickers: ${state.activeStickers.length}', name: 'StickerAllocation');

    if (state.allocation != null) {
      developer.log('Allocation usage: ${state.allocation!.used}/${state.allocation!.total}', name: 'StickerAllocation');
      developer.log('Allocation status: ${state.allocation!.allocationStatus}', name: 'StickerAllocation');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Stickers'),
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
      floatingActionButton: state.allocation != null &&
              !state.allocation!.isExceeded
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToRequestSticker(context),
              icon: const Icon(Icons.add),
              label: const Text('Request Sticker'),
            )
          : null,
    );
  }

  Widget _buildBody(StickerState state) {
    if (state.isLoading && state.allocation == null) {
      return const LoadingWidget(message: 'Loading sticker allocation...');
    }

    if (state.error != null && state.allocation == null) {
      return custom.AppErrorWidget(
        message: state.error!,
        onRetry: () => _refreshData(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Allocation status card
          if (state.allocation != null) _buildAllocationCard(state.allocation!),
          const SizedBox(height: 16),

          // Pending requests section
          if (state.pendingRequests.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Pending Requests',
              state.pendingRequests.length,
              onViewAll: () => context.push('/stickers/requests'),
            ),
            const SizedBox(height: 12),
            ...state.pendingRequests.take(3).map((request) {
              return StickerCard(
                request: request,
                onTap: () => _navigateToRequestDetails(context, request.id),
              );
            }),
            if (state.pendingRequests.length > 3)
              TextButton(
                onPressed: () => context.push('/stickers/requests'),
                child: const Text('View All Requests'),
              ),
            const SizedBox(height: 16),
          ],

          // Active stickers section
          if (state.activeStickers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Active Stickers',
              state.activeStickers.length,
            ),
            const SizedBox(height: 12),
            ...state.activeStickers.take(3).map((sticker) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.local_parking,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: Text(
                    sticker.vehiclePlate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Code: ${sticker.stickerCode}'),
                  trailing: Chip(
                    label: Text(
                      sticker.statusDisplay,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.green.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              );
            }),
          ],

          // Empty state
          if (state.pendingRequests.isEmpty && state.activeStickers.isEmpty) ...[
            const SizedBox(height: 32),
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildAllocationCard(allocation) {
    final percentage = allocation.usagePercentage;
    final color = allocation.isExceeded
        ? Colors.red
        : allocation.isAlmostFull
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sticker Allocation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allocation.allocationStatus,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Circular progress indicator
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${allocation.used}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        'of ${allocation.total}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      Text(
                        'used',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Allocation details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAllocationStat(
                  context,
                  'Total',
                  allocation.total.toString(),
                  Colors.blue,
                ),
                _buildAllocationStat(
                  context,
                  'Used',
                  allocation.used.toString(),
                  color,
                ),
                _buildAllocationStat(
                  context,
                  'Available',
                  allocation.available.toString(),
                  allocation.available > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),

            // Warning message
            if (allocation.isExceeded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have reached your sticker allocation limit. Contact admin to request additional stickers.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text('View All ($count)'),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.local_parking_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Sticker Requests Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Request your first vehicle sticker to get started',
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
    developer.log('Refreshing sticker allocation data...', name: 'StickerAllocation');
    await ref.read(stickerProvider.notifier).refreshData();
    developer.log('Sticker allocation data refresh completed', name: 'StickerAllocation');
  }

  void _navigateToRequestSticker(BuildContext context) {
    developer.log('Navigating to request sticker screen', name: 'StickerAllocation');
    context.push('/stickers/request').then((_) {
      developer.log('Returned from request sticker screen, refreshing data', name: 'StickerAllocation');
      _refreshData();
    });
  }

  void _navigateToRequestDetails(BuildContext context, String requestId) {
    developer.log('Navigating to sticker details: $requestId', name: 'StickerAllocation');
    context.push('/stickers/details/$requestId');
  }
}
