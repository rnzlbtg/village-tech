import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:permission_handler/permission_handler.dart';

/// NFC scan result containing sticker information
class NfcScanResult {
  final String rfidCode;
  final String? stickerType;
  final Map<String, dynamic>? rawData;
  final DateTime scanTime;
  final bool isSuccess;
  final String? errorMessage;

  const NfcScanResult({
    required this.rfidCode,
    this.stickerType,
    this.rawData,
    required this.scanTime,
    required this.isSuccess,
    this.errorMessage,
  });

  factory NfcScanResult.success(String rfidCode, {String? stickerType, Map<String, dynamic>? rawData}) {
    return NfcScanResult(
      rfidCode: rfidCode,
      stickerType: stickerType,
      rawData: rawData,
      scanTime: DateTime.now(),
      isSuccess: true,
    );
  }

  factory NfcScanResult.error(String errorMessage) {
    return NfcScanResult(
      rfidCode: '',
      scanTime: DateTime.now(),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// NFC scan configuration
class NfcScanConfig {
  final Duration timeout;
  final bool showAlertDialogs;
  final bool requireNdef;
  final bool soundEnabled;
  final bool hapticFeedback;

  const NfcScanConfig({
    this.timeout = const Duration(seconds: 5),
    this.showAlertDialogs = true,
    this.requireNdef = false,
    this.soundEnabled = true,
    this.hapticFeedback = true,
  });
}

/// NFC scan event types
enum NfcScanEvent {
  scanningStarted,
  tagDetected,
  scanningCompleted,
  scanningStopped,
  error,
  permissionDenied,
  nfcUnavailable,
}

/// NFC service for RFID sticker scanning and verification
class NfcService {
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();

  bool _isScanning = false;
  bool _isInitialized = false;
  bool _isNfcAvailable = false;
  final StreamController<NfcScanResult> _scanResultsController = StreamController<NfcScanResult>.broadcast();
  final StreamController<NfcScanEvent> _eventController = StreamController<NfcScanEvent>.broadcast();

  // Stream subscriptions
  StreamSubscription<NFCTag>? _pollingSubscription;
  Timer? _timeoutTimer;

  /// Public streams
  Stream<NfcScanResult> get scanResults => _scanResultsController.stream;
  Stream<NfcScanEvent> get scanEvents => _eventController.stream;

  /// Getters for service state
  bool get isScanning => _isScanning;
  bool get isInitialized => _isInitialized;
  bool get isNfcAvailable => _isNfcAvailable;

  /// Initialize NFC service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _eventController.add(NfcScanEvent.scanningStarted);

      // Check NFC availability
      _isNfcAvailable = await FlutterNfcKit.nfcAvailability == NFCAvailability.available;

      if (!_isNfcAvailable) {
        _eventController.add(NfcScanEvent.nfcUnavailable);
        return;
      }

      // Request permissions
      final hasPermission = await _requestNfcPermission();
      if (!hasPermission) {
        _eventController.add(NfcScanEvent.permissionDenied);
        return;
      }

      _isInitialized = true;
      debugPrint('NFC Service initialized successfully');
    } catch (e) {
      debugPrint('NFC Service initialization failed: $e');
      _eventController.add(NfcScanEvent.error);
    }
  }

  /// Start RFID scanning session
  Future<void> startScanning({NfcScanConfig? config}) async {
    if (_isScanning) {
      debugPrint('NFC scanning already in progress');
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    if (!_isNfcAvailable) {
      _scanResultsController.add(NfcScanResult.error('NFC is not available on this device'));
      return;
    }

    try {
      _isScanning = true;
      _eventController.add(NfcScanEvent.scanningStarted);

      final scanConfig = config ?? const NfcScanConfig();

      // Start polling for NFC tags
      _startPolling(scanConfig);

      // Set up timeout timer
      _timeoutTimer = Timer(scanConfig.timeout, () {
        stopScanning();
        _scanResultsController.add(NfcScanResult.error('Scanning timeout'));
      });

      debugPrint('NFC scanning started with timeout: ${scanConfig.timeout}');
    } catch (e) {
      _isScanning = false;
      debugPrint('Failed to start NFC scanning: $e');
      _scanResultsController.add(NfcScanResult.error('Failed to start scanning: $e'));
    }
  }

  /// Stop NFC scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      _isScanning = false;

      // Cancel polling subscription
      await _pollingSubscription?.cancel();
      _pollingSubscription = null;

      // Cancel timeout timer
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      // Stop NFC polling
      await FlutterNfcKit.finish();

      _eventController.add(NfcScanEvent.scanningStopped);
      debugPrint('NFC scanning stopped');
    } catch (e) {
      debugPrint('Error stopping NFC scanning: $e');
    }
  }

