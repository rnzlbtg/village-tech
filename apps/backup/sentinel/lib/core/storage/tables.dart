import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Database table definitions for Sentinel App
/// Based on data-model.md specifications

/// Entry logs table - Comprehensive log of all gate activity
@DataClassName('EntryLog')
class EntryLogs extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get guardId => text()(); // Guard UUID
  TextColumn get entryType => text()(); // 'resident', 'guest', 'delivery', 'construction'
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get vehicleInfo => text().nullable()(); // JSON string
  TextColumn get personInfo => text().nullable()(); // JSON string
  TextColumn get verificationMethod => text()(); // 'rfid', 'manual', 'pre_registered', 'permit'
  TextColumn get verificationStatus => text()(); // 'granted', 'denied', 'pending'
  TextColumn get denialReason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// RFID stickers table - Vehicle RFID sticker registry
@DataClassName('RfidSticker')
class RfidStickers extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get stickerCode => text()(); // Unique RFID code
  TextColumn get householdId => text()(); // Household UUID
  TextColumn get vehiclePlate => text()();
  TextColumn get vehicleMake => text().nullable()();
  TextColumn get status => text()(); // 'active', 'expired', 'revoked', 'lost'
  DateColumn get issuedDate => date()();
  DateColumn get expiryDate => date()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {stickerCode}, // Unique sticker code
  ];
}

/// Pre-registered guests table
@DataClassName('PreRegisteredGuest')
class PreRegisteredGuests extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get householdId => text()(); // Household UUID
  TextColumn get guestName => text()();
  TextColumn get guestContact => text().nullable()();
  DateColumn get visitDate => date()();
  TimeColumn get expectedTime => time().nullable()();
  IntColumn get durationHours => integer().nullable()();
  TextColumn get purpose => text()();
  TextColumn get vehiclePlate => text().nullable()();
  TextColumn get status => text()(); // 'pending', 'arrived', 'cancelled', 'expired'
  DateTimeColumn get checkedInAt => dateTime().nullable()();
  TextColumn get entryLogId => text().nullable()(); // Entry log UUID
  TextColumn get createdBy => text()(); // Household head UUID
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Guest logs table - Detailed guest entry records
@DataClassName('GuestLog')
class GuestLogs extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entryLogId => text()(); // Entry log UUID
  TextColumn get guestName => text()();
  TextColumn get householdId => text()(); // Household UUID
  TextColumn get purpose => text()();
  TextColumn get verificationMethod => text()(); // 'pre_registered', 'household_call', 'manual'
  BoolColumn get householdContacted => boolean().withDefault(const Constant(false))();
  TextColumn get householdResponse => text().nullable()();
  DateTimeColumn get exitTimestamp => dateTime().nullable()();
  IntColumn get visitDurationMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Delivery logs table
@DataClassName('DeliveryLog')
class DeliveryLogs extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entryLogId => text()(); // Entry log UUID
  TextColumn get deliveryCompany => text()();
  TextColumn get recipientHouseholdId => text()(); // Household UUID
  TextColumn get packageType => text()(); // 'standard', 'perishable', 'large'
  TextColumn get packageDescription => text().nullable()();
  BoolColumn get recipientContacted => boolean().withDefault(const Constant(false))();
  BoolColumn get recipientAvailable => boolean().nullable()();
  TextColumn get specialInstructions => text().nullable()();
  DateTimeColumn get entryTimestamp => dateTime()();
  DateTimeColumn get exitTimestamp => dateTime().nullable()();
  IntColumn get deliveryDurationMinutes => integer().nullable()();
  BoolColumn get durationAlertSent => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Construction permits table
@DataClassName('ConstructionPermit')
class ConstructionPermits extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get householdId => text()(); // Household UUID
  TextColumn get permitReference => text()(); // Permit reference number
  TextColumn get projectDescription => text()();
  TextColumn get contractorName => text()();
  TextColumn get contractorContact => text()();
  TextColumn get authorizedWorkers => text()(); // JSON array
  DateColumn get startDate => date()();
  DateColumn get endDate => date()();
  TextColumn get status => text()(); // 'pending', 'active', 'expired', 'completed', 'revoked'
  TextColumn get approvedBy => text().nullable()(); // Admin UUID
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {permitReference}, // Unique permit reference
  ];
}

