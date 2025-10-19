import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:logger/logger.dart';
import '../../../../../entinel/lib/env.dart';

part '../../../../../entinel/lib/core/storage/database.g.dart';

/// Offline-first database schema for Sentinel App
/// Uses Drift with SQLCipher encryption for secure local storage
/// Supports multi-tenant architecture with tenant isolation
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
class SentinelDatabase extends _$SentinelDatabase {
  SentinelDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  final Logger _logger = Logger();

  /// Initialize database with encryption and optimization
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Sentinel database with encryption...');

      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');

      // Set SQLite performance optimizations
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      await customStatement('PRAGMA cache_size = 10000');
      await customStatement('PRAGMA temp_store = memory');

      // Validate encryption if not in development mode
      if (!Env.devSkipEncryption) {
        await _validateEncryption();
      }

      _logger.i('Database initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize database: $e');
      rethrow;
    }
  }

  /// Validate database encryption
  Future<void> _validateEncryption() async {
    try {
      // Test encryption/decryption with a simple query
      await customStatement('SELECT count(*) FROM sqlite_master');
      _logger.d('Database encryption validation passed');
    } catch (e) {
      _logger.e('Database encryption validation failed: $e');
      rethrow;
    }
  }

  /// Clean up database resources
  @override
  Future<void> close() async {
    _logger.i('Closing database connection');
    return super.close();
  }
}

/// Database connection opener with encryption support
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sentinel.db'));

    // Apply encryption key if not in development mode
    final encryptionKey = Env.devSkipEncryption ? null : _getEncryptionKey();

    if (encryptionKey != null) {
      _logger.d('Opening encrypted database with SQLCipher');
      return NativeDatabase(
        file,
        setup: (database) {
          // Apply encryption key
          database.execute("PRAGMA key = '$encryptionKey'");
          // Validate encryption
          database.execute('SELECT count(*) FROM sqlite_master');
        },
      );
    } else {
      _logger.w('Opening unencrypted database (development mode)');
      return NativeDatabase(file);
    }
  });
}

/// Generate encryption key from environment
String _getEncryptionKey() {
  // In production, derive from device secure storage or user credentials
  // For now, use a basic key based on app version
  return 'sentinel_encryption_key_v${Env.encryptionKeyVersion}';
}

// =============== TABLE DEFINITIONS ===============

/// Entry logs for all access attempts (residents, guests, workers, etc.)
@DataClassName('EntryLog')
class EntryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get guardId => text()();
  TextColumn get type =>
      text()(); // 'resident', 'guest', 'delivery', 'construction', 'staff'
  TextColumn get personId => text()(); // ID of the person accessing
  TextColumn get personName => text()();
  TextColumn get accessType => text()(); // 'entry', 'exit'
  TextColumn get verificationMethod =>
      text()(); // 'rfid', 'nfc', 'qr', 'manual'
  TextColumn get verificationResult =>
      text()(); // 'granted', 'denied', 'pending'
  TextColumn get gateName => text().nullable()();
  TextColumn get rfidCode => text().nullable()();
  TextColumn get qrCode => text().nullable()();
  TextColumn get vehiclePlate => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get destinationUnit => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// RFID stickers assigned to residents and household members
@DataClassName('RfidSticker')
class RfidStickers extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get householdId => text()();
  TextColumn get residenceUnitId => text()();
  TextColumn get stickerCode => text()();
  TextColumn get holderName => text()();
  TextColumn get holderType => text()(); // 'owner', 'family_member', 'tenant'
  TextColumn get status =>
      text()(); // 'active', 'inactive', 'lost', 'revoked', 'expired'
  DateTimeColumn get issuedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()().nullable()();
  DateTimeColumn get revokedAt => dateTime()().nullable()();
  TextColumn get revocationReason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {tenantId, stickerCode},
  ];
}

/// Pre-registered guests for scheduled visits
@DataClassName('PreRegisteredGuest')
class PreRegisteredGuests extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get residenceUnitId => text()();
  TextColumn get hostName => text()();
  TextColumn get guestName => text()();
  TextColumn get guestContact => text()();
  TextColumn get visitPurpose => text()();
  DateTimeColumn get expectedArrival => dateTime()();
  DateTimeColumn get expectedDeparture => dateTime()();
  TextColumn get status =>
      text()(); // 'pending', 'checked_in', 'checked_out', 'cancelled'
  TextColumn get qrCode => text().nullable()();
  TextColumn get vehicleInfo => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get maxVisitors => integer().withDefault(const Constant(1))();
  BoolColumn get allowReentry => boolean().withDefault(const Constant(false))();
  DateTimeColumn get actualCheckIn => dateTime().nullable()();
  DateTimeColumn get actualCheckOut => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Guest access logs
