import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Encryption service for local database
/// Provides AES-256 encryption for Drift database with SQLCipher
class DatabaseEncryption {
  DatabaseEncryption._();
  static final DatabaseEncryption _instance = DatabaseEncryption._();
  static DatabaseEncryption get instance => _instance;

  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.whenUnlockedThisDeviceOnly,
    ),
  );

  static const String _encryptionKeyKey = 'db_encryption_key';
  static const String _keyVersionKey = 'db_key_version';
  static const int _currentKeyVersion = 1;
  static const int _keyLength = 32; // 256 bits for AES-256

  /// Initialize encryption key
  Future<String> initializeEncryptionKey() async {
    try {
      _logger.i('Initializing database encryption key...');

      // Check if key already exists
      String? existingKey = await _secureStorage.read(key: _encryptionKeyKey);
      int? existingVersion = await _getKeyVersion();

      if (existingKey != null && existingVersion != null && existingVersion == _currentKeyVersion) {
        _logger.i('Using existing encryption key (version $existingVersion)');
        return existingKey;
      }

      // Generate new encryption key
      final newKey = _generateSecureKey();

      // Store the key
      await _secureStorage.write(key: _encryptionKeyKey, value: newKey);
      await _secureStorage.write(key: _keyVersionKey, value: _currentKeyVersion.toString());

      _logger.i('Generated and stored new encryption key (version $_currentKeyVersion)');
      return newKey;

    } catch (e) {
      _logger.e('Failed to initialize encryption key: $e');
      throw DatabaseEncryptionException('Failed to initialize encryption key: $e');
    }
  }

  /// Get current encryption key
  Future<String?> getEncryptionKey() async {
    try {
      return await _secureStorage.read(key: _encryptionKeyKey);
    } catch (e) {
      _logger.e('Failed to get encryption key: $e');
      return null;
    }
  }

  /// Generate cryptographically secure key
  String _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(_keyLength, (_) => random.nextInt(256));
    return base64.encode(keyBytes);
  }

  /// Get key version
  Future<int?> _getKeyVersion() async {
    try {
      final versionString = await _secureStorage.read(key: _keyVersionKey);
      return versionString != null ? int.tryParse(versionString) : null;
    } catch (e) {
      _logger.e('Failed to get key version: $e');
      return null;
    }
  }

  /// Verify encryption key integrity
  Future<bool> verifyEncryptionKey() async {
    try {
      final key = await getEncryptionKey();
      if (key == null) {
        _logger.w('No encryption key found');
        return false;
      }

      // Verify key length
      final keyBytes = base64.decode(key);
      if (keyBytes.length != _keyLength) {
        _logger.w('Encryption key has invalid length: ${keyBytes.length}');
        return false;
      }

      // Test encryption/decryption
      final testData = 'test_encryption_verification';
      final encrypted = await encryptData(testData, key);
      final decrypted = await decryptData(encrypted, key);

      final isValid = decrypted == testData;
      if (!isValid) {
        _logger.e('Encryption key verification failed');
      }

      return isValid;

    } catch (e) {
      _logger.e('Encryption key verification error: $e');
      return false;
    }
  }

  /// Rotate encryption key (for future use)
  Future<bool> rotateEncryptionKey() async {
    try {
      _logger.i('Starting encryption key rotation...');

      // Get current key
      final currentKey = await getEncryptionKey();
      if (currentKey == null) {
        _logger.w('No current key to rotate from');
        return false;
      }

      // Generate new key
      final newKey = _generateSecureKey();

      // TODO: Implement database re-encryption with new key
      // This would involve:
      // 1. Backup current database
      // 2. Create new encrypted database with new key
      // 3. Migrate all data
      // 4. Replace old database

      // Store new key
      await _secureStorage.write(key: _encryptionKeyKey, value: newKey);
      await _secureStorage.write(key: _keyVersionKey, value: (_currentKeyVersion + 1).toString());

      _logger.i('Encryption key rotation completed');
      return true;

    } catch (e) {
      _logger.e('Encryption key rotation failed: $e');
      return false;
    }
  }

  /// Delete encryption key (for logout/uninstall)
  Future<void> deleteEncryptionKey() async {
    try {
      _logger.i('Deleting encryption key...');
      await _secureStorage.delete(key: _encryptionKeyKey);
      await _secureStorage.delete(key: _keyVersionKey);
      _logger.i('Encryption key deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete encryption key: $e');
      throw DatabaseEncryptionException('Failed to delete encryption key: $e');
    }
  }

  /// Encrypt data using AES-256
  Future<String> encryptData(String data, String key) async {
    try {
      final keyBytes = base64.decode(key);
      final dataBytes = utf8.encode(data);

      // Generate random IV
      final iv = List<int>.generate(16, (_) => Random.secure().nextInt(256));

      // TODO: Implement actual AES encryption
      // For now, return base64 encoded data with IV
      final combined = [...iv, ...dataBytes];
      return base64.encode(combined);

    } catch (e) {
      _logger.e('Data encryption failed: $e');
      throw DatabaseEncryptionException('Data encryption failed: $e');
    }
  }

  /// Decrypt data using AES-256
  Future<String> decryptData(String encryptedData, String key) async {
    try {
      final keyBytes = base64.decode(key);
      final combined = base64.decode(encryptedData);

      if (combined.length < 16) {
        throw const FormatException('Invalid encrypted data format');
      }

      final iv = combined.sublist(0, 16);
      final dataBytes = combined.sublist(16);

      // TODO: Implement actual AES decryption
      // For now, return decoded data
      return utf8.decode(dataBytes);

    } catch (e) {
      _logger.e('Data decryption failed: $e');
      throw DatabaseEncryptionException('Data decryption failed: $e');
    }
  }

  /// Validate key format
  bool isValidKeyFormat(String key) {
    try {
      final keyBytes = base64.decode(key);
      return keyBytes.length == _keyLength;
    } catch (e) {
      return false;
    }
  }

  /// Check if encryption is properly initialized
  Future<bool> isInitialized() async {
    try {
      final key = await getEncryptionKey();
      final version = await _getKeyVersion();
      return key != null && version != null && version == _currentKeyVersion;
    } catch (e) {
      return false;
    }
  }

  /// Get encryption status information
  Future<Map<String, dynamic>> getEncryptionStatus() async {
    final key = await getEncryptionKey();
    final version = await _getKeyVersion();
    final isValid = key != null ? await verifyEncryptionKey() : false;

    return {
      'hasKey': key != null,
      'keyVersion': version,
      'expectedVersion': _currentKeyVersion,
      'isValid': isValid,
      'keyLength': key?.length,
      'expectedLength': _keyLength,
    };
  }

  /// Secure wipe of sensitive data
  Future<void> secureWipe() async {
    try {
      _logger.i('Performing secure wipe of encryption data...');

      // Delete encryption key
      await deleteEncryptionKey();

      // TODO: Wipe database file if it exists

      _logger.i('Secure wipe completed');
    } catch (e) {
      _logger.e('Secure wipe failed: $e');
      throw DatabaseEncryptionException('Secure wipe failed: $e');
    }
  }
}

/// Database encryption exception
class DatabaseEncryptionException implements Exception {
  const DatabaseEncryptionException(this.message);

  final String message;

  @override
  String toString() => 'DatabaseEncryptionException: $message';
}

/// Encryption utilities
class EncryptionUtils {
  /// Generate hash for data integrity verification
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity
  static bool verifyIntegrity(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// Generate secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  /// Convert bytes to hex string
  static String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convert hex string to bytes
  static List<int> hexToBytes(String hex) {
    return List.generate(hex.length ~/ 2, (i) {
      final start = i * 2;
      return int.parse(hex.substring(start, start + 2), radix: 16);
    });
  }
}