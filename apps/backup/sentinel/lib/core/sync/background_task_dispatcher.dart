import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import '../auth/auth_provider.dart';
import '../network/network_monitor.dart';
import 'sync_service.dart';
import 'workmanager_config.dart';

/// Background Task Dispatcher
/// Handles and coordinates various background tasks with proper error handling and logging
class BackgroundTaskDispatcher {
  BackgroundTaskDispatcher._();
  static final BackgroundTaskDispatcher _instance = BackgroundTaskDispatcher._();
  static BackgroundTaskDispatcher get instance => _instance;

  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Initialize the background task dispatcher
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _logger.i('Initializing Background Task Dispatcher...');

      // Initialize WorkManager
      final workManagerConfig = WorkManagerConfig.instance;
      await workManagerConfig.initialize();

      // Register background tasks
      await _registerBackgroundTasks();

      _isInitialized = true;
      _logger.i('Background Task Dispatcher initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Background Task Dispatcher: $e');
      rethrow;
    }
  }

  /// Register all background tasks
  Future<void> _registerBackgroundTasks() async {
    try {
      _logger.d('Registering background tasks...');

      // Tasks are already registered in WorkManagerConfig
      // This method can be used to register additional tasks if needed

      _logger.d('Background tasks registered');
    } catch (e) {
      _logger.e('Failed to register background tasks: $e');
      rethrow;
    }
  }

  /// Handle background task execution
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundTask() async {
    try {
      final logger = Logger();
      logger.i('Background task dispatcher invoked');

      // Initialize services
      await _initializeBackgroundServices();

      // Get the task name
      final taskName = Workmanager().getCurrentWorkmanagerTaskName();
      logger.i('Processing background task: $taskName');

      switch (taskName) {
        case WorkManagerConfig._periodicSyncTask:
          await _handlePeriodicSyncTask();
          break;
        case WorkManagerConfig._immediateSyncTask:
          await _handleImmediateSyncTask();
          break;
        case WorkManagerConfig._cleanupTask:
          await _handleCleanupTask();
          break;
        default:
          logger.w('Unknown background task: $taskName');
      }

      logger.i('Background task completed: $taskName');
    } catch (e, stackTrace) {
      final logger = Logger();
      logger.e('Background task error: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// Initialize services needed for background tasks
  static Future<void> _initializeBackgroundServices() async {
    try {
      final logger = Logger();
      logger.d('Initializing background services...');

      // Initialize network monitoring
      await NetworkMonitor.instance.startMonitoring();

      // Initialize sync service
      await SyncService.initialize();

      // Initialize auth provider (check existing session)
      await AuthProvider.instance.initialize();

      logger.d('Background services initialized');
    } catch (e) {
      final logger = Logger();
      logger.e('Failed to initialize background services: $e');
      rethrow;
    }
  }

  /// Handle periodic sync task
  static Future<void> _handlePeriodicSyncTask() async {
    try {
      final logger = Logger();
      logger.d('Executing periodic sync task...');

      // Check prerequisites
      if (!await _checkSyncPrerequisites()) {
        logger.d('Sync prerequisites not met, skipping periodic sync');
        return;
      }

      // Perform sync
      final syncService = SyncService.instance;
      await syncService.performPeriodicSync();

      // Log results
      final syncStatus = await syncService.getSyncStatus();
      logger.d('Periodic sync completed. Status: $syncStatus');

    } catch (e) {
      final logger = Logger();
      logger.e('Error in periodic sync task: $e');
    }
  }

  /// Handle immediate sync task
  static Future<void> _handleImmediateSyncTask() async {
    try {
      final logger = Logger();
      logger.d('Executing immediate sync task...');

      // Check prerequisites
      if (!await _checkSyncPrerequisites()) {
        logger.d('Sync prerequisites not met, skipping immediate sync');
        return;
      }

      // Perform sync
      final syncService = SyncService.instance;
      await syncService.performImmediateSync();

      // Log results
      final syncStatus = await syncService.getSyncStatus();
      logger.d('Immediate sync completed. Status: $syncStatus');

    } catch (e) {
      final logger = Logger();
      logger.e('Error in immediate sync task: $e');
    }
  }

  /// Handle cleanup task
  static Future<void> _handleCleanupTask() async {
    try {
      final logger = Logger();
      logger.d('Executing cleanup task...');

      // Perform cleanup
      final syncService = SyncService.instance;
      await syncService.performCleanup();

      // Additional cleanup tasks
      await _performAdditionalCleanup();

      logger.d('Cleanup task completed');
    } catch (e) {
      final logger = Logger();
      logger.e('Error in cleanup task: $e');
    }
  }

  /// Check if sync prerequisites are met
  static Future<bool> _checkSyncPrerequisites() async {
    try {
      final logger = Logger();

      // Check network connectivity
      if (!NetworkMonitor.instance.isConnected) {
        logger.d('No network connectivity');
        return false;
      }

      // Check authentication
      final authProvider = AuthProvider.instance;
      if (!authProvider.isAuthenticated) {
        logger.d('User not authenticated');
        return false;
      }

      // Check for valid session
      if (!await authProvider.isSessionValid()) {
        logger.d('Session not valid');
        return false;
      }

      return true;
    } catch (e) {
      final logger = Logger();
      logger.e('Error checking sync prerequisites: $e');
      return false;
    }
  }

  /// Perform additional cleanup tasks
  static Future<void> _performAdditionalCleanup() async {
    try {
      final logger = Logger();

      // Clean up old logs
      await _cleanupOldLogs();

      // Clean up temporary files
      await _cleanupTempFiles();

      // Clean up expired cache
      await _cleanupExpiredCache();

      logger.d('Additional cleanup completed');
    } catch (e) {
      final logger = Logger();
      logger.e('Error in additional cleanup: $e');
    }
  }

  /// Clean up old logs
  static Future<void> _cleanupOldLogs() async {
    try {
      final logger = Logger();

      // This would implement log cleanup logic
      // For now, we'll just log the action
      logger.d('Cleaning up old logs...');

      // TODO: Implement actual log cleanup based on retention policies

    } catch (e) {
      final logger = Logger();
      logger.e('Error cleaning up old logs: $e');
    }
  }

  /// Clean up temporary files
  static Future<void> _cleanupTempFiles() async {
    try {
      final logger = Logger();

      // This would implement temporary file cleanup
      // For now, we'll just log the action
      logger.d('Cleaning up temporary files...');

      // TODO: Implement actual temp file cleanup

    } catch (e) {
      final logger = Logger();
      logger.e('Error cleaning up temporary files: $e');
    }
  }

  /// Clean up expired cache
  static Future<void> _cleanupExpiredCache() async {
    try {
      final logger = Logger();

      // This would implement cache cleanup
      // For now, we'll just log the action
      logger.d('Cleaning up expired cache...');

      // TODO: Implement actual cache cleanup

    } catch (e) {
      final logger = Logger();
      logger.e('Error cleaning up expired cache: $e');
    }
  }

  /// Schedule a custom background task
  Future<void> scheduleCustomTask({
    required String taskName,
    required Duration delay,
    Map<String, dynamic>? inputData,
    String? tag,
  }) async {
    try {
      _logger.i('Scheduling custom background task: $taskName');

      final workManagerConfig = WorkManagerConfig.instance;
      await workManagerConfig.scheduleOneTimeTask(
        taskName: taskName,
        delay: delay,
        inputData: inputData ?? {},
        tag: tag ?? 'custom_task',
      );

      _logger.i('Custom background task scheduled: $taskName');
    } catch (e) {
      _logger.e('Failed to schedule custom task: $taskName - $e');
      rethrow;
    }
  }

  /// Cancel a background task
  Future<void> cancelTask(String taskName) async {
    try {
      _logger.i('Cancelling background task: $taskName');

      final workManagerConfig = WorkManagerConfig.instance;
      await workManagerConfig.cancelTask(taskName);

      _logger.i('Background task cancelled: $taskName');
    } catch (e) {
      _logger.e('Failed to cancel task: $taskName - $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAllTasks() async {
    try {
      _logger.i('Cancelling all background tasks...');

      final workManagerConfig = WorkManagerConfig.instance;
      await workManagerConfig.cancelAllTasks();

      _logger.i('All background tasks cancelled');
    } catch (e) {
      _logger.e('Failed to cancel all tasks: $e');
    }
  }

  /// Get status of all background tasks
  Future<Map<String, dynamic>> getTaskStatuses() async {
    try {
      final workManagerConfig = WorkManagerConfig.instance;
      return await workManagerConfig.getSyncStatus();
    } catch (e) {
      _logger.e('Failed to get task statuses: $e');
      return {
        'error': e.toString(),
        'isInitialized': _isInitialized,
      };
    }
  }

  /// Force trigger all background tasks
  Future<void> forceTriggerAllTasks() async {
    try {
      _logger.i('Force triggering all background tasks...');

      // Force sync
      final syncService = SyncService.instance;
      await syncService.forceSyncAll();

      // Force immediate sync task
      final workManagerConfig = WorkManagerConfig.instance;
      await workManagerConfig.forceTriggerSync();

      _logger.i('All background tasks force triggered');
    } catch (e) {
      _logger.e('Failed to force trigger tasks: $e');
      rethrow;
    }
  }

  /// Check if background task dispatcher is initialized
  bool get isInitialized => _isInitialized;

  /// Get initialization status
  Map<String, dynamic> getInitializationStatus() {
    return {
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose background task dispatcher
  Future<void> dispose() async {
    try {
      _logger.i('Disposing Background Task Dispatcher...');

      // Cancel all tasks
      await cancelAllTasks();

      // Stop network monitoring
      await NetworkMonitor.instance.stopMonitoring();

      _isInitialized = false;

      _logger.i('Background Task Dispatcher disposed');
    } catch (e) {
      _logger.e('Error disposing Background Task Dispatcher: $e');
    }
  }
}

/// Background task types
enum BackgroundTaskType {
  periodicSync,
  immediateSync,
  cleanup,
  custom,
}

/// Background task result
class BackgroundTaskResult {
  final BackgroundTaskType taskType;
  final bool success;
  final String? error;
  final Map<String, dynamic>? result;
  final DateTime timestamp;

  const BackgroundTaskResult({
    required this.taskType,
    required this.success,
    this.error,
    this.result,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BackgroundTaskResult(type: $taskType, success: $success, timestamp: $timestamp)';
  }
}

/// Background task exception
class BackgroundTaskException implements Exception {
  const BackgroundTaskException(this.message);

  final String message;

  @override
  String toString() => 'BackgroundTaskException: $message';
}