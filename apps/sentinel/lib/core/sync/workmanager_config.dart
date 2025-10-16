import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';
import 'sync_service.dart';

/// WorkManager configuration for Sentinel App
/// Handles background sync operations with proper scheduling and constraints
class WorkManagerConfig {
  WorkManagerConfig._();
  static final WorkManagerConfig _instance = WorkManagerConfig._();
  static WorkManagerConfig get instance => _instance;

  final Logger _logger = Logger();

  // WorkManager task names
  static const String _periodicSyncTask = 'periodic_sync';
  static const String _immediateSyncTask = 'immediate_sync';
  static const String _cleanupTask = 'data_cleanup';

  // Sync intervals (in minutes)
  static const int _periodicSyncInterval = 15;
  static const int _immediateSyncDelay = 1;
  static const int _cleanupInterval = 60; // 1 hour

  /// Initialize WorkManager
  Future<bool> initialize() async {
    try {
      _logger.i('Initializing WorkManager...');

      // Initialize WorkManager callback dispatcher
      await Workmanager().initialize(
        callbackDispatcher: _workmanagerCallbackDispatcher,
      );

      // Register periodic sync task
      await _registerPeriodicSyncTask();

      // Register cleanup task
      await _registerCleanupTask();

      _logger.i('WorkManager initialized successfully');
      return true;

    } catch (e) {
      _logger.e('Failed to initialize WorkManager: $e');
      return false;
    }
  }

  /// Register periodic sync task
  Future<void> _registerPeriodicSyncTask() async {
    try {
      _logger.i('Registering periodic sync task...');

      await Workmanager().registerPeriodicTask(
        _periodicSyncTask,
        _periodicSyncTask,
        frequency: Duration(minutes: _periodicSyncInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: false, // Allow on battery
          requiresDeviceIdle: false, // Allow when device is in use
          triggerOnContentUpdate: false,
        ),
        backoffPolicy: BackoffPolicy.exponentialBackoff,
        backoffDelay: Duration(seconds: 10),
        initialDelay: Duration(minutes: 5),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: 'sentinel_sync',
        keepWhileEnlisted: true,
      );

      _logger.i('Periodic sync task registered (every $_periodicSyncInterval minutes)');
    } catch (e) {
      _logger.e('Failed to register periodic sync task: $e');
      rethrow;
    }
  }

  /// Register cleanup task
  Future<void> _registerCleanupTask() async {
    try {
      _logger.i('Registering cleanup task...');

      await Workmanager().registerPeriodicTask(
        _cleanupTask,
        _cleanupTask,
        frequency: Duration(minutes: _cleanupInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: true, // Only when device is idle
        ),
        backoffPolicy: BackoffPolicy.exponentialBackoff,
        backoffDelay: Duration(seconds: 5),
        initialDelay: Duration(hours: 2), // Start after 2 hours
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: 'sentinel_cleanup',
        keepWhileEnlisted: true,
      );

      _logger.i('Cleanup task registered (every $_cleanupInterval minutes)');
    } catch (e) {
      _logger.e('Failed to register cleanup task: $e');
      rethrow;
    }
  }

  /// Schedule immediate sync task
  Future<void> scheduleImmediateSync() async {
    try {
      _logger.i('Scheduling immediate sync task...');

      await Workmanager().registerOneOffTask(
        _immediateSyncTask,
        _immediateSyncTask,
        initialDelay: Duration(minutes: _immediateSyncDelay),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.exponentialBackoff,
        backoffDelay: Duration(seconds: 5),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: 'sentinel_immediate_sync',
      );

      _logger.i('Immediate sync task scheduled');
    } catch (e) {
      _logger.e('Failed to schedule immediate sync task: $e');
    }
  }

  /// Cancel all tasks
  Future<void> cancelAllTasks() async {
    try {
      _logger.i('Cancelling all WorkManager tasks...');

      await Workmanager().cancelAll();

      _logger.i('All WorkManager tasks cancelled');
    } catch (e) {
      _logger.e('Failed to cancel WorkManager tasks: $e');
    }
  }

  /// Cancel specific task
  Future<void> cancelTask(String taskName) async {
    try {
      _logger.i('Cancelling WorkManager task: $taskName');

      await Workmanager().cancelByTag(taskName);

      _logger.i('WorkManager task cancelled: $taskName');
    } catch (e) {
      _logger.e('Failed to cancel WorkManager task: $taskName - $e');
    }
  }

  /// Get task status
  Future<List<WorkInfo>> getTaskStatus() async {
    try {
      return await Workmanager().getWorkInfosForTag('sentinel');
    } catch (e) {
      _logger.e('Failed to get task status: $e');
      return [];
    }
  }

  /// Check if WorkManager is initialized
  bool get isInitialized => _isInitialized;

  bool _isInitialized = false;

