import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/nfc_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../widgets/shared/loading_indicator.dart';
import '../../widgets/shared/error_display.dart';
import '../rfid_scanning/manual_verification_screen.dart';

/// RFID scanning state
enum RfidScanState {
  idle,
  initializing,
  scanning,
  processing,
  success,
  error,
  manualVerification,
}

/// RFID scan data
class RfidScanData {
  final String rfidCode;
  final String? stickerType;
  final Map<String, dynamic>? rawData;
  final DateTime scanTime;

  const RfidScanData({
    required this.rfidCode,
    this.stickerType,
    this.rawData,
    required this.scanTime,
  });
}

/// RFID scanning screen provider
class RfidScanProvider extends StateNotifier<RfidScanState> {
  RfidScanProvider() : super(RfidScanState.idle);

  final NfcService _nfcService = NfcService();
  StreamSubscription<NfcScanResult>? _scanSubscription;
  StreamSubscription<NfcScanEvent>? _eventSubscription;
  RfidScanData? _lastScanData;
  String? _lastError;

  RfidScanData? get lastScanData => _lastScanData;
  String? get lastError => _lastError;

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _eventSubscription?.cancel();
    _nfcService.dispose();
    super.dispose();
  }

  Future<void> initializeNfc() async {
    if (state == RfidScanState.initializing) return;

    state = RfidScanState.initializing;

    try {
      await _nfcService.initialize();

      // Listen to scan events
      _eventSubscription = _nfcService.scanEvents.listen((event) {
        switch (event) {
          case NfcScanEvent.scanningStarted:
            state = RfidScanState.scanning;
            break;
          case NfcScanEvent.tagDetected:
            state = RfidScanState.processing;
            break;
          case NfcScanEvent.scanningCompleted:
            // Will be handled in scan results
            break;
          case NfcScanEvent.error:
          case NfcScanEvent.nfcUnavailable:
            state = RfidScanState.error;
            break;
          default:
            break;
        }
      });

      // Listen to scan results
      _scanSubscription = _nfcService.scanResults.listen((result) {
        if (result.isSuccess) {
          _lastScanData = RfidScanData(
            rfidCode: result.rfidCode,
            stickerType: result.stickerType,
            rawData: result.rawData,
            scanTime: result.scanTime,
          );
          state = RfidScanState.success;
        } else {
          _lastError = result.errorMessage;
          state = RfidScanState.error;
        }
      });

      state = RfidScanState.idle;
    } catch (e) {
      _lastError = e.toString();
      state = RfidScanState.error;
    }
  }

  Future<void> startScanning() async {
    if (state == RfidScanState.scanning) return;

    try {
      // Reset state
      _lastScanData = null;
      _lastError = null;

      // Start NFC scanning with configuration
      await _nfcService.startScanning(
        config: const NfcScanConfig(
          timeout: Duration(seconds: 5),
          showAlertDialogs: false,
          soundEnabled: true,
          hapticFeedback: true,
        ),
      );
    } catch (e) {
      _lastError = e.toString();
      state = RfidScanState.error;
    }
  }

  Future<void> stopScanning() async {
    try {
      await _nfcService.stopScanning();
      state = RfidScanState.idle;
    } catch (e) {
      _lastError = e.toString();
      state = RfidScanState.error;
    }
  }

  void reset() {
    _lastScanData = null;
    _lastError = null;
    state = RfidScanState.idle;
  }

  void goToManualVerification() {
    state = RfidScanState.manualVerification;
  }

  void returnFromManualVerification() {
    state = RfidScanState.idle;
  }
}

/// Provider for RFID scanning state
final rfidScanProvider = StateNotifierProvider<RfidScanProvider, RfidScanState>((ref) {
  return RfidScanProvider();
});

/// RFID scanning screen
class RfidScanScreen extends ConsumerStatefulWidget {
  const RfidScanScreen({super.key});

  @override
  ConsumerState<RfidScanScreen> createState() => _RfidScanScreenState();
}

