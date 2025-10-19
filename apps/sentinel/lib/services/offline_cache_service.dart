import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/guard.dart';
import '../models/rfid_sticker.dart';
import '../models/entry_log.dart';
import '../models/guard_session.dart';

/// Cache configuration
class CacheConfig {
  final Duration defaultExpiration;
  final int maxCacheSize;
  final bool enableEncryption;

  const CacheConfig({
    this.defaultExpiration = const Duration(hours: 1),
    this.maxCacheSize = 1000,
    this.enableEncryption = true,
  });
}

/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final DateTime expiration;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiration,
  });

  factory CacheEntry.create(T data, Duration expiration) {
    final now = DateTime.now();
    return CacheEntry(
      data: data,
      timestamp: now,
      expiration: now.add(expiration),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiration);

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiration': expiration.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return CacheEntry(
      data: fromJson(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      expiration: DateTime.parse(json['expiration']),
    );
  }
}

/// Offline cache service for local data storage
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  late final Box _cacheBox;
  late final Box _settingsBox;
  bool _isInitialized = false;
  final CacheConfig _config = const CacheConfig();

  /// Cache keys
  static const String _guardsKey = 'guards';
  static const String _rfidStickersKey = 'rfid_stickers';
  static const String _entryLogsKey = 'entry_logs';
  static const String _guardSessionsKey = 'guard_sessions';
  static const String _todayEntriesKey = 'today_entries';
  static const String _pendingSyncKey = 'pending_sync';

  /// Getters
  bool get isInitialized => _isInitialized;

  /// Initialize cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GuardAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(RfidStickerAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(EntryLogAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(GuardSessionAdapter());
      }

      // Open boxes
      _cacheBox = await Hive.openBox('sentinel_cache');
      _settingsBox = await Hive.openBox('sentinel_settings');

      _isInitialized = true;
      debugPrint('Offline cache service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize cache service: $e');
      rethrow;
    }
  }

  // ==================== GUARD CACHE ====================

  /// Cache guard data
  Future<void> cacheGuards(List<Guard> guards, {Duration? expiration}) async {
    try {
      final entry = CacheEntry.create(
        guards.map((g) => g.toJson()).toList(),
        expiration ?? _config.defaultExpiration,
      );
      await _cacheBox.put(_guardsKey, entry.toJson());
      debugPrint('Cached ${guards.length} guards');
    } catch (e) {
      debugPrint('Failed to cache guards: $e');
    }
  }

  /// Get cached guards
  Future<List<Guard>?> getCachedGuards() async {
    try {
      final json = _cacheBox.get(_guardsKey);
      if (json == null) return null;

      final entry = CacheEntry.fromJson(
        json,
        (data) => (data as List).map((g) => Guard.fromJson(g)).toList(),
      );

      if (entry.isExpired) {
        await _cacheBox.delete(_guardsKey);
        return null;
      }

      return entry.data as List<Guard>;
    } catch (e) {
      debugPrint('Failed to get cached guards: $e');
      return null;
    }
  }

  // ==================== RFID STICKERS CACHE ====================

  /// Cache RFID stickers
  Future<void> cacheRfidStickers(List<RfidSticker> stickers, {Duration? expiration}) async {
    try {
      final entry = CacheEntry.create(
        stickers.map((s) => s.toJson()).toList(),
        expiration ?? _config.defaultExpiration,
      );
      await _cacheBox.put(_rfidStickersKey, entry.toJson());
      debugPrint('Cached ${stickers.length} RFID stickers');
    } catch (e) {
      debugPrint('Failed to cache RFID stickers: $e');
    }
  }

  /// Get cached RFID stickers
  Future<List<RfidSticker>?> getCachedRfidStickers() async {
    try {
      final json = _cacheBox.get(_rfidStickersKey);
      if (json == null) return null;

      final entry = CacheEntry.fromJson(
        json,
        (data) => (data as List).map((s) => RfidSticker.fromJson(s)).toList(),
      );

      if (entry.isExpired) {
        await _cacheBox.delete(_rfidStickersKey);
        return null;
      }

      return entry.data as List<RfidSticker>;
    } catch (e) {
      debugPrint('Failed to get cached RFID stickers: $e');
      return null;
    }
  }

  /// Find RFID sticker by code
  Future<RfidSticker?> findRfidStickerByCode(String stickerCode) async {
    try {
      final stickers = await getCachedRfidStickers();
      if (stickers == null) return null;

      for (final sticker in stickers) {
        if (sticker.stickerCode == stickerCode && sticker.isValid) {
          return sticker;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to find RFID sticker: $e');
      return null;
    }
  }

  // ==================== ENTRY LOGS CACHE ====================

  /// Cache entry logs
  Future<void> cacheEntryLogs(List<EntryLog> entries, {Duration? expiration}) async {
    try {
      final entry = CacheEntry.create(
        entries.map((e) => e.toJson()).toList(),
        expiration ?? _config.defaultExpiration,
      );
      await _cacheBox.put(_entryLogsKey, entry.toJson());
      debugPrint('Cached ${entries.length} entry logs');
    } catch (e) {
      debugPrint('Failed to cache entry logs: $e');
    }
  }

  /// Get cached entry logs
  Future<List<EntryLog>?> getCachedEntryLogs() async {
    try {
      final json = _cacheBox.get(_entryLogsKey);
      if (json == null) return null;

      final entry = CacheEntry.fromJson(
        json,
        (data) => (data as List).map((e) => EntryLog.fromJson(e)).toList(),
      );

      if (entry.isExpired) {
        await _cacheBox.delete(_entryLogsKey);
        return null;
      }

      return entry.data as List<EntryLog>;
    } catch (e) {
      debugPrint('Failed to get cached entry logs: $e');
      return null;
    }
  }

  /// Cache today's entries
  Future<void> cacheTodayEntries(List<EntryLog> entries, {Duration? expiration}) async {
    try {
      final entry = CacheEntry.create(
        entries.map((e) => e.toJson()).toList(),
        expiration ?? const Duration(minutes: 30), // Shorter cache for today's entries
      );
      await _cacheBox.put(_todayEntriesKey, entry.toJson());
      debugPrint('Cached ${entries.length} today\'s entries');
    } catch (e) {
      debugPrint('Failed to cache today\'s entries: $e');
    }
  }

  /// Get cached today's entries
  Future<List<EntryLog>?> getCachedTodayEntries() async {
    try {
      final json = _cacheBox.get(_todayEntriesKey);
      if (json == null) return null;

      final entry = CacheEntry.fromJson(
        json,
        (data) => (data as List).map((e) => EntryLog.fromJson(e)).toList(),
      );

      if (entry.isExpired) {
        await _cacheBox.delete(_todayEntriesKey);
        return null;
      }

      return entry.data as List<EntryLog>;
    } catch (e) {
      debugPrint('Failed to get cached today\'s entries: $e');
      return null;
    }
  }

  // ==================== GUARD SESSIONS CACHE ====================

  /// Cache guard sessions
  Future<void> cacheGuardSessions(List<GuardSession> sessions, {Duration? expiration}) async {
    try {
      final entry = CacheEntry.create(
        sessions.map((s) => s.toJson()).toList(),
        expiration ?? const Duration(minutes: 15), // Short cache for sessions
      );
      await _cacheBox.put(_guardSessionsKey, entry.toJson());
      debugPrint('Cached ${sessions.length} guard sessions');
    } catch (e) {
      debugPrint('Failed to cache guard sessions: $e');
    }
  }

  /// Get cached guard sessions
  Future<List<GuardSession>?> getCachedGuardSessions() async {
    try {
      final json = _cacheBox.get(_guardSessionsKey);
      if (json == null) return null;

      final entry = CacheEntry.fromJson(
        json,
        (data) => (data as List).map((s) => GuardSession.fromJson(s)).toList(),
      );

      if (entry.isExpired) {
        await _cacheBox.delete(_guardSessionsKey);
        return null;
      }

      return entry.data as List<GuardSession>;
    } catch (e) {
      debugPrint('Failed to get cached guard sessions: $e');
      return null;
    }
  }

  // ==================== PENDING SYNC CACHE ====================

  /// Add pending sync operation
  Future<void> addPendingSyncOperation(Map<String, dynamic> operation) async {
    try {
      final pendingOps = await getPendingSyncOperations();
      pendingOps.add(operation);
      await _cacheBox.put(_pendingSyncKey, pendingOps);
      debugPrint('Added pending sync operation');
    } catch (e) {
      debugPrint('Failed to add pending sync operation: $e');
    }
  }

  /// Get pending sync operations
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    try {
      final json = _cacheBox.get(_pendingSyncKey);
      if (json == null) return [];

      return (json as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to get pending sync operations: $e');
      return [];
    }
  }

  /// Remove pending sync operation
  Future<void> removePendingSyncOperation(String operationId) async {
    try {
      final pendingOps = await getPendingSyncOperations();
      pendingOps.removeWhere((op) => op['id'] == operationId);
      await _cacheBox.put(_pendingSyncKey, pendingOps);
      debugPrint('Removed pending sync operation: $operationId');
    } catch (e) {
      debugPrint('Failed to remove pending sync operation: $e');
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  /// Clear expired entries
  Future<void> clearExpiredEntries() async {
    try {
      final keys = _cacheBox.keys.toList();
      int removedCount = 0;

      for (final key in keys) {
        final json = _cacheBox.get(key);
        if (json != null && json is Map<String, dynamic>) {
          try {
            final entry = CacheEntry.fromJson(
              json,
              (data) => data, // Generic deserialization for expiration check
            );

            if (entry.isExpired) {
              await _cacheBox.delete(key);
              removedCount++;
            }
          } catch (e) {
            // If we can't parse, remove the entry
            await _cacheBox.delete(key);
            removedCount++;
          }
        }
      }

      debugPrint('Cleared $removedCount expired cache entries');
    } catch (e) {
      debugPrint('Failed to clear expired entries: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final totalEntries = _cacheBox.keys.length;
      final totalSize = await _getCacheSize();

      final guards = await getCachedGuards();
      final stickers = await getCachedRfidStickers();
      final entries = await getCachedEntryLogs();
      final todayEntries = await getCachedTodayEntries();
      final sessions = await getCachedGuardSessions();
      final pendingOps = await getPendingSyncOperations();

      return {
        'total_entries': totalEntries,
        'total_size_bytes': totalSize,
        'guards_count': guards?.length ?? 0,
        'rfid_stickers_count': stickers?.length ?? 0,
        'entry_logs_count': entries?.length ?? 0,
        'today_entries_count': todayEntries?.length ?? 0,
        'guard_sessions_count': sessions?.length ?? 0,
        'pending_sync_count': pendingOps.length,
        'last_cleanup': await _getLastCleanupTime(),
      };
    } catch (e) {
      debugPrint('Failed to get cache stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Get cache size in bytes
  Future<int> _getCacheSize() async {
    try {
      int totalSize = 0;
      for (final key in _cacheBox.keys) {
        final value = _cacheBox.get(key);
        if (value != null) {
          totalSize += json.encode(value).length;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get last cleanup time
  Future<String?> _getLastCleanupTime() async {
    return _settingsBox.get('last_cleanup_time');
  }

  /// Set last cleanup time
  Future<void> _setLastCleanupTime() async {
    await _settingsBox.put('last_cleanup_time', DateTime.now().toIso8601String());
  }

  /// Perform cache maintenance
  Future<void> performMaintenance() async {
    try {
      await clearExpiredEntries();
      await _setLastCleanupTime();
      debugPrint('Cache maintenance completed');
    } catch (e) {
      debugPrint('Cache maintenance failed: $e');
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    try {
      await _cacheBox.close();
      await _settingsBox.close();
      _isInitialized = false;
      debugPrint('Offline cache service disposed');
    } catch (e) {
      debugPrint('Error disposing cache service: $e');
    }
  }
}

// Hive Type Adapters
class GuardAdapter extends TypeAdapter<Guard> {
  @override
  final int typeId = 1;

  @override
  Guard read(BinaryReader reader) {
    return Guard.fromJson(jsonDecode(reader.read()));
  }

  @override
  void write(BinaryWriter writer, Guard obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}

class RfidStickerAdapter extends TypeAdapter<RfidSticker> {
  @override
  final int typeId = 2;

  @override
  RfidSticker read(BinaryReader reader) {
    return RfidSticker.fromJson(jsonDecode(reader.read()));
  }

  @override
  void write(BinaryWriter writer, RfidSticker obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}

class EntryLogAdapter extends TypeAdapter<EntryLog> {
  @override
  final int typeId = 3;

  @override
  EntryLog read(BinaryReader reader) {
    return EntryLog.fromJson(jsonDecode(reader.read()));
  }

  @override
  void write(BinaryWriter writer, EntryLog obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}

class GuardSessionAdapter extends TypeAdapter<GuardSession> {
  @override
  final int typeId = 4;

  @override
  GuardSession read(BinaryReader reader) {
    return GuardSession.fromJson(jsonDecode(reader.read()));
  }

  @override
  void write(BinaryWriter writer, GuardSession obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}