import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guest.dart';
import '../../services/household_contact_service.dart';
import '../../shared/theme/app_theme.dart';

/// Guest verification form component
class GuestVerificationForm extends ConsumerStatefulWidget {
  final Guest guest;
  final Function(bool verified, String? notes)? onVerificationComplete;
  final Function(String householdId, String guestName)? onContactHousehold;
  final bool showContactOptions;

  const GuestVerificationForm({
    super.key,
    required this.guest,
    this.onVerificationComplete,
    this.onContactHousehold,
    this.showContactOptions = true,
  });

  @override
  ConsumerState<GuestVerificationForm> createState() => _GuestVerificationFormState();
}

class _GuestVerificationFormState extends ConsumerState<GuestVerificationForm> {
  bool _isVerified = false;
  final List<VerificationItem> _verificationItems = [
    VerificationItem(id: 'name', label: 'Guest name matches registration', isRequired: true),
    VerificationItem(id: 'photo', label: 'Photo verification completed', isRequired: true),
    VerificationItem(id: 'id', label: 'ID verification (if available)', isRequired: false),
    VerificationItem(id: 'purpose', label: 'Purpose of visit confirmed', isRequired: true),
    VerificationItem(id: 'suspicious', label: 'No suspicious items detected', isRequired: true),
    VerificationItem(id: 'behavior', label: 'Behavior appears normal', isRequired: false),
  ];

  final TextEditingController _notesController = TextEditingController();
  bool _isContactingHousehold = false;
  ContactRecord? _lastContactRecord;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isVerified ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: _isVerified ? Colors.green : AppTheme.primaryColor,
                  size: 24,
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
                if (_isVerified) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Guest info summary
            _buildGuestSummary(),
            const SizedBox(height: 16),

            // Verification checklist
            _buildVerificationChecklist(),
            const SizedBox(height: 16),

            // Notes section
            _buildNotesSection(),
            const SizedBox(height: 16),

            // Contact options
            if (widget.showContactOptions) ...[
              _buildContactOptions(),
              const SizedBox(height: 16),
            ],

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(widget.guest.guestName, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(widget.guest.phoneNumber),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.guest.purpose)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Checklist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ..._verificationItems.map((item) => _buildVerificationItem(item)),
      ],
    );
  }

  Widget _buildVerificationItem(VerificationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          InkWell(
            onTap: () => _toggleVerificationItem(item),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isChecked ? Colors.green : Colors.grey,
                  width: 2,
                ),
                color: item.isChecked ? Colors.green : Colors.transparent,
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleVerificationItem(item),
              child: Text(
                item.label,
                style: TextStyle(
                  decoration: item.isChecked ? null : TextDecoration.lineThrough,
                  color: item.isChecked ? Colors.black87 : Colors.grey[600],
                  fontWeight: item.isRequired ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (item.isRequired)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes about the verification process...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildContactOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Household',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (_lastContactRecord != null)
          _buildLastContactInfo(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isContactingHousehold ? null : _callHousehold,
                icon: const Icon(Icons.call, size: 16),
                label: Text(_isContactingHousehold ? 'Calling...' : 'Call Household'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isContactingHousehold ? null : _sendSMS,
                icon: const Icon(Icons.sms, size: 16),
                label: Text(_isContactingHousehold ? 'Sending...' : 'Send SMS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastContactInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last contact: ${_formatContactType(_lastContactRecord!.contactType)} at ${_formatTime(_lastContactRecord!.timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canVerify = _verificationItems.where((item) => item.isRequired).every((item) => item.isChecked);

    return Column(
      children: [
        if (canVerify)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeVerification(true),
              icon: const Icon(Icons.check),
              label: const Text('Verify Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _completeVerification(false),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Deny Verification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () {
                  if (widget.onVerificationComplete != null) {
                    widget.onVerificationComplete!(false, null);
                  }
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleVerificationItem(VerificationItem item) {
    setState(() {
      item.isChecked = !item.isChecked;
      _isVerified = _verificationItems.every((i) => i.isChecked);
    });
  }

  void _callHousehold() async {
    setState(() {
      _isContactingHousehold = true;
    });

    try {
      // Mock contact service call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isContactingHousehold = false;
        _lastContactRecord = ContactRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          householdId: widget.guest.householdId,
          contactType: ContactType.call,
          contactPerson: 'Household Head',
          contactInfo: '+1234567890',
          timestamp: DateTime.now(),
          guestName: widget.guest.guestName,
          initiatedBy: 'guard-1',
          success: true,
          message: 'Call completed successfully',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call placed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isContactingHousehold = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendSMS() async {
    setState(() {
      _isContactingHousehold = true;
    });

    try {
      // Mock SMS service call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isContactingHousehold = false;
        _lastContactRecord = ContactRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          householdId: widget.guest.householdId,
          contactType: ContactType.sms,
          contactPerson: 'Household Head',
          contactInfo: '+1234567890',
          timestamp: DateTime.now(),
          guestName: widget.guest.guestName,
          initiatedBy: 'guard-1',
          success: true,
          message: 'SMS sent successfully',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isContactingHousehold = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _completeVerification(bool verified) {
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (widget.onVerificationComplete != null) {
      widget.onVerificationComplete!(verified, notes);
    }
  }

  String _formatContactType(ContactType type) {
    switch (type) {
      case ContactType.call:
        return 'Call';
      case ContactType.sms:
        return 'SMS';
      case ContactType.approval:
        return 'Approval';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Verification item for checklist
class VerificationItem {
  final String id;
  final String label;
  final bool isRequired;
  bool isChecked;

  VerificationItem({
    required this.id,
    required this.label,
    required this.isRequired,
    this.isChecked = false,
  });
}

/// Compact guest verification widget for use in tight spaces
class CompactGuestVerification extends StatelessWidget {
  final Guest guest;
  final bool isVerified;
  final VoidCallback? onTap;

  const CompactGuestVerification({
    super.key,
    required this.guest,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          child: Icon(
            isVerified ? Icons.verified_user : Icons.person_search,
            color: isVerified ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          guest.guestName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verification ${isVerified ? "Completed" : "Pending"}'),
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
            color: isVerified ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isVerified ? 'Verified' : 'Pending',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}