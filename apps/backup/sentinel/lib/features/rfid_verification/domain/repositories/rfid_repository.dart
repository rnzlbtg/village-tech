import '../entities/rfid_sticker.dart';
import '../entities/entry_log.dart';

/// Custom exceptions for RFID operations
class RfidException implements Exception {
  const RfidException(this.message);
  final String message;
  @override
  String toString() => 'RfidException: $message';
}

class NetworkException extends RfidException {
  const NetworkException(super.message);
}

class ValidationException extends RfidException {
  const ValidationException(super.message);
}

class ServerException extends RfidException {
  const ServerException(super.message);
}

class DatabaseException extends RfidException {
  const DatabaseException(super.message);
}

class SyncException extends RfidException {
  const SyncException(super.message);
}

class AuthorizationException extends RfidException {
  const AuthorizationException(super.message);
}

/// RFID Repository Interface
/// Defines the contract for RFID sticker validation and entry logging operations
///
/// This repository follows Clean Architecture principles and provides an abstraction
/// layer between the domain logic and data sources. It supports both online
/// (Supabase) and offline (local database) operations with automatic sync.
abstract class RfidRepository {
  /// Validate an RFID sticker by its code
  ///
  /// [stickerCode] - The RFID sticker code scanned from NFC tag
  /// [tenantId] - The tenant ID for multi-tenant isolation
  ///
  /// Returns [RfidStickerValidationResult] with validation outcome
  ///
  /// Throws [NetworkException] when network connectivity fails
  /// Throws [ValidationException] when validation encounters errors
  /// Throws [ServerException] when server API calls fail
  Future<RfidStickerValidationResult> validateRfidSticker(
    String stickerCode,
    String tenantId,
  );

  /// Log an RFID entry (resident vehicle entry)
  ///
  /// [entryLog] - The entry log to record
  /// [isOffline] - Whether this operation is happening offline
  ///
  /// Returns the created/updated [EntryLog] with ID assigned
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server sync fails
  /// Throws [ValidationException] when entry log data is invalid
  Future<EntryLog> logRfidEntry(
    EntryLog entryLog, {
    bool isOffline = false,
  });

  /// Get RFID stickers by status for caching purposes
  ///
  /// [filters] - Optional filters for the search
  /// [limit] - Maximum number of results to return
  ///
  /// Returns a list of [RfidSticker] matching the criteria
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<List<RfidSticker>> getRfidStickers({
    RfidStickerFilters? filters,
    int? limit,
  });

  /// Get entry logs with filtering options
  ///
  /// [filters] - Filters for the entry logs search
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
  });

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
  });

  /// Sync pending offline entries to server
  ///
  /// This method processes the sync queue and uploads any pending
  /// entry logs that were created while offline.
  ///
  /// Returns the number of successfully synced entries
  ///
  /// Throws [NetworkException] when network connectivity fails
  /// Throws [SyncException] when sync operations encounter errors
  Future<int> syncPendingEntries();

  /// Get sync queue status for monitoring
  ///
  /// Returns information about pending sync operations
  ///
  /// Throws [DatabaseException] when local database operations fail
  Future<SyncQueueStatus> getSyncQueueStatus();

  /// Clear cached RFID stickers (for cache invalidation)
  ///
  /// [tenantId] - Optional tenant ID to clear specific tenant cache
  ///
  /// Returns true if cache was cleared successfully
  ///
  /// Throws [DatabaseException] when local database operations fail
  Future<bool> clearRfidStickerCache({String? tenantId});

  /// Refresh RFID stickers cache from server
  ///
  /// [tenantId] - The tenant ID to refresh cache for
  /// [forceRefresh] - Whether to force refresh even if cache is recent
  ///
  /// Returns the number of stickers refreshed
  ///
  /// Throws [NetworkException] when server requests fail
  /// Throws [DatabaseException] when local database operations fail
  Future<int> refreshRfidStickerCache(
    String tenantId, {
    bool forceRefresh = false,
  });

  /// Search RFID stickers by various criteria
  ///
  /// [query] - Search query string
  /// [filters] - Additional filters for the search
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns a list of [RfidSticker] matching the search criteria
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<List<RfidSticker>> searchRfidStickers(
    String query, {
    RfidStickerFilters? filters,
    required String tenantId,
  });

  /// Check if a sticker code is cached locally
  ///
  /// [stickerCode] - The RFID sticker code to check
  /// [tenantId] - The tenant ID for multi-tenant isolation
  ///
  /// Returns true if the sticker is available in local cache
  ///
  /// Throws [DatabaseException] when local database operations fail
  Future<bool> isStickerCached(
    String stickerCode,
    String tenantId,
  );

  /// Get RFID stickers that are expiring soon
  ///
  /// [daysUntilExpiry] - Number of days until expiration to include
  /// [tenantId] - Tenant ID for multi-tenant isolation
  ///
  /// Returns a list of [RfidSticker] expiring within the specified period
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<List<RfidSticker>> getExpiringStickers(
    int daysUntilExpiry,
    String tenantId,
  );

  /// Update RFID sticker status (for admin operations)
  ///
  /// [stickerId] - The sticker ID to update
  /// [status] - The new status to set
  /// [reason] - Optional reason for status change
  ///
  /// Returns the updated [RfidSticker]
  ///
  /// Throws [AuthorizationException] when user lacks permissions
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<RfidSticker> updateRfidStickerStatus(
    String stickerId,
    RfidStickerStatus status, {
    String? reason,
  });

  /// Get RFID sticker by its unique code
  ///
  /// [stickerCode] - The RFID sticker code
  /// [tenantId] - The tenant ID for multi-tenant isolation
  ///
  /// Returns the [RfidSticker] if found, null otherwise
  ///
  /// Throws [DatabaseException] when local database operations fail
  /// Throws [NetworkException] when server requests fail
  Future<RfidSticker?> getRfidStickerByCode(
    String stickerCode,
    String tenantId,
  );

  /// Batch validation of multiple sticker codes
  ///
  /// [stickerCodes] - List of sticker codes to validate
  /// [tenantId] - The tenant ID for multi-tenant isolation
  ///
  /// Returns a map of sticker code to validation result
  ///
  /// Throws [NetworkException] when network connectivity fails
  /// Throws [ValidationException] when validation encounters errors
  Future<Map<String, RfidStickerValidationResult>> batchValidateRfidStickers(
    List<String> stickerCodes,
    String tenantId,
  );
}

/// Sync Queue Status
/// Information about the current sync queue state
class SyncQueueStatus {
  const SyncQueueStatus({
    required this.pendingItems,
    required this.processingItems,
    required this.failedItems,
    required this.completedItems,
    this.lastSyncTime,
    this.nextSyncTime,
  });

  /// Number of items pending sync
  final int pendingItems;

  /// Number of items currently processing
  final int processingItems;

  /// Number of items that failed to sync
  final int failedItems;

  /// Number of items successfully synced
  final int completedItems;

  /// Last successful sync time
  final DateTime? lastSyncTime;

  /// Next scheduled sync time
  final DateTime? nextSyncTime;

  /// Total items in sync queue
  int get totalItems => pendingItems + processingItems + failedItems + completedItems;

  /// Whether sync is currently active
  bool get isSyncing => processingItems > 0;

  /// Whether there are items that need attention
  bool get needsAttention => failedItems > 0 || pendingItems > 0;

  @override
  String toString() => 'SyncQueueStatus(pending: $pendingItems, processing: $processingItems, failed: $failedItems, completed: $completedItems, isSyncing: $isSyncing)';
}