/// Construction worker logs table
@DataClassName('ConstructionWorkerLog')
class ConstructionWorkerLogs extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entryLogId => text()(); // Entry log UUID
  TextColumn get permitId => text()(); // Permit UUID
  TextColumn get workerName => text()();
  TextColumn get workerIdNumber => text()();
  DateTimeColumn get entryTimestamp => dateTime()();
  DateTimeColumn get exitTimestamp => dateTime().nullable()();
  IntColumn get timeOnsiteMinutes => integer().nullable()();
  BoolColumn get currentlyOnsite => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Incident reports table
@DataClassName('IncidentReport')
class IncidentReports extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get guardId => text()(); // Guard UUID
  TextColumn get incidentType => text()(); // 'security', 'rule_violation', 'suspicious_activity', 'other'
  TextColumn get severity => text()(); // 'low', 'medium', 'high', 'critical'
  TextColumn get location => text()();
  TextColumn get description => text()();
  TextColumn get involvedParties => text().nullable()(); // JSON array
  TextColumn get photos => text().nullable()(); // JSON array of photo URLs
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get dispatchNotified => boolean().withDefault(const Constant(false))();
  TextColumn get dispatchResponse => text().nullable()();
  TextColumn get resolution => text().nullable()();
  TextColumn get status => text()(); // 'open', 'in_progress', 'resolved', 'closed'
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Village rules table
@DataClassName('VillageRule')
class VillageRules extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get ruleCategory => text()(); // 'curfew', 'parking', 'noise', 'security', 'general'
  TextColumn get ruleTitle => text()();
  TextColumn get ruleDescription => text()();
  TextColumn get enforcementInstructions => text().nullable()();
  DateColumn get effectiveDate => date()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text()(); // Admin UUID
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Announcements table
@DataClassName('Announcement')
class Announcements extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text()(); // Tenant UUID
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get priority => text()(); // 'normal', 'high', 'urgent'
  TextColumn get targetAudience => text()(); // 'all_guards', 'specific_gate', 'specific_guard'
  TextColumn get createdBy => text()(); // Admin UUID
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue table - Local only for offline operations
@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // 'CREATE', 'UPDATE', 'DELETE'
  TextColumn get entityType => text()(); // Entity type being synced
  TextColumn get entityId => text()(); // ID of entity being synced
  TextColumn get payload => text()(); // JSON payload
  IntColumn get timestamp => integer()(); // Unix timestamp
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // 'pending', 'processing', 'failed', 'completed'
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

/// Database table extensions for JSON columns
extension EntryLogExtension on EntryLog {
  Map<String, dynamic>? get vehicleInfoMap {
    if (vehicleInfo == null) return null;
    // TODO: Parse JSON string to Map
    return {};
  }

  Map<String, dynamic>? get personInfoMap {
    if (personInfo == null) return null;
    // TODO: Parse JSON string to Map
    return {};
  }
}

extension RfidStickerExtension on RfidSticker {
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isActive {
    return status.toLowerCase() == 'active' && !isExpired;
  }
}

extension PreRegisteredGuestExtension on PreRegisteredGuest {
  bool get isExpired {
    return DateTime.now().isAfter(visitDate.add(const Duration(days: 1)));
  }

  bool get canCheckIn {
    return status.toLowerCase() == 'pending' && !isExpired;
  }
}

extension ConstructionPermitExtension on ConstructionPermit {
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isActive {
    return status.toLowerCase() == 'active' && !isExpired;
  }

  List<String> get authorizedWorkersList {
    if (authorizedWorkers == null) return [];
    // TODO: Parse JSON string to List<String>
    return [];
  }
}

extension IncidentReportExtension on IncidentReport {
  List<String> get photosList {
    if (photos == null) return [];
    // TODO: Parse JSON string to List<String>
    return [];
  }

  List<Map<String, dynamic>> get involvedPartiesList {
    if (involvedParties == null) return [];
    // TODO: Parse JSON string to List<Map>
    return [];
  }
}

extension AnnouncementExtension on Announcement {
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive {
    return active && !isExpired;
  }

  bool get isUrgent {
    return priority.toLowerCase() == 'urgent';
  }
}