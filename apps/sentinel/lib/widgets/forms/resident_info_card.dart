import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/rfid_sticker.dart';
import '../../models/entry_log.dart';
import '../../shared/theme/app_theme.dart';

/// Resident information display card
class ResidentInfoCard extends StatelessWidget {
  final RfidSticker sticker;
  final EntryLog? entryLog;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onDetails;

  const ResidentInfoCard({
    super.key,
    required this.sticker,
    this.entryLog,
    this.showActions = true,
    this.onApprove,
    this.onDeny,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(context),
            const SizedBox(height: 16),

            // RFID sticker info
            _buildStickerInfo(),
            const SizedBox(height: 16),

            // Vehicle info
            if (sticker.vehicleInfo != null) ...[
              _buildVehicleInfo(),
              const SizedBox(height: 16),
            ],

            // Status and dates
            _buildStatusInfo(),
            const SizedBox(height: 16),

            // Action buttons
            if (showActions) ...[
              _buildActionButtons(),
            ] else if (onDetails != null) ...[
              _buildDetailsButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.successColor),
          ),
          child: const Icon(
            Icons.home,
            color: AppTheme.successColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resident Entry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'RFID Verified',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onDetails != null)
          IconButton(
            onPressed: onDetails,
            icon: const Icon(Icons.info_outline),
            tooltip: 'View Details',
          ),
      ],
    );
  }

  Widget _buildStickerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariantColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'RFID Sticker',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Code', sticker.stickerCode),
          const SizedBox(height: 8),
          _buildInfoRow('Status', sticker.statusDisplayText),
          if (sticker.isExpiringSoon) ...[
            const SizedBox(height: 8),
            _buildExpiryWarning(),
          ],
          if (sticker.isExpired) ...[
            const SizedBox(height: 8),
            _buildExpiredWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                size: 20,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sticker.vehicleInfo!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sticker.licensePlate != null) ...[
            const SizedBox(height: 4),
            Text(
              'License: ${sticker.licensePlate}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.outlineColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateRow(
          'Issued',
          sticker.issuedAt,
          Icons.calendar_today,
        ),
        const SizedBox(height: 8),
        _buildDateRow(
          'Expires',
          sticker.expiresAt,
          Icons.event_busy,
          showWarning: sticker.isExpiringSoon || sticker.isExpired,
        ),
        if (sticker.lastUsedAt != null) ...[
          const SizedBox(height: 8),
          _buildDateRow(
            'Last Used',
            sticker.lastUsedAt!,
            Icons.access_time,
          ),
        ],
        if (entryLog != null) ...[
          const SizedBox(height: 8),
          _buildDateRow(
            'Current Entry',
            entryLog!.entryTime,
            Icons.login,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.outlineColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date, IconData icon, {bool showWarning = false}) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('h:mm a').format(date);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: showWarning ? Colors.orange : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: showWarning ? Colors.orange : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: showWarning ? Colors.orange : null,
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.outlineColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            size: 16,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Expires in ${sticker.daysUntilExpiration} days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'RFID sticker has expired',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onDeny?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.errorColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 20,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deny Entry',
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
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              onApprove?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 20,
                ),
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
      ],
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onDetails,
        icon: const Icon(Icons.info_outline),
        label: const Text('View Details'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Compact resident info card for lists
class CompactResidentInfoCard extends StatelessWidget {
  final RfidSticker sticker;
  final VoidCallback? onTap;
  final bool showStatus;

  const CompactResidentInfoCard({
    super.key,
    required this.sticker,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),

              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sticker.stickerCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (sticker.vehicleInfo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sticker.vehicleInfo!,
                        style: TextStyle(
                          color: AppTheme.outlineColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status text
              if (showStatus) ...[
                Text(
                  sticker.statusDisplayText,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],

              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppTheme.outlineColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (sticker.status) {
      case RfidStatus.active:
        if (sticker.isExpired) return AppTheme.errorColor;
        if (sticker.isExpiringSoon) return Colors.orange;
        return AppTheme.successColor;
      case RfidStatus.expired:
        return AppTheme.errorColor;
      case RfidStatus.disabled:
      case RfidStatus.lost:
        return AppTheme.errorColor;
    }
  }
}