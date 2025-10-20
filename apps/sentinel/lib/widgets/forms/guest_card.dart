import 'package:flutter/material.dart';
import '../../models/guest.dart';
import '../../shared/theme/app_theme.dart';

/// Guest card widget for displaying guest information in lists
class GuestCard extends StatelessWidget {
  final Guest guest;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCheckOut;
  final VoidCallback? onCancel;

  const GuestCard({
    super.key,
    required this.guest,
    this.onTap,
    this.onCheckIn,
    this.onCheckOut,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(guest.status),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusColor(guest.status).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with guest name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      guest.guestName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(guest.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      guest.statusDisplayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Guest details
              _buildDetailRow('Phone', guest.phoneNumber, Icons.phone),
              _buildDetailRow('Purpose', guest.purpose, Icons.info),
              _buildDetailRow('Scheduled',
                '${_formatDate(guest.scheduledDate)} at ${guest.expectedArrival}',
                Icons.calendar_today,
              ),

              // Time information
              if (guest.actualArrival != null)
                _buildDetailRow('Arrived',
                  _formatDateTime(guest.actualArrival!),
                  Icons.login,
                  color: Colors.green,
                ),

              if (guest.actualDeparture != null)
                _buildDetailRow('Departed',
                  _formatDateTime(guest.actualDeparture!),
                  Icons.logout,
                  color: Colors.blue,
                ),

              if (guest.isOverdue && guest.isCheckedIn)
                _buildDetailRow('Overdue',
                  'Expected departure: ${guest.expectedDeparture}',
                  Icons.warning,
                  color: Colors.orange,
                ),

              if (guest.isLate && guest.actualArrival != null)
                _buildDetailRow('Late Arrival',
                  'Expected: ${guest.expectedArrival}',
                  Icons.schedule,
                  color: Colors.red,
                ),

              // Vehicle info if available
              if (guest.vehicleInfo != null && guest.vehicleInfo!.isNotEmpty)
                _buildDetailRow('Vehicle', guest.vehicleInfo!, Icons.directions_car),

              // Notes if available
              if (guest.notes != null && guest.notes!.isNotEmpty)
                _buildDetailRow('Notes', guest.notes!, Icons.note),

              const SizedBox(height: 12),

              // Action buttons
              if (onCheckIn != null || onCheckOut != null || onCancel != null)
                _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onCheckIn != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCheckIn,
              icon: const Icon(Icons.login, size: 16),
              label: const Text('Check In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (onCancel != null) const SizedBox(width: 8),
        ],

        if (onCheckOut != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCheckOut,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Check Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        if (onCancel != null && onCheckIn == null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        if (onTap != null && onCheckIn == null && onCheckOut == null && onCancel == null)
          Expanded(
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(GuestStatus status) {
    switch (status) {
      case GuestStatus.pending:
        return Colors.orange;
      case GuestStatus.checkedIn:
        return Colors.green;
      case GuestStatus.checkedOut:
        return Colors.blue;
      case GuestStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact guest card widget for use in tight spaces
class CompactGuestCard extends StatelessWidget {
  final Guest guest;
  final VoidCallback? onTap;

  const CompactGuestCard({
    super.key,
    required this.guest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(guest.status).withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: _getStatusColor(guest.status),
          ),
        ),
        title: Text(
          guest.guestName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guest.phoneNumber),
            const SizedBox(height: 2),
            Text(
              '${_formatDate(guest.scheduledDate)} at ${guest.expectedArrival}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(guest.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            guest.statusDisplayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(GuestStatus status) {
    switch (status) {
      case GuestStatus.pending:
        return Colors.orange;
      case GuestStatus.checkedIn:
        return Colors.green;
      case GuestStatus.checkedOut:
        return Colors.blue;
      case GuestStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}