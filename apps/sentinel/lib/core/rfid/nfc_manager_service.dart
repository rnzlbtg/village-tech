import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

/// NFC Manager Service for RFID sticker scanning
/// Handles NFC operations for 13.56 MHz RFID tags using nfc_manager package
class NfcManagerService {
  NfcManagerService._();
  static final NfcManagerService _instance = NfcManagerService._();
  static NfcManagerService get instance => _instance;

  final Logger _logger = Logger();
  bool _isInitialized = false;
  bool _isSessionActive = false;
  StreamSubscription<NfcTag>? _sessionSubscription;

  // NFC session configuration
  static const Duration _sessionTimeout = Duration(seconds: 5);
  static const Duration _pollingTimeout = Duration(seconds: 3);

  // Event streams
  final StreamController<NfcScanResult> _scanResultsController =
      StreamController<NfcScanResult>.broadcast();
  final StreamController<NfcStatus> _statusController =
      StreamController<NfcStatus>.broadcast();

  /// Get NFC scan results stream
  Stream<NfcScanResult> get scanResults => _scanResultsController.stream;

  /// Get NFC status stream
  Stream<NfcStatus> get statusStream => _statusController.stream;

  /// Initialize NFC manager
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _logger.d('NFC manager already initialized');
        return true;
      }

      _logger.i('Initializing NFC manager...');

      // Check NFC availability
      final isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _logger.w('NFC not available on this device');
        _statusController.add(NfcStatus.unavailable);
        return false;
      }

      // Request permissions on Android
      if (Platform.isAndroid) {
        final hasPermission = await _requestNfcPermission();
        if (!hasPermission) {
          _logger.w('NFC permission denied');
          _statusController.add(NfcStatus.permissionDenied);
          return false;
        }
      }

      _isInitialized = true;
      _statusController.add(NfcStatus.ready);
      _logger.i('NFC manager initialized successfully');
      return true;

    } catch (e) {
      _logger.e('Failed to initialize NFC manager: $e');
      _statusController.add(NfcStatus.error(e.toString()));
      return false;
    }
  }

  /// Request NFC permission on Android
  Future<bool> _requestNfcPermission() async {
    try {
      final status = await Permission.nfc.request();
      return status.isGranted;
    } catch (e) {
      _logger.e('Failed to request NFC permission: $e');
      return false;
    }
  }

  /// Start NFC scanning session
  Future<NfcScanResult?> startScanning({
    Duration? timeout,
    bool alertOnSuccess = true,
    bool alertOnError = true,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          throw const NfcException('NFC manager not initialized');
        }
      }

      if (_isSessionActive) {
        _logger.w('NFC session already active');
        throw const NfcException('NFC session already active');
      }

      _logger.i('Starting NFC scanning session...');
      _statusController.add(NfcStatus.scanning);

      final completer = Completer<NfcScanResult?>();

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            _logger.d('NFC tag discovered: ${tag.id}');

            // Process the tag
            final result = await _processNfcTag(tag);

            if (result != null) {
              _scanResultsController.add(result);
              _statusController.add(NfcStatus.success);

              if (alertOnSuccess) {
                _showFeedback(true);
              }
            }

            // Stop the session
            await _stopScanning();

            if (!completer.isCompleted) {
              completer.complete(result);
            }

          } catch (e) {
            _logger.e('Error processing NFC tag: $e');

            if (!completer.isCompleted) {
              completer.completeError(e);
            }
          }
        },
        onError: (dynamic error) async {
          _logger.e('NFC session error: $error');
          await _stopScanning();
          _statusController.add(NfcStatus.error(error.toString()));

          if (alertOnError) {
            _showFeedback(false);
          }

          if (!completer.isCompleted) {
            completer.completeError(NfcException(error.toString()));
          }
        },
      );

      _isSessionActive = true;

      // Set session timeout
      Timer(timeout ?? _sessionTimeout, () async {
        if (_isSessionActive && !completer.isCompleted) {
          _logger.w('NFC scanning session timeout');
          await _stopScanning();
          _statusController.add(NfcStatus.timeout);
          completer.complete(null);
        }
      });

      return await completer.future;

    } catch (e) {
      _logger.e('Failed to start NFC scanning: $e');
      await _stopScanning();
      _statusController.add(NfcStatus.error(e.toString()));
      throw NfcException('Failed to start NFC scanning: $e');
    }
  }

  /// Stop NFC scanning session
  Future<void> stopScanning() async {
    try {
      if (!_isSessionActive) {
        _logger.d('No active NFC session to stop');
        return;
      }

      _logger.d('Stopping NFC scanning session...');
      await NfcManager.instance.stopSession();
      _isSessionActive = false;
      _statusController.add(NfcStatus.ready);

      _logger.d('NFC scanning session stopped');
    } catch (e) {
      _logger.e('Error stopping NFC session: $e');
    }
  }

  /// Process discovered NFC tag
  Future<NfcScanResult?> _processNfcTag(NfcTag tag) async {
    try {
      final tagData = <String, dynamic>{
        'id': tag.id,
        'type': tag.type,
        'data': <String, dynamic>{},
      };

      // Extract NDEF data if available
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        final cachedMessage = await ndef.read();
        if (cachedMessage != null) {
          tagData['ndef'] = _processNdefMessage(cachedMessage);
        }
      }

      // Extract raw tag data
      tagData['data'] = await _extractTagData(tag);

      // Try to extract RFID sticker code
      final stickerCode = _extractStickerCode(tagData);

      if (stickerCode != null) {
        _logger.i('RFID sticker code extracted: $stickerCode');
        return NfcScanResult(
          success: true,
          stickerCode: stickerCode,
          tagData: tagData,
          timestamp: DateTime.now(),
        );
      } else {
        _logger.w('No valid RFID sticker code found in tag');
        return NfcScanResult(
          success: false,
          error: 'No valid RFID sticker code found',
          tagData: tagData,
          timestamp: DateTime.now(),
        );
      }

    } catch (e) {
      _logger.e('Error processing NFC tag: $e');
      return NfcScanResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Process NDEF message
  Map<String, dynamic> _processNdefMessage(NdefMessage message) {
    final records = <Map<String, dynamic>>[];

    for (final record in message.records) {
      records.add({
        'typeNameFormat': record.typeNameFormat.toString(),
        'type': record.type,
        'identifier': record.identifier,
        'payload': record.payload,
      });
    }

    return {
      'records': records,
      'recordCount': records.length,
    };
  }

  /// Extract raw tag data
  Future<Map<String, dynamic>> _extractTagData(NfcTag tag) async {
    final data = <String, dynamic>{};

    try {
      // Get standard NDEF technology
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        data['ndefAvailable'] = true;
        data['ndefCacheable'] = await ndef.isCacheable();
        data['ndefWritable'] = await ndef.isWritable();
        data['ndefMaxSize'] = await ndef.maxSize();
      } else {
        data['ndefAvailable'] = false;
      }

      // Get additional tag information
      data['id'] = tag.id;
      data['type'] = tag.type;

    } catch (e) {
      _logger.w('Error extracting tag data: $e');
    }

    return data;
  }

  /// Extract RFID sticker code from tag data
  String? _extractStickerCode(Map<String, dynamic> tagData) {
    try {
      // Method 1: Check NDEF records for sticker code
      if (tagData.containsKey('ndef')) {
        final ndef = tagData['ndef'] as Map<String, dynamic>;
        final records = ndef['records'] as List<dynamic>? ?? [];

        for (final record in records) {
          final payload = record['payload'] as List<int>?;
          if (payload != null) {
            final payloadString = utf8.decode(payload);
            if (_isValidStickerCode(payloadString)) {
              return payloadString.trim();
            }
          }
        }
      }

      // Method 2: Use tag ID as potential sticker code
      final tagId = tagData['id'] as List<int>?;
      if (tagId != null) {
        final tagIdHex = tagId.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
        if (_isValidStickerCode(tagIdHex)) {
          return tagIdHex.toUpperCase();
        }
      }

      return null;

    } catch (e) {
      _logger.e('Error extracting sticker code: $e');
      return null;
    }
  }

  /// Validate if string is a valid sticker code
  bool _isValidStickerCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;
    if (cleanCode.length < 4) return false;
    if (cleanCode.length > 64) return false;

    final validPattern = RegExp(r'^[A-F0-9-]+$');
    return validPattern.hasMatch(cleanCode);
  }

  /// Show haptic feedback
  void _showFeedback(bool success) {
    // Simple feedback - could be enhanced with haptic package
    if (kDebugMode) {
      print(success ? '✓ NFC Success' : '✗ NFC Error');
    }
  }

  /// Check if NFC is available
  Future<bool> isNfcAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      _logger.e('Error checking NFC availability: $e');
      return false;
    }
  }

  /// Get current NFC status
  NfcStatus get currentStatus {
    if (!_isInitialized) return NfcStatus.uninitialized;
    if (_isSessionActive) return NfcStatus.scanning;
    return NfcStatus.ready;
  }

  /// Dispose NFC manager
  Future<void> dispose() async {
    try {
      _logger.i('Disposing NFC manager...');
      await stopScanning();
      await _scanResultsController.close();
      await _statusController.close();
      _isInitialized = false;
      _logger.i('NFC manager disposed');
    } catch (e) {
      _logger.e('Error disposing NFC manager: $e');
    }
  }
}

