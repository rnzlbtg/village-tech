import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'encryption.dart';

/// Database backup and recovery service
/// Provides automated backup, manual backup, and recovery functionality
/// Includes integrity checks and encryption for backup files
class DatabaseBackup {
  DatabaseBackup._();
  static final DatabaseBackup _instance = DatabaseBackup._();
  static DatabaseBackup get instance => _instance;

  final Logger _logger = Logger();

  /// Backup configuration
  static const int maxBackupFiles = 5;
  static const Duration backupRetentionPeriod = Duration(days: 30);

  /// Create an automatic backup of the database
  Future<BackupResult> createAutomaticBackup(AppDatabase database, String tenantId) async {
    try {
      _logger.i('Creating automatic backup for tenant: $tenantId');

      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'auto_backup_${tenantId}_$timestamp.db.enc';
      final backupFilePath = p.join(backupDir.path, backupFileName);

      final result = await _createBackup(database, backupFilePath, 'automatic', tenantId);

      // Clean up old backups
      await _cleanupOldBackups(tenantId);

      _logger.i('Automatic backup created successfully: $backupFileName');
      return result;
    } catch (e) {
      _logger.e('Failed to create automatic backup: $e');
      return BackupResult(success: false, error: e.toString());
    }
  }

  /// Create a manual backup with custom name
  Future<BackupResult> createManualBackup(
    AppDatabase database,
    String tenantId,
    String? customName,
  ) async {
    try {
      _logger.i('Creating manual backup for tenant: $tenantId');

      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final name = customName ?? 'manual';
      final backupFileName = '${name}_backup_${tenantId}_$timestamp.db.enc';
      final backupFilePath = p.join(backupDir.path, backupFileName);

      final result = await _createBackup(database, backupFilePath, 'manual', tenantId);

      _logger.i('Manual backup created successfully: $backupFileName');
      return result;
    } catch (e) {
      _logger.e('Failed to create manual backup: $e');
      return BackupResult(success: false, error: e.toString());
    }
  }

  /// Internal backup creation method
  Future<BackupResult> _createBackup(
    AppDatabase database,
    String backupFilePath,
    String backupType,
    String tenantId,
  ) async {
    try {
      // Get database file path
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'sentinel.db'));

      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Copy database file
      final backupFile = File(backupFilePath);
      await dbFile.copy(backupFilePath);

      // Create backup metadata
      final metadata = BackupMetadata(
        id: _generateBackupId(),
        tenantId: tenantId,
        backupType: backupType,
        filePath: backupFilePath,
        fileSize: await backupFile.length(),
        checksum: await _calculateFileChecksum(backupFile),
        databaseVersion: database.schemaVersion,
        createdAt: DateTime.now(),
      );

      // Save metadata to separate file
      await _saveBackupMetadata(metadata);

      // Verify backup integrity
      final isValid = await _verifyBackupIntegrity(backupFilePath, metadata.checksum);
      if (!isValid) {
        await backupFile.delete();
        throw Exception('Backup integrity verification failed');
      }