class _RfidScanScreenState extends ConsumerState<RfidScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation for scanning indicator
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);

    // Initialize NFC service on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNfc();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNfc() async {
    await ref.read(rfidScanProvider.notifier).initializeNfc();
  }

  Future<void> _startScanning() async {
    HapticFeedback.lightImpact();
    await ref.read(rfidScanProvider.notifier).startScanning();
  }

  Future<void> _stopScanning() async {
    HapticFeedback.lightImpact();
    await ref.read(rfidScanProvider.notifier).stopScanning();
  }

  void _goToManualVerification() {
    HapticFeedback.mediumImpact();
    ref.read(rfidScanProvider.notifier).goToManualVerification();
  }

  void _resetScan() {
    HapticFeedback.lightImpact();
    ref.read(rfidScanProvider.notifier).reset();
  }

  void _handleScanSuccess(RfidScanData scanData) {
    // Vibrate on successful scan
    HapticFeedback.heavyImpact();

    // Auto-reset after 3 seconds
    _statusTimer?.cancel();
    _statusTimer = Timer(const Duration(seconds: 3), () {
      _resetScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(rfidScanProvider);
    final scanProvider = ref.read(rfidScanProvider.notifier);

    // Handle manual verification navigation
    if (scanState == RfidScanState.manualVerification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ManualVerificationScreen(),
          ),
        ).then((_) {
          scanProvider.returnFromManualVerification();
        });
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('RFID Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // TODO: Show scan history
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Status and instructions
              _buildStatusSection(scanState, scanProvider),

              const SizedBox(height: 32),

              // Main scanning interface
              Expanded(
                child: _buildScanningInterface(scanState),
              ),

              // Action buttons
              _buildActionButtons(scanState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(RfidScanState state, RfidScanProvider scanProvider) {
    String title;
    String subtitle;
    Color textColor;

    switch (state) {
      case RfidScanState.idle:
        title = 'Ready to Scan';
        subtitle = 'Hold device near RFID sticker';
        textColor = Colors.white;
        break;
      case RfidScanState.initializing:
        title = 'Initializing...';
        subtitle = 'Setting up NFC scanner';
        textColor = Colors.white70;
        break;
      case RfidScanState.scanning:
        title = 'Scanning...';
        subtitle = 'Move device closer to the sticker';
        textColor = Colors.white;
        break;
      case RfidScanState.processing:
        title = 'Processing...';
        subtitle = 'Reading sticker data';
        textColor = Colors.white;
        break;
      case RfidScanState.success:
        title = 'Scan Successful!';
        subtitle = 'RFID sticker detected';
        textColor = AppTheme.successColor;
        break;
      case RfidScanState.error:
        title = 'Scan Failed';
        subtitle = scanProvider.lastError ?? 'Unknown error occurred';
        textColor = AppTheme.errorColor;
        break;
      case RfidScanState.manualVerification:
        title = 'Manual Verification';
        subtitle = 'Alternative verification method';
        textColor = Colors.white;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScanningInterface(RfidScanState state) {
    switch (state) {
      case RfidScanState.idle:
        return _buildIdleInterface();
      case RfidScanState.initializing:
        return _buildInitializingInterface();
      case RfidScanState.scanning:
        return _buildScanningActiveInterface();
      case RfidScanState.processing:
        return _buildProcessingInterface();
      case RfidScanState.success:
        return _buildSuccessInterface();
      case RfidScanState.error:
        return _buildErrorInterface();
      case RfidScanState.manualVerification:
        return _buildManualVerificationInterface();
    }
  }

  Widget _buildIdleInterface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.nfc,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tap the button below to start scanning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitializingInterface() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(color: Colors.white),
          SizedBox(height: 24),
          Text(
            'Initializing NFC scanner...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningActiveInterface() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.nfc,
                size: 100,
                color: AppTheme.successColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingInterface() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(color: Colors.white),
          SizedBox(height: 24),
          Text(
            'Processing RFID data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessInterface() {
    final scanData = ref.read(rfidScanProvider.notifier).lastScanData;
    if (scanData == null) return const SizedBox.shrink();

    _handleScanSuccess(scanData);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.successColor,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 100,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'RFID Code',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scanData.rfidCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                if (scanData.stickerType != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${scanData.stickerType}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorInterface() {
    final error = ref.read(rfidScanProvider.notifier).lastError;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.errorColor,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 100,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 24),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualVerificationInterface() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(color: Colors.white),
          SizedBox(height: 24),
          Text(
            'Opening manual verification...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RfidScanState state) {
    switch (state) {
      case RfidScanState.idle:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nfc, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Start Scanning',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _goToManualVerification,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Manual Verification',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      case RfidScanState.scanning:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _stopScanning,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: Colors.white),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop, size: 24),
                SizedBox(width: 12),
                Text(
                  'Stop Scanning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      case RfidScanState.success:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _resetScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Scan Another',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      case RfidScanState.error:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _resetScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _goToManualVerification,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Manual Verification',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}