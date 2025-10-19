import 'package:equatable/equatable.dart';

/// Entry Log Entity
/// Represents a comprehensive log of all gate activity for resident entries
///
/// This entity mirrors the entry_logs table in Supabase and includes all fields
/// from the data-model specification with proper tenant isolation and tracking.
class EntryLog extends Equatable {
  const EntryLog({
    required this.id,
    required this.tenantId,
    required this.guardId,
    required this.entryType,
    required this.timestamp,
    required this.verificationMethod,
    required this.verificationStatus,
    this.vehicleInfo,
    this.personInfo,
    this.denialReason,
    this.notes,
    this.synced = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique entry log identifier (UUID)
  final String id;

  /// Reference to tenant (community) for multi-tenant isolation
  final String tenantId;

  /// Reference to guard who processed this entry
  final String guardId;

  /// Type of entry: 'resident', 'guest', 'delivery', 'construction'
  final EntryType entryType;

  /// Entry timestamp
  final DateTime timestamp;

  /// Method used for verification: 'rfid', 'manual', 'pre_registered', 'permit'
  final VerificationMethod verificationMethod;

  /// Status of verification: 'granted', 'denied', 'pending'
  final VerificationStatus verificationStatus;

  /// Vehicle details: {plate, make, model, color}
  final Map<String, String>? vehicleInfo;

  /// Person details: {name, contact, id_number}
  final Map<String, String>? personInfo;

  /// Reason if entry was denied
  final String? denialReason;

  /// Additional notes from guard
  final String? notes;

  /// Sync status for offline logs
  final bool synced;

  /// Record creation timestamp
  final DateTime? createdAt;

  /// Record update timestamp
  final DateTime? updatedAt;

  /// Whether this entry was granted access
  bool get isGranted => verificationStatus == VerificationStatus.granted;

  /// Whether this entry was denied access
  bool get isDenied => verificationStatus == VerificationStatus.denied;

  /// Whether this entry is pending verification
  bool get isPending => verificationStatus == VerificationStatus.pending;

  /// Vehicle information formatted for display
  String get vehicleDisplay {
    if (vehicleInfo == null || vehicleInfo!.isEmpty) {
      return 'No vehicle info';
    }

    final parts = <String>[];

    if (vehicleInfo!['plate']?.isNotEmpty == true) {
      parts.add(vehicleInfo!['plate']!);
    }

    if (vehicleInfo!['make']?.isNotEmpty == true) {
      parts.add(vehicleInfo!['make']!);
    }

    if (vehicleInfo!['model']?.isNotEmpty == true) {
      parts.add(vehicleInfo!['model']!);
    }

    if (vehicleInfo!['color']?.isNotEmpty == true) {
      parts.add('${vehicleInfo!['color']}');
    }

    return parts.isEmpty ? 'No vehicle info' : parts.join(' - ');
  }

  /// Person information formatted for display
  String get personDisplay {
    if (personInfo == null || personInfo!.isEmpty) {
      return 'No person info';
    }

    final parts = <String>[];

    if (personInfo!['name']?.isNotEmpty == true) {
      parts.add(personInfo!['name']!);
    }

    if (personInfo!['contact']?.isNotEmpty == true) {
      parts.add('📞 ${personInfo!['contact']!}');
    }

    return parts.isEmpty ? 'No person info' : parts.join(' • ');
  }

  /// Status display with icon
  String get statusDisplay {
    switch (verificationStatus) {
      case VerificationStatus.granted:
        return '✅ Granted';
      case VerificationStatus.denied:
        return '❌ Denied';
      case VerificationStatus.pending:
        return '⏳ Pending';
    }
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        guardId,
        entryType,
        timestamp,
        verificationMethod,
        verificationStatus,
        vehicleInfo,
        personInfo,
        denialReason,
        notes,
        synced,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'EntryLog('
        'id: $id, '
        'entryType: ${entryType.value}, '
        'verificationMethod: ${verificationMethod.value}, '
        'verificationStatus: ${verificationStatus.value}, '
        'timestamp: $timestamp, '
        'isGranted: $isGranted'
        ')';
  }

  /// Create a copy with updated fields
  EntryLog copyWith({
    String? id,
    String? tenantId,
    String? guardId,
    EntryType? entryType,
    DateTime? timestamp,
    VerificationMethod? verificationMethod,
    VerificationStatus? verificationStatus,
    Map<String, String>? vehicleInfo,
    Map<String, String>? personInfo,
    String? denialReason,
    String? notes,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntryLog(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      guardId: guardId ?? this.guardId,
      entryType: entryType ?? this.entryType,
      timestamp: timestamp ?? this.timestamp,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      personInfo: personInfo ?? this.personInfo,
      denialReason: denialReason ?? this.denialReason,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Entry Type Enumeration
/// Matches the database constraint for entry_logs.entry_type field
enum EntryType {
  resident('resident'),
  guest('guest'),
  delivery('delivery'),
  construction('construction');

  const EntryType(this.value);

  /// String value for database storage
  final String value;

  @override
  String toString() => value;
}

/// Verification Method Enumeration
/// Matches the database constraint for entry_logs.verification_method field
enum VerificationMethod {
  rfid('rfid'),
  manual('manual'),
  preRegistered('pre_registered'),
  permit('permit');

  const VerificationMethod(this.value);

  /// String value for database storage
  final String value;

  @override
  String toString() => value;
}

/// Verification Status Enumeration
/// Matches the database constraint for entry_logs.verification_status field
enum VerificationStatus {
  granted('granted'),
  denied('denied'),
  pending('pending');

  const VerificationStatus(this.value);

  /// String value for database storage
  final String value;

  @override
  String toString() => value;
}

/// Entry Log Statistics
/// Represents aggregated statistics for entry logs
class EntryLogStatistics extends Equatable {
  const EntryLogStatistics({
    required this.totalEntries,
    required this.grantedEntries,
    required this.deniedEntries,
    required this.pendingEntries,
    required this.residentEntries,
    required this.guestEntries,
    required this.deliveryEntries,
    required this.constructionEntries,
    required this.rfidVerifications,
    required this.manualVerifications,
    this.periodStart,
    this.periodEnd,
  });

  /// Total number of entries
  final int totalEntries;

  /// Number of granted entries
  final int grantedEntries;

  /// Number of denied entries
  final int deniedEntries;

  /// Number of pending entries
  final int pendingEntries;

  /// Number of resident entries
  final int residentEntries;

  /// Number of guest entries
  final int guestEntries;

  /// Number of delivery entries
  final int deliveryEntries;

  /// Number of construction entries
  final int constructionEntries;

  /// Number of RFID verifications
  final int rfidVerifications;

  /// Number of manual verifications
  final int manualVerifications;

  /// Start date for statistics period
  final DateTime? periodStart;

  /// End date for statistics period
  final DateTime? periodEnd;

  /// Percentage of granted entries
  double get grantPercentage {
    if (totalEntries == 0) return 0.0;
    return (grantedEntries / totalEntries) * 100;
  }

  /// Percentage of denied entries
  double get denialPercentage {
    if (totalEntries == 0) return 0.0;
    return (deniedEntries / totalEntries) * 100;
  }

  @override
  List<Object?> get props => [
        totalEntries,
        grantedEntries,
        deniedEntries,
        pendingEntries,
        residentEntries,
        guestEntries,
        deliveryEntries,
        constructionEntries,
        rfidVerifications,
        manualVerifications,
        periodStart,
        periodEnd,
      ];

  @override
  String toString() {
    return 'EntryLogStatistics('
        'total: $totalEntries, '
        'granted: $grantedEntries (${grantPercentage.toStringAsFixed(1)}%), '
        'denied: $deniedEntries (${denialPercentage.toStringAsFixed(1)}%)'
        ')';
  }
}

/// Entry Log Search Filters
/// Used for filtering and searching entry logs
class EntryLogFilters extends Equatable {
  const EntryLogFilters({
    this.entryType,
    this.verificationStatus,
    this.verificationMethod,
    this.guardId,
    this.startDate,
    this.endDate,
    this.unsyncedOnly = false,
    this.searchQuery,
  });

  /// Filter by entry type
  final EntryType? entryType;

  /// Filter by verification status
  final VerificationStatus? verificationStatus;

  /// Filter by verification method
  final VerificationMethod? verificationMethod;

  /// Filter by guard ID
  final String? guardId;

  /// Filter by start date
  final DateTime? startDate;

  /// Filter by end date
  final DateTime? endDate;

  /// Show only unsynced entries
  final bool unsyncedOnly;

  /// Search query for vehicle/person info
  final String? searchQuery;

  @override
  List<Object?> get props => [
        entryType,
        verificationStatus,
        verificationMethod,
        guardId,
        startDate,
        endDate,
        unsyncedOnly,
        searchQuery,
      ];

  /// Create a copy with updated filters
  EntryLogFilters copyWith({
    EntryType? entryType,
    VerificationStatus? verificationStatus,
    VerificationMethod? verificationMethod,
    String? guardId,
    DateTime? startDate,
    DateTime? endDate,
    bool? unsyncedOnly,
    String? searchQuery,
  }) {
    return EntryLogFilters(
      entryType: entryType ?? this.entryType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      guardId: guardId ?? this.guardId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      unsyncedOnly: unsyncedOnly ?? this.unsyncedOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}