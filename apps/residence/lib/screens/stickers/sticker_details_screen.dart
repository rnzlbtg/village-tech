import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../models/sticker_request.dart';
import '../../providers/sticker_provider.dart';
import '../../widgets/shared/loading_widget.dart';

/// Sticker details screen
/// Shows detailed information about a sticker request
class StickerDetailsScreen extends ConsumerStatefulWidget {
  final String requestId;

  const StickerDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<StickerDetailsScreen> createState() =>
      _StickerDetailsScreenState();
}

class _StickerDetailsScreenState extends ConsumerState<StickerDetailsScreen> {
  StickerRequest? _request;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing sticker details screen for request: ${widget.requestId}', name: 'StickerDetails');
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    developer.log('Loading sticker request details...', name: 'StickerDetails');
    developer.log('Request ID: ${widget.requestId}', name: 'StickerDetails');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref
        .read(stickerProvider.notifier)
        .fetchStickerRequest(requestId: widget.requestId);

    developer.log('Sticker request fetch completed', name: 'StickerDetails');
    developer.log('Success: ${result.success}', name: 'StickerDetails');
    developer.log('Error: ${result.error}', name: 'StickerDetails');

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _request = result.data;
          developer.log('Request data loaded successfully', name: 'StickerDetails');
          developer.log('Request status: ${_request?.status}', name: 'StickerDetails');
          developer.log('Vehicle plate: ${_request?.vehiclePlate}', name: 'StickerDetails');
        } else {
          _error = result.error;
          developer.log('Failed to load request: $_error', name: 'StickerDetails');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading request details...'),
      );
    }

    if (_error != null || _request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(_error ?? 'Request not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRequest,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          if (_request!.isPending)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showCancelConfirmation(context),
              tooltip: 'Cancel Request',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequest,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status card
            _buildStatusCard(_request!),
            const SizedBox(height: 16),

            // Vehicle information
            _buildInfoCard(
              context,
              'Vehicle Information',
              Icons.directions_car,
              [
                _buildInfoRow('Plate Number', _request!.vehiclePlate),
                if (_request!.vehicleMake != null)
                  _buildInfoRow('Make/Model', _request!.vehicleMake!),
                if (_request!.vehicleColor != null)
                  _buildInfoRow('Color', _request!.vehicleColor!),
              ],
            ),
            const SizedBox(height: 16),

            // Owner information
            if (_request!.ownerName != null)
              _buildInfoCard(
                context,
                'Owner Information',
                Icons.person,
                [
                  _buildInfoRow('Name', _request!.ownerName!),
                  _buildInfoRow(
                    'Type',
                    OwnerType.displayNames[_request!.ownerType] ??
                        _request!.ownerType,
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Request timeline
            _buildInfoCard(
              context,
              'Request Timeline',
              Icons.timeline,
              [
                _buildInfoRow(
                  'Requested',
                  _formatDateTime(_request!.requestedAt),
                ),
                if (_request!.approvedAt != null)
                  _buildInfoRow(
                    'Approved',
                    _formatDateTime(_request!.approvedAt!),
                  ),
                if (_request!.distributedAt != null)
                  _buildInfoRow(
                    'Distributed',
                    _formatDateTime(_request!.distributedAt!),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Rejection reason (if rejected)
            if (_request!.isRejected && _request!.rejectionReason != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _request!.rejectionReason!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ],
                ),
              ),

            // Pickup instructions (if approved)
            if (_request!.isApproved) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Ready for Pickup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your sticker request has been approved! Please visit the admin office during office hours to collect your vehicle sticker.',
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'What to bring:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildChecklistItem('Valid ID'),
                    _buildChecklistItem('Vehicle registration documents'),
                    _buildChecklistItem('This request reference'),
                    const SizedBox(height: 12),
                    Text(
                      'Note: You will need to sign upon collection.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Distributed info (if distributed)
            if (_request!.isDistributed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Sticker Distributed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your vehicle sticker has been successfully distributed. You can now use it for gate entry.',
                      style: TextStyle(color: Colors.blue.shade800),
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

  Widget _buildStatusCard(StickerRequest request) {
    Color color;
    IconData icon;

    switch (request.status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'distributed':
        color = Colors.blue;
        icon = Icons.verified;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  request.statusDisplay,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.green.shade800),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    developer.log('Showing cancel confirmation for sticker request: ${widget.requestId}', name: 'StickerDetails');

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
      developer.log('User confirmed cancellation of sticker request: ${widget.requestId}', name: 'StickerDetails');
      await _cancelRequest(context);
    } else {
      developer.log('User cancelled sticker request cancellation', name: 'StickerDetails');
    }
  }

  Future<void> _cancelRequest(BuildContext context) async {
    developer.log('Cancelling sticker request from details screen: ${widget.requestId}', name: 'StickerDetails');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ref
        .read(stickerProvider.notifier)
        .cancelRequest(requestId: widget.requestId);

    if (!context.mounted) return;

    Navigator.of(context).pop(); // Dismiss loading

    developer.log('Sticker request cancellation completed', name: 'StickerDetails');
    developer.log('Success: ${result.success}', name: 'StickerDetails');
    developer.log('Error: ${result.error}', name: 'StickerDetails');

    if (result.success) {
      developer.log('Sticker request cancelled successfully from details: ${widget.requestId}', name: 'StickerDetails');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(); // Return to previous screen
    } else {
      developer.log('ERROR cancelling sticker request from details: ${result.error}', name: 'StickerDetails');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to cancel request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
