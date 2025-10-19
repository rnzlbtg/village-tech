import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';

/// RFID Tag Parser Utility
/// Extracts and parses data from 13.56 MHz RFID tags and NFC tags
class RfidTagParser {
  RfidTagParser._();
  static final RfidTagParser _instance = RfidTagParser._();
  static RfidTagParser get instance => _instance;

  final Logger _logger = Logger();

  /// Parse raw RFID tag data and extract sticker code
  RfidParseResult parseTagData(Map<String, dynamic> tagData) {
    try {
      _logger.d('Parsing RFID tag data...');

      final result = RfidParseResult(
        tagId: _extractTagId(tagData),
        tagType: _extractTagType(tagData),
        rawData: tagData,
        extractedData: <String, dynamic>{},
      );

      // Method 1: Extract from NDEF records
      if (tagData.containsKey('ndef')) {
        final ndefData = _parseNdefData(tagData['ndef']);
        result.extractedData['ndef'] = ndefData;

        final stickerCode = _extractStickerCodeFromNdef(ndefData);
        if (stickerCode != null) {
          result.stickerCode = stickerCode;
          result.extractionMethod = 'ndef_record';
          _logger.i('Sticker code extracted from NDEF: $stickerCode');
          return result;
        }
      }

      // Method 2: Extract from tag ID
      final tagIdCode = _extractStickerCodeFromTagId(result.tagId);
      if (tagIdCode != null && _isValidRfidCode(tagIdCode)) {
        result.stickerCode = tagIdCode;
        result.extractionMethod = 'tag_id';
        _logger.i('Sticker code extracted from tag ID: $tagIdCode');
        return result;
      }

      // Method 3: Extract from custom data formats
      if (tagData.containsKey('data')) {
        final customData = _parseCustomTagData(tagData['data']);
        result.extractedData['custom'] = customData;

        final customCode = _extractStickerCodeFromCustom(customData);
        if (customCode != null) {
          result.stickerCode = customCode;
          result.extractionMethod = 'custom_data';
          _logger.i('Sticker code extracted from custom data: $customCode');
          return result;
        }
      }

      // Method 4: Try to decode as common RFID formats
      final decodedCode = _decodeCommonRfidFormats(tagData);
      if (decodedCode != null) {
        result.stickerCode = decodedCode;
        result.extractionMethod = 'rfid_format';
        _logger.i('Sticker code decoded from RFID format: $decodedCode');
        return result;
      }

      // No valid sticker code found
      result.extractionMethod = 'none';
      _logger.w('No valid RFID sticker code found in tag data');
      return result;

    } catch (e) {
      _logger.e('Error parsing RFID tag data: $e');
      return RfidParseResult.error('Parsing error: $e');
    }
  }

  /// Extract tag ID from tag data
  String _extractTagId(Map<String, dynamic> tagData) {
    try {
      final id = tagData['id'] as List<int>?;
      if (id == null) return '';

      // Convert to hex string
      return id.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
    } catch (e) {
      _logger.e('Error extracting tag ID: $e');
      return '';
    }
  }

  /// Extract tag type from tag data
  String _extractTagType(Map<String, dynamic> tagData) {
    try {
      return tagData['type'] as String? ?? 'unknown';
    } catch (e) {
      _logger.e('Error extracting tag type: $e');
      return 'unknown';
    }
  }

  /// Parse NDEF data from tag
  Map<String, dynamic> _parseNdefData(dynamic ndefData) {
    try {
      if (ndefData is! Map) return {};

      final parsed = <String, dynamic>{
        'recordCount': ndefData['recordCount'] ?? 0,
        'records': <Map<String, dynamic>>[],
      };

      final records = ndefData['records'] as List<dynamic>? ?? [];
      for (final record in records) {
        if (record is Map) {
          parsed['records']!.add({
            'typeNameFormat': record['typeNameFormat'],
            'type': record['type'],
            'identifier': record['identifier'],
            'payload': record['payload'],
            'payloadText': _extractTextFromPayload(record['payload']),
          });
        }
      }

      return parsed;
    } catch (e) {
      _logger.e('Error parsing NDEF data: $e');
      return {};
    }
  }

