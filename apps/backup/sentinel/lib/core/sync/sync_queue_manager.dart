import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../storage/database.dart';
import '../storage/tables.dart';

/// Sync Queue Manager
/// Manages offline operations queue with exponential backoff retry logic
class SyncQueueManager {
  SyncQueueManager._();
  static final SyncQueueManager _instance = SyncQueueManager._();
  static SyncQueueManager get instance => _instance;

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // Retry configuration
  static const int _maxRetryCount = 5;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _maxDelay = Duration(minutes: 5);
  static const double _backoffMultiplier = 2.0;
  static const double _jitterFactor = 0.1;

  /// Add item to sync queue
  Future<String> addToQueue({
    required String operation,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    int priority = 0,
  }) async {
    try {
      final queueId = _uuid.v4();

      final queueItem = SyncQueueCompanion.insert(
        operation: operation,
        entityType: entityType,
        entityId: entityId,
        payload: jsonEncode(payload),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: const Value('pending'),
        retryCount: const Value(0),
        createdAt: Value(DateTime.now()),
      );

      final database = DatabaseProvider.instance;
      await database.into(database.syncQueue).insert(queueItem);

      _logger.d('Added to sync queue: $operation $entityType/$entityId (ID: $queueId)');

      // Trigger immediate sync if available
      await _triggerSyncIfPossible();

      return queueId;
    } catch (e) {
      _logger.e('Failed to add item to sync queue: $e');
      throw SyncQueueException('Failed to add item to sync queue: $e');
    }
  }

  /// Get pending items from queue
  Future<List<SyncQueueEntry>> getPendingItems({
    int limit = 50,
    String? entityType,
  }) async {
    try {
      final database = DatabaseProvider.instance;
      var query = database.select(database.syncQueue)
        ..where((SyncQueue tbl) => tbl.status.equals('pending'))
        ..orderBy([(SyncQueue tbl) => OrderingTerm.asc(tbl.timestamp)]);

      if (entityType != null) {
        query = query..where((SyncQueue tbl) => tbl.entityType.equals(entityType));
      }

      query = query..limit(limit);

      return await query.get();
    } catch (e) {
      _logger.e('Failed to get pending items: $e');
      return [];
    }
  }

  /// Get items ready for retry
  Future<List<SyncQueueEntry>> getRetryItems() async {
    try {
      final database = DatabaseProvider.instance;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Get all failed items and filter in application logic
      final failedItems = await (database.select(database.syncQueue)
            ..where((SyncQueue tbl) => tbl.status.equals('failed'))
            ..orderBy([(SyncQueue tbl) => OrderingTerm.asc(tbl.retryCount), (SyncQueue tbl) => OrderingTerm.asc(tbl.timestamp)])
          ).get();

      // Filter items that are ready for retry
      return failedItems.where((item) {
        if (item.retryCount >= _maxRetryCount) return false;

        final retryDelay = _calculateRetryDelay(item.retryCount);
        final retryTime = item.updatedAt!.add(retryDelay);
        return retryTime.isBefore(DateTime.now());
      }).toList();
    } catch (e) {
      _logger.e('Failed to get retry items: $e');
      return [];
    }
  }

  /// Mark item as processing
  Future<void> markAsProcessing(int queueId) async {
    try {
      final database = DatabaseProvider.instance;
      await (database.update(database.syncQueue)..where((tbl) => tbl.id.equals(queueId)))
          .write(SyncQueueCompanion(
        status: const Value('processing'),
        updatedAt: Value(DateTime.now()),
      ));
      _logger.d('Marked item $queueId as processing');
    } catch (e) {
      _logger.e('Failed to mark item as processing: $queueId - $e');
    }
  }

  /// Mark item as completed
  Future<void> markAsCompleted(int queueId, {Map<String, dynamic>? result}) async {
    try {
      final database = DatabaseProvider.instance;
      final updateData = SyncQueueCompanion(
        status: const Value('completed'),
        updatedAt: Value(DateTime.now()),
      );

      if (result != null) {
        // Note: We could store result in a separate table or as JSON in payload
        // For now, we'll just update the status
      }

      await (database.update(database.syncQueue)..where((tbl) => tbl.id.equals(queueId)))
          .write(updateData);

      _logger.d('Marked item $queueId as completed');
    } catch (e) {
      _logger.e('Failed to mark item as completed: $queueId - $e');
    }
  }

