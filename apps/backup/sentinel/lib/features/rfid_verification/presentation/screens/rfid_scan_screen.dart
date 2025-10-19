import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../core/rfid/nfc_manager_service.dart';

/// RFID Scan screen for scanning RFID stickers
class RfidScanScreen extends ConsumerStatefulWidget {
  const RfidScanScreen({super.key});

  @override
  ConsumerState<RfidScanScreen> createState() => _RfidScanScreenState();
}

class _RfidScanScreenState extends ConsumerState<RfidScanScreen> {
  final NfcManagerService _nfcService = NfcManagerService.instance;
  bool _isScanning = false;
  NfcScanResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initializeNfc();
  }

  Future<void> _initializeNfc() async {
    try {
      final initialized = await _nfcService.initialize();
      if (!initialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NFC is not available on this device'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize NFC: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _lastResult = null;
    });

    try {
      final result = await _nfcService.startScanning(
        timeout: const Duration(seconds: 5),
      );

      if (mounted) {
        setState(() {
          _lastResult = result;
          _isScanning = false;
        });

        if (result != null && result.success) {
          _showSuccessDialog(result);
        } else if (result != null) {
          _showErrorDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanning failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(NfcScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('RFID Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sticker Code: ${result.stickerCode ?? 'Unknown'}'),
            SizedBox(height: 8),
            Text('Time: ${_formatTime(result.timestamp)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(NfcScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            SizedBox(width: 8),
            Text('Scan Failed'),
          ],
        ),
        content: Text(result.error ?? 'Unknown error occurred'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RFID Scanner'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.nfc,
                      size: 48.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'RFID Scanner',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Hold the device near an RFID sticker to scan',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // NFC Status
              StreamBuilder<NfcStatus>(
                stream: _nfcService.statusStream,
                builder: (context, snapshot) {
                  final status = snapshot.data ?? NfcStatus.uninitialized;
                  return _buildStatusCard(status);
                },
              ),

              SizedBox(height: 32.h),

              // Scan Button
              ElevatedButton(
                onPressed: _isScanning ? null : _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: _isScanning
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            'Scanning...',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nfc, size: 24.w),
                          SizedBox(width: 12.w),
                          Text(
                            'Start Scanning',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),

              SizedBox(height: 24.h),

              // Last Result
              if (_lastResult != null) ...[
                Text(
                  'Last Scan Result',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _lastResult!.success
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _lastResult!.success
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!.success ? Icons.check_circle : Icons.error,
                            color: _lastResult!.success ? Colors.green : AppColors.error,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _lastResult!.success ? 'Success' : 'Failed',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _lastResult!.success ? Colors.green : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      if (_lastResult!.success && _lastResult!.stickerCode != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Sticker Code: ${_lastResult!.stickerCode}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                      if (_lastResult!.error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Error: ${_lastResult!.error}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Text(
                        'Time: ${_formatTime(_lastResult!.timestamp)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(NfcStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case NfcStatus.ready:
        statusColor = Colors.green;
        statusText = 'NFC Ready';
        statusIcon = Icons.check_circle;
        break;
      case NfcStatus.scanning:
        statusColor = AppColors.primary;
        statusText = 'Scanning...';
        statusIcon = Icons.nfc;
        break;
      case NfcStatus.success:
        statusColor = Colors.green;
        statusText = 'Scan Successful';
        statusIcon = Icons.check_circle;
        break;
      case NfcStatus.unavailable:
        statusColor = Colors.grey;
        statusText = 'NFC Not Available';
        statusIcon = Icons.block;
        break;
      case NfcStatus.permissionDenied:
        statusColor = Colors.orange;
        statusText = 'NFC Permission Denied';
        statusIcon = Icons.warning;
        break;
      case NfcStatus.timeout:
        statusColor = Colors.orange;
        statusText = 'Scan Timeout';
        statusIcon = Icons.timer_off;
        break;
      case NfcStatus.error:
        statusColor = AppColors.error;
        statusText = 'NFC Error';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'NFC Initializing...';
        statusIcon = Icons.sync;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              statusText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}