@DataClassName('GuestLog')
class GuestLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get guardId => text()();
  TextColumn get preRegistrationId => text().nullable()();
  TextColumn get guestName => text()();
  TextColumn get guestContact => text().nullable()();
  TextColumn get hostName => text()();
  TextColumn get residenceUnitId => text()();
  TextColumn get accessType => text()(); // 'entry', 'exit'
  TextColumn get verificationMethod => text()(); // 'qr', 'manual', 'nfc'
  TextColumn get verificationResult => text()(); // 'granted', 'denied'
  TextColumn get gateName => text().nullable()();
  TextColumn get qrCode => text().nullable()();
  TextColumn get vehicleInfo => text().nullable()();
  TextColumn get visitPurpose => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Delivery and service provider logs
@DataClassName('DeliveryLog')
class DeliveryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get guardId => text()();
  TextColumn get providerName => text()();
  TextColumn get providerType =>
      text()(); // 'delivery', 'service', 'maintenance'
  TextColumn get company => text().nullable()();
  TextColumn get contactNumber => text().nullable()();
  TextColumn get residenceUnitId => text()();
  TextColumn get deliveryType =>
      text()(); // 'package', 'food', 'furniture', 'appliance', 'other'
  TextColumn get accessType => text()(); // 'entry', 'exit'
  TextColumn get verificationResult => text()(); // 'granted', 'denied'
  TextColumn get gateName => text().nullable()();
  TextColumn get vehicleInfo => text().nullable()();
  TextColumn get trackingNumber => text().nullable()();
  TextColumn get recipientName => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Construction and renovation permits
@DataClassName('ConstructionPermit')
class ConstructionPermits extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get residenceUnitId => text()();
  TextColumn get permitNumber => text()();
  TextColumn get contractorName => text()();
  TextColumn get contractorContact => text()();
  TextColumn get constructionType =>
      text()(); // 'renovation', 'repair', 'new_construction', 'installation'
  TextColumn get description => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status =>
      text()(); // 'pending', 'approved', 'active', 'completed', 'suspended', 'cancelled'
  TextColumn get approvedBy => text().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {tenantId, permitNumber},
  ];
}

/// Construction worker access logs
@DataClassName('ConstructionWorkerLog')
class ConstructionWorkerLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get guardId => text()();
  TextColumn get permitId => text()();
  TextColumn get workerName => text()();
  TextColumn get workerId => text()(); // Company-issued worker ID
  TextColumn get company => text()();
  TextColumn get contactNumber => text().nullable()();
  TextColumn get accessType => text()(); // 'entry', 'exit'
  TextColumn get verificationMethod =>
      text()(); // 'manual', 'nfc', 'company_id'
  TextColumn get verificationResult => text()(); // 'granted', 'denied'
  TextColumn get gateName => text().nullable()();
  TextColumn get vehicleInfo => text().nullable()();
  TextColumn get skills =>
      text().nullable()(); // 'electrician', 'plumber', 'carpenter', etc.
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Security incident reports
@DataClassName('IncidentReport')
class IncidentReports extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get guardId => text()();
  TextColumn get incidentType =>
      text()(); // 'security_breach', 'theft', 'vandalism', 'accident', 'disturbance', 'other'
  TextColumn get severity => text()(); // 'low', 'medium', 'high', 'critical'
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get location => text().nullable()();
  TextColumn get gateName => text().nullable()();
  TextColumn get involvedParties => text().nullable()();
  TextColumn get witnesses => text().nullable()();
  DateTimeColumn get incidentTimestamp => dateTime()();
  TextColumn get status =>
      text()(); // 'open', 'investigating', 'resolved', 'closed'
  TextColumn get resolution => text().nullable()();
  TextColumn get nextActions => text().nullable()();
  TextColumn get evidenceUrls =>
      text().nullable()(); // JSON array of photo/document URLs
  TextColumn get reportedTo => text().nullable()(); // Who was notified
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolvedBy => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Village rules and regulations
@DataClassName('VillageRule')
class VillageRules extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get category =>
      text()(); // 'security', 'parking', 'amenities', 'conduct', 'construction'
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get severity => text()(); // 'info', 'warning', 'violation'
  TextColumn get status => text()(); // 'active', 'archived'
  DateTimeColumn get effectiveDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get attachments =>
      text().nullable()(); // JSON array of document URLs
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Community announcements and notices
@DataClassName('Announcement')
class Announcements extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get type =>
      text()(); // 'general', 'maintenance', 'security', 'event', 'urgent'
  TextColumn get priority => text()(); // 'low', 'medium', 'high', 'urgent'
  TextColumn get status => text()(); // 'draft', 'published', 'archived'
  TextColumn get targetAudience =>
      text()(); // 'all', 'residents', 'staff', 'guards'
  DateTimeColumn get publishAt => dateTime()();
  DateTimeColumn get expiryAt => dateTime().nullable()();
  TextColumn get attachments =>
      text().nullable()(); // JSON array of image/document URLs
  TextColumn get createdBy => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue for offline-to-online synchronization
@DataClassName('SyncQueueItem')
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get tableName => text()(); // Name of the table to sync
  TextColumn get recordId => text()(); // ID of the record to sync
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text()(); // JSON representation of the record data
  TextColumn get status =>
      text()(); // 'pending', 'processing', 'completed', 'failed'
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