  /// Extract text from NDEF payload
  String _extractTextFromPayload(dynamic payload) {
    try {
      if (payload is! List<int>) return '';

      final bytes = Uint8List.fromList(payload);

      // Check if it's a text record with language code
      if (bytes.isNotEmpty) {
        final languageCodeLength = bytes[0];
        if (bytes.length > languageCodeLength + 1) {
          final textBytes = bytes.sublist(languageCodeLength + 1);
          return utf8.decode(textBytes);
        }
      }

      // Try direct UTF-8 decode
      return utf8.decode(bytes);
    } catch (e) {
      _logger.e('Error extracting text from payload: $e');
      return '';
    }
  }

  /// Extract sticker code from NDEF records
  String? _extractStickerCodeFromNdef(Map<String, dynamic> ndefData) {
    try {
      final records = ndefData['records'] as List<dynamic>? ?? [];

      for (final record in records) {
        if (record is Map) {
          final payloadText = record['payloadText'] as String?;
          if (payloadText != null && _isValidRfidCode(payloadText)) {
            return payloadText.trim();
          }
        }
      }

      return null;
    } catch (e) {
      _logger.e('Error extracting sticker code from NDEF: $e');
      return null;
    }
  }

  /// Extract sticker code from tag ID
  String? _extractStickerCodeFromTagId(String tagId) {
    try {
      // Remove colons and convert to uppercase
      final cleanId = tagId.replaceAll(':', '').toUpperCase();

      // Common RFID sticker code patterns
      final patterns = [
        // Pattern: RFID-XXXXXX
        RegExp(r'RFID-(.+)'),
        // Pattern: SENTINEL-XXXXXX
        RegExp(r'SENTINEL-(.+)'),
        // Pattern: VILLAGE-XXXXXX
        RegExp(r'VILLAGE-(.+)'),
        // Pattern: 8-16 character alphanumeric
        RegExp(r'([A-Z0-9]{8,16})'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(cleanId);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }

      // If no pattern matches, use the clean ID if it's valid
      if (_isValidRfidCode(cleanId)) {
        return cleanId;
      }

      return null;
    } catch (e) {
      _logger.e('Error extracting sticker code from tag ID: $e');
      return null;
    }
  }

  /// Parse custom tag data
  Map<String, dynamic> _parseCustomTagData(dynamic customData) {
    try {
      if (customData is! Map) return {};

      final parsed = <String, dynamic>{};

      // Extract common custom fields
      if (customData.containsKey('manufacturer')) {
        parsed['manufacturer'] = customData['manufacturer'];
      }

      if (customData.containsKey('serialNumber')) {
        parsed['serialNumber'] = customData['serialNumber'];
      }

      if (customData.containsKey('customData')) {
        parsed['customData'] = customData['customData'];
      }

      return parsed;
    } catch (e) {
      _logger.e('Error parsing custom tag data: $e');
      return {};
    }
  }

  /// Extract sticker code from custom data
  String? _extractStickerCodeFromCustom(Map<String, dynamic> customData) {
    try {
      // Check common custom data fields
      final fieldsToCheck = [
        'stickerCode',
        'serialNumber',
        'customData',
        'rfidCode',
        'accessCode',
      ];

      for (final field in fieldsToCheck) {
        final value = customData[field]?.toString();
        if (value != null && _isValidRfidCode(value)) {
          return value.trim();
        }
      }

      return null;
    } catch (e) {
      _logger.e('Error extracting sticker code from custom data: $e');
      return null;
    }
  }

  /// Decode common RFID formats
  String? _decodeCommonRfidFormats(Map<String, dynamic> tagData) {
    try {
      // This would contain logic for specific RFID formats
      // such as EM4100, MIFARE Classic, etc.

      // Example: Try to decode as EM4100 format
      final tagId = _extractTagId(tagData);
      final cleanId = tagId.replaceAll(':', '');

      if (cleanId.length == 8) {
        // Could be EM4100 format
        return _decodeEm4100(cleanId);
      }

      // Add more format decoders as needed
      return null;
    } catch (e) {
      _logger.e('Error decoding RFID formats: $e');
      return null;
    }
  }

  /// Decode EM4100 format RFID
  String? _decodeEm4100(String hexData) {
    try {
      // EM4100 decoding logic
      // This is a simplified example

      if (hexData.length != 8) return null;

      final bytes = _hexToBytes(hexData);

      // Check EM4100 parity and format
      // This would need the actual EM4100 specification

      return 'EM4100-$hexData';
    } catch (e) {
      _logger.e('Error decoding EM4100: $e');
      return null;
    }
  }

  /// Validate RFID code format
  bool _isValidRfidCode(String code) {
    final cleanCode = code.trim().toUpperCase();

    if (cleanCode.isEmpty) return false;
    if (cleanCode.length < 4) return false;
    if (cleanCode.length > 32) return false;

    // Allow alphanumeric and hyphens
    final validPattern = RegExp(r'^[A-Z0-9-]+$');
    return validPattern.hasMatch(cleanCode);
  }

  /// Convert hex string to bytes
  List<int> _hexToBytes(String hex) {
    return List.generate(hex.length ~/ 2, (i) {
      final start = i * 2;
      return int.parse(hex.substring(start, start + 2), radix: 16);
    });
  }

  /// Format tag ID for display
  String formatTagIdForDisplay(String tagId) {
    try {
      if (tagId.isEmpty) return 'Unknown';

      // If already formatted with colons, return as-is
      if (tagId.contains(':')) {
        return tagId.toUpperCase();
      }

      // Format as XX:XX:XX:XX
      final clean = tagId.replaceAll(':', '');
      final formatted = <String>[];

      for (int i = 0; i < clean.length; i += 2) {
        if (i + 1 < clean.length) {
          formatted.add(clean.substring(i, i + 2));
        }
      }

      return formatted.join(':').toUpperCase();
    } catch (e) {
      _logger.e('Error formatting tag ID: $e');
      return tagId;
    }
  }

  /// Generate mock RFID data for testing
  Map<String, dynamic> generateMockRfidData() {
    final tagId = _generateRandomTagId();
    final stickerCode = _generateMockStickerCode();

    return {
      'id': _hexToBytes(tagId.replaceAll(':', '')),
      'type': 'iso7816',
      'data': {
        'ndefAvailable': true,
        'ndefWritable': false,
        'ndefMaxSize': 137,
      },
      'ndef': {
        'recordCount': 1,
        'records': [
          {
            'typeNameFormat': 'NdefTypeNameFormat.nfcWellKnown',
            'type': [84], // 'T' for Text
            'identifier': [],
            'payload': [2, 101, 110], // "en" + sticker code
            'payloadText': stickerCode,
          }
        ],
      },
    };
  }

  /// Generate random tag ID
  String _generateRandomTagId() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final hex = random.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '${hex.substring(0, 2)}:${hex.substring(2, 4)}:${hex.substring(4, 6)}:${hex.substring(6, 8)}';
  }

  /// Generate mock sticker code
  String _generateMockStickerCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'RFID-${random.toString().substring(4)}';
  }
}

/// RFID parse result
class RfidParseResult {
  const RfidParseResult({
    required this.tagId,
    required this.tagType,
    required this.rawData,
    required this.extractedData,
    this.stickerCode,
    this.extractionMethod = 'none',
    this.error,
  });

  final String tagId;
  final String tagType;
  final Map<String, dynamic> rawData;
  final Map<String, dynamic> extractedData;
  final String? stickerCode;
  final String extractionMethod;
  final String? error;

  bool get isSuccess => error == null && stickerCode != null;
  bool get hasError => error != null;

  factory RfidParseResult.error(String error) {
    return RfidParseResult(
      tagId: '',
      tagType: 'unknown',
      rawData: {},
      extractedData: {},
      error: error,
    );
  }

  @override
  String toString() {
    return 'RfidParseResult('
        'success: $isSuccess, '
        'stickerCode: $stickerCode, '
        'extractionMethod: $extractionMethod, '
        'tagId: $tagId, '
        'error: $error)';
  }
}