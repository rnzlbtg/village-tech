import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rfid_sticker.dart';
import '../models/entry_log.dart';
import '../models/guard.dart';
import '../services/nfc_service.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';

/// RFID scanning state
enum RfidState {
  idle,
  initializing,
  scanning,
  processing,
  success,
  error,
  disabled,
}

/// RFID scan result with validation
class RfidScanResult {
  final String rfidCode;
  final RfidSticker? sticker;
  final bool isValid;
  final String? error;
  final DateTime scanTime;

  const RfidScanResult({
    required this.rfidCode,
    this.sticker,
    required this.isValid,
    this.error,
    required this.scanTime,
  });

  factory RfidScanResult.success({
    required String rfidCode,
    RfidSticker? sticker,
  }) {
    return RfidScanResult(
      rfidCode: rfidCode,
      sticker: sticker,
      isValid: true,
      scanTime: DateTime.now(),
    );
  }

  factory RfidScanResult.error({
    required String rfidCode,
    required String error,
  }) {
    return RfidScanResult(
      rfidCode: rfidCode,
      isValid: false,
      error: error,
      scanTime: DateTime.now(),
    );
  }
}

/// RFID provider state
class RfidStateData {
  final RfidState state;
  final RfidScanResult? lastScanResult;
  final List<RfidSticker> cachedStickers;
  final bool isOnline;
  final String? errorMessage;

  const RfidStateData({
    required this.state,
    this.lastScanResult,
    this.cachedStickers = const [],
    this.isOnline = true,
    this.errorMessage,
  });

