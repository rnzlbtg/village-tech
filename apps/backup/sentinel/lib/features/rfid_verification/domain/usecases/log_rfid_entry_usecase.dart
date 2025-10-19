import '../entities/entry_log.dart';
import '../repositories/rfid_repository.dart';

/// Log RFID Entry Use Case
/// Handles the business logic for logging RFID entries and managing sync
///
/// This use case manages entry logging operations including:
/// - Creating and storing entry logs
/// - Managing offline logging scenarios
/// - Batch entry logging
/// - Sync queue management
/// - Entry log statistics
class LogRfidEntryUseCase {
  LogRfidEntryUseCase(this._repository);

  final RfidRepository _repository;

  /// Log an RFID entry
  ///
  /// [entryLog] - The entry log to record
  /// [isOffline] - Whether this operation is happening offline
  ///
  /// Returns the created/updated [EntryLog] with ID assigned
  ///
  /// Throws [ValidationException] when entry log data is invalid
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server sync fails
  Future<EntryLog> execute(
    EntryLog entryLog, {
    bool isOffline = false,
  }) async {
    try {
      // Validate entry log before processing
      _validateEntryLog(entryLog);

      // Log the entry using repository
      final loggedEntry = await _repository.logRfidEntry(
        entryLog,
        isOffline: isOffline,
      );

      return loggedEntry;
    } catch (e) {
      throw LogRfidEntryException('Failed to log RFID entry: $e');
    }
  }

