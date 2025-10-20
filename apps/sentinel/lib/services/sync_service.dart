import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/sync_queue.dart';
import '../models/entry_log.dart';
import '../models/guard.dart';
import '../models/rfid_sticker.dart';
import '../models/guard_session.dart';
import 'supabase_service.dart';
import 'offline_cache_service.dart';

/// Sync service configuration
class SyncConfig {
  final Duration batchInterval;
  final int batchSize;
  final Duration timeout;
  final int maxRetryAttempts;
  final bool enableRealTimeSync;

  const SyncConfig({
    this.batchInterval = const Duration(minutes: 5),
    this.batchSize = 50,
    this.timeout = const Duration(seconds: 30),
    this.maxRetryAttempts = 3,
    this.enableRealTimeSync = true,
  });
}

/// Sync operation result
class SyncOperationResult {
  final String operationId;
  final bool success;
  final String? error;
  final Duration duration;

  const SyncOperationResult({
    required this.operationId,
    required this.success,
    this.error,
    required this.duration,
  });
}

/// Sync service for offline data synchronization
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SyncConfig _config = const SyncConfig();
  final SupabaseService _supabaseService = SupabaseService();
  final OfflineCacheService _cacheService = OfflineCacheService();

  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _isRealTimeSyncEnabled = true;
  Timer? _batchSyncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final StreamController<SyncOperationResult> _syncResultsController =
      StreamController<SyncOperationResult>.broadcast();

  /// Public streams
  Stream<SyncOperationResult> get syncResults => _syncResultsController.stream;

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  bool get isRealTimeSyncEnabled => _isRealTimeSyncEnabled;

  /// Initialize sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize dependencies
      await _supabaseService.initialize();
      await _cacheService.initialize();

      // Set up connectivity monitoring
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        _handleConnectivityChange(result);
      });

      // Start batch sync timer
      _startBatchSyncTimer();

      _isInitialized = true;
      debugPrint('Sync service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize sync service: $e');
      rethrow;
    }
  }

  /// Add operation to sync queue
  Future<void> addOperation(SyncQueue operation) async {
    try {
      // Add to local cache queue
      await _cacheService.addPendingSyncOperation({
        'id': operation.id,
        'tenant_id': operation.tenantId,
        'operation': operation.operation.toApiString(),
        'entity_type': operation.entityType,
        'entity_id': operation.entityId,
        'payload': operation.payload,
        'priority': operation.priority.toApiString(),
        'retry_count': operation.retryCount,
        'max_retries': operation.maxRetries,
        'scheduled_for': operation.scheduledFor.toIso8601String(),
        'last_attempt_at': operation.lastAttemptAt?.toIso8601String(),
        'next_attempt_at': operation.nextAttemptAt.toIso8601String(),
        'status': operation.status.toApiString(),
        'error_message': operation.errorMessage,
        'created_at': operation.createdAt.toIso8601String(),
        'updated_at': operation.updatedAt.toIso8601String(),
      });

      debugPrint('Added sync operation: ${operation.id} (${operation.operation.name} ${operation.entityType})');

      // If real-time sync is enabled and we have connectivity, try immediate sync
      if (_isRealTimeSyncEnabled && await _hasConnectivity()) {
        unawaited(_processImmediateOperation(operation));
      }
    } catch (e) {
      debugPrint('Failed to add sync operation: $e');
    }
  }

  /// Process immediate operation (for real-time sync)
  Future<void> _processImmediateOperation(SyncQueue operation) async {
    if (!await _hasConnectivity()) return;

    try {
      await _executeSyncOperation(operation);
    } catch (e) {
      debugPrint('Failed to process immediate operation: $e');
    }
  }

  /// Start batch sync timer
  void _startBatchSyncTimer() {
    _batchSyncTimer?.cancel();
    _batchSyncTimer = Timer.periodic(_config.batchInterval, (_) {
      unawaited(_performBatchSync());
    });
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      debugPrint('Network connectivity restored, starting sync');
      unawaited(_performBatchSync());
    } else {
      debugPrint('Network connectivity lost');
    }
  }

  /// Check if device has connectivity
  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Perform batch synchronization
  Future<void> _performBatchSync() async {
    if (_isSyncing || !await _hasConnectivity()) return;

    _isSyncing = true;
    debugPrint('Starting batch synchronization');

    try {
      final pendingOperations = await _getPendingOperations();
      if (pendingOperations.isEmpty) {
        debugPrint('No pending operations to sync');
        return;
      }

      debugPrint('Processing ${pendingOperations.length} pending operations');

      // Process operations in batches
      for (int i = 0; i < pendingOperations.length; i += _config.batchSize) {
        final end = (i + _config.batchSize).clamp(0, pendingOperations.length);
        final batch = pendingOperations.sublist(i, end);

        await _processBatch(batch);
      }

      // Clean up completed operations
      await _cleanupCompletedOperations();

      debugPrint('Batch synchronization completed');
    } catch (e) {
      debugPrint('Batch synchronization failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Get pending operations from cache
  Future<List<SyncQueue>> _getPendingOperations() async {
    try {
      final cachedOps = await _cacheService.getPendingSyncOperations();
      return cachedOps.map((op) => _jsonToSyncQueue(op)).where((op) =>
          op.isReadyToProcess && !op.isExpired).toList()
        ..sort((a, b) {
          // Sort by priority, then by scheduled time
          if (a.priorityValue != b.priorityValue) {
            return b.priorityValue.compareTo(a.priorityValue);
          }
          return a.nextAttemptAt.compareTo(b.nextAttemptAt);
        });
    } catch (e) {
      debugPrint('Failed to get pending operations: $e');
      return [];
    }
  }

  /// Convert JSON to SyncQueue
  SyncQueue _jsonToSyncQueue(Map<String, dynamic> json) {
    return SyncQueue(
      id: json['id'],
      tenantId: json['tenant_id'],
      operation: SyncOperation.fromString(json['operation']),
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      payload: Map<String, dynamic>.from(json['payload']),
      priority: SyncPriority.fromString(json['priority']),
      retryCount: json['retry_count'],
      maxRetries: json['max_retries'],
      scheduledFor: DateTime.parse(json['scheduled_for']),
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'])
          : null,
      nextAttemptAt: DateTime.parse(json['next_attempt_at']),
      status: SyncStatus.fromString(json['status']),
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Process a batch of operations
  Future<void> _processBatch(List<SyncQueue> operations) async {
    for (final operation in operations) {
      try {
        await _executeSyncOperation(operation);
      } catch (e) {
        debugPrint('Failed to execute operation ${operation.id}: $e');
      }
    }
  }

  /// Execute a single sync operation
  Future<void> _executeSyncOperation(SyncQueue operation) async {
    final startTime = DateTime.now();
    debugPrint('Executing sync operation: ${operation.id} (${operation.operation.name} ${operation.entityType})');

    try {
      // Mark as processing
      await _updateOperationStatus(operation.markAsProcessing());

      // Execute based on operation type and entity type
      switch (operation.entityType) {
        case 'entry_log':
          await _executeEntryLogOperation(operation);
          break;
        case 'guard':
          await _executeGuardOperation(operation);
          break;
        case 'rfid_sticker':
          await _executeRfidStickerOperation(operation);
          break;
        case 'guard_session':
          await _executeGuardSessionOperation(operation);
          break;
        default:
          throw UnsupportedError('Unsupported entity type: ${operation.entityType}');
      }

      // Mark as completed
      await _updateOperationStatus(operation.markAsCompleted());

      final duration = DateTime.now().difference(startTime);
      _syncResultsController.add(SyncOperationResult(
        operationId: operation.id,
        success: true,
        duration: duration,
      ));

      debugPrint('Successfully executed operation: ${operation.id}');
    } catch (e) {
      // Mark as failed
      final failedOperation = operation.markAsFailed(e.toString());
      await _updateOperationStatus(failedOperation);

      final duration = DateTime.now().difference(startTime);
      _syncResultsController.add(SyncOperationResult(
        operationId: operation.id,
        success: false,
        error: e.toString(),
        duration: duration,
      ));

      debugPrint('Failed to execute operation ${operation.id}: $e');
      rethrow;
    }
  }

  /// Execute entry log operation
  Future<void> _executeEntryLogOperation(SyncQueue operation) async {
    final entryLog = EntryLog.fromJson(operation.payload);

    switch (operation.operation) {
      case SyncOperation.create:
        await _supabaseService.createEntryLog(entryLog);
        break;
      case SyncOperation.update:
        await _supabaseService.updateEntryLog(entryLog);
        break;
      case SyncOperation.delete:
        throw UnsupportedError('Entry log deletion is not supported');
    }
  }

  /// Execute guard operation
  Future<void> _executeGuardOperation(SyncQueue operation) async {
    final guard = Guard.fromJson(operation.payload);

    switch (operation.operation) {
      case SyncOperation.update:
        await _supabaseService.updateGuardProfile(guard);
        break;
      case SyncOperation.create:
      case SyncOperation.delete:
        throw UnsupportedError('Guard create/delete operations are not supported');
    }
  }

  /// Execute RFID sticker operation
  Future<void> _executeRfidStickerOperation(SyncQueue operation) async {
    // RFID operations are typically read-only from the app perspective
    // This can be extended to support sticker updates if needed
    throw UnsupportedError('RFID sticker operations are not supported from client');
  }

  /// Execute guard session operation
  Future<void> _executeGuardSessionOperation(SyncQueue operation) async {
    final session = GuardSession.fromJson(operation.payload);

    switch (operation.operation) {
      case SyncOperation.create:
        await _supabaseService.createGuardSession(session);
        break;
      case SyncOperation.update:
        await _supabaseService.endGuardSession(session.id);
        break;
      case SyncOperation.delete:
        throw UnsupportedError('Guard session deletion is not supported');
    }
  }

  /// Update operation status in cache
  Future<void> _updateOperationStatus(SyncQueue operation) async {
    try {
      // Convert operation to JSON
      final operationJson = {
        'id': operation.id,
        'tenant_id': operation.tenantId,
        'operation': operation.operation.toApiString(),
        'entity_type': operation.entityType,
        'entity_id': operation.entityId,
        'payload': operation.payload,
        'priority': operation.priority.toApiString(),
        'retry_count': operation.retryCount,
        'max_retries': operation.maxRetries,
        'scheduled_for': operation.scheduledFor.toIso8601String(),
        'last_attempt_at': operation.lastAttemptAt?.toIso8601String(),
        'next_attempt_at': operation.nextAttemptAt.toIso8601String(),
        'status': operation.status.toApiString(),
        'error_message': operation.errorMessage,
        'created_at': operation.createdAt.toIso8601String(),
        'updated_at': operation.updatedAt.toIso8601String(),
      };

      // Update or remove from cache based on status
      if (operation.status == SyncStatus.completed) {
        await _cacheService.removePendingSyncOperation(operation.id);
      } else {
        final pendingOps = await _cacheService.getPendingSyncOperations();
        final index = pendingOps.indexWhere((op) => op['id'] == operation.id);
        if (index >= 0) {
          pendingOps[index] = operationJson;
          // Update the cache by replacing all operations
          await _cacheService.clearCache();
          for (final op in pendingOps) {
            await _cacheService.addPendingSyncOperation(op);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to update operation status: $e');
    }
  }

  /// Clean up completed operations
  Future<void> _cleanupCompletedOperations() async {
    try {
      // This could be enhanced to remove old completed operations from server
      // For now, we'll focus on local cache cleanup
      await _cacheService.performMaintenance();
    } catch (e) {
      debugPrint('Failed to cleanup completed operations: $e');
    }
  }

  /// Force immediate sync
  Future<void> forceSync() async {
    if (!await _hasConnectivity()) {
      throw Exception('No network connectivity available');
    }

    await _performBatchSync();
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final pendingOperations = await _getPendingOperations();
      final cacheStats = await _cacheService.getCacheStats();

      return {
        'is_syncing': _isSyncing,
        'is_real_time_enabled': _isRealTimeSyncEnabled,
        'has_connectivity': await _hasConnectivity(),
        'pending_operations_count': pendingOperations.length,
        'cache_stats': cacheStats,
        'last_sync_time': cacheStats['last_cleanup_time'],
        'config': {
          'batch_interval_seconds': _config.batchInterval.inSeconds,
          'batch_size': _config.batchSize,
          'timeout_seconds': _config.timeout.inSeconds,
          'max_retry_attempts': _config.maxRetryAttempts,
        },
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
      };
    }
  }

  /// Enable/disable real-time sync
  void setRealTimeSyncEnabled(bool enabled) {
    _isRealTimeSyncEnabled = enabled;
    debugPrint('Real-time sync ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    try {
      await _cacheService.clearCache();
      debugPrint('Cleared all pending operations');
    } catch (e) {
      debugPrint('Failed to clear pending operations: $e');
    }
  }

  /// Dispose sync service
  Future<void> dispose() async {
    try {
      _batchSyncTimer?.cancel();
      await _connectivitySubscription?.cancel();
      await _syncResultsController.close();

      _isInitialized = false;
      debugPrint('Sync service disposed');
    } catch (e) {
      debugPrint('Error disposing sync service: $e');
    }
  }
}

// Helper function to avoid "unawaited" warnings
void unawaited(Future<void> future) {
  // Intentionally empty
}