  RfidStateData copyWith({
    RfidState? state,
    RfidScanResult? lastScanResult,
    List<RfidSticker>? cachedStickers,
    bool? isOnline,
    String? errorMessage,
  }) {
    return RfidStateData(
      state: state ?? this.state,
      lastScanResult: lastScanResult ?? this.lastScanResult,
      cachedStickers: cachedStickers ?? this.cachedStickers,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// RFID provider for state management
class RfidProvider extends StateNotifier<RfidStateData> {
  final NfcService _nfcService;
  final SupabaseService _supabaseService;
  final OfflineCacheService _cacheService;

  StreamSubscription<NfcScanResult>? _scanSubscription;
  StreamSubscription<NfcScanEvent>? _eventSubscription;
  Timer? _statusTimer;

  RfidProvider({
    required NfcService nfcService,
    required SupabaseService supabaseService,
    required OfflineCacheService cacheService,
  }) : _nfcService = nfcService,
       _supabaseService = supabaseService,
       _cacheService = cacheService,
       super(const RfidStateData(state: RfidState.idle));

  /// Initialize the RFID provider
  Future<void> initialize() async {
    if (state.state == RfidState.initializing) return;

    state = state.copyWith(state: RfidState.initializing);

    try {
      // Initialize NFC service
      await _nfcService.initialize();

      // Listen to NFC events
      _eventSubscription = _nfcService.scanEvents.listen(_handleNfcEvent);

      // Listen to scan results
      _scanSubscription = _nfcService.scanResults.listen(_handleScanResult);

      // Load cached stickers
      await _loadCachedStickers();

      // Periodic status check
      _startStatusMonitoring();

      state = state.copyWith(state: RfidState.idle);
    } catch (e) {
      state = state.copyWith(
        state: RfidState.error,
        errorMessage: 'Failed to initialize RFID: $e',
      );
    }
  }

  /// Start RFID scanning
  Future<void> startScanning({Duration? timeout}) async {
    if (state.state == RfidState.scanning) return;

    try {
      // Clear previous results
      state = state.copyWith(
        state: RfidState.scanning,
        lastScanResult: null,
        errorMessage: null,
      );

      await _nfcService.startScanning(
        config: NfcScanConfig(
          timeout: timeout ?? const Duration(seconds: 5),
          showAlertDialogs: false,
          soundEnabled: true,
          hapticFeedback: true,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        state: RfidState.error,
        errorMessage: 'Failed to start scanning: $e',
      );
    }
  }

  /// Stop RFID scanning
  Future<void> stopScanning() async {
    if (state.state != RfidState.scanning) return;

    try {
      await _nfcService.stopScanning();
      state = state.copyWith(state: RfidState.idle);
    } catch (e) {
      state = state.copyWith(
        state: RfidState.error,
        errorMessage: 'Failed to stop scanning: $e',
      );
    }
  }

  /// Reset scanning state
  void resetScan() {
    state = state.copyWith(
      state: RfidState.idle,
      lastScanResult: null,
      errorMessage: null,
    );
  }

  /// Simulate scan for testing
  void simulateScan(String rfidCode) {
    if (kDebugMode) {
      _nfcService.simulateScan(rfidCode);
    }
  }

  /// Find RFID sticker by code (offline first)
  Future<RfidSticker?> findStickerByCode(String rfidCode) async {
    try {
      // Try cache first
      final cachedSticker = await _cacheService.findRfidStickerByCode(rfidCode);
      if (cachedSticker != null && cachedSticker.isValid) {
        return cachedSticker;
      }

      // Try online if available
      if (state.isOnline) {
        final response = await _supabaseService.verifyRfidSticker(rfidCode);
        if (response.success && response.data != null) {
          // Cache the result
          await _cacheSticker(response.data!);
          return response.data!;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error finding sticker by code: $e');
      return null;
    }
  }

  /// Get cached stickers
  Future<void> _loadCachedStickers() async {
    try {
      final cachedStickers = await _cacheService.getCachedRfidStickers();
      if (cachedStickers != null) {
        state = state.copyWith(cachedStickers: cachedStickers);
      }
    } catch (e) {
      debugPrint('Error loading cached stickers: $e');
    }
  }

  /// Cache sticker data
  Future<void> _cacheSticker(RfidSticker sticker) async {
    try {
      // Update existing cached stickers
      final updatedStickers = <RfidSticker>[...state.cachedStickers];
      final existingIndex = updatedStickers.indexWhere((s) => s.id == sticker.id);

      if (existingIndex >= 0) {
        updatedStickers[existingIndex] = sticker;
      } else {
        updatedStickers.add(sticker);
      }

      state = state.copyWith(cachedStickers: updatedStickers);

      // Update cache service
      await _cacheService.cacheRfidStickers(updatedStickers);
    } catch (e) {
      debugPrint('Error caching sticker: $e');
    }
  }

  /// Refresh cached stickers from server
  Future<void> refreshStickers() async {
    try {
      if (!state.isOnline) return;

      state = state.copyWith(isOnline: false);

      final response = await _supabaseService.getRfidStickers();
      if (response.success && response.data != null) {
        state = state.copyWith(
          cachedStickers: response.data!,
          isOnline: true,
        );

        // Update cache
        await _cacheService.cacheRfidStickers(response.data!);
      } else {
        throw Exception(response.error ?? 'Failed to fetch stickers');
      }
    } catch (e) {
      state = state.copyWith(
        isOnline: true,
        errorMessage: 'Failed to refresh stickers: $e',
      );
    }
  }

  /// Handle NFC events
  void _handleNfcEvent(NfcScanEvent event) {
    switch (event) {
      case NfcScanEvent.scanningStarted:
        state = state.copyWith(state: RfidState.scanning);
        break;
      case NfcScanEvent.tagDetected:
        state = state.copyWith(state: RfidState.processing);
        break;
      case NfcScanEvent.scanningCompleted:
        // Will be handled in scan results
        break;
      case NfcScanEvent.scanningStopped:
        state = state.copyWith(state: RfidState.idle);
        break;
      case NfcScanEvent.error:
      case NfcScanEvent.nfcUnavailable:
        state = state.copyWith(
          state: RfidState.disabled,
          errorMessage: 'NFC not available on this device',
        );
        break;
      case NfcScanEvent.permissionDenied:
        state = state.copyWith(
          state: RfidState.disabled,
          errorMessage: 'NFC permission denied',
        );
        break;
    }
  }

  /// Handle scan results
  Future<void> _handleScanResult(NfcScanResult scanResult) async {
    if (scanResult.isSuccess) {
      // Validate and find sticker
      final sticker = await findStickerByCode(scanResult.rfidCode);

      if (sticker != null) {
        // Valid sticker found
        state = state.copyWith(
          state: RfidState.success,
          lastScanResult: RfidScanResult.success(
            rfidCode: scanResult.rfidCode,
            sticker: sticker,
          ),
        );

        // Auto-reset after success
        _scheduleAutoReset();
      } else {
        // No valid sticker found
        state = state.copyWith(
          state: RfidState.error,
          lastScanResult: RfidScanResult.error(
            rfidCode: scanResult.rfidCode,
            error: 'RFID sticker not found or inactive',
          ),
        );

        // Auto-reset after error
        _scheduleAutoReset();
      }
    } else {
      // Scan failed
      state = state.copyWith(
        state: RfidState.error,
        lastScanResult: RfidScanResult.error(
          rfidCode: scanResult.rfidCode,
          error: scanResult.errorMessage ?? 'Unknown scan error',
        ),
      );

      // Auto-reset after error
      _scheduleAutoReset();
    }
  }

  /// Schedule automatic reset after scan
  void _scheduleAutoReset() {
    _statusTimer?.cancel();
    _statusTimer = Timer(const Duration(seconds: 3), () {
      resetScan();
    });
  }

  /// Start status monitoring
  void _startStatusMonitoring() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkNfcAvailability();
    });
  }

  /// Check NFC availability
  Future<void> _checkNfcAvailability() async {
    try {
      final availability = await _nfcService.checkNfcAvailability();
      if (availability != NFCAvailability.available && state.state != RfidState.disabled) {
        state = state.copyWith(
          state: RfidState.disabled,
          errorMessage: 'NFC became unavailable',
        );
      } else if (availability == NFCAvailability.available && state.state == RfidState.disabled) {
        state = state.copyWith(
          state: RfidState.idle,
          errorMessage: null,
        );
      }
    } catch (e) {
      debugPrint('Error checking NFC availability: $e');
    }
  }

  /// Get scan statistics
  Map<String, dynamic> getScanStatistics() {
    return {
      'totalCachedStickers': state.cachedStickers.length,
      'activeStickers': state.cachedStickers.where((s) => s.isValid).length,
      'expiredStickers': state.cachedStickers.where((s) => s.isExpired).length,
      'expiringSoonStickers': state.cachedStickers.where((s) => s.isExpiringSoon).length,
      'lastScanResult': state.lastScanResult?.toJson(),
      'currentState': state.state.toString(),
      'isOnline': state.isOnline,
    };
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _eventSubscription?.cancel();
    _statusTimer?.cancel();
    _nfcService.dispose();
    super.dispose();
  }
}

/// Provider for RFID service
final rfidServiceProvider = Provider<NfcService>((ref) {
  return NfcService();
});

/// Provider for RFID state management
final rfidProvider = StateNotifierProvider<RfidProvider, RfidStateData>((ref) {
  return RfidProvider(
    nfcService: ref.watch(rfidServiceProvider),
    supabaseService: ref.watch(supabaseServiceProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

/// Provider for Supabase service (should be defined elsewhere)
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider for cache service (should be defined elsewhere)
final cacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});

/// Stream provider for real-time scan results
final rfidScanResultsProvider = StreamProvider<RfidScanResult?>((ref) {
  final nfcService = ref.watch(rfidServiceProvider);
  return nfcService.scanResults.map((result) => result.isSuccess
    ? RfidScanResult.success(rfidCode: result.rfidCode)
    : RfidScanResult.error(rfidCode: result.rfidCode, error: result.errorMessage)
  );
});

/// Provider for scan statistics
final rfidStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final rfidState = ref.watch(rfidProvider);
  return rfidState.getScanStatistics();
});