  /// WorkManager callback dispatcher
  @pragma('vm:entry-point')
  static Future<void> _workmanagerCallbackDispatcher() async {
    try {
      final logger = Logger();
      logger.i('WorkManager callback invoked');

      // Initialize sync service
      await SyncService.initialize();

      // Get the task name
      final taskName = Workmanager().getCurrentWorkmanagerTaskName();
      logger.i('Processing WorkManager task: $taskName');

      switch (taskName) {
        case _periodicSyncTask:
          await _handlePeriodicSync();
          break;
        case _immediateSyncTask:
          await _handleImmediateSync();
          break;
        case _cleanupTask:
          await _handleCleanup();
          break;
        default:
          logger.w('Unknown WorkManager task: $taskName');
      }

      logger.i('WorkManager task completed: $taskName');
    } catch (e, stackTrace) {
      final logger = Logger();
      logger.e('WorkManager callback error: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// Handle periodic sync task
  static Future<void> _handlePeriodicSync() async {
    try {
      final logger = Logger();
      logger.d('Executing periodic sync...');

      final syncService = SyncService.instance;
      await syncService.performPeriodicSync();

      logger.d('Periodic sync completed');
    } catch (e) {
      final logger = Logger();
      logger.e('Error in periodic sync: $e');
    }
  }

  /// Handle immediate sync task
  static Future<void> _handleImmediateSync() async {
    try {
      final logger = Logger();
      logger.d('Executing immediate sync...');

      final syncService = SyncService.instance;
      await syncService.performImmediateSync();

      logger.d('Immediate sync completed');
    } catch (e) {
      final logger = Logger();
      logger.e('Error in immediate sync: $e');
    }
  }

  /// Handle cleanup task
  static Future<void> _handleCleanup() async {
    try {
      final logger = Logger();
      logger.d('Executing data cleanup...');

      final syncService = SyncService.instance;
      await syncService.performCleanup();

      logger.d('Data cleanup completed');
    } catch (e) {
      final logger = Logger();
      logger.e('Error in data cleanup: $e');
    }
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final workInfos = await getTaskStatus();
      final syncService = SyncService.instance;

      return {
        'tasks': workInfos.map((info) => {
          'name': info.name,
          'state': info.state.toString(),
          'isRunning': info.state == WorkInfoState.running,
          'timestamp': info.timestamp?.toIso8601String(),
        }).toList(),
        'pendingItems': await syncService.getPendingItemCount(),
        'lastSync': await syncService.getLastSyncTime(),
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return {
        'error': e.toString(),
        'isInitialized': _isInitialized,
      };
    }
  }

  /// Update task configuration (for testing)
  Future<void> updateConfiguration({
    int? periodicInterval,
    int? immediateDelay,
    bool? requiresCharging,
    bool? requiresBatteryNotLow,
    bool? requiresDeviceIdle,
  }) async {
    try {
      _logger.i('Updating WorkManager configuration...');

      // Cancel existing tasks
      await cancelAllTasks();

      // Update configuration and re-register tasks
      if (periodicInterval != null) {
        // Note: This would require making the intervals configurable
        // For now, we'll use the static values
      }

      await _registerPeriodicSyncTask();
      await _registerCleanupTask();

      _logger.i('WorkManager configuration updated');
    } catch (e) {
      _logger.e('Failed to update WorkManager configuration: $e');
    }
  }

  /// Schedule one-time task with custom delay
  Future<void> scheduleOneTimeTask({
    required String taskName,
    required Duration delay,
    required String tag,
    required Map<String, dynamic> inputData,
  }) async {
    try {
      _logger.i('Scheduling one-time task: $taskName');

      await Workmanager().registerOneOffTask(
        taskName,
        taskName,
        initialDelay: delay,
        inputData: inputData,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        tag: tag,
      );

      _logger.i('One-time task scheduled: $taskName');
    } catch (e) {
      _logger.e('Failed to schedule one-time task: $taskName - $e');
    }
  }

  /// Force trigger sync (for testing/debugging)
  Future<bool> forceTriggerSync() async {
    try {
      _logger.i('Force triggering sync...');

      // Cancel existing immediate sync task
      await cancelTask(_immediateSyncTask);

      // Schedule new immediate sync
      await scheduleImmediateSync();

      _logger.i('Force sync triggered successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to force trigger sync: $e');
      return false;
    }
  }

  /// Dispose WorkManager
  Future<void> dispose() async {
    try {
      _logger.i('Disposing WorkManager...');
      await cancelAllTasks();
      _isInitialized = false;
      _logger.i('WorkManager disposed');
    } catch (e) {
      _logger.e('Error disposing WorkManager: $e');
    }
  }
}

/// WorkManager configuration exception
class WorkManagerException implements Exception {
  const WorkManagerException(this.message);

  final String message;

  @override
  String toString() => 'WorkManagerException: $message';
}