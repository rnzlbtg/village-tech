import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'entry_log.g.dart';

/// Entry Log model for comprehensive audit trail of all gate activities
@JsonSerializable()
class EntryLog {
  final String id;
  final String tenantId;
  final String guardId;
  final EntryType entryType;
  final String personName;
  final String? vehicleInfo;
  final String? rfidStickerId;
  final String? guestId;
  final String? deliveryId;
  final String? constructionPermitId;
  final String destination;
  final String? purpose;
  final VerificationMethod verificationMethod;
  final VerificationStatus verificationStatus;
  final DateTime entryTime;
  final DateTime? exitTime;
  final Duration? durationOnSite;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EntryLog({
    required this.id,
    required this.tenantId,
    required this.guardId,
    required this.entryType,
    required this.personName,
    this.vehicleInfo,
    this.rfidStickerId,
    this.guestId,
    this.deliveryId,
    this.constructionPermitId,
    required this.destination,
    this.purpose,
    required this.verificationMethod,
    required this.verificationStatus,
    required this.entryTime,
    this.exitTime,
    this.durationOnSite,
    this.notes,
    this.metadata,
    required this.synced,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new entry log with generated ID and timestamps
  factory EntryLog.create({
    required String tenantId,
    required String guardId,
    required EntryType entryType,
    required String personName,
    String? vehicleInfo,
    String? rfidStickerId,
    String? guestId,
    String? deliveryId,
    String? constructionPermitId,
    required String destination,
    String? purpose,
    required VerificationMethod verificationMethod,
    required VerificationStatus verificationStatus,
    String? notes,
    Map<String, dynamic>? metadata,
    bool synced = false,
  }) {
    final now = DateTime.now();
    return EntryLog(
      id: const Uuid().v4(),
      tenantId: tenantId,
      guardId: guardId,
      entryType: entryType,
      personName: personName,
      vehicleInfo: vehicleInfo,
      rfidStickerId: rfidStickerId,
      guestId: guestId,
      deliveryId: deliveryId,
      constructionPermitId: constructionPermitId,
      destination: destination,
      purpose: purpose,
      verificationMethod: verificationMethod,
      verificationStatus: verificationStatus,
      entryTime: now,
      exitTime: null,
      durationOnSite: null,
      notes: notes,
      metadata: metadata ?? {},
      synced: synced,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create entry log from JSON
  factory EntryLog.fromJson(Map<String, dynamic> json) => _$EntryLogFromJson(json);

  /// Convert entry log to JSON
  Map<String, dynamic> toJson() => _$EntryLogToJson(this);

  /// Create a copy with updated fields
  EntryLog copyWith({
    String? id,
    String? tenantId,
    String? guardId,
    EntryType? entryType,
    String? personName,
    String? vehicleInfo,
    String? rfidStickerId,
    String? guestId,
    String? deliveryId,
    String? constructionPermitId,
    String? destination,
    String? purpose,
    VerificationMethod? verificationMethod,
    VerificationStatus? verificationStatus,
    DateTime? entryTime,
    DateTime? exitTime,
    Duration? durationOnSite,
    String? notes,
    Map<String, dynamic>? metadata,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntryLog(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      guardId: guardId ?? this.guardId,
      entryType: entryType ?? this.entryType,
      personName: personName ?? this.personName,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      rfidStickerId: rfidStickerId ?? this.rfidStickerId,
      guestId: guestId ?? this.guestId,
      deliveryId: deliveryId ?? this.deliveryId,
      constructionPermitId: constructionPermitId ?? this.constructionPermitId,
      destination: destination ?? this.destination,
      purpose: purpose ?? this.purpose,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      durationOnSite: durationOnSite ?? this.durationOnSite,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Record exit time and calculate duration
  EntryLog recordExit({String? notes}) {
    final now = DateTime.now();
    final duration = now.difference(entryTime);

    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    updatedMetadata['exit_recorded_at'] = now.toIso8601String();

    return copyWith(
      exitTime: now,
      durationOnSite: duration,
      notes: notes ?? this.notes,
      metadata: updatedMetadata,
      updatedAt: now,
    );
  }

  /// Update verification status
  EntryLog updateVerificationStatus(VerificationStatus newStatus, {String? notes}) {
    var updatedMetadata = Map<String, dynamic>.from(metadata ?? {});
    updatedMetadata['verification_status_updated'] = {
      'old_status': verificationStatus.toApiString(),
      'new_status': newStatus.toApiString(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return copyWith(
      verificationStatus: newStatus,
      notes: notes ?? this.notes,
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as synced with server
  EntryLog markAsSynced() {
    return copyWith(
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as needing sync
  EntryLog markAsNeedingSync() {
    return copyWith(
      synced: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if entry is currently active (person on site)
  bool get isActive => exitTime == null && verificationStatus == VerificationStatus.verified;

  /// Check if entry was denied
  bool get isDenied => verificationStatus == VerificationStatus.denied;

  /// Check if entry is pending verification
  bool get isPending => verificationStatus == VerificationStatus.pending;

  /// Get formatted duration
  String get formattedDuration {
    if (durationOnSite == null) return 'N/A';

    final duration = durationOnSite!;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Check if entry exceeded maximum allowed duration
  bool exceededMaxDuration(Duration maxDuration) {
    if (durationOnSite == null) return false;
    return durationOnSite! > maxDuration;
  }

  /// Get risk level based on entry details
  EntryRiskLevel getRiskLevel() {
    // High risk indicators
    if (verificationStatus == VerificationStatus.denied) {
      return EntryRiskLevel.high;
    }
    if (entryType == EntryType.other) {
      return EntryRiskLevel.medium;
    }
    if (durationOnSite != null && exceededMaxDuration(const Duration(hours: 4))) {
      return EntryRiskLevel.high;
    }

    // Medium risk indicators
    if (verificationStatus == VerificationStatus.pending) {
      return EntryRiskLevel.medium;
    }
    if (entryType == EntryType.construction) {
      return EntryRiskLevel.medium;
    }

    return EntryRiskLevel.low;
  }

  /// Validate entry log data
  bool isValidData() {
    return _validatePersonName(personName) &&
        _validateDestination(destination) &&
        _validateVehicleInfo(vehicleInfo) &&
        _validateNotes(notes);
  }

  bool _validatePersonName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 100;
  }

  bool _validateDestination(String destination) {
    return destination.trim().length >= 2 && destination.trim().length <= 200;
  }

  bool _validateVehicleInfo(String? info) {
    if (info == null || info.trim().isEmpty) return true; // Optional
    return info.trim().length <= 200;
  }

  bool _validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return true; // Optional
    return notes.trim().length <= 1000;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntryLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'EntryLog(id: $id, entryType: $entryType, personName: $personName, verificationStatus: $verificationStatus, isActive: $isActive)';
  }
}

/// Entry type enumeration
enum EntryType {
  @JsonValue('resident')
  resident('Resident', 'Resident entry'),
  @JsonValue('guest')
  guest('Guest', 'Visitor entry'),
  @JsonValue('delivery')
  delivery('Delivery', 'Delivery personnel entry'),
  @JsonValue('construction')
  construction('Construction', 'Construction worker entry'),
  @JsonValue('other')
  other('Other', 'Other type of entry');

  const EntryType(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get entry type from string value
  static EntryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'resident':
        return EntryType.resident;
      case 'guest':
        return EntryType.guest;
      case 'delivery':
        return EntryType.delivery;
      case 'construction':
        return EntryType.construction;
      case 'other':
        return EntryType.other;
      default:
        throw ArgumentError('Invalid EntryType: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case EntryType.resident:
        return 'resident';
      case EntryType.guest:
        return 'guest';
      case EntryType.delivery:
        return 'delivery';
      case EntryType.construction:
        return 'construction';
      case EntryType.other:
        return 'other';
    }
  }
}

/// Verification method enumeration
enum VerificationMethod {
  @JsonValue('rfid')
  rfid('RFID Scan', 'RFID sticker verification'),
  @JsonValue('manual')
  manual('Manual', 'Manual verification'),
  @JsonValue('phone_call')
  phoneCall('Phone Call', 'Verification via phone call'),
  @JsonValue('permit')
  permit('Permit', 'Permit verification');

  const VerificationMethod(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get verification method from string value
  static VerificationMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'rfid':
        return VerificationMethod.rfid;
      case 'manual':
        return VerificationMethod.manual;
      case 'phone_call':
        return VerificationMethod.phoneCall;
      case 'permit':
        return VerificationMethod.permit;
      default:
        throw ArgumentError('Invalid VerificationMethod: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case VerificationMethod.rfid:
        return 'rfid';
      case VerificationMethod.manual:
        return 'manual';
      case VerificationMethod.phoneCall:
        return 'phone_call';
      case VerificationMethod.permit:
        return 'permit';
    }
  }
}

/// Verification status enumeration
enum VerificationStatus {
  @JsonValue('verified')
  verified('Verified', 'Entry verified and allowed'),
  @JsonValue('pending')
  pending('Pending', 'Verification in progress'),
  @JsonValue('denied')
  denied('Denied', 'Entry denied');

  const VerificationStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get verification status from string value
  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'denied':
        return VerificationStatus.denied;
      default:
        throw ArgumentError('Invalid VerificationStatus: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.denied:
        return 'denied';
    }
  }
}

/// Entry risk level enumeration
enum EntryRiskLevel {
  low('Low', 'Normal entry'),
  medium('Medium', 'Requires attention'),
  high('High', 'Requires immediate attention');

  const EntryRiskLevel(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Entry log validation errors
enum EntryLogValidationError {
  personNameInvalid,
  destinationInvalid,
  vehicleInfoInvalid,
  notesInvalid,
  guardIdInvalid,
  tenantIdInvalid,
}

/// Entry log validation result
class EntryLogValidationResult {
  final bool isValid;
  final List<EntryLogValidationError> errors;

  const EntryLogValidationResult(this.isValid, this.errors);

  factory EntryLogValidationResult.success() {
    return const EntryLogValidationResult(true, []);
  }

  factory EntryLogValidationResult.failure(List<EntryLogValidationError> errors) {
    return EntryLogValidationResult(false, errors);
  }
}