  /// Start polling for NFC tags
  Future<void> _startPolling(NfcScanConfig config) async {
    try {
      final tag = await FlutterNfcKit.poll(timeout: config.timeout);
      await _handleNfcTag(tag);
    } catch (e) {
      _handleScanError(e);
    }
  }

  /// Handle detected NFC tag
  Future<void> _handleNfcTag(NFCTag tag) async {
    try {
      _eventController.add(NfcScanEvent.tagDetected);

      // Extract RFID code from tag
      final rfidCode = _extractRfidCode(tag);

      if (rfidCode.isEmpty) {
        _scanResultsController.add(NfcScanResult.error('No RFID code found in tag'));
        return;
      }

      // Validate RFID code format
      if (!_isValidRfidCode(rfidCode)) {
        _scanResultsController.add(NfcScanResult.error('Invalid RFID code format: $rfidCode'));
        return;
      }

      // Create successful scan result
      final result = NfcScanResult.success(
        rfidCode,
        stickerType: tag.standard.toString(),
        rawData: {
          'id': tag.id,
          'standard': tag.standard.toString(),
        },
      );

      _scanResultsController.add(result);
      _eventController.add(NfcScanEvent.scanningCompleted);

      // Stop scanning after successful read
      await stopScanning();
    } catch (e) {
      debugPrint('Error handling NFC tag: $e');
      _scanResultsController.add(NfcScanResult.error('Error reading NFC tag: $e'));
    }
  }

  /// Handle scanning errors
  void _handleScanError(dynamic error) {
    debugPrint('NFC scanning error: $error');
    _scanResultsController.add(NfcScanResult.error('Scanning error: $error'));
    _eventController.add(NfcScanEvent.error);
  }

  /// Extract RFID code from NFC tag
  String _extractRfidCode(NFCTag tag) {
    try {
      // For now, use the tag ID as the RFID code
      // This can be enhanced later to read specific NDEF records
      return tag.id;
    } catch (e) {
      debugPrint('Error extracting RFID code: $e');
      return ''; // Return empty string on error
    }
  }

  /// Validate RFID code format
  bool _isValidRfidCode(String rfidCode) {
    if (rfidCode.isEmpty) return false;

    // Basic validation - RFID codes should be alphanumeric
    final validPattern = RegExp(r'^[a-zA-Z0-9]+$');
    return validPattern.hasMatch(rfidCode) && rfidCode.length >= 4;
  }

  /// Request NFC permission
  Future<bool> _requestNfcPermission() async {
    try {
      if (Platform.isAndroid) {
        // NFC permission is typically granted at app installation
        // We'll assume it's available for now, but can add platform-specific handling
        return true;
      } else if (Platform.isIOS) {
        // iOS doesn't require explicit NFC permission
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting NFC permission: $e');
      return false;
    }
  }

  /// Check NFC availability status
  Future<NFCAvailability> checkNfcAvailability() async {
    try {
      return await FlutterNfcKit.nfcAvailability;
    } catch (e) {
      debugPrint('Error checking NFC availability: $e');
      return NFCAvailability.not_supported;
    }
  }

  /// Simulate RFID scan for testing purposes
  void simulateScan(String rfidCode) {
    if (kDebugMode) {
      final result = NfcScanResult.success(rfidCode);
      _scanResultsController.add(result);
      _eventController.add(NfcScanEvent.scanningCompleted);
    }
  }

  /// Dispose service resources
  Future<void> dispose() async {
    await stopScanning();

    await _scanResultsController.close();
    await _eventController.close();

    _isInitialized = false;
    _isNfcAvailable = false;

    debugPrint('NFC Service disposed');
  }

  /// Get NFC device info for diagnostics
  Future<Map<String, dynamic>> getNfcDeviceInfo() async {
    try {
      final availability = await checkNfcAvailability();

      return {
        'isAvailable': availability == NFCAvailability.available,
        'availability': availability.toString(),
        'platform': Platform.operatingSystem,
        'isInitialized': _isInitialized,
        'isScanning': _isScanning,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isAvailable': false,
      };
    }
  }
}

/// NFC error types for better error handling
enum NfcErrorType {
  unavailable,
  permissionDenied,
  timeout,
  readError,
  invalidFormat,
  unknown,
}

/// NFC scan error
class NfcError {
  final NfcErrorType type;
  final String message;
  final dynamic originalError;

  const NfcError({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() {
    return 'NfcError(type: $type, message: $message)';
  }
}