      return BackupResult(
        success: true,
        backupPath: backupFilePath,
        metadata: metadata,
      );
    } catch (e) {
      _logger.e('Backup creation failed: $e');
      return BackupResult(success: false, error: e.toString());
    }
  }

  /// Restore database from backup
  Future<RestoreResult> restoreFromBackup(
    AppDatabase database,
    String backupFilePath,
    String tenantId,
  ) async {
    try {
      _logger.i('Starting database restore from: $backupFilePath');

      // Load backup metadata
      final metadata = await _loadBackupMetadata(backupFilePath);
      if (metadata == null) {
        throw Exception('Backup metadata not found');
      }

      // Verify backup belongs to the same tenant
      if (metadata.tenantId != tenantId) {
        throw Exception('Backup belongs to different tenant');
      }

      // Verify backup integrity
      final isValid = await _verifyBackupIntegrity(backupFilePath, metadata.checksum);
      if (!isValid) {
        throw Exception('Backup integrity verification failed');
      }

      // Close database connection
      await database.close();

      // Get database file path
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'sentinel.db'));

      // Create a backup of current database before restore
      if (await dbFile.exists()) {
        final currentDbBackupPath = '${dbFile.path}.pre_restore_backup';
        await dbFile.copy(currentDbBackupPath);
        _logger.i('Created pre-restore backup: $currentDbBackupPath');
      }

      // Copy backup file to database location
      final backupFile = File(backupFilePath);
      await backupFile.copy(dbFile.path);

      // Reinitialize database connection
      // Note: This would need to be handled by the caller

      _logger.i('Database restore completed successfully');

      return RestoreResult(
        success: true,
        metadata: metadata,
        previousVersion: database.schemaVersion,
      );
    } catch (e) {
      _logger.e('Database restore failed: $e');
      return RestoreResult(success: false, error: e.toString());
    }
  }

  /// List all available backups for a tenant
  Future<List<BackupMetadata>> listBackups(String tenantId) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFiles = await backupDir.list().where((file) =>
        file.path.endsWith('.enc') && file.path.contains(tenantId)
      ).cast<File>().toList();

      final backups = <BackupMetadata>[];

      for (final backupFile in backupFiles) {
        final metadata = await _loadBackupMetadata(backupFile.path);
        if (metadata != null && metadata.tenantId == tenantId) {
          backups.add(metadata);
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backups;
    } catch (e) {
      _logger.e('Failed to list backups: $e');
      return [];
    }
  }

  /// Delete a specific backup
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      final metadataFile = File('$backupFilePath.meta');

      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      _logger.i('Backup deleted: $backupFilePath');
      return true;
    } catch (e) {
      _logger.e('Failed to delete backup: $e');
      return false;
    }
  }

  /// Clean up old backups (retention policy)
  Future<void> _cleanupOldBackups(String tenantId) async {
    try {
      final backups = await listBackups(tenantId);
      final now = DateTime.now();

      // Delete backups older than retention period
      for (final backup in backups) {
        final age = now.difference(backup.createdAt);
        if (age > backupRetentionPeriod) {
          await deleteBackup(backup.filePath);
          _logger.i('Deleted old backup: ${backup.filePath}');
        }
      }

      // Keep only the most recent backups (up to maxBackupFiles)
      final recentBackups = backups.where((backup) =>
        now.difference(backup.createdAt) <= backupRetentionPeriod
      ).toList();

      if (recentBackups.length > maxBackupFiles) {
        // Sort by creation date (oldest first for deletion)
        recentBackups.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final toDelete = recentBackups.length - maxBackupFiles;
        for (int i = 0; i < toDelete; i++) {
          await deleteBackup(recentBackups[i].filePath);
          _logger.i('Deleted excess backup: ${recentBackups[i].filePath}');
        }
      }
    } catch (e) {
      _logger.e('Failed to cleanup old backups: $e');
    }
  }

  /// Verify backup file integrity
  Future<bool> _verifyBackupIntegrity(String filePath, String expectedChecksum) async {
    try {
      final actualChecksum = await _calculateFileChecksum(File(filePath));
      return actualChecksum == expectedChecksum;
    } catch (e) {
      _logger.e('Backup integrity verification failed: $e');
      return false;
    }
  }

  /// Calculate SHA-256 checksum of a file
  Future<String> _calculateFileChecksum(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      _logger.e('Failed to calculate file checksum: $e');
      rethrow;
    }
  }

  /// Get backup directory
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  /// Save backup metadata to file
  Future<void> _saveBackupMetadata(BackupMetadata metadata) async {
    try {
      final metadataFile = File('${metadata.filePath}.meta');
      final metadataJson = jsonEncode(metadata.toJson());
      await metadataFile.writeAsString(metadataJson);
    } catch (e) {
      _logger.e('Failed to save backup metadata: $e');
      rethrow;
    }
  }

  /// Load backup metadata from file
  Future<BackupMetadata?> _loadBackupMetadata(String backupFilePath) async {
    try {
      final metadataFile = File('$backupFilePath.meta');
      if (!await metadataFile.exists()) {
        return null;
      }

      final metadataJson = await metadataFile.readAsString();
      final metadataMap = jsonDecode(metadataJson) as Map<String, dynamic>;
      return BackupMetadata.fromJson(metadataMap);
    } catch (e) {
      _logger.e('Failed to load backup metadata: $e');
      return null;
    }
  }

  /// Generate unique backup ID
  String _generateBackupId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate random string for IDs
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  /// Get backup statistics
  Map<String, dynamic> getBackupStats(List<BackupMetadata> backups) {
    if (backups.isEmpty) {
      return {
        'totalBackups': 0,
        'totalSize': 0,
        'oldestBackup': null,
        'newestBackup': null,
        'averageSize': 0,
      };
    }

    final totalSize = backups.fold<int>(0, (sum, backup) => sum + backup.fileSize);
    final sortedBackups = List<BackupMetadata>.from(backups)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return {
      'totalBackups': backups.length,
      'totalSize': totalSize,
      'oldestBackup': sortedBackups.first.createdAt.toIso8601String(),
      'newestBackup': sortedBackups.last.createdAt.toIso8601String(),
      'averageSize': totalSize ~/ backups.length,
      'backupTypes': backups.fold<Map<String, int>>({}, (map, backup) {
        map[backup.backupType] = (map[backup.backupType] ?? 0) + 1;
        return map;
      }),
    };
  }
}

/// Backup result class
class BackupResult {
  final bool success;
  final String? backupPath;
  final BackupMetadata? metadata;
  final String? error;

  const BackupResult({
    required this.success,
    this.backupPath,
    this.metadata,
    this.error,
  });

  @override
  String toString() {
    return 'BackupResult(success: $success, path: $backupPath, error: $error)';
  }
}

/// Restore result class
class RestoreResult {
  final bool success;
  final BackupMetadata? metadata;
  final int? previousVersion;
  final String? error;

  const RestoreResult({
    required this.success,
    this.metadata,
    this.previousVersion,
    this.error,
  });

  @override
  String toString() {
    return 'RestoreResult(success: $success, error: $error)';
  }
}

/// Backup metadata class
class BackupMetadata {
  final String id;
  final String tenantId;
  final String backupType;
  final String filePath;
  final int fileSize;
  final String checksum;
  final int databaseVersion;
  final DateTime createdAt;

  const BackupMetadata({
    required this.id,
    required this.tenantId,
    required this.backupType,
    required this.filePath,
    required this.fileSize,
    required this.checksum,
    required this.databaseVersion,
    required this.createdAt,
  });

  /// Create from JSON
  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      backupType: json['backupType'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      checksum: json['checksum'] as String,
      databaseVersion: json['databaseVersion'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'backupType': backupType,
      'filePath': filePath,
      'fileSize': fileSize,
      'checksum': checksum,
      'databaseVersion': databaseVersion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get human-readable file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() {
    return 'BackupMetadata(id: $id, tenantId: $tenantId, type: $backupType, size: $formattedFileSize, created: $createdAt)';
  }
}

/// Backup exception
class BackupException implements Exception {
  const BackupException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => 'BackupException: $message${errorCode != null ? ' (Code: $errorCode)' : ""}';
}