  /// Mark item as failed with retry count increment
  Future<void> markAsFailed(int queueId, String error, {int? retryCount}) async {
    try {
      final database = DatabaseProvider.instance;
      final currentRetryCount = retryCount ?? 0;
      final newRetryCount = currentRetryCount + 1;

      await (database.update(database.syncQueue)..where((tbl) => tbl.id.equals(queueId)))
          .write(SyncQueueCompanion(
        status: Value(newRetryCount >= _maxRetryCount
            ? 'dead_letter'
            : 'failed'),
        retryCount: Value(newRetryCount),
        errorMessage: Value(error),
        updatedAt: Value(DateTime.now()),
      ));

      _logger.w('Marked item $queueId as failed (attempt $newRetryCount/$_maxRetryCount): $error');

      // If max retries reached, this item goes to dead letter queue
      if (newRetryCount >= _maxRetryCount) {
        _logger.e('Item $queueId reached max retries, moving to dead letter queue');
      }
    } catch (e) {
      _logger.e('Failed to mark item as failed: $queueId - $e');
    }
  }

  /// Get queue statistics
  Future<Map<String, int>> getQueueStats() async {
    try {
      final database = DatabaseProvider.instance;

      final pendingCount = await (database.select(database.syncQueue)
          ..where((tbl) => tbl.status.equals('pending'))
          .count()
        ).getSingle();

      final processingCount = await (database.select(database.syncQueue)
          ..where((tbl) => tbl.status.equals('processing'))
          .count()
        ).getSingle();

      final failedCount = await (database.select(database.syncQueue)
          ..where((tbl) => tbl.status.equals('failed'))
          .count()
        ).getSingle();

      final completedCount = await (database.select(database.syncQueue)
          ..where((tbl) => tbl.status.equals('completed'))
          .count()
        ).getSingle();

      final deadLetterCount = await (database.select(database.syncQueue)
          ..where((tbl) => tbl.status.equals('dead_letter'))
          .count()
        ).getSingle();

      return {
        'pending': pendingCount,
        'processing': processingCount,
        'failed': failedCount,
        'completed': completedCount,
        'dead_letter': deadLetterCount,
        'total': pendingCount + processingCount + failedCount + completedCount + deadLetterCount,
      };
    } catch (e) {
      _logger.e('Failed to get queue stats: $e');
      return {'error': 1};
    }
  }

  /// Clean up old completed items
  Future<int> cleanupCompletedItems({int daysOld = 7}) async {
    try {
      final database = DatabaseProvider.instance;
      final cutoffTime = DateTime.now().subtract(Duration(days: daysOld)).millisecondsSinceEpoch;

      final result = await (database.delete(database.syncQueue)
          ..where((tbl) =>
              tbl.status.equals('completed') &
              (tbl.updatedAt!.isSmallerThanValue(cutoffTime)))
        ).go();

      final deletedCount = result;
      if (deletedCount > 0) {
        _logger.i('Cleaned up $deletedCount completed sync items (older than $daysOld days)');
      }

      return deletedCount;
    } catch (e) {
      _logger.e('Failed to cleanup completed items: $e');
      return 0;
    }
  }

  /// Remove item from queue
  Future<void> removeFromQueue(int queueId) async {
    try {
      final database = DatabaseProvider.instance;
      await (database.delete(database.syncQueue)..where((tbl) => tbl.id.equals(queueId))).go();
      _logger.d('Removed item from queue: $queueId');
    } catch (e) {
      _logger.e('Failed to remove item from queue: $queueId - $e');
    }
  }

  /// Clear entire queue (for reset/debugging)
  Future<int> clearQueue() async {
    try {
      final database = DatabaseProvider.instance;
      final result = await database.delete(database.syncQueue).go();
      _logger.w('Cleared entire sync queue ($result items)');
      return result;
    } catch (e) {
      _logger.e('Failed to clear sync queue: $e');
      return 0;
    }
  }

  /// Get items by entity type
  Future<List<SyncQueueEntry>> getItemsByEntityType(String entityType, {String? status}) async {
    try {
      final database = DatabaseProvider.instance;
      var query = database.select(database.syncQueue)
        ..where((tbl) => tbl.entityType.equals(entityType));

      if (status != null) {
        query = query..where((tbl) => tbl.status.equals(status));
      }

      query = query..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]);

