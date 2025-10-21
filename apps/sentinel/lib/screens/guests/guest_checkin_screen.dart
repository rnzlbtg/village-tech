import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../shared/theme/app_theme.dart';

/// Guest Check-in/Check-out Screen - Interface for processing guest entries/exits
class GuestCheckinScreen extends ConsumerStatefulWidget {
  final String? guestId;
  final Guest? guest;

  const GuestCheckinScreen({
    super.key,
    this.guestId,
    this.guest,
  }) : assert(guestId != null || guest != null, 'Either guestId or guest must be provided');

  @override
  ConsumerState<GuestCheckinScreen> createState() => _GuestCheckinScreenState();
}

class _GuestCheckinScreenState extends ConsumerState<GuestCheckinScreen> {
  late Guest _guest;
  bool _isProcessing = false;
  String? _error;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _initializeGuest();
  }

  void _initializeGuest() {
    if (widget.guest != null) {
      _guest = widget.guest!;
    } else if (widget.guestId != null) {
      // Find guest from provider
      final guestState = ref.read(guestProvider);
      final foundGuest = guestState.guests.firstWhere(
        (guest) => guest.id == widget.guestId,
        orElse: () => throw Exception('Guest not found'),
      );
      _guest = foundGuest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: guestState.isLoading || _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  String _getScreenTitle() {
    if (_guest.isCheckedIn) {
      return 'Guest Check-out';
    } else if (_guest.isCheckedOut) {
      return 'Guest Details';
    } else {
      return 'Guest Check-in';
    }
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest Information Card
          _buildGuestInfoCard(),
          const SizedBox(height: 24),

          // Verification Section
          if (!_guest.isCheckedOut) _buildVerificationSection(),
          if (!_guest.isCheckedOut) const SizedBox(height: 24),

          // Notes Section
          _buildNotesSection(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(_guest.status),
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getStatusColor(_guest.status).withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: _getStatusColor(_guest.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _guest.guestName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_guest.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _guest.statusDisplayText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Guest Details
            _buildDetailRow('Phone Number', _guest.phoneNumber, Icons.phone),
            _buildDetailRow('Purpose of Visit', _guest.purpose, Icons.info),
            _buildDetailRow('Scheduled Date', _formatDate(_guest.scheduledDate), Icons.calendar_today),
            _buildDetailRow('Expected Arrival', _guest.expectedArrival, Icons.access_time),
            _buildDetailRow('Expected Departure', _guest.expectedDeparture, Icons.access_time),

            // Vehicle info if available
            if (_guest.vehicleInfo != null && _guest.vehicleInfo!.isNotEmpty)
              _buildDetailRow('Vehicle', _guest.vehicleInfo!, Icons.directions_car),

            // Notes if available
            if (_guest.notes != null && _guest.notes!.isNotEmpty)
              _buildDetailRow('Registration Notes', _guest.notes!, Icons.note),

            // Actual times if available
            if (_guest.actualArrival != null)
              _buildDetailRow(
                'Actual Arrival',
                _formatDateTime(_guest.actualArrival!),
                Icons.login,
                color: Colors.green,
              ),

            if (_guest.actualDeparture != null)
              _buildDetailRow(
                'Actual Departure',
                _formatDateTime(_guest.actualDeparture!),
                Icons.logout,
                color: Colors.blue,
              ),

            // Visit duration if completed
            if (_guest.visitDuration != null)
              _buildDetailRow(
                'Visit Duration',
                _formatDuration(_guest.visitDuration!),
                Icons.hourglass_bottom,
                color: Colors.purple,
              ),

            // Status indicators
            if (_guest.isLate && _guest.actualArrival != null)
              _buildStatusIndicator(
                'Late Arrival',
                'Arrived after scheduled time',
                Icons.warning,
                Colors.orange,
              ),

            if (_guest.isOverdue && _guest.isCheckedIn)
              _buildStatusIndicator(
                'Overdue',
                'Departure time has passed',
                Icons.warning,
                Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Identity Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Verification checklist
            _buildVerificationItem('Guest name matches registration', true),
            _buildVerificationItem('Phone number verified', true),
            _buildVerificationItem('Guest appears to be the registered person', true),
            _buildVerificationItem('No suspicious items detected', true),

            const SizedBox(height: 16),

            // Photo verification placeholder
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Photo verification placeholder',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem(String text, bool verified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle : Icons.radio_button_unchecked,
            color: verified ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: verified ? Colors.black87 : Colors.grey[600],
                decoration: verified ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Guard Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any notes about this guest visit...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value.trim().isEmpty ? null : value.trim();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_guest.isExpected) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _checkInGuest,
              icon: const Icon(Icons.login),
              label: const Text('Check In Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _denyEntry,
              icon: const Icon(Icons.block),
              label: const Text('Deny Entry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        if (_guest.isCheckedIn) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _checkOutGuest,
              icon: const Icon(Icons.logout),
              label: const Text('Check Out Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        if (_guest.isCheckedOut) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _checkInGuest() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      await ref.read(guestProvider.notifier).checkInGuest(_guest.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_guest.guestName} checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to check in guest: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _checkOutGuest() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      await ref.read(guestProvider.notifier).checkOutGuest(_guest.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_guest.guestName} checked out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to check out guest: $e';
        _isProcessing = false;
      });
    }
  }

  void _denyEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Entry'),
        content: Text('Are you sure you want to deny entry for ${_guest.guestName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelGuestRegistration();
            },
            child: const Text('Deny Entry'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelGuestRegistration() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      await ref.read(guestProvider.notifier).cancelGuest(_guest.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_guest.guestName} registration cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to cancel registration: $e';
        _isProcessing = false;
      });
    }
  }

  Color _getStatusColor(GuestStatus status) {
    switch (status) {
      case GuestStatus.expected:
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}