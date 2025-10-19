import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/rfid_sticker.dart';
import '../../shared/theme/app_theme.dart';
import 'resident_info_card.dart';

/// Entry decision dialog
class EntryDecisionDialog extends StatefulWidget {
  final RfidSticker sticker;
  final String destination;
  final String? purpose;
  final Function(bool allowed, {String? notes, String? reason}) onDecision;

  const EntryDecisionDialog({
    super.key,
    required this.sticker,
    required this.destination,
    this.purpose,
    required this.onDecision,
  });

  @override
  State<EntryDecisionDialog> createState() => _EntryDecisionDialogState();
}

class _EntryDecisionDialogState extends State<EntryDecisionDialog> {
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  // Predefined denial reasons
  static const List<String> _denialReasons = [
    'Invalid RFID sticker',
    'Sticker expired',
    'Sticker disabled',
    'Unauthorized person',
    'Unknown vehicle',
    'Wrong destination',
    'Other (specify)',
  ];

  String? _selectedDenialReason;

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      await widget.onDecision(
        true,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving entry: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleDeny() async {
    if (_selectedDenialReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for denial'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    if (_selectedDenialReason == 'Other (specify)' && _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify the reason'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final reason = _selectedDenialReason == 'Other (specify)'
          ? _reasonController.text.trim()
          : _selectedDenialReason;

      await widget.onDecision(
        false,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        reason: reason,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error denying entry: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resident info card
                    ResidentInfoCard(
                      sticker: widget.sticker,
                      showActions: false,
                    ),
                    const SizedBox(height: 24),

                    // Destination info
                    _buildDestinationInfo(),
                    const SizedBox(height: 24),

                    // Notes field
                    _buildNotesField(),
                    const SizedBox(height: 24),

                    // Denial reason selection
                    _buildDenialReasonSelection(),
                  ],
                ),
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.sticker.isValid ? AppTheme.successColor : AppTheme.errorColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            widget.sticker.isValid ? Icons.check_circle : Icons.error,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            widget.sticker.isValid ? 'Verify Entry' : 'Entry Alert',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.sticker.isValid
                ? 'Please verify this resident entry'
                : 'This entry requires attention',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Destination',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.destination,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.purpose != null) ...[
            const SizedBox(height: 8),
            Text(
              'Purpose: ${widget.purpose}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes about this entry...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional - Only add notes if necessary',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildDenialReasonSelection() {
    if (widget.sticker.isValid) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Denial',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please select a reason for denying this entry',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _denialReasons.map((reason) {
            final isSelected = _selectedDenialReason == reason;
            return ChoiceChip(
              label: Text(reason),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDenialReason = selected ? reason : null;
                  if (!selected) {
                    _reasonController.clear();
                  }
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.errorColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.errorColor : Colors.black87,
              ),
            );
          }).toList(),
        ),
        if (_selectedDenialReason == 'Other (specify)') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Specify the reason...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.errorColor),
              ),
              filled: true,
              fillColor: Colors.red[50],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (widget.sticker.isValid) ...[
            // Deny button for valid stickers
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {
                  setState(() => _selectedDenialReason = 'Manual denial');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.errorColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block,
                            size: 20,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Deny',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Approve button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Allow Entry',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ] else ...[
            // Only deny button for invalid stickers
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDeny,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.block, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Deny Entry',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick entry decision dialog for common actions
class QuickEntryDecisionDialog extends StatelessWidget {
  final RfidSticker sticker;
  final String destination;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onDetails;

  const QuickEntryDecisionDialog({
    super.key,
    required this.sticker,
    required this.destination,
    this.onApprove,
    this.onDeny,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 16),
          Text(
            'RFID Verified',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sticker.stickerCode,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          if (sticker.vehicleInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              sticker.vehicleInfo!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Destination: $destination',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        if (onDetails != null)
          TextButton(
            onPressed: onDetails,
            child: const Text('Details'),
          ),
        if (onDeny != null)
          TextButton(
            onPressed: onDeny,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Deny'),
          ),
        if (onApprove != null)
          ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow Entry'),
          ),
      ],
    );
  }
}