      return await query.get();
    } catch (e) {
      _logger.e('Failed to get items by entity type: $entityType - $e');
      return [];
    }
  }

  /// Update item payload
  Future<void> updateItemPayload(int queueId, Map<String, dynamic> newPayload) async {
    try {
      final database = DatabaseProvider.instance;
      await (database.update(database.syncQueue)..where((tbl) => tbl.id.equals(queueId)))
          .write(SyncQueueCompanion(
        payload: Value(jsonEncode(newPayload)),
        updatedAt: Value(DateTime.now()),
      ));

      _logger.d('Updated payload for item $queueId');
    } catch (e) {
      _logger.e('Failed to update item payload: $queueId - $e');
    }
  }

  /// Get next item to process
  Future<SyncQueueEntry?> getNextItem() async {
    try {
      // Get highest priority pending item
      final pendingItems = await getPendingItems(limit: 1);
      if (pendingItems.isNotEmpty) {
        return pendingItems.first;
      }

      // Get items ready for retry
      final retryItems = await getRetryItems();
      if (retryItems.isNotEmpty) {
        return retryItems.first;
      }

      return null;
    } catch (e) {
      _logger.e('Failed to get next item: $e');
      return null;
    }
  }

  /// Calculate retry delay with exponential backoff and jitter
  Duration _calculateRetryDelay(int retryCount) {
    final baseDelayMs = _baseDelay.inMilliseconds;
    final delay = (baseDelayMs * pow(_backoffMultiplier, retryCount)).toInt();

    // Apply jitter to prevent thundering herd
    final jitter = (delay * _jitterFactor).toInt();
    final finalDelayMs = delay + jitter;

    // Cap at maximum delay
    final maxDelayMs = _maxDelay.inMilliseconds;
    return Duration(milliseconds: finalDelayMs > maxDelayMs ? maxDelayMs : finalDelayMs);
  }

  /// Double value for power calculation
  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Trigger sync if network is available and conditions are met
  Future<void> _triggerSyncIfPossible() async {
    try {
      // This would check network connectivity and trigger sync if appropriate
      // For now, we'll just log that items are ready
      final pendingCount = await getQueueStats();
      _logger.d('Trigger sync check: ${pendingCount['pending']} pending items ready');

      // Could integrate with network monitoring service here
    } catch (e) {
      _logger.e('Failed to trigger sync: $e');
    }
  }

  /// Validate queue item
  bool _validateQueueItem(SyncQueueEntry item) {
    return item.operation.isNotEmpty &&
        item.entityType.isNotEmpty &&
        item.entityId.isNotEmpty &&
        item.payload.isNotEmpty &&
        ['CREATE', 'UPDATE', 'DELETE'].contains(item.operation);
  }

  /// Process queue items in batch
  Future<List<SyncQueueEntry>> processBatch({
    required List<SyncQueueEntry> items,
    int batchSize = 10,
  }) async {
    try {
      final validItems = <SyncQueueEntry>[];
      final invalidItems = <SyncQueueEntry>[];

      for (final item in items) {
        if (_validateQueueItem(item)) {
          validItems.add(item);
        } else {
          invalidItems.add(item);
          _logger.w('Invalid queue item: ${item.id} - ${item.operation} ${item.entityType}/${item.entityId}');
        }
      }

      // Mark invalid items as failed
      for (final item in invalidItems) {
        await markAsFailed(item.id, 'Invalid queue item format');
      }

      // Mark valid items as processing
      for (final item in validItems) {
        await markAsProcessing(item.id);
      }

      _logger.d('Processing batch: ${validItems.length} valid items, ${invalidItems.length} invalid items');
      return validItems;
    } catch (e) {
      _logger.e('Failed to process batch: $e');
      return [];
    }
  }

  /// Dispose sync queue manager
  Future<void> dispose() async {
    try {
      _logger.i('Disposing sync queue manager...');
      // No resources to dispose
      _logger.i('Sync queue manager disposed');
    } catch (e) {
      _logger.e('Error disposing sync queue manager: $e');
    }
  }
}

/// Sync queue exception
class SyncQueueException implements Exception {
  const SyncQueueException(this.message);

  final String message;

  @override
  String toString() => 'SyncQueueException: $message';
}