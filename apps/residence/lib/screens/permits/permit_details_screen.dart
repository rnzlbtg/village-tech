import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/construction_permit_request.dart';
import '../../models/payment_log.dart';
import '../../providers/permit_provider.dart';
import '../../services/permit_service.dart';

/// Permit details screen showing fee, payment status, approval, and permit reference
class PermitDetailsScreen extends ConsumerStatefulWidget {
  final String permitId;

  const PermitDetailsScreen({
    super.key,
    required this.permitId,
  });

  @override
  ConsumerState<PermitDetailsScreen> createState() =>
      _PermitDetailsScreenState();
}

class _PermitDetailsScreenState extends ConsumerState<PermitDetailsScreen> {
  PaymentLog? _paymentLog;
  bool _loadingPayment = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentLog();
  }

  Future<void> _loadPaymentLog() async {
    final result =
        await PermitService.instance.fetchPaymentLog(widget.permitId);
    if (result.isSuccess) {
      setState(() {
        _paymentLog = result.data;
        _loadingPayment = false;
      });
    } else {
      setState(() {
        _loadingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permitProvider);
    final permit = state.permits.firstWhere(
      (p) => p.id == widget.permitId,
      orElse: () => throw Exception('Permit not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permit Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            color: _getStatusColor(permit).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getStatusIcon(permit),
                          color: _getStatusColor(permit)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              permit.statusDisplay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(permit),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (permit.permitReference != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Permit Reference: ${permit.permitReference}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Project details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.construction,
                    'Project Type',
                    permit.projectTypeDisplay,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.description,
                    'Description',
                    permit.description,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Start Date',
                    _formatDate(permit.startDate),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.event,
                    'End Date',
                    _formatDate(permit.endDate),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.access_time,
                    'Duration',
                    '${permit.durationInDays} days',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contractor details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contractor Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.person,
                    'Contractor Name',
                    permit.contractorName,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.phone,
                    'Contact Number',
                    permit.contractorContact,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.people,
                    'Estimated Workers',
                    permit.estimatedWorkers.toString(),
                  ),
                ],
              ),
            ),
          ),

          // Fee and payment card
          if (permit.feeAmount != null) ...[
            const SizedBox(height: 16),
            Card(
              color: permit.feePaid == true
                  ? Colors.green[50]
                  : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          permit.feePaid == true
                              ? Icons.check_circle
                              : Icons.payment,
                          color: permit.feePaid == true
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fee Computation',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₱${permit.feeAmount!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: permit.feePaid == true
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: permit.feePaid == true
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            permit.feePaid == true ? 'PAID' : 'PENDING',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: permit.feePaid == true
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_loadingPayment && _paymentLog != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.payment,
                        'Payment Method',
                        _paymentLog!.paymentMethodDisplay,
                      ),
                      if (_paymentLog!.referenceNumber != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.receipt,
                          'Reference Number',
                          _paymentLog!.referenceNumber!,
                        ),
                      ],
                      if (_paymentLog!.paidAt != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Paid At',
                          _formatDateTime(_paymentLog!.paidAt!),
                        ),
                      ],
                    ],
                    if (permit.feePaid != true) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showPaymentInstructions(permit),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('View Payment Instructions'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Rejection reason
          if (permit.isRejected && permit.rejectionReason != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        const Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(permit.rejectionReason!),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          if (permit.isPending)
            ElevatedButton.icon(
              onPressed: () => _confirmCancel(permit),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
            ),

          if (permit.isApproved) ...[
            ElevatedButton.icon(
              onPressed: () => _markCompleted(permit.id),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ConstructionPermitRequest permit) {
    if (permit.isPending) return Colors.blue;
    if (permit.isFeePending) return Colors.orange;
    if (permit.isApproved) return Colors.green;
    if (permit.isRejected) return Colors.red;
    if (permit.isCompleted) return Colors.grey;
    return Colors.grey;
  }

  IconData _getStatusIcon(ConstructionPermitRequest permit) {
    if (permit.isPending) return Icons.schedule;
    if (permit.isFeePending) return Icons.payment;
    if (permit.isApproved) return Icons.check_circle;
    if (permit.isRejected) return Icons.cancel;
    if (permit.isCompleted) return Icons.done_all;
    return Icons.info;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showPaymentInstructions(ConstructionPermitRequest permit) {
    context.push('/permits/payment-instructions/${permit.id}');
  }

  Future<void> _markCompleted(String permitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content:
            const Text('Are you sure the construction project is completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        context.pop();
      } else {
        final errorMessage = ref.read(permitProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        context.pop();
      } else {
        final errorMessage = ref.read(permitProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }
}
