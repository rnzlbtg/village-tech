import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'encryption.dart';

/// Secure key storage manager
/// Handles storage and retrieval of encryption keys using platform secure storage
class SecureKeyStorage {
  SecureKeyStorage._();
  static final SecureKeyStorage _instance = SecureKeyStorage._();
  static SecureKeyStorage get instance => _instance;

  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage;

  SecureKeyStorage() : _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Use stronger security on Android
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      // Only accessible when device is unlocked
      accessibility: KeychainItemAccessibility.whenUnlockedThisDeviceOnly,
      // Synchronize with iCloud if needed
      synchronizable: false,
    ),
  );

  // Storage keys
  static const String _dbEncryptionKeyKey = 'sentinel_db_encryption_key';
  static const String _dbKeyVersionKey = 'sentinel_db_key_version';
  static const String _sessionTokenKey = 'sentinel_session_token';
  static const String _biometricEnabledKey = 'sentinel_biometric_enabled';
  static const String _lastBackupKey = 'sentinel_last_backup';
  static const String _appSettingsKey = 'sentinel_app_settings';

  /// Initialize secure storage
  Future<void> initialize() async {
    try {
      _logger.i('Initializing secure key storage...');

      // Test secure storage availability
      await _testSecureStorage();

      _logger.i('Secure key storage initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize secure key storage: $e');
      throw SecureStorageException('Failed to initialize secure key storage: $e');
    }
  }

  /// Test secure storage functionality
  Future<void> _testSecureStorage() async {
    try {
      const testKey = 'test_access';
      const testValue = 'test_value_${DateTime.now().millisecondsSinceEpoch}';

      // Write test value
      await _secureStorage.write(key: testKey, value: testValue);

      // Read test value
      final readValue = await _secureStorage.read(key: testKey);

      // Clean up test value
      await _secureStorage.delete(key: testKey);

      if (readValue != testValue) {
        throw Exception('Secure storage read/write test failed');
      }

      _logger.d('Secure storage test passed');
    } catch (e) {
      _logger.e('Secure storage test failed: $e');
      rethrow;
    }
  }

  /// Store database encryption key
  Future<void> storeDatabaseEncryptionKey(String key, {int version = 1}) async {
    try {
      _logger.d('Storing database encryption key (version $version)...');

      await _secureStorage.write(
        key: _dbEncryptionKeyKey,
        value: key,
        iOptions: const IOSOptions(
          accessibility: KeychainItemAccessibility.whenUnlockedThisDeviceOnly,
        ),
      );

      await _secureStorage.write(
        key: _dbKeyVersionKey,
        value: version.toString(),
      );

      _logger.d('Database encryption key stored successfully');
    } catch (e) {
      _logger.e('Failed to store database encryption key: $e');
      throw SecureStorageException('Failed to store database encryption key: $e');
    }
  }

  /// Retrieve database encryption key
  Future<String?> getDatabaseEncryptionKey() async {
    try {
      return await _secureStorage.read(key: _dbEncryptionKeyKey);
    } catch (e) {
      _logger.e('Failed to retrieve database encryption key: $e');
      return null;
    }
  }

  /// Get database encryption key version
  Future<int?> getDatabaseKeyVersion() async {
    try {
      final versionString = await _secureStorage.read(key: _dbKeyVersionKey);
      return versionString != null ? int.tryParse(versionString) : null;
    } catch (e) {
      _logger.e('Failed to get database key version: $e');
      return null;
    }
  }

  /// Delete database encryption key
  Future<void> deleteDatabaseEncryptionKey() async {
    try {
      _logger.d('Deleting database encryption key...');

      await _secureStorage.delete(key: _dbEncryptionKeyKey);
      await _secureStorage.delete(key: _dbKeyVersionKey);

      _logger.d('Database encryption key deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete database encryption key: $e');
      throw SecureStorageException('Failed to delete database encryption key: $e');
    }
  }

  /// Store session token
  Future<void> storeSessionToken(String token) async {
    try {
      await _secureStorage.write(
        key: _sessionTokenKey,
        value: token,
        iOptions: const IOSOptions(
          accessibility: KeychainItemAccessibility.whenUnlockedThisDeviceOnly,
        ),
      );
      _logger.d('Session token stored successfully');
    } catch (e) {
      _logger.e('Failed to store session token: $e');
      throw SecureStorageException('Failed to store session token: $e');
    }
  }

  /// Retrieve session token
  Future<String?> getSessionToken() async {
    try {
      return await _secureStorage.read(key: _sessionTokenKey);
    } catch (e) {
      _logger.e('Failed to retrieve session token: $e');
      return null;
    }
  }

  /// Delete session token
  Future<void> deleteSessionToken() async {
    try {
      await _secureStorage.delete(key: _sessionTokenKey);
      _logger.d('Session token deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete session token: $e');
    }
  }

  /// Store biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
      _logger.d('Biometric preference updated: $enabled');
    } catch (e) {
      _logger.e('Failed to store biometric preference: $e');
    }
  }

  /// Get biometric authentication preference
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      _logger.e('Failed to get biometric preference: $e');
      return false;
    }
  }

  /// Store last backup timestamp
  Future<void> setLastBackup(DateTime timestamp) async {
    try {
      await _secureStorage.write(
        key: _lastBackupKey,
        value: timestamp.toIso8601String(),
      );
      _logger.d('Last backup timestamp updated: $timestamp');
    } catch (e) {
      _logger.e('Failed to store last backup timestamp: $e');
    }
  }

  /// Get last backup timestamp
  Future<DateTime?> getLastBackup() async {
    try {
      final value = await _secureStorage.read(key: _lastBackupKey);
      return value != null ? DateTime.tryParse(value) : null;
    } catch (e) {
      _logger.e('Failed to get last backup timestamp: $e');
      return null;
    }
  }

  /// Store app settings
  Future<void> storeAppSettings(Map<String, dynamic> settings) async {
    try {
      final settingsJson = jsonEncode(settings);
      await _secureStorage.write(
        key: _appSettingsKey,
        value: settingsJson,
      );
      _logger.d('App settings stored successfully');
    } catch (e) {
      _logger.e('Failed to store app settings: $e');
      throw SecureStorageException('Failed to store app settings: $e');
    }
  }

  /// Retrieve app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final settingsJson = await _secureStorage.read(key: _appSettingsKey);
      if (settingsJson == null) return null;

      return Map<String, dynamic>.from(jsonDecode(settingsJson));
    } catch (e) {
      _logger.e('Failed to retrieve app settings: $e');
      return null;
    }
  }

  /// Store custom key-value pair
  Future<void> storeCustomValue(String key, String value, {
    KeychainItemAccessibility? accessibility,
    bool requireAuthentication = false,
  }) async {
    try {
      await _secureStorage.write(
        key: 'sentinel_custom_$key',
        value: value,
        iOptions: accessibility != null
            ? IOSOptions(accessibility: accessibility)
            : null,
        aOptions: requireAuthentication
            ? const AndroidOptions(
                encryptedSharedPreferences: true,
                authenticationRequired: true,
              )
            : null,
      );
      _logger.d('Custom value stored: $key');
    } catch (e) {
      _logger.e('Failed to store custom value: $key - $e');
      throw SecureStorageException('Failed to store custom value: $key - $e');
    }
  }

  /// Retrieve custom key-value pair
  Future<String?> getCustomValue(String key) async {
    try {
      return await _secureStorage.read(key: 'sentinel_custom_$key');
    } catch (e) {
      _logger.e('Failed to retrieve custom value: $key - $e');
      return null;
    }
  }

  /// Delete custom key-value pair
  Future<void> deleteCustomValue(String key) async {
    try {
      await _secureStorage.delete(key: 'sentinel_custom_$key');
      _logger.d('Custom value deleted: $key');
    } catch (e) {
      _logger.e('Failed to delete custom value: $key - $e');
    }
  }

  /// Check if secure storage is available
  Future<bool> isAvailable() async {
    try {
      const testKey = 'availability_test';
      await _secureStorage.write(key: testKey, value: 'test');
      await _secureStorage.delete(key: testKey);
      return true;
    } catch (e) {
      _logger.e('Secure storage not available: $e');
      return false;
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final dbKeyExists = await getDatabaseEncryptionKey() != null;
      final sessionTokenExists = await getSessionToken() != null;
      final biometricEnabled = await isBiometricEnabled();
      final lastBackup = await getLastBackup();

      return {
        'dbKeyExists': dbKeyExists,
        'sessionTokenExists': sessionTokenExists,
        'biometricEnabled': biometricEnabled,
        'lastBackup': lastBackup?.toIso8601String(),
        'isAvailable': await isAvailable(),
      };
    } catch (e) {
      _logger.e('Failed to get storage stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Clear all stored data (for logout/reset)
  Future<void> clearAll() async {
    try {
      _logger.i('Clearing all secure storage data...');

      final keys = [
        _dbEncryptionKeyKey,
        _dbKeyVersionKey,
        _sessionTokenKey,
        _biometricEnabledKey,
        _lastBackupKey,
        _appSettingsKey,
      ];

      for (final key in keys) {
        try {
          await _secureStorage.delete(key: key);
        } catch (e) {
          _logger.w('Failed to delete key $key: $e');
        }
      }

      // Also clear any custom keys
      await _clearCustomKeys();

      _logger.i('All secure storage data cleared');
    } catch (e) {
      _logger.e('Failed to clear secure storage: $e');
      throw SecureStorageException('Failed to clear secure storage: $e');
    }
  }

  /// Clear custom keys
  Future<void> _clearCustomKeys() async {
    try {
      // This is a simplified approach - in production, you might want to
      // maintain a list of custom keys or use a naming pattern
      const customPrefix = 'sentinel_custom_';

      // Note: FlutterSecureStorage doesn't provide a way to list all keys
      // This would need to be implemented based on your specific needs
    } catch (e) {
      _logger.w('Failed to clear custom keys: $e');
    }
  }
}

/// Secure storage exception
class SecureStorageException implements Exception {
  const SecureStorageException(this.message);

  final String message;

  @override
  String toString() => 'SecureStorageException: $message';
}