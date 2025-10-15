import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';

/// Guest details screen showing check-in/check-out status and visit duration
class GuestDetailsScreen extends ConsumerWidget {
  final String guestId;

  const GuestDetailsScreen({
    super.key,
    required this.guestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guestProvider);
    final notifier = ref.read(guestProvider.notifier);

    final guest = state.guests.firstWhere(
      (g) => g.id == guestId,
      orElse: () => throw Exception('Guest not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Details'),
        actions: [
          if (guest.isScheduled)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/guests/edit/$guestId'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Guest info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: _getStatusColor(guest),
                        child: Text(
                          guest.initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guest.guestName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusBadge(guest),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Visit details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.event,
                    'Visit Type',
                    guest.visitTypeDisplay,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Start',
                    _formatDateTime(guest.visitStart),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.event,
                    'End',
                    _formatDateTime(guest.visitEnd),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.access_time,
                    'Duration',
                    _formatDuration(guest),
                  ),
                  if (guest.isUpcoming) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.timer,
                      'Time Until Visit',
                      guest.countdownString,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contact & vehicle info card
          if (guest.contactNumber != null ||
              guest.vehiclePlate != null ||
              guest.purpose != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (guest.contactNumber != null)
                      _buildDetailRow(
                        Icons.phone,
                        'Contact',
                        guest.contactNumber!,
                      ),
                    if (guest.contactNumber != null &&
                        (guest.vehiclePlate != null || guest.purpose != null))
                      const SizedBox(height: 8),
                    if (guest.vehiclePlate != null)
                      _buildDetailRow(
                        Icons.directions_car,
                        'Vehicle Plate',
                        guest.vehiclePlate!,
                      ),
                    if (guest.vehiclePlate != null && guest.purpose != null)
                      const SizedBox(height: 8),
                    if (guest.purpose != null)
                      _buildDetailRow(
                        Icons.description,
                        'Purpose',
                        guest.purpose!,
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Check-in/out status card
          if (guest.checkInTime != null || guest.checkOutTime != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visit Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (guest.checkInTime != null)
                      _buildDetailRow(
                        Icons.login,
                        'Checked In',
                        _formatDateTime(guest.checkInTime!),
                      ),
                    if (guest.checkInTime != null && guest.checkOutTime != null)
                      const SizedBox(height: 8),
                    if (guest.checkOutTime != null)
                      _buildDetailRow(
                        Icons.logout,
                        'Checked Out',
                        _formatDateTime(guest.checkOutTime!),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          if (guest.isScheduled) ...[
            ElevatedButton.icon(
              onPressed: () => _confirmCancel(context, ref, guest),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Visit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],

          if (guest.isActive && guest.isScheduled) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _checkIn(context, ref, guestId),
              icon: const Icon(Icons.login),
              label: const Text('Check In Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],

          if (guest.isCheckedIn) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _checkOut(context, ref, guestId),
              icon: const Icon(Icons.logout),
              label: const Text('Check Out Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(Guest guest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(guest).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(guest).withOpacity(0.3)),
      ),
      child: Text(
        guest.statusDisplay.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(guest),
        ),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(Guest guest) {
    if (guest.isScheduled) {
      return Colors.blue;
    } else if (guest.isCheckedIn) {
      return Colors.green;
    } else if (guest.isCheckedOut) {
      return Colors.grey;
    } else if (guest.isCancelled) {
      return Colors.red;
    }
    return Colors.grey;
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
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
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute $period';
  }

  /// Format duration
  String _formatDuration(Guest guest) {
    if (guest.isDayTrip) {
      return 'Day Trip (${guest.durationInHours}h)';
    } else {
      return '${guest.durationInDays} day${guest.durationInDays > 1 ? 's' : ''}';
    }
  }

  /// Check in guest
  Future<void> _checkIn(
      BuildContext context, WidgetRef ref, String guestId) async {
    final notifier = ref.read(guestProvider.notifier);
    final success = await notifier.checkInGuest(guestId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest checked in successfully')),
      );
    } else {
      final errorMessage = ref.read(guestProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  /// Check out guest
  Future<void> _checkOut(
      BuildContext context, WidgetRef ref, String guestId) async {
    final notifier = ref.read(guestProvider.notifier);
    final success = await notifier.checkOutGuest(guestId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest checked out successfully')),
      );
    } else {
      final errorMessage = ref.read(guestProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  /// Confirm cancel visit
  Future<void> _confirmCancel(
      BuildContext context, WidgetRef ref, Guest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Guest Visit'),
        content: Text(
          'Are you sure you want to cancel the visit for ${guest.guestName}?',
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

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(guestProvider.notifier);
      final success = await notifier.cancelGuestVisit(guest.id);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest visit cancelled')),
        );
        context.pop();
      } else {
        final errorMessage = ref.read(guestProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }
}