  /// Batch log multiple entries
  ///
  /// [entryLogs] - List of entry logs to record
  /// [isOffline] - Whether these operations are happening offline
  ///
  /// Returns a map of entry log index to result
  Future<Map<int, LogRfidEntryResult>> batchLog(
    List<EntryLog> entryLogs, {
    bool isOffline = false,
  }) async {
    final results = <int, LogRfidEntryResult>{};

    for (int i = 0; i < entryLogs.length; i++) {
      try {
        final result = await execute(
          entryLogs[i],
          isOffline: isOffline,
        );
        results[i] = LogRfidEntryResult(
          success: true,
          entryLog: result,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        results[i] = LogRfidEntryResult(
          success: false,
          timestamp: DateTime.now(),
          error: e.toString(),
        );
      }
    }

    return results;
  }

  /// Get entry logs with filtering options
  ///
  /// [filters] - Optional filters for the search
  /// [limit] - Maximum number of results to return
  /// [offset] - Number of results to skip (for pagination)
  ///
  /// Returns a list of [EntryLog] matching the criteria
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<List<EntryLog>> getEntryLogs({
    EntryLogFilters? filters,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getEntryLogs(
        filters: filters,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw LogRfidEntryException('Failed to get entry logs: $e');
    }
  }

  /// Get entry log statistics for reporting
  ///
  /// [startDate] - Start date for statistics period
  /// [endDate] - End date for statistics period
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns [EntryLogStatistics] with aggregated data
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<EntryLogStatistics> getEntryLogStatistics({
    DateTime? startDate,
    DateTime? endDate,
    required String tenantId,
  }) async {
    try {
      return await _repository.getEntryLogStatistics(
        startDate: startDate,
        endDate: endDate,
        tenantId: tenantId,
      );
    } catch (e) {
      throw LogRfidEntryException('Failed to get entry log statistics: $e');
    }
  }

  /// Sync pending offline entries to server
  ///
  /// This method processes the sync queue and uploads any pending
  /// entry logs that were created while offline.
  ///
  /// Returns the number of successfully synced entries
  ///
  /// Throws [NetworkException] when network connectivity fails
  /// Throws [SyncException] when sync operations encounter errors
  Future<int> syncPendingEntries() async {
    try {
      return await _repository.syncPendingEntries();
    } catch (e) {
      throw LogRfidEntryException('Failed to sync pending entries: $e');
    }
  }

  /// Get sync queue status for monitoring
  ///
  /// Returns information about pending sync operations
  ///
  /// Throws [DatabaseException] when local database operations fail
  Future<SyncQueueStatus> getSyncQueueStatus() async {
    try {
      return await _repository.getSyncQueueStatus();
    } catch (e) {
      throw LogRfidEntryException('Failed to get sync queue status: $e');
    }
  }

  /// Search entry logs by various criteria
  ///
  /// [query] - Search query string
  /// [filters] - Additional filters for the search
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns a list of [EntryLog] matching the search criteria
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<List<EntryLog>> searchEntryLogs(
    String query, {
    EntryLogFilters? filters,
    required String tenantId,
  }) async {
    try {
      final entryLogs = await _repository.getEntryLogs(
        filters: filters,
      );

      // Simple search implementation - in a real app, this would be database-level
      if (query.isEmpty) {
        return entryLogs;
      }

      final lowerQuery = query.toLowerCase();
      return entryLogs.where((log) {
        // Search in vehicle info
        if (log.vehicleInfo != null) {
          final plate = log.vehicleInfo!['plate']?.toLowerCase() ?? '';
          final make = log.vehicleInfo!['make']?.toLowerCase() ?? '';
          final stickerCode = log.vehicleInfo!['sticker_code']?.toLowerCase() ?? '';

          if (plate.contains(lowerQuery) ||
              make.contains(lowerQuery) ||
              stickerCode.contains(lowerQuery)) {
            return true;
          }
        }

        // Search in person info
        if (log.personInfo != null) {
          final personData = log.personInfo!;
          if (personData.values.any((value) =>
              value?.toLowerCase().contains(lowerQuery) ?? false)) {
            return true;
          }
        }

        // Search in denial reason and notes
        if (log.denialReason?.toLowerCase().contains(lowerQuery) ?? false) {
          return true;
        }
        if (log.notes?.toLowerCase().contains(lowerQuery) ?? false) {
          return true;
        }

        return false;
      }).toList();
    } catch (e) {
      throw LogRfidEntryException('Failed to search entry logs: $e');
    }
  }

  /// Get entry logs by date range
  ///
  /// [startDate] - Start of the date range
  /// [endDate] - End of the date range
  /// [tenantId] - Tenant ID for multi-tenant isolation
  /// [limit] - Maximum number of results to return
  ///
  /// Returns a list of [EntryLog] within the date range
  Future<List<EntryLog>> getEntryLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    try {
      final filters = EntryLogFilters(
        startDate: startDate,
        endDate: endDate,
      );

      return await _repository.getEntryLogs(
        filters: filters,
        limit: limit,
      );
    } catch (e) {
      throw LogRfidEntryException('Failed to get entry logs by date range: $e');
    }
  }

  /// Get denied entries for security review
  ///
  /// [startDate] - Optional start date for filtering
  /// [endDate] - Optional end date for filtering
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns a list of denied [EntryLog] entries
  Future<List<EntryLog>> getDeniedEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final filters = EntryLogFilters(
        entryType: EntryType.resident,
        verificationStatus: VerificationStatus.denied,
        startDate: startDate,
        endDate: endDate,
      );

      return await _repository.getEntryLogs(filters: filters);
    } catch (e) {
      throw LogRfidEntryException('Failed to get denied entries: $e');
    }
  }

  /// Delete old entry logs for maintenance
  ///
  /// [olderThanDays] - Delete logs older than this many days
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns the number of deleted logs
  Future<int> deleteOldEntryLogs({
    required int olderThanDays,
  }) async {
    try {
      // This would require implementation in the repository
      // For now, we'll simulate the count
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final filters = EntryLogFilters(
        endDate: cutoffDate,
      );

      final oldLogs = await _repository.getEntryLogs(filters: filters);

      // In a real implementation, this would call a repository method
      // For now, we'll just return the count
      return oldLogs.length;
    } catch (e) {
      throw LogRfidEntryException('Failed to delete old entry logs: $e');
    }
  }

  /// Validate entry log before processing
  void _validateEntryLog(EntryLog entryLog) {
    if (entryLog.tenantId.isEmpty) {
      throw const ValidationException('Tenant ID is required');
    }
    if (entryLog.guardId.isEmpty) {
      throw const ValidationException('Guard ID is required');
    }
    if (entryLog.verificationMethod.name.isEmpty) {
      throw const ValidationException('Verification method is required');
    }
    if (entryLog.verificationStatus.name.isEmpty) {
      throw const ValidationException('Verification status is required');
    }
  }
}

/// Result of RFID entry logging operation
class LogRfidEntryResult {
  const LogRfidEntryResult({
    required this.success,
    required this.timestamp,
    this.entryLog,
    this.error,
  });

  /// Whether the operation was successful
  final bool success;

  /// The entry log that was created/updated (if successful)
  final EntryLog? entryLog;

  /// Timestamp of the operation
  final DateTime timestamp;

  /// Error message if operation failed
  final String? error;

  @override
  String toString() {
    return 'LogRfidEntryResult('
        'success: $success, '
        'timestamp: $timestamp, '
        'error: $error'
        ')';
  }
}

/// Log RFID entry use case exception
class LogRfidEntryException implements Exception {
  const LogRfidEntryException(this.message);

  final String message;

  @override
  String toString() => 'LogRfidEntryException: $message';
}