/// NFC scan result
class NfcScanResult {
  const NfcScanResult({
    required this.success,
    required this.timestamp,
    this.stickerCode,
    this.tagData,
    this.error,
  });

  final bool success;
  final String? stickerCode;
  final Map<String, dynamic>? tagData;
  final String? error;
  final DateTime timestamp;

  @override
  String toString() {
    return 'NfcScanResult(success: $success, stickerCode: $stickerCode, error: $error)';
  }
}

/// NFC status enum
enum NfcStatus {
  uninitialized,
  unavailable,
  permissionDenied,
  ready,
  scanning,
  success,
  timeout,
  error;

  String get displayName {
    switch (this) {
      case NfcStatus.uninitialized:
        return 'NFC not initialized';
      case NfcStatus.unavailable:
        return 'NFC not available';
      case NfcStatus.permissionDenied:
        return 'NFC permission denied';
      case NfcStatus.ready:
        return 'NFC ready';
      case NfcStatus.scanning:
        return 'Scanning...';
      case NfcStatus.success:
        return 'Scan successful';
      case NfcStatus.timeout:
        return 'Scan timeout';
      case NfcStatus.error:
        return 'NFC error';
    }
  }
}

/// NFC exception
class NfcException implements Exception {
  const NfcException(this.message);

  final String message;

  @override
  String toString() => 'NfcException: $message';
}