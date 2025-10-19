import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';
import '../storage/database.dart';
import 'sync_queue_manager.dart';
import 'workmanager_config.dart';

/// Sync Service
/// Coordinates background synchronization with batch processing capabilities
class SyncService {
  SyncService._();
  static final SyncService _instance = SyncService._();
  static SyncService get instance => _instance;

  final Logger _logger = Logger();
  bool _isInitialized = false;
  bool _isSyncing = false;
  Timer? _syncTimer;

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxBatchSize = 20;
  static const Duration _syncTimeout = Duration(minutes: 10);
  static const int _maxRetries = 3;

  /// Initialize sync service
  static Future<void> initialize() async {
    try {
      final syncService = SyncService.instance;
      if (syncService._isInitialized) {
        return;
      }

      _logger.i('Initializing Sync Service...');

      // Initialize WorkManager
      final workManagerConfig = WorkManagerConfig.instance;
      final workManagerInitialized = await workManagerConfig.initialize();

      if (!workManagerInitialized) {
        _logger.w('WorkManager initialization failed, falling back to timer-based sync');
        syncService._startPeriodicSyncTimer();
      }

      // Check for pending sync items on startup
      unawaited(syncService._checkAndSyncPendingItems());

      syncService._isInitialized = true;
      _logger.i('Sync Service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Sync Service: $e');
      rethrow;
    }
  }

