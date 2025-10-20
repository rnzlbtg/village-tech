import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../env.dart';
import 'encryption.dart';
import 'tables.dart';

part 'database.g.dart';

/// Main application database using Drift
/// Offline-first architecture with SQLCipher encryption
@DriftDatabase(
  tables: [
    EntryLogs,
    RfidStickers,
    PreRegisteredGuests,
    GuestLogs,
    DeliveryLogs,
    ConstructionPermits,
    ConstructionWorkerLogs,
    IncidentReports,
    VillageRules,
    Announcements,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Migration strategy for database schema updates
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        Logger().i('Creating database tables...');

        // Create all tables
        await m.createAll();

        // Create indexes for performance
        await _createIndexes(m);

        Logger().i('Database tables created successfully');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        Logger().i('Upgrading database from version $from to $to');

        // Handle migrations based on version
        switch (from) {
          case 1:
            // Migration from version 1 to 2
            if (to >= 2) {
              // Add new columns or tables here
            }
          // Add more migration cases as needed
        }

        Logger().i('Database upgrade completed');
      },
      beforeOpen: (OpeningDetails details) async {
        Logger().d('Opening database version ${details.version}');

        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');

        // Set WAL mode for better performance
        await customStatement('PRAGMA journal_mode = WAL');

        // Set cache size
        await customStatement('PRAGMA cache_size = 10000');

        // Set synchronous mode for safety
        await customStatement('PRAGMA synchronous = NORMAL');
      },
    );
  }

  /// Create performance indexes
  Future<void> _createIndexes(Migrator m) async {
    // EntryLogs indexes
    await m.createIndex(Index('idx_entry_logs_tenant_timestamp', 'entry_logs', ['tenant_id', 'timestamp']));
    await m.createIndex(Index('idx_entry_logs_guard_id', 'entry_logs', ['guard_id']));
    await m.createIndex(Index('idx_entry_logs_type', 'entry_logs', ['entry_type']));
    await m.createIndex(Index('idx_entry_logs_synced', 'entry_logs', ['synced']));

    // RfidStickers indexes
    await m.createIndex(Index('idx_rfid_stickers_code', 'rfid_stickers', ['sticker_code']));
    await m.createIndex(Index('idx_rfid_stickers_tenant_household', 'rfid_stickers', ['tenant_id', 'household_id']));
    await m.createIndex(Index('idx_rfid_stickers_status', 'rfid_stickers', ['status']));

    // PreRegisteredGuests indexes
    await m.createIndex(Index('idx_preregistered_guests_visit_date', 'pre_registered_guests', ['visit_date', 'status']));
    await m.createIndex(Index('idx_preregistered_guests_household', 'pre_registered_guests', ['household_id']));

    // GuestLogs indexes
    await m.createIndex(Index('idx_guest_logs_entry_log', 'guest_logs', ['entry_log_id']));
    await m.createIndex(Index('idx_guest_logs_household', 'guest_logs', ['household_id']));

    // DeliveryLogs indexes
    await m.createIndex(Index('idx_delivery_logs_entry_log', 'delivery_logs', ['entry_log_id']));
    await m.createIndex(Index('idx_delivery_logs_household', 'delivery_logs', ['recipient_household_id']));
    await m.createIndex(Index('idx_delivery_logs_exit', 'delivery_logs', ['exit_timestamp']));

    // ConstructionWorkerLogs indexes
    await m.createIndex(Index('idx_construction_worker_logs_permit', 'construction_worker_logs', ['permit_id']));
    await m.createIndex(Index('idx_construction_worker_logs_onsite', 'construction_worker_logs', ['currently_onsite']));

    // IncidentReports indexes
    await m.createIndex(Index('idx_incident_reports_tenant_timestamp', 'incident_reports', ['tenant_id', 'timestamp']));
    await m.createIndex(Index('idx_incident_reports_status', 'incident_reports', ['status']));

    // VillageRules indexes
    await m.createIndex(Index('idx_village_rules_tenant_active', 'village_rules', ['tenant_id', 'active']));

    // Announcements indexes
    await m.createIndex(Index('idx_announcements_tenant_active', 'announcements', ['tenant_id', 'active']));
    await m.createIndex(Index('idx_announcements_priority', 'announcements', ['priority']));

    // SyncQueue indexes
    await m.createIndex(Index('idx_sync_queue_status', 'sync_queue', ['status']));
    await m.createIndex(Index('idx_sync_queue_timestamp', 'sync_queue', ['timestamp']));
  }

  /// Open database connection with encryption
  static QueryExecutor _openConnection() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sentinel.db'));

    final logger = Logger();
    logger.i('Opening database at: ${file.path}');

    return NativeDatabase.createInBackground(
      file,
      setup: (database) async {
        try {
          // Initialize encryption if not in development mode
          if (!Env.devSkipEncryption) {
            await _setupEncryption(database);
          } else {
            logger.w('Skipping database encryption (development mode)');
          }

          // Database optimizations
          await database.execute('PRAGMA foreign_keys = ON');
          await database.execute('PRAGMA journal_mode = WAL');
          await database.execute('PRAGMA cache_size = 10000');
          await database.execute('PRAGMA synchronous = NORMAL');

          logger.d('Database connection setup completed');
        } catch (e) {
          logger.e('Database setup failed: $e');
          rethrow;
        }
      },
    );
  }

  /// Setup SQLCipher encryption for the database
  static Future<void> _setupEncryption(dynamic database) async {
    final logger = Logger();
    final encryption = DatabaseEncryption.instance;

    try {
      // Initialize or get existing encryption key
      final encryptionKey = await encryption.initializeEncryptionKey();

      if (encryptionKey.isEmpty) {
        throw const DatabaseEncryptionException('Failed to initialize encryption key');
      }

      // Set encryption key for SQLCipher
      await database.execute("PRAGMA key = '$encryptionKey'");

      // Verify database can be opened with encryption
      await database.execute('SELECT count(*) FROM sqlite_master');

      logger.i('SQLCipher encryption setup completed successfully');
    } catch (e) {
      logger.e('Failed to setup database encryption: $e');

      // If encryption fails, try to continue without it in development
      if (Env.debugMode) {
        logger.w('Continuing without encryption due to error in debug mode');
      } else {
        rethrow;
      }
    }
  }

  // ============== Convenience Methods for Common Operations ==============

  /// Get unsynced entry logs
  Future<List<EntryLog>> getUnsyncedEntryLogs() {
    return (select(entryLogs)..where((tbl) => tbl.synced.equals(false))).get();
  }

  /// Get active delivery logs (no exit time)
  Future<List<DeliveryLog>> getActiveDeliveries() {
    return (select(deliveryLogs)..where((tbl) => tbl.exitTimestamp.isNull())).get();
  }

  /// Get workers currently on-site
  Future<List<ConstructionWorkerLog>> getWorkersOnSite() {
    return (select(constructionWorkerLogs)..where((tbl) => tbl.currentlyOnsite.equals(true))).get();
  }

  /// Get pending sync queue items
  Future<List<SyncQueueEntry>> getPendingSyncItems() {
    return (select(syncQueue)..where((tbl) => tbl.status.equals('pending'))).get();
  }

  /// Add entry to sync queue
  Future<void> addToSyncQueue({
    required String operation,
    required String entityType,
    required String entityId,
    required String payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        operation: operation,
        entityType: entityType,
        entityId: entityId,
        payload: payload,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: const Value('pending'),
        retryCount: const Value(0),
      ),
    );
  }

  /// Mark entry log as synced
  Future<void> markEntryLogAsSynced(String entryLogId) {
    return (update(entryLogs)..where((tbl) => tbl.id.equals(entryLogId)))
        .write(const EntryLogsCompanion(synced: Value(true)));
  }

  /// Update sync queue item status
  Future<void> updateSyncQueueStatus(int queueId, String status, {String? errorMessage}) {
    return (update(syncQueue)..where((tbl) => tbl.id.equals(queueId)))
        .write(SyncQueueCompanion(
      status: Value(status),
      errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() {
    return customSelect('SELECT COUNT(*) as count FROM sync_queue WHERE status = \'pending\'')
        .map((row) => row.read<int>('count'))
        .getSingle();
  }

  /// Clean up old sync queue items
  Future<void> cleanupOldSyncItems({int daysOld = 30}) {
    final cutoffTime = DateTime.now().subtract(Duration(days: daysOld)).millisecondsSinceEpoch;

    return (delete(syncQueue)..where((tbl) =>
      tbl.timestamp.isSmallerThanValue(cutoffTime) &
      tbl.status.equals('completed')
    )).go();
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final entryLogsCount = await customSelect('SELECT COUNT(*) as count FROM entry_logs')
        .map((row) => row.read<int>('count')).getSingle();

    final pendingSyncCount = await getPendingSyncCount();

    return {
      'entry_logs': entryLogsCount,
      'pending_sync': pendingSyncCount,
    };
  }
}

/// Database instance provider
class DatabaseProvider {
  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }

  static Future<void> initialize() async {
    Logger().i('Initializing database...');
    instance;
    Logger().i('Database initialized successfully');
  }

  static Future<void> close() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
      Logger().i('Database closed');
    }
  }
}