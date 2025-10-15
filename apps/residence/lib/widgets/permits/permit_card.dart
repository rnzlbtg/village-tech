import 'package:flutter/material.dart';
import '../../models/construction_permit_request.dart';

/// Permit card widget with status badge and project timeline
class PermitCard extends StatelessWidget {
  final ConstructionPermitRequest permit;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onMarkCompleted;

  const PermitCard({
    super.key,
    required this.permit,
    this.onTap,
    this.onCancel,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          permit.projectTypeDisplay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          permit.contractorName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Project timeline
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(permit.startDate),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(permit.endDate),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Duration badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${permit.durationInDays} days',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),

              // Fee amount if available
              if (permit.feeAmount != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: permit.feePaid == true
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: permit.feePaid == true
                          ? Colors.green[300]!
                          : Colors.orange[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        permit.feePaid == true
                            ? Icons.check_circle
                            : Icons.payment,
                        size: 16,
                        color: permit.feePaid == true
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${permit.feeAmount!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: permit.feePaid == true
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        permit.feePaid == true ? '(Paid)' : '(Pending)',
                        style: TextStyle(
                          fontSize: 12,
                          color: permit.feePaid == true
                              ? Colors.green[600]
                              : Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              if (_shouldShowActions()) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (permit.isApproved && onMarkCompleted != null)
                      TextButton.icon(
                        onPressed: onMarkCompleted,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Mark Complete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    if (permit.isPending && onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        permit.statusDisplay.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor() {
    if (permit.isPending) {
      return Colors.blue;
    } else if (permit.isFeePending) {
      return Colors.orange;
    } else if (permit.isApproved) {
      return Colors.green;
    } else if (permit.isRejected) {
      return Colors.red;
    } else if (permit.isCompleted) {
      return Colors.grey;
    }
    return Colors.grey;
  }

  /// Format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Check if should show action buttons
  bool _shouldShowActions() {
    return (permit.isPending && onCancel != null) ||
        (permit.isApproved && onMarkCompleted != null);
  }
}