  /// Start periodic sync timer (fallback when WorkManager fails)
  void _startPeriodicSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      _logger.d('Periodic sync timer triggered');
      unawaited(_checkAndSyncPendingItems());
    });
  }

  /// Perform periodic sync (called by WorkManager)
  Future<void> performPeriodicSync() async {
    try {
      _logger.d('Performing periodic sync...');

      // Check network connectivity
      if (!await _hasNetworkConnectivity()) {
        _logger.d('No network connectivity, skipping periodic sync');
        return;
      }

      // Sync pending items
      await _syncPendingItems();

      // Clean up old completed items
      final queueManager = SyncQueueManager.instance;
      await queueManager.cleanupCompletedItems();

      _logger.d('Periodic sync completed');
    } catch (e) {
      _logger.e('Error in periodic sync: $e');
    }
  }

  /// Perform immediate sync (called by WorkManager)
  Future<void> performImmediateSync() async {
    try {
      _logger.d('Performing immediate sync...');

      if (!await _hasNetworkConnectivity()) {
        _logger.d('No network connectivity for immediate sync');
        return;
      }

      await _syncPendingItems(forceSync: true);

      _logger.d('Immediate sync completed');
    } catch (e) {
      _logger.e('Error in immediate sync: $e');
    }
  }

  /// Perform cleanup task (called by WorkManager)
  Future<void> performCleanup() async {
    try {
      _logger.d('Performing cleanup task...');

      final queueManager = SyncQueueManager.instance;

      // Clean up old completed items
      await queueManager.cleanupCompletedItems();

      // Clean up old database entries
      final database = DatabaseProvider.instance;
      await database.cleanupOldSyncItems();

      _logger.d('Cleanup task completed');
    } catch (e) {
      _logger.e('Error in cleanup task: $e');
    }
  }

  /// Check and sync pending items
  Future<void> _checkAndSyncPendingItems() async {
    try {
      if (_isSyncing) {
        _logger.d('Sync already in progress, skipping');
        return;
      }

      if (!await _hasNetworkConnectivity()) {
        _logger.d('No network connectivity');
        return;
      }

      // Check if user is authenticated
      final authProvider = AuthProvider.instance;
      if (!authProvider.isAuthenticated) {
        _logger.d('User not authenticated, skipping sync');
        return;
      }

      await _syncPendingItems();
    } catch (e) {
      _logger.e('Error checking and syncing pending items: $e');
    }
  }

  /// Sync pending items with batch processing
  Future<void> _syncPendingItems({bool forceSync = false}) async {
    if (_isSyncing && !forceSync) {
      _logger.d('Sync already in progress');
      return;
    }

    _isSyncing = true;

    try {
      _logger.d('Starting sync of pending items...');

      final queueManager = SyncQueueManager.instance;
      final database = DatabaseProvider.instance;

      // Get pending items in batches
      int totalProcessed = 0;
      int totalBatches = 0;

      while (true) {
        // Get next batch of items
        final pendingItems = await queueManager.getPendingItems(limit: _maxBatchSize);

        if (pendingItems.isEmpty) {
          break;
        }

        totalBatches++;
        _logger.d('Processing batch $totalBatches with ${pendingItems.length} items');

        // Process batch
        final processedItems = await queueManager.processBatch(items: pendingItems);

        if (processedItems.isEmpty) {
          continue;
        }

        // Sync items to server
        await _syncBatchToServer(processedItems);

        totalProcessed += processedItems.length;

        // Add delay between batches to prevent overwhelming the server
        if (pendingItems.length >= _maxBatchSize) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      _logger.i('Sync completed: $totalProcessed items in $totalBatches batches');
    } catch (e) {
      _logger.e('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync batch of items to server
  Future<void> _syncBatchToServer(List<SyncQueueEntry> items) async {
    if (items.isEmpty) {
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final queueManager = SyncQueueManager.instance;

      // Group items by entity type for batch operations
      final groupedItems = <String, List<SyncQueueEntry>>{};
      for (final item in items) {
        final entityType = item.entityType;
        if (!groupedItems.containsKey(entityType)) {
          groupedItems[entityType] = [];
        }
        groupedItems[entityType]!.add(item);
      }

      // Process each group
      for (final entry in groupedItems.entries) {
        final entityType = entry.key;
        final entityItems = entry.value;

        _logger.d('Syncing ${entityItems.length} $entityType items');

        await _syncEntityTypeToServer(supabase, entityType, entityItems, queueManager);
      }
    } catch (e) {
      _logger.e('Error syncing batch to server: $e');

      // Mark all items in batch as failed
      final queueManager = SyncQueueManager.instance;
      for (final item in items) {
        await queueManager.markAsFailed(item.id, 'Batch sync failed: $e');
      }
    }
  }

  /// Sync specific entity type items to server
  Future<void> _syncEntityTypeToServer(
    SupabaseClient supabase,
    String entityType,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    try {
      switch (entityType) {
        case 'entry_logs':
          await _syncEntryLogs(supabase, items, queueManager);
          break;
        case 'guest_logs':
          await _syncGuestLogs(supabase, items, queueManager);
          break;
        case 'delivery_logs':
          await _syncDeliveryLogs(supabase, items, queueManager);
          break;
        case 'construction_worker_logs':
          await _syncConstructionWorkerLogs(supabase, items, queueManager);
          break;
        case 'incident_reports':
          await _syncIncidentReports(supabase, items, queueManager);
          break;
        default:
          _logger.w('Unknown entity type: $entityType');
          for (final item in items) {
            await queueManager.markAsFailed(item.id, 'Unknown entity type: $entityType');
          }
      }
    } catch (e) {
      _logger.e('Error syncing $entityType to server: $e');
      rethrow;
    }
  }

  /// Sync entry logs to server
  Future<void> _syncEntryLogs(
    SupabaseClient supabase,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        final operation = item.operation;

        switch (operation) {
          case 'CREATE':
            final response = await supabase
                .from('entry_logs')
                .insert(payload)
                .select()
                .single();

            // Mark local entry as synced
            final database = DatabaseProvider.instance;
            await database.markEntryLogAsSynced(payload['id']);

            await queueManager.markAsCompleted(item.id);
            break;

          case 'UPDATE':
            await supabase
                .from('entry_logs')
                .update(payload)
                .eq('id', payload['id']);

            await queueManager.markAsCompleted(item.id);
            break;

          default:
            throw Exception('Unsupported operation: $operation');
        }
      } catch (e) {
        _logger.e('Error syncing entry log ${item.entityId}: $e');
        await queueManager.markAsFailed(item.id, e.toString());
      }
    }
  }

  /// Sync guest logs to server
  Future<void> _syncGuestLogs(
    SupabaseClient supabase,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        await supabase
            .from('guest_logs')
            .insert(payload);

        await queueManager.markAsCompleted(item.id);
      } catch (e) {
        _logger.e('Error syncing guest log ${item.entityId}: $e');
        await queueManager.markAsFailed(item.id, e.toString());
      }
    }
  }

  /// Sync delivery logs to server
  Future<void> _syncDeliveryLogs(
    SupabaseClient supabase,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        await supabase
            .from('delivery_logs')
            .insert(payload);

        await queueManager.markAsCompleted(item.id);
      } catch (e) {
        _logger.e('Error syncing delivery log ${item.entityId}: $e');
        await queueManager.markAsFailed(item.id, e.toString());
      }
    }
  }

  /// Sync construction worker logs to server
  Future<void> _syncConstructionWorkerLogs(
    SupabaseClient supabase,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        await supabase
            .from('construction_worker_logs')
            .insert(payload);

        await queueManager.markAsCompleted(item.id);
      } catch (e) {
        _logger.e('Error syncing construction worker log ${item.entityId}: $e');
        await queueManager.markAsFailed(item.id, e.toString());
      }
    }
  }

  /// Sync incident reports to server
  Future<void> _syncIncidentReports(
    SupabaseClient supabase,
    List<SyncQueueEntry> items,
    SyncQueueManager queueManager,
  ) async {
    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        await supabase
            .from('incident_reports')
            .insert(payload);

        await queueManager.markAsCompleted(item.id);
      } catch (e) {
        _logger.e('Error syncing incident report ${item.entityId}: $e');
        await queueManager.markAsFailed(item.id, e.toString());
      }
    }
  }

  /// Check network connectivity
  Future<bool> _hasNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.d('Network connectivity check failed: $e');
      return false;
    }
  }

  /// Force sync all pending items
  Future<void> forceSyncAll() async {
    try {
      _logger.i('Force syncing all pending items...');

      if (!await _hasNetworkConnectivity()) {
        throw Exception('No network connectivity');
      }

      await _syncPendingItems(forceSync: true);

      _logger.i('Force sync completed');
    } catch (e) {
      _logger.e('Error in force sync: $e');
      rethrow;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final queueManager = SyncQueueManager.instance;
      final database = DatabaseProvider.instance;

      final queueStats = await queueManager.getQueueStats();
      final databaseStats = await database.getDatabaseStats();
      final workManagerStatus = await WorkManagerConfig.instance.getSyncStatus();

      return {
        'isInitialized': _isInitialized,
        'isSyncing': _isSyncing,
        'hasNetwork': await _hasNetworkConnectivity(),
        'queueStats': queueStats,
        'databaseStats': databaseStats,
        'workManagerStatus': workManagerStatus,
        'lastSyncCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return {
        'error': e.toString(),
        'isInitialized': _isInitialized,
        'isSyncing': _isSyncing,
      };
    }
  }

  /// Get pending item count
  Future<int> getPendingItemCount() async {
    try {
      final queueManager = SyncQueueManager.instance;
      final stats = await queueManager.getQueueStats();
      return stats['pending'] ?? 0;
    } catch (e) {
      _logger.e('Error getting pending item count: $e');
      return 0;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final database = DatabaseProvider.instance;
      final lastSyncedEntry = await (database.select(database.entryLogs)
            ..where((tbl) => tbl.synced.equals(true))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
            ..limit(1)
          ).getSingleOrNull();

      return lastSyncedEntry?.updatedAt;
    } catch (e) {
      _logger.e('Error getting last sync time: $e');
      return null;
    }
  }

  /// Add item to sync queue
  Future<String> addToSyncQueue({
    required String operation,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final queueManager = SyncQueueManager.instance;
      return await queueManager.addToQueue(
        operation: operation,
        entityType: entityType,
        entityId: entityId,
        payload: payload,
      );
    } catch (e) {
      _logger.e('Error adding item to sync queue: $e');
      rethrow;
    }
  }

  /// Clear sync queue (for debugging/reset)
  Future<int> clearSyncQueue() async {
    try {
      final queueManager = SyncQueueManager.instance;
      return await queueManager.clearQueue();
    } catch (e) {
      _logger.e('Error clearing sync queue: $e');
      rethrow;
    }
  }

  /// Dispose sync service
  Future<void> dispose() async {
    try {
      _logger.i('Disposing Sync Service...');

      _syncTimer?.cancel();
      _syncTimer = null;

      _isInitialized = false;
      _isSyncing = false;

      _logger.i('Sync Service disposed');
    } catch (e) {
      _logger.e('Error disposing Sync Service: $e');
    }
  }
}

/// Sync service exception
class SyncServiceException implements Exception {
  const SyncServiceException(this.message);

  final String message;

  @override
  String toString() => 'SyncServiceException: $message';
}

/// Extension for unawaited futures
extension UnawaitedExtension on Future<void> {
  void unawaited() {
    // Ignore the result to prevent "unawaited future" warnings
  }
}