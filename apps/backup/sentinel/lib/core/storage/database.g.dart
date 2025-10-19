// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EntryLogsTable extends EntryLogs
    with TableInfo<$EntryLogsTable, EntryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guardIdMeta =
      const VerificationMeta('guardId');
  @override
  late final GeneratedColumn<String> guardId = GeneratedColumn<String>(
      'guard_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _vehicleInfoMeta =
      const VerificationMeta('vehicleInfo');
  @override
  late final GeneratedColumn<String> vehicleInfo = GeneratedColumn<String>(
      'vehicle_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _personInfoMeta =
      const VerificationMeta('personInfo');
  @override
  late final GeneratedColumn<String> personInfo = GeneratedColumn<String>(
      'person_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _verificationMethodMeta =
      const VerificationMeta('verificationMethod');
  @override
  late final GeneratedColumn<String> verificationMethod =
      GeneratedColumn<String>('verification_method', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verificationStatusMeta =
      const VerificationMeta('verificationStatus');
  @override
  late final GeneratedColumn<String> verificationStatus =
      GeneratedColumn<String>('verification_status', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _denialReasonMeta =
      const VerificationMeta('denialReason');
  @override
  late final GeneratedColumn<String> denialReason = GeneratedColumn<String>(
      'denial_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        guardId,
        entryType,
        timestamp,
        vehicleInfo,
        personInfo,
        verificationMethod,
        verificationStatus,
        denialReason,
        notes,
        synced,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_logs';
  @override
  VerificationContext validateIntegrity(Insertable<EntryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('guard_id')) {
      context.handle(_guardIdMeta,
          guardId.isAcceptableOrUnknown(data['guard_id']!, _guardIdMeta));
    } else if (isInserting) {
      context.missing(_guardIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('vehicle_info')) {
      context.handle(
          _vehicleInfoMeta,
          vehicleInfo.isAcceptableOrUnknown(
              data['vehicle_info']!, _vehicleInfoMeta));
    }
    if (data.containsKey('person_info')) {
      context.handle(
          _personInfoMeta,
          personInfo.isAcceptableOrUnknown(
              data['person_info']!, _personInfoMeta));
    }
    if (data.containsKey('verification_method')) {
      context.handle(
          _verificationMethodMeta,
          verificationMethod.isAcceptableOrUnknown(
              data['verification_method']!, _verificationMethodMeta));
    } else if (isInserting) {
      context.missing(_verificationMethodMeta);
    }
    if (data.containsKey('verification_status')) {
      context.handle(
          _verificationStatusMeta,
          verificationStatus.isAcceptableOrUnknown(
              data['verification_status']!, _verificationStatusMeta));
    } else if (isInserting) {
      context.missing(_verificationStatusMeta);
    }
    if (data.containsKey('denial_reason')) {
      context.handle(
          _denialReasonMeta,
          denialReason.isAcceptableOrUnknown(
              data['denial_reason']!, _denialReasonMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      guardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guard_id'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      vehicleInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_info']),
      personInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_info']),
      verificationMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verification_method'])!,
      verificationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verification_status'])!,
      denialReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}denial_reason']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EntryLogsTable createAlias(String alias) {
    return $EntryLogsTable(attachedDatabase, alias);
  }
}

class EntryLog extends DataClass implements Insertable<EntryLog> {
  final String id;
  final String tenantId;
  final String guardId;
  final String entryType;
  final DateTime timestamp;
  final String? vehicleInfo;
  final String? personInfo;
  final String verificationMethod;
  final String verificationStatus;
  final String? denialReason;
  final String? notes;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryLog(
      {required this.id,
      required this.tenantId,
      required this.guardId,
      required this.entryType,
      required this.timestamp,
      this.vehicleInfo,
      this.personInfo,
      required this.verificationMethod,
      required this.verificationStatus,
      this.denialReason,
      this.notes,
      required this.synced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['guard_id'] = Variable<String>(guardId);
    map['entry_type'] = Variable<String>(entryType);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || vehicleInfo != null) {
      map['vehicle_info'] = Variable<String>(vehicleInfo);
    }
    if (!nullToAbsent || personInfo != null) {
      map['person_info'] = Variable<String>(personInfo);
    }
    map['verification_method'] = Variable<String>(verificationMethod);
    map['verification_status'] = Variable<String>(verificationStatus);
    if (!nullToAbsent || denialReason != null) {
      map['denial_reason'] = Variable<String>(denialReason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['synced'] = Variable<bool>(synced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntryLogsCompanion toCompanion(bool nullToAbsent) {
    return EntryLogsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      guardId: Value(guardId),
      entryType: Value(entryType),
      timestamp: Value(timestamp),
      vehicleInfo: vehicleInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleInfo),
      personInfo: personInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(personInfo),
      verificationMethod: Value(verificationMethod),
      verificationStatus: Value(verificationStatus),
      denialReason: denialReason == null && nullToAbsent
          ? const Value.absent()
          : Value(denialReason),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      synced: Value(synced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryLog(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      guardId: serializer.fromJson<String>(json['guardId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      vehicleInfo: serializer.fromJson<String?>(json['vehicleInfo']),
      personInfo: serializer.fromJson<String?>(json['personInfo']),
      verificationMethod:
          serializer.fromJson<String>(json['verificationMethod']),
      verificationStatus:
          serializer.fromJson<String>(json['verificationStatus']),
      denialReason: serializer.fromJson<String?>(json['denialReason']),
      notes: serializer.fromJson<String?>(json['notes']),
      synced: serializer.fromJson<bool>(json['synced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'guardId': serializer.toJson<String>(guardId),
      'entryType': serializer.toJson<String>(entryType),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'vehicleInfo': serializer.toJson<String?>(vehicleInfo),
      'personInfo': serializer.toJson<String?>(personInfo),
      'verificationMethod': serializer.toJson<String>(verificationMethod),
      'verificationStatus': serializer.toJson<String>(verificationStatus),
      'denialReason': serializer.toJson<String?>(denialReason),
      'notes': serializer.toJson<String?>(notes),
      'synced': serializer.toJson<bool>(synced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryLog copyWith(
          {String? id,
          String? tenantId,
          String? guardId,
          String? entryType,
          DateTime? timestamp,
          Value<String?> vehicleInfo = const Value.absent(),
          Value<String?> personInfo = const Value.absent(),
          String? verificationMethod,
          String? verificationStatus,
          Value<String?> denialReason = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? synced,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EntryLog(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        guardId: guardId ?? this.guardId,
        entryType: entryType ?? this.entryType,
        timestamp: timestamp ?? this.timestamp,
        vehicleInfo: vehicleInfo.present ? vehicleInfo.value : this.vehicleInfo,
        personInfo: personInfo.present ? personInfo.value : this.personInfo,
        verificationMethod: verificationMethod ?? this.verificationMethod,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        denialReason:
            denialReason.present ? denialReason.value : this.denialReason,
        notes: notes.present ? notes.value : this.notes,
        synced: synced ?? this.synced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  EntryLog copyWithCompanion(EntryLogsCompanion data) {
    return EntryLog(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      guardId: data.guardId.present ? data.guardId.value : this.guardId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      vehicleInfo:
          data.vehicleInfo.present ? data.vehicleInfo.value : this.vehicleInfo,
      personInfo:
          data.personInfo.present ? data.personInfo.value : this.personInfo,
      verificationMethod: data.verificationMethod.present
          ? data.verificationMethod.value
          : this.verificationMethod,
      verificationStatus: data.verificationStatus.present
          ? data.verificationStatus.value
          : this.verificationStatus,
      denialReason: data.denialReason.present
          ? data.denialReason.value
          : this.denialReason,
      notes: data.notes.present ? data.notes.value : this.notes,
      synced: data.synced.present ? data.synced.value : this.synced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryLog(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('guardId: $guardId, ')
          ..write('entryType: $entryType, ')
          ..write('timestamp: $timestamp, ')
          ..write('vehicleInfo: $vehicleInfo, ')
          ..write('personInfo: $personInfo, ')
          ..write('verificationMethod: $verificationMethod, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('denialReason: $denialReason, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      guardId,
      entryType,
      timestamp,
      vehicleInfo,
      personInfo,
      verificationMethod,
      verificationStatus,
      denialReason,
      notes,
      synced,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryLog &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.guardId == this.guardId &&
          other.entryType == this.entryType &&
          other.timestamp == this.timestamp &&
          other.vehicleInfo == this.vehicleInfo &&
          other.personInfo == this.personInfo &&
          other.verificationMethod == this.verificationMethod &&
          other.verificationStatus == this.verificationStatus &&
          other.denialReason == this.denialReason &&
          other.notes == this.notes &&
          other.synced == this.synced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntryLogsCompanion extends UpdateCompanion<EntryLog> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> guardId;
  final Value<String> entryType;
  final Value<DateTime> timestamp;
  final Value<String?> vehicleInfo;
  final Value<String?> personInfo;
  final Value<String> verificationMethod;
  final Value<String> verificationStatus;
  final Value<String?> denialReason;
  final Value<String?> notes;
  final Value<bool> synced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EntryLogsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.guardId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.vehicleInfo = const Value.absent(),
    this.personInfo = const Value.absent(),
    this.verificationMethod = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.denialReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryLogsCompanion.insert({
    required String id,
    required String tenantId,
    required String guardId,
    required String entryType,
    required DateTime timestamp,
    this.vehicleInfo = const Value.absent(),
    this.personInfo = const Value.absent(),
    required String verificationMethod,
    required String verificationStatus,
    this.denialReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.synced = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        guardId = Value(guardId),
        entryType = Value(entryType),
        timestamp = Value(timestamp),
        verificationMethod = Value(verificationMethod),
        verificationStatus = Value(verificationStatus),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EntryLog> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? guardId,
    Expression<String>? entryType,
    Expression<DateTime>? timestamp,
    Expression<String>? vehicleInfo,
    Expression<String>? personInfo,
    Expression<String>? verificationMethod,
    Expression<String>? verificationStatus,
    Expression<String>? denialReason,
    Expression<String>? notes,
    Expression<bool>? synced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (guardId != null) 'guard_id': guardId,
      if (entryType != null) 'entry_type': entryType,
      if (timestamp != null) 'timestamp': timestamp,
      if (vehicleInfo != null) 'vehicle_info': vehicleInfo,
      if (personInfo != null) 'person_info': personInfo,
      if (verificationMethod != null) 'verification_method': verificationMethod,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (denialReason != null) 'denial_reason': denialReason,
      if (notes != null) 'notes': notes,
      if (synced != null) 'synced': synced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? guardId,
      Value<String>? entryType,
      Value<DateTime>? timestamp,
      Value<String?>? vehicleInfo,
      Value<String?>? personInfo,
      Value<String>? verificationMethod,
      Value<String>? verificationStatus,
      Value<String?>? denialReason,
      Value<String?>? notes,
      Value<bool>? synced,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return EntryLogsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      guardId: guardId ?? this.guardId,
      entryType: entryType ?? this.entryType,
      timestamp: timestamp ?? this.timestamp,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      personInfo: personInfo ?? this.personInfo,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      denialReason: denialReason ?? this.denialReason,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (guardId.present) {
      map['guard_id'] = Variable<String>(guardId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (vehicleInfo.present) {
      map['vehicle_info'] = Variable<String>(vehicleInfo.value);
    }
    if (personInfo.present) {
      map['person_info'] = Variable<String>(personInfo.value);
    }
    if (verificationMethod.present) {
      map['verification_method'] = Variable<String>(verificationMethod.value);
    }
    if (verificationStatus.present) {
      map['verification_status'] = Variable<String>(verificationStatus.value);
    }
    if (denialReason.present) {
      map['denial_reason'] = Variable<String>(denialReason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryLogsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('guardId: $guardId, ')
          ..write('entryType: $entryType, ')
          ..write('timestamp: $timestamp, ')
          ..write('vehicleInfo: $vehicleInfo, ')
          ..write('personInfo: $personInfo, ')
          ..write('verificationMethod: $verificationMethod, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('denialReason: $denialReason, ')
          ..write('notes: $notes, ')
          ..write('synced: $synced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RfidStickersTable extends RfidStickers
    with TableInfo<$RfidStickersTable, RfidSticker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RfidStickersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stickerCodeMeta =
      const VerificationMeta('stickerCode');
  @override
  late final GeneratedColumn<String> stickerCode = GeneratedColumn<String>(
      'sticker_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehiclePlateMeta =
      const VerificationMeta('vehiclePlate');
  @override
  late final GeneratedColumn<String> vehiclePlate = GeneratedColumn<String>(
      'vehicle_plate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleMakeMeta =
      const VerificationMeta('vehicleMake');
  @override
  late final GeneratedColumn<String> vehicleMake = GeneratedColumn<String>(
      'vehicle_make', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        stickerCode,
        householdId,
        vehiclePlate,
        vehicleMake,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rfid_stickers';
  @override
  VerificationContext validateIntegrity(Insertable<RfidSticker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('sticker_code')) {
      context.handle(
          _stickerCodeMeta,
          stickerCode.isAcceptableOrUnknown(
              data['sticker_code']!, _stickerCodeMeta));
    } else if (isInserting) {
      context.missing(_stickerCodeMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('vehicle_plate')) {
      context.handle(
          _vehiclePlateMeta,
          vehiclePlate.isAcceptableOrUnknown(
              data['vehicle_plate']!, _vehiclePlateMeta));
    } else if (isInserting) {
      context.missing(_vehiclePlateMeta);
    }
    if (data.containsKey('vehicle_make')) {
      context.handle(
          _vehicleMakeMeta,
          vehicleMake.isAcceptableOrUnknown(
              data['vehicle_make']!, _vehicleMakeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {stickerCode},
      ];
  @override
  RfidSticker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RfidSticker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      stickerCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sticker_code'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      vehiclePlate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_plate'])!,
      vehicleMake: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_make']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RfidStickersTable createAlias(String alias) {
    return $RfidStickersTable(attachedDatabase, alias);
  }
}

class RfidSticker extends DataClass implements Insertable<RfidSticker> {
  final String id;
  final String tenantId;
  final String stickerCode;
  final String householdId;
  final String vehiclePlate;
  final String? vehicleMake;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RfidSticker(
      {required this.id,
      required this.tenantId,
      required this.stickerCode,
      required this.householdId,
      required this.vehiclePlate,
      this.vehicleMake,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['sticker_code'] = Variable<String>(stickerCode);
    map['household_id'] = Variable<String>(householdId);
    map['vehicle_plate'] = Variable<String>(vehiclePlate);
    if (!nullToAbsent || vehicleMake != null) {
      map['vehicle_make'] = Variable<String>(vehicleMake);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RfidStickersCompanion toCompanion(bool nullToAbsent) {
    return RfidStickersCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      stickerCode: Value(stickerCode),
      householdId: Value(householdId),
      vehiclePlate: Value(vehiclePlate),
      vehicleMake: vehicleMake == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleMake),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RfidSticker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RfidSticker(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      stickerCode: serializer.fromJson<String>(json['stickerCode']),
      householdId: serializer.fromJson<String>(json['householdId']),
      vehiclePlate: serializer.fromJson<String>(json['vehiclePlate']),
      vehicleMake: serializer.fromJson<String?>(json['vehicleMake']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'stickerCode': serializer.toJson<String>(stickerCode),
      'householdId': serializer.toJson<String>(householdId),
      'vehiclePlate': serializer.toJson<String>(vehiclePlate),
      'vehicleMake': serializer.toJson<String?>(vehicleMake),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RfidSticker copyWith(
          {String? id,
          String? tenantId,
          String? stickerCode,
          String? householdId,
          String? vehiclePlate,
          Value<String?> vehicleMake = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RfidSticker(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        stickerCode: stickerCode ?? this.stickerCode,
        householdId: householdId ?? this.householdId,
        vehiclePlate: vehiclePlate ?? this.vehiclePlate,
        vehicleMake: vehicleMake.present ? vehicleMake.value : this.vehicleMake,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RfidSticker copyWithCompanion(RfidStickersCompanion data) {
    return RfidSticker(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      stickerCode:
          data.stickerCode.present ? data.stickerCode.value : this.stickerCode,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      vehiclePlate: data.vehiclePlate.present
          ? data.vehiclePlate.value
          : this.vehiclePlate,
      vehicleMake:
          data.vehicleMake.present ? data.vehicleMake.value : this.vehicleMake,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RfidSticker(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('stickerCode: $stickerCode, ')
          ..write('householdId: $householdId, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('vehicleMake: $vehicleMake, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, stickerCode, householdId,
      vehiclePlate, vehicleMake, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RfidSticker &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.stickerCode == this.stickerCode &&
          other.householdId == this.householdId &&
          other.vehiclePlate == this.vehiclePlate &&
          other.vehicleMake == this.vehicleMake &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RfidStickersCompanion extends UpdateCompanion<RfidSticker> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> stickerCode;
  final Value<String> householdId;
  final Value<String> vehiclePlate;
  final Value<String?> vehicleMake;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RfidStickersCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.stickerCode = const Value.absent(),
    this.householdId = const Value.absent(),
    this.vehiclePlate = const Value.absent(),
    this.vehicleMake = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RfidStickersCompanion.insert({
    required String id,
    required String tenantId,
    required String stickerCode,
    required String householdId,
    required String vehiclePlate,
    this.vehicleMake = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        stickerCode = Value(stickerCode),
        householdId = Value(householdId),
        vehiclePlate = Value(vehiclePlate),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RfidSticker> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? stickerCode,
    Expression<String>? householdId,
    Expression<String>? vehiclePlate,
    Expression<String>? vehicleMake,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (stickerCode != null) 'sticker_code': stickerCode,
      if (householdId != null) 'household_id': householdId,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (vehicleMake != null) 'vehicle_make': vehicleMake,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RfidStickersCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? stickerCode,
      Value<String>? householdId,
      Value<String>? vehiclePlate,
      Value<String?>? vehicleMake,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RfidStickersCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      stickerCode: stickerCode ?? this.stickerCode,
      householdId: householdId ?? this.householdId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (stickerCode.present) {
      map['sticker_code'] = Variable<String>(stickerCode.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (vehiclePlate.present) {
      map['vehicle_plate'] = Variable<String>(vehiclePlate.value);
    }
    if (vehicleMake.present) {
      map['vehicle_make'] = Variable<String>(vehicleMake.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RfidStickersCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('stickerCode: $stickerCode, ')
          ..write('householdId: $householdId, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('vehicleMake: $vehicleMake, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreRegisteredGuestsTable extends PreRegisteredGuests
    with TableInfo<$PreRegisteredGuestsTable, PreRegisteredGuest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreRegisteredGuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guestNameMeta =
      const VerificationMeta('guestName');
  @override
  late final GeneratedColumn<String> guestName = GeneratedColumn<String>(
      'guest_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guestContactMeta =
      const VerificationMeta('guestContact');
  @override
  late final GeneratedColumn<String> guestContact = GeneratedColumn<String>(
      'guest_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationHoursMeta =
      const VerificationMeta('durationHours');
  @override
  late final GeneratedColumn<int> durationHours = GeneratedColumn<int>(
      'duration_hours', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehiclePlateMeta =
      const VerificationMeta('vehiclePlate');
  @override
  late final GeneratedColumn<String> vehiclePlate = GeneratedColumn<String>(
      'vehicle_plate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checkedInAtMeta =
      const VerificationMeta('checkedInAt');
  @override
  late final GeneratedColumn<DateTime> checkedInAt = GeneratedColumn<DateTime>(
      'checked_in_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _entryLogIdMeta =
      const VerificationMeta('entryLogId');
  @override
  late final GeneratedColumn<String> entryLogId = GeneratedColumn<String>(
      'entry_log_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        guestName,
        guestContact,
        durationHours,
        purpose,
        vehiclePlate,
        status,
        checkedInAt,
        entryLogId,
        createdBy,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_registered_guests';
  @override
  VerificationContext validateIntegrity(Insertable<PreRegisteredGuest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('guest_name')) {
      context.handle(_guestNameMeta,
          guestName.isAcceptableOrUnknown(data['guest_name']!, _guestNameMeta));
    } else if (isInserting) {
      context.missing(_guestNameMeta);
    }
    if (data.containsKey('guest_contact')) {
      context.handle(
          _guestContactMeta,
          guestContact.isAcceptableOrUnknown(
              data['guest_contact']!, _guestContactMeta));
    }
    if (data.containsKey('duration_hours')) {
      context.handle(
          _durationHoursMeta,
          durationHours.isAcceptableOrUnknown(
              data['duration_hours']!, _durationHoursMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('vehicle_plate')) {
      context.handle(
          _vehiclePlateMeta,
          vehiclePlate.isAcceptableOrUnknown(
              data['vehicle_plate']!, _vehiclePlateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checked_in_at')) {
      context.handle(
          _checkedInAtMeta,
          checkedInAt.isAcceptableOrUnknown(
              data['checked_in_at']!, _checkedInAtMeta));
    }
    if (data.containsKey('entry_log_id')) {
      context.handle(
          _entryLogIdMeta,
          entryLogId.isAcceptableOrUnknown(
              data['entry_log_id']!, _entryLogIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreRegisteredGuest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreRegisteredGuest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      guestName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guest_name'])!,
      guestContact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guest_contact']),
      durationHours: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_hours']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      vehiclePlate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_plate']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      checkedInAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}checked_in_at']),
      entryLogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_log_id']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PreRegisteredGuestsTable createAlias(String alias) {
    return $PreRegisteredGuestsTable(attachedDatabase, alias);
  }
}

class PreRegisteredGuest extends DataClass
    implements Insertable<PreRegisteredGuest> {
  final String id;
  final String householdId;
  final String guestName;
  final String? guestContact;
  final int? durationHours;
  final String purpose;
  final String? vehiclePlate;
  final String status;
  final DateTime? checkedInAt;
  final String? entryLogId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PreRegisteredGuest(
      {required this.id,
      required this.householdId,
      required this.guestName,
      this.guestContact,
      this.durationHours,
      required this.purpose,
      this.vehiclePlate,
      required this.status,
      this.checkedInAt,
      this.entryLogId,
      required this.createdBy,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['guest_name'] = Variable<String>(guestName);
    if (!nullToAbsent || guestContact != null) {
      map['guest_contact'] = Variable<String>(guestContact);
    }
    if (!nullToAbsent || durationHours != null) {
      map['duration_hours'] = Variable<int>(durationHours);
    }
    map['purpose'] = Variable<String>(purpose);
    if (!nullToAbsent || vehiclePlate != null) {
      map['vehicle_plate'] = Variable<String>(vehiclePlate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || checkedInAt != null) {
      map['checked_in_at'] = Variable<DateTime>(checkedInAt);
    }
    if (!nullToAbsent || entryLogId != null) {
      map['entry_log_id'] = Variable<String>(entryLogId);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PreRegisteredGuestsCompanion toCompanion(bool nullToAbsent) {
    return PreRegisteredGuestsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      guestName: Value(guestName),
      guestContact: guestContact == null && nullToAbsent
          ? const Value.absent()
          : Value(guestContact),
      durationHours: durationHours == null && nullToAbsent
          ? const Value.absent()
          : Value(durationHours),
      purpose: Value(purpose),
      vehiclePlate: vehiclePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(vehiclePlate),
      status: Value(status),
      checkedInAt: checkedInAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedInAt),
      entryLogId: entryLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryLogId),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PreRegisteredGuest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreRegisteredGuest(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      guestName: serializer.fromJson<String>(json['guestName']),
      guestContact: serializer.fromJson<String?>(json['guestContact']),
      durationHours: serializer.fromJson<int?>(json['durationHours']),
      purpose: serializer.fromJson<String>(json['purpose']),
      vehiclePlate: serializer.fromJson<String?>(json['vehiclePlate']),
      status: serializer.fromJson<String>(json['status']),
      checkedInAt: serializer.fromJson<DateTime?>(json['checkedInAt']),
      entryLogId: serializer.fromJson<String?>(json['entryLogId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'guestName': serializer.toJson<String>(guestName),
      'guestContact': serializer.toJson<String?>(guestContact),
      'durationHours': serializer.toJson<int?>(durationHours),
      'purpose': serializer.toJson<String>(purpose),
      'vehiclePlate': serializer.toJson<String?>(vehiclePlate),
      'status': serializer.toJson<String>(status),
      'checkedInAt': serializer.toJson<DateTime?>(checkedInAt),
      'entryLogId': serializer.toJson<String?>(entryLogId),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PreRegisteredGuest copyWith(
          {String? id,
          String? householdId,
          String? guestName,
          Value<String?> guestContact = const Value.absent(),
          Value<int?> durationHours = const Value.absent(),
          String? purpose,
          Value<String?> vehiclePlate = const Value.absent(),
          String? status,
          Value<DateTime?> checkedInAt = const Value.absent(),
          Value<String?> entryLogId = const Value.absent(),
          String? createdBy,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PreRegisteredGuest(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        guestName: guestName ?? this.guestName,
        guestContact:
            guestContact.present ? guestContact.value : this.guestContact,
        durationHours:
            durationHours.present ? durationHours.value : this.durationHours,
        purpose: purpose ?? this.purpose,
        vehiclePlate:
            vehiclePlate.present ? vehiclePlate.value : this.vehiclePlate,
        status: status ?? this.status,
        checkedInAt: checkedInAt.present ? checkedInAt.value : this.checkedInAt,
        entryLogId: entryLogId.present ? entryLogId.value : this.entryLogId,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PreRegisteredGuest copyWithCompanion(PreRegisteredGuestsCompanion data) {
    return PreRegisteredGuest(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      guestName: data.guestName.present ? data.guestName.value : this.guestName,
      guestContact: data.guestContact.present
          ? data.guestContact.value
          : this.guestContact,
      durationHours: data.durationHours.present
          ? data.durationHours.value
          : this.durationHours,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      vehiclePlate: data.vehiclePlate.present
          ? data.vehiclePlate.value
          : this.vehiclePlate,
      status: data.status.present ? data.status.value : this.status,
      checkedInAt:
          data.checkedInAt.present ? data.checkedInAt.value : this.checkedInAt,
      entryLogId:
          data.entryLogId.present ? data.entryLogId.value : this.entryLogId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreRegisteredGuest(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('guestName: $guestName, ')
          ..write('guestContact: $guestContact, ')
          ..write('durationHours: $durationHours, ')
          ..write('purpose: $purpose, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('status: $status, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      guestName,
      guestContact,
      durationHours,
      purpose,
      vehiclePlate,
      status,
      checkedInAt,
      entryLogId,
      createdBy,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreRegisteredGuest &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.guestName == this.guestName &&
          other.guestContact == this.guestContact &&
          other.durationHours == this.durationHours &&
          other.purpose == this.purpose &&
          other.vehiclePlate == this.vehiclePlate &&
          other.status == this.status &&
          other.checkedInAt == this.checkedInAt &&
          other.entryLogId == this.entryLogId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PreRegisteredGuestsCompanion extends UpdateCompanion<PreRegisteredGuest> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> guestName;
  final Value<String?> guestContact;
  final Value<int?> durationHours;
  final Value<String> purpose;
  final Value<String?> vehiclePlate;
  final Value<String> status;
  final Value<DateTime?> checkedInAt;
  final Value<String?> entryLogId;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PreRegisteredGuestsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.guestName = const Value.absent(),
    this.guestContact = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.purpose = const Value.absent(),
    this.vehiclePlate = const Value.absent(),
    this.status = const Value.absent(),
    this.checkedInAt = const Value.absent(),
    this.entryLogId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreRegisteredGuestsCompanion.insert({
    required String id,
    required String householdId,
    required String guestName,
    this.guestContact = const Value.absent(),
    this.durationHours = const Value.absent(),
    required String purpose,
    this.vehiclePlate = const Value.absent(),
    required String status,
    this.checkedInAt = const Value.absent(),
    this.entryLogId = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        guestName = Value(guestName),
        purpose = Value(purpose),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PreRegisteredGuest> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? guestName,
    Expression<String>? guestContact,
    Expression<int>? durationHours,
    Expression<String>? purpose,
    Expression<String>? vehiclePlate,
    Expression<String>? status,
    Expression<DateTime>? checkedInAt,
    Expression<String>? entryLogId,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (guestName != null) 'guest_name': guestName,
      if (guestContact != null) 'guest_contact': guestContact,
      if (durationHours != null) 'duration_hours': durationHours,
      if (purpose != null) 'purpose': purpose,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (status != null) 'status': status,
      if (checkedInAt != null) 'checked_in_at': checkedInAt,
      if (entryLogId != null) 'entry_log_id': entryLogId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreRegisteredGuestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? guestName,
      Value<String?>? guestContact,
      Value<int?>? durationHours,
      Value<String>? purpose,
      Value<String?>? vehiclePlate,
      Value<String>? status,
      Value<DateTime?>? checkedInAt,
      Value<String?>? entryLogId,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PreRegisteredGuestsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      guestName: guestName ?? this.guestName,
      guestContact: guestContact ?? this.guestContact,
      durationHours: durationHours ?? this.durationHours,
      purpose: purpose ?? this.purpose,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      entryLogId: entryLogId ?? this.entryLogId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (guestName.present) {
      map['guest_name'] = Variable<String>(guestName.value);
    }
    if (guestContact.present) {
      map['guest_contact'] = Variable<String>(guestContact.value);
    }
    if (durationHours.present) {
      map['duration_hours'] = Variable<int>(durationHours.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (vehiclePlate.present) {
      map['vehicle_plate'] = Variable<String>(vehiclePlate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checkedInAt.present) {
      map['checked_in_at'] = Variable<DateTime>(checkedInAt.value);
    }
    if (entryLogId.present) {
      map['entry_log_id'] = Variable<String>(entryLogId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreRegisteredGuestsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('guestName: $guestName, ')
          ..write('guestContact: $guestContact, ')
          ..write('durationHours: $durationHours, ')
          ..write('purpose: $purpose, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('status: $status, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuestLogsTable extends GuestLogs
    with TableInfo<$GuestLogsTable, GuestLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuestLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryLogIdMeta =
      const VerificationMeta('entryLogId');
  @override
  late final GeneratedColumn<String> entryLogId = GeneratedColumn<String>(
      'entry_log_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guestNameMeta =
      const VerificationMeta('guestName');
  @override
  late final GeneratedColumn<String> guestName = GeneratedColumn<String>(
      'guest_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verificationMethodMeta =
      const VerificationMeta('verificationMethod');
  @override
  late final GeneratedColumn<String> verificationMethod =
      GeneratedColumn<String>('verification_method', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdContactedMeta =
      const VerificationMeta('householdContacted');
  @override
  late final GeneratedColumn<bool> householdContacted = GeneratedColumn<bool>(
      'household_contacted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("household_contacted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _householdResponseMeta =
      const VerificationMeta('householdResponse');
  @override
  late final GeneratedColumn<String> householdResponse =
      GeneratedColumn<String>('household_response', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exitTimestampMeta =
      const VerificationMeta('exitTimestamp');
  @override
  late final GeneratedColumn<DateTime> exitTimestamp =
      GeneratedColumn<DateTime>('exit_timestamp', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _visitDurationMinutesMeta =
      const VerificationMeta('visitDurationMinutes');
  @override
  late final GeneratedColumn<int> visitDurationMinutes = GeneratedColumn<int>(
      'visit_duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryLogId,
        guestName,
        householdId,
        purpose,
        verificationMethod,
        householdContacted,
        householdResponse,
        exitTimestamp,
        visitDurationMinutes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guest_logs';
  @override
  VerificationContext validateIntegrity(Insertable<GuestLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_log_id')) {
      context.handle(
          _entryLogIdMeta,
          entryLogId.isAcceptableOrUnknown(
              data['entry_log_id']!, _entryLogIdMeta));
    } else if (isInserting) {
      context.missing(_entryLogIdMeta);
    }
    if (data.containsKey('guest_name')) {
      context.handle(_guestNameMeta,
          guestName.isAcceptableOrUnknown(data['guest_name']!, _guestNameMeta));
    } else if (isInserting) {
      context.missing(_guestNameMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('verification_method')) {
      context.handle(
          _verificationMethodMeta,
          verificationMethod.isAcceptableOrUnknown(
              data['verification_method']!, _verificationMethodMeta));
    } else if (isInserting) {
      context.missing(_verificationMethodMeta);
    }
    if (data.containsKey('household_contacted')) {
      context.handle(
          _householdContactedMeta,
          householdContacted.isAcceptableOrUnknown(
              data['household_contacted']!, _householdContactedMeta));
    }
    if (data.containsKey('household_response')) {
      context.handle(
          _householdResponseMeta,
          householdResponse.isAcceptableOrUnknown(
              data['household_response']!, _householdResponseMeta));
    }
    if (data.containsKey('exit_timestamp')) {
      context.handle(
          _exitTimestampMeta,
          exitTimestamp.isAcceptableOrUnknown(
              data['exit_timestamp']!, _exitTimestampMeta));
    }
    if (data.containsKey('visit_duration_minutes')) {
      context.handle(
          _visitDurationMinutesMeta,
          visitDurationMinutes.isAcceptableOrUnknown(
              data['visit_duration_minutes']!, _visitDurationMinutesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GuestLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuestLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryLogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_log_id'])!,
      guestName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guest_name'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      verificationMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verification_method'])!,
      householdContacted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}household_contacted'])!,
      householdResponse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}household_response']),
      exitTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}exit_timestamp']),
      visitDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}visit_duration_minutes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GuestLogsTable createAlias(String alias) {
    return $GuestLogsTable(attachedDatabase, alias);
  }
}

class GuestLog extends DataClass implements Insertable<GuestLog> {
  final String id;
  final String entryLogId;
  final String guestName;
  final String householdId;
  final String purpose;
  final String verificationMethod;
  final bool householdContacted;
  final String? householdResponse;
  final DateTime? exitTimestamp;
  final int? visitDurationMinutes;
  final DateTime createdAt;
  const GuestLog(
      {required this.id,
      required this.entryLogId,
      required this.guestName,
      required this.householdId,
      required this.purpose,
      required this.verificationMethod,
      required this.householdContacted,
      this.householdResponse,
      this.exitTimestamp,
      this.visitDurationMinutes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_log_id'] = Variable<String>(entryLogId);
    map['guest_name'] = Variable<String>(guestName);
    map['household_id'] = Variable<String>(householdId);
    map['purpose'] = Variable<String>(purpose);
    map['verification_method'] = Variable<String>(verificationMethod);
    map['household_contacted'] = Variable<bool>(householdContacted);
    if (!nullToAbsent || householdResponse != null) {
      map['household_response'] = Variable<String>(householdResponse);
    }
    if (!nullToAbsent || exitTimestamp != null) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp);
    }
    if (!nullToAbsent || visitDurationMinutes != null) {
      map['visit_duration_minutes'] = Variable<int>(visitDurationMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GuestLogsCompanion toCompanion(bool nullToAbsent) {
    return GuestLogsCompanion(
      id: Value(id),
      entryLogId: Value(entryLogId),
      guestName: Value(guestName),
      householdId: Value(householdId),
      purpose: Value(purpose),
      verificationMethod: Value(verificationMethod),
      householdContacted: Value(householdContacted),
      householdResponse: householdResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(householdResponse),
      exitTimestamp: exitTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(exitTimestamp),
      visitDurationMinutes: visitDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(visitDurationMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory GuestLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuestLog(
      id: serializer.fromJson<String>(json['id']),
      entryLogId: serializer.fromJson<String>(json['entryLogId']),
      guestName: serializer.fromJson<String>(json['guestName']),
      householdId: serializer.fromJson<String>(json['householdId']),
      purpose: serializer.fromJson<String>(json['purpose']),
      verificationMethod:
          serializer.fromJson<String>(json['verificationMethod']),
      householdContacted: serializer.fromJson<bool>(json['householdContacted']),
      householdResponse:
          serializer.fromJson<String?>(json['householdResponse']),
      exitTimestamp: serializer.fromJson<DateTime?>(json['exitTimestamp']),
      visitDurationMinutes:
          serializer.fromJson<int?>(json['visitDurationMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryLogId': serializer.toJson<String>(entryLogId),
      'guestName': serializer.toJson<String>(guestName),
      'householdId': serializer.toJson<String>(householdId),
      'purpose': serializer.toJson<String>(purpose),
      'verificationMethod': serializer.toJson<String>(verificationMethod),
      'householdContacted': serializer.toJson<bool>(householdContacted),
      'householdResponse': serializer.toJson<String?>(householdResponse),
      'exitTimestamp': serializer.toJson<DateTime?>(exitTimestamp),
      'visitDurationMinutes': serializer.toJson<int?>(visitDurationMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GuestLog copyWith(
          {String? id,
          String? entryLogId,
          String? guestName,
          String? householdId,
          String? purpose,
          String? verificationMethod,
          bool? householdContacted,
          Value<String?> householdResponse = const Value.absent(),
          Value<DateTime?> exitTimestamp = const Value.absent(),
          Value<int?> visitDurationMinutes = const Value.absent(),
          DateTime? createdAt}) =>
      GuestLog(
        id: id ?? this.id,
        entryLogId: entryLogId ?? this.entryLogId,
        guestName: guestName ?? this.guestName,
        householdId: householdId ?? this.householdId,
        purpose: purpose ?? this.purpose,
        verificationMethod: verificationMethod ?? this.verificationMethod,
        householdContacted: householdContacted ?? this.householdContacted,
        householdResponse: householdResponse.present
            ? householdResponse.value
            : this.householdResponse,
        exitTimestamp:
            exitTimestamp.present ? exitTimestamp.value : this.exitTimestamp,
        visitDurationMinutes: visitDurationMinutes.present
            ? visitDurationMinutes.value
            : this.visitDurationMinutes,
        createdAt: createdAt ?? this.createdAt,
      );
  GuestLog copyWithCompanion(GuestLogsCompanion data) {
    return GuestLog(
      id: data.id.present ? data.id.value : this.id,
      entryLogId:
          data.entryLogId.present ? data.entryLogId.value : this.entryLogId,
      guestName: data.guestName.present ? data.guestName.value : this.guestName,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      verificationMethod: data.verificationMethod.present
          ? data.verificationMethod.value
          : this.verificationMethod,
      householdContacted: data.householdContacted.present
          ? data.householdContacted.value
          : this.householdContacted,
      householdResponse: data.householdResponse.present
          ? data.householdResponse.value
          : this.householdResponse,
      exitTimestamp: data.exitTimestamp.present
          ? data.exitTimestamp.value
          : this.exitTimestamp,
      visitDurationMinutes: data.visitDurationMinutes.present
          ? data.visitDurationMinutes.value
          : this.visitDurationMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuestLog(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('guestName: $guestName, ')
          ..write('householdId: $householdId, ')
          ..write('purpose: $purpose, ')
          ..write('verificationMethod: $verificationMethod, ')
          ..write('householdContacted: $householdContacted, ')
          ..write('householdResponse: $householdResponse, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('visitDurationMinutes: $visitDurationMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entryLogId,
      guestName,
      householdId,
      purpose,
      verificationMethod,
      householdContacted,
      householdResponse,
      exitTimestamp,
      visitDurationMinutes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuestLog &&
          other.id == this.id &&
          other.entryLogId == this.entryLogId &&
          other.guestName == this.guestName &&
          other.householdId == this.householdId &&
          other.purpose == this.purpose &&
          other.verificationMethod == this.verificationMethod &&
          other.householdContacted == this.householdContacted &&
          other.householdResponse == this.householdResponse &&
          other.exitTimestamp == this.exitTimestamp &&
          other.visitDurationMinutes == this.visitDurationMinutes &&
          other.createdAt == this.createdAt);
}

class GuestLogsCompanion extends UpdateCompanion<GuestLog> {
  final Value<String> id;
  final Value<String> entryLogId;
  final Value<String> guestName;
  final Value<String> householdId;
  final Value<String> purpose;
  final Value<String> verificationMethod;
  final Value<bool> householdContacted;
  final Value<String?> householdResponse;
  final Value<DateTime?> exitTimestamp;
  final Value<int?> visitDurationMinutes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GuestLogsCompanion({
    this.id = const Value.absent(),
    this.entryLogId = const Value.absent(),
    this.guestName = const Value.absent(),
    this.householdId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.verificationMethod = const Value.absent(),
    this.householdContacted = const Value.absent(),
    this.householdResponse = const Value.absent(),
    this.exitTimestamp = const Value.absent(),
    this.visitDurationMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuestLogsCompanion.insert({
    required String id,
    required String entryLogId,
    required String guestName,
    required String householdId,
    required String purpose,
    required String verificationMethod,
    this.householdContacted = const Value.absent(),
    this.householdResponse = const Value.absent(),
    this.exitTimestamp = const Value.absent(),
    this.visitDurationMinutes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryLogId = Value(entryLogId),
        guestName = Value(guestName),
        householdId = Value(householdId),
        purpose = Value(purpose),
        verificationMethod = Value(verificationMethod),
        createdAt = Value(createdAt);
  static Insertable<GuestLog> custom({
    Expression<String>? id,
    Expression<String>? entryLogId,
    Expression<String>? guestName,
    Expression<String>? householdId,
    Expression<String>? purpose,
    Expression<String>? verificationMethod,
    Expression<bool>? householdContacted,
    Expression<String>? householdResponse,
    Expression<DateTime>? exitTimestamp,
    Expression<int>? visitDurationMinutes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryLogId != null) 'entry_log_id': entryLogId,
      if (guestName != null) 'guest_name': guestName,
      if (householdId != null) 'household_id': householdId,
      if (purpose != null) 'purpose': purpose,
      if (verificationMethod != null) 'verification_method': verificationMethod,
      if (householdContacted != null) 'household_contacted': householdContacted,
      if (householdResponse != null) 'household_response': householdResponse,
      if (exitTimestamp != null) 'exit_timestamp': exitTimestamp,
      if (visitDurationMinutes != null)
        'visit_duration_minutes': visitDurationMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuestLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryLogId,
      Value<String>? guestName,
      Value<String>? householdId,
      Value<String>? purpose,
      Value<String>? verificationMethod,
      Value<bool>? householdContacted,
      Value<String?>? householdResponse,
      Value<DateTime?>? exitTimestamp,
      Value<int?>? visitDurationMinutes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GuestLogsCompanion(
      id: id ?? this.id,
      entryLogId: entryLogId ?? this.entryLogId,
      guestName: guestName ?? this.guestName,
      householdId: householdId ?? this.householdId,
      purpose: purpose ?? this.purpose,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      householdContacted: householdContacted ?? this.householdContacted,
      householdResponse: householdResponse ?? this.householdResponse,
      exitTimestamp: exitTimestamp ?? this.exitTimestamp,
      visitDurationMinutes: visitDurationMinutes ?? this.visitDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryLogId.present) {
      map['entry_log_id'] = Variable<String>(entryLogId.value);
    }
    if (guestName.present) {
      map['guest_name'] = Variable<String>(guestName.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (verificationMethod.present) {
      map['verification_method'] = Variable<String>(verificationMethod.value);
    }
    if (householdContacted.present) {
      map['household_contacted'] = Variable<bool>(householdContacted.value);
    }
    if (householdResponse.present) {
      map['household_response'] = Variable<String>(householdResponse.value);
    }
    if (exitTimestamp.present) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp.value);
    }
    if (visitDurationMinutes.present) {
      map['visit_duration_minutes'] = Variable<int>(visitDurationMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuestLogsCompanion(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('guestName: $guestName, ')
          ..write('householdId: $householdId, ')
          ..write('purpose: $purpose, ')
          ..write('verificationMethod: $verificationMethod, ')
          ..write('householdContacted: $householdContacted, ')
          ..write('householdResponse: $householdResponse, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('visitDurationMinutes: $visitDurationMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveryLogsTable extends DeliveryLogs
    with TableInfo<$DeliveryLogsTable, DeliveryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryLogIdMeta =
      const VerificationMeta('entryLogId');
  @override
  late final GeneratedColumn<String> entryLogId = GeneratedColumn<String>(
      'entry_log_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deliveryCompanyMeta =
      const VerificationMeta('deliveryCompany');
  @override
  late final GeneratedColumn<String> deliveryCompany = GeneratedColumn<String>(
      'delivery_company', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipientHouseholdIdMeta =
      const VerificationMeta('recipientHouseholdId');
  @override
  late final GeneratedColumn<String> recipientHouseholdId =
      GeneratedColumn<String>('recipient_household_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packageTypeMeta =
      const VerificationMeta('packageType');
  @override
  late final GeneratedColumn<String> packageType = GeneratedColumn<String>(
      'package_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packageDescriptionMeta =
      const VerificationMeta('packageDescription');
  @override
  late final GeneratedColumn<String> packageDescription =
      GeneratedColumn<String>('package_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recipientContactedMeta =
      const VerificationMeta('recipientContacted');
  @override
  late final GeneratedColumn<bool> recipientContacted = GeneratedColumn<bool>(
      'recipient_contacted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("recipient_contacted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recipientAvailableMeta =
      const VerificationMeta('recipientAvailable');
  @override
  late final GeneratedColumn<bool> recipientAvailable = GeneratedColumn<bool>(
      'recipient_available', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("recipient_available" IN (0, 1))'));
  static const VerificationMeta _specialInstructionsMeta =
      const VerificationMeta('specialInstructions');
  @override
  late final GeneratedColumn<String> specialInstructions =
      GeneratedColumn<String>('special_instructions', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entryTimestampMeta =
      const VerificationMeta('entryTimestamp');
  @override
  late final GeneratedColumn<DateTime> entryTimestamp =
      GeneratedColumn<DateTime>('entry_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _exitTimestampMeta =
      const VerificationMeta('exitTimestamp');
  @override
  late final GeneratedColumn<DateTime> exitTimestamp =
      GeneratedColumn<DateTime>('exit_timestamp', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deliveryDurationMinutesMeta =
      const VerificationMeta('deliveryDurationMinutes');
  @override
  late final GeneratedColumn<int> deliveryDurationMinutes =
      GeneratedColumn<int>('delivery_duration_minutes', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationAlertSentMeta =
      const VerificationMeta('durationAlertSent');
  @override
  late final GeneratedColumn<bool> durationAlertSent = GeneratedColumn<bool>(
      'duration_alert_sent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("duration_alert_sent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryLogId,
        deliveryCompany,
        recipientHouseholdId,
        packageType,
        packageDescription,
        recipientContacted,
        recipientAvailable,
        specialInstructions,
        entryTimestamp,
        exitTimestamp,
        deliveryDurationMinutes,
        durationAlertSent,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_log_id')) {
      context.handle(
          _entryLogIdMeta,
          entryLogId.isAcceptableOrUnknown(
              data['entry_log_id']!, _entryLogIdMeta));
    } else if (isInserting) {
      context.missing(_entryLogIdMeta);
    }
    if (data.containsKey('delivery_company')) {
      context.handle(
          _deliveryCompanyMeta,
          deliveryCompany.isAcceptableOrUnknown(
              data['delivery_company']!, _deliveryCompanyMeta));
    } else if (isInserting) {
      context.missing(_deliveryCompanyMeta);
    }
    if (data.containsKey('recipient_household_id')) {
      context.handle(
          _recipientHouseholdIdMeta,
          recipientHouseholdId.isAcceptableOrUnknown(
              data['recipient_household_id']!, _recipientHouseholdIdMeta));
    } else if (isInserting) {
      context.missing(_recipientHouseholdIdMeta);
    }
    if (data.containsKey('package_type')) {
      context.handle(
          _packageTypeMeta,
          packageType.isAcceptableOrUnknown(
              data['package_type']!, _packageTypeMeta));
    } else if (isInserting) {
      context.missing(_packageTypeMeta);
    }
    if (data.containsKey('package_description')) {
      context.handle(
          _packageDescriptionMeta,
          packageDescription.isAcceptableOrUnknown(
              data['package_description']!, _packageDescriptionMeta));
    }
    if (data.containsKey('recipient_contacted')) {
      context.handle(
          _recipientContactedMeta,
          recipientContacted.isAcceptableOrUnknown(
              data['recipient_contacted']!, _recipientContactedMeta));
    }
    if (data.containsKey('recipient_available')) {
      context.handle(
          _recipientAvailableMeta,
          recipientAvailable.isAcceptableOrUnknown(
              data['recipient_available']!, _recipientAvailableMeta));
    }
    if (data.containsKey('special_instructions')) {
      context.handle(
          _specialInstructionsMeta,
          specialInstructions.isAcceptableOrUnknown(
              data['special_instructions']!, _specialInstructionsMeta));
    }
    if (data.containsKey('entry_timestamp')) {
      context.handle(
          _entryTimestampMeta,
          entryTimestamp.isAcceptableOrUnknown(
              data['entry_timestamp']!, _entryTimestampMeta));
    } else if (isInserting) {
      context.missing(_entryTimestampMeta);
    }
    if (data.containsKey('exit_timestamp')) {
      context.handle(
          _exitTimestampMeta,
          exitTimestamp.isAcceptableOrUnknown(
              data['exit_timestamp']!, _exitTimestampMeta));
    }
    if (data.containsKey('delivery_duration_minutes')) {
      context.handle(
          _deliveryDurationMinutesMeta,
          deliveryDurationMinutes.isAcceptableOrUnknown(
              data['delivery_duration_minutes']!,
              _deliveryDurationMinutesMeta));
    }
    if (data.containsKey('duration_alert_sent')) {
      context.handle(
          _durationAlertSentMeta,
          durationAlertSent.isAcceptableOrUnknown(
              data['duration_alert_sent']!, _durationAlertSentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryLogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_log_id'])!,
      deliveryCompany: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_company'])!,
      recipientHouseholdId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recipient_household_id'])!,
      packageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_type'])!,
      packageDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}package_description']),
      recipientContacted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}recipient_contacted'])!,
      recipientAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}recipient_available']),
      specialInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}special_instructions']),
      entryTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}entry_timestamp'])!,
      exitTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}exit_timestamp']),
      deliveryDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delivery_duration_minutes']),
      durationAlertSent: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}duration_alert_sent'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DeliveryLogsTable createAlias(String alias) {
    return $DeliveryLogsTable(attachedDatabase, alias);
  }
}

class DeliveryLog extends DataClass implements Insertable<DeliveryLog> {
  final String id;
  final String entryLogId;
  final String deliveryCompany;
  final String recipientHouseholdId;
  final String packageType;
  final String? packageDescription;
  final bool recipientContacted;
  final bool? recipientAvailable;
  final String? specialInstructions;
  final DateTime entryTimestamp;
  final DateTime? exitTimestamp;
  final int? deliveryDurationMinutes;
  final bool durationAlertSent;
  final DateTime createdAt;
  const DeliveryLog(
      {required this.id,
      required this.entryLogId,
      required this.deliveryCompany,
      required this.recipientHouseholdId,
      required this.packageType,
      this.packageDescription,
      required this.recipientContacted,
      this.recipientAvailable,
      this.specialInstructions,
      required this.entryTimestamp,
      this.exitTimestamp,
      this.deliveryDurationMinutes,
      required this.durationAlertSent,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_log_id'] = Variable<String>(entryLogId);
    map['delivery_company'] = Variable<String>(deliveryCompany);
    map['recipient_household_id'] = Variable<String>(recipientHouseholdId);
    map['package_type'] = Variable<String>(packageType);
    if (!nullToAbsent || packageDescription != null) {
      map['package_description'] = Variable<String>(packageDescription);
    }
    map['recipient_contacted'] = Variable<bool>(recipientContacted);
    if (!nullToAbsent || recipientAvailable != null) {
      map['recipient_available'] = Variable<bool>(recipientAvailable);
    }
    if (!nullToAbsent || specialInstructions != null) {
      map['special_instructions'] = Variable<String>(specialInstructions);
    }
    map['entry_timestamp'] = Variable<DateTime>(entryTimestamp);
    if (!nullToAbsent || exitTimestamp != null) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp);
    }
    if (!nullToAbsent || deliveryDurationMinutes != null) {
      map['delivery_duration_minutes'] = Variable<int>(deliveryDurationMinutes);
    }
    map['duration_alert_sent'] = Variable<bool>(durationAlertSent);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DeliveryLogsCompanion toCompanion(bool nullToAbsent) {
    return DeliveryLogsCompanion(
      id: Value(id),
      entryLogId: Value(entryLogId),
      deliveryCompany: Value(deliveryCompany),
      recipientHouseholdId: Value(recipientHouseholdId),
      packageType: Value(packageType),
      packageDescription: packageDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(packageDescription),
      recipientContacted: Value(recipientContacted),
      recipientAvailable: recipientAvailable == null && nullToAbsent
          ? const Value.absent()
          : Value(recipientAvailable),
      specialInstructions: specialInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(specialInstructions),
      entryTimestamp: Value(entryTimestamp),
      exitTimestamp: exitTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(exitTimestamp),
      deliveryDurationMinutes: deliveryDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDurationMinutes),
      durationAlertSent: Value(durationAlertSent),
      createdAt: Value(createdAt),
    );
  }

  factory DeliveryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryLog(
      id: serializer.fromJson<String>(json['id']),
      entryLogId: serializer.fromJson<String>(json['entryLogId']),
      deliveryCompany: serializer.fromJson<String>(json['deliveryCompany']),
      recipientHouseholdId:
          serializer.fromJson<String>(json['recipientHouseholdId']),
      packageType: serializer.fromJson<String>(json['packageType']),
      packageDescription:
          serializer.fromJson<String?>(json['packageDescription']),
      recipientContacted: serializer.fromJson<bool>(json['recipientContacted']),
      recipientAvailable:
          serializer.fromJson<bool?>(json['recipientAvailable']),
      specialInstructions:
          serializer.fromJson<String?>(json['specialInstructions']),
      entryTimestamp: serializer.fromJson<DateTime>(json['entryTimestamp']),
      exitTimestamp: serializer.fromJson<DateTime?>(json['exitTimestamp']),
      deliveryDurationMinutes:
          serializer.fromJson<int?>(json['deliveryDurationMinutes']),
      durationAlertSent: serializer.fromJson<bool>(json['durationAlertSent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryLogId': serializer.toJson<String>(entryLogId),
      'deliveryCompany': serializer.toJson<String>(deliveryCompany),
      'recipientHouseholdId': serializer.toJson<String>(recipientHouseholdId),
      'packageType': serializer.toJson<String>(packageType),
      'packageDescription': serializer.toJson<String?>(packageDescription),
      'recipientContacted': serializer.toJson<bool>(recipientContacted),
      'recipientAvailable': serializer.toJson<bool?>(recipientAvailable),
      'specialInstructions': serializer.toJson<String?>(specialInstructions),
      'entryTimestamp': serializer.toJson<DateTime>(entryTimestamp),
      'exitTimestamp': serializer.toJson<DateTime?>(exitTimestamp),
      'deliveryDurationMinutes':
          serializer.toJson<int?>(deliveryDurationMinutes),
      'durationAlertSent': serializer.toJson<bool>(durationAlertSent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DeliveryLog copyWith(
          {String? id,
          String? entryLogId,
          String? deliveryCompany,
          String? recipientHouseholdId,
          String? packageType,
          Value<String?> packageDescription = const Value.absent(),
          bool? recipientContacted,
          Value<bool?> recipientAvailable = const Value.absent(),
          Value<String?> specialInstructions = const Value.absent(),
          DateTime? entryTimestamp,
          Value<DateTime?> exitTimestamp = const Value.absent(),
          Value<int?> deliveryDurationMinutes = const Value.absent(),
          bool? durationAlertSent,
          DateTime? createdAt}) =>
      DeliveryLog(
        id: id ?? this.id,
        entryLogId: entryLogId ?? this.entryLogId,
        deliveryCompany: deliveryCompany ?? this.deliveryCompany,
        recipientHouseholdId: recipientHouseholdId ?? this.recipientHouseholdId,
        packageType: packageType ?? this.packageType,
        packageDescription: packageDescription.present
            ? packageDescription.value
            : this.packageDescription,
        recipientContacted: recipientContacted ?? this.recipientContacted,
        recipientAvailable: recipientAvailable.present
            ? recipientAvailable.value
            : this.recipientAvailable,
        specialInstructions: specialInstructions.present
            ? specialInstructions.value
            : this.specialInstructions,
        entryTimestamp: entryTimestamp ?? this.entryTimestamp,
        exitTimestamp:
            exitTimestamp.present ? exitTimestamp.value : this.exitTimestamp,
        deliveryDurationMinutes: deliveryDurationMinutes.present
            ? deliveryDurationMinutes.value
            : this.deliveryDurationMinutes,
        durationAlertSent: durationAlertSent ?? this.durationAlertSent,
        createdAt: createdAt ?? this.createdAt,
      );
  DeliveryLog copyWithCompanion(DeliveryLogsCompanion data) {
    return DeliveryLog(
      id: data.id.present ? data.id.value : this.id,
      entryLogId:
          data.entryLogId.present ? data.entryLogId.value : this.entryLogId,
      deliveryCompany: data.deliveryCompany.present
          ? data.deliveryCompany.value
          : this.deliveryCompany,
      recipientHouseholdId: data.recipientHouseholdId.present
          ? data.recipientHouseholdId.value
          : this.recipientHouseholdId,
      packageType:
          data.packageType.present ? data.packageType.value : this.packageType,
      packageDescription: data.packageDescription.present
          ? data.packageDescription.value
          : this.packageDescription,
      recipientContacted: data.recipientContacted.present
          ? data.recipientContacted.value
          : this.recipientContacted,
      recipientAvailable: data.recipientAvailable.present
          ? data.recipientAvailable.value
          : this.recipientAvailable,
      specialInstructions: data.specialInstructions.present
          ? data.specialInstructions.value
          : this.specialInstructions,
      entryTimestamp: data.entryTimestamp.present
          ? data.entryTimestamp.value
          : this.entryTimestamp,
      exitTimestamp: data.exitTimestamp.present
          ? data.exitTimestamp.value
          : this.exitTimestamp,
      deliveryDurationMinutes: data.deliveryDurationMinutes.present
          ? data.deliveryDurationMinutes.value
          : this.deliveryDurationMinutes,
      durationAlertSent: data.durationAlertSent.present
          ? data.durationAlertSent.value
          : this.durationAlertSent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryLog(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('deliveryCompany: $deliveryCompany, ')
          ..write('recipientHouseholdId: $recipientHouseholdId, ')
          ..write('packageType: $packageType, ')
          ..write('packageDescription: $packageDescription, ')
          ..write('recipientContacted: $recipientContacted, ')
          ..write('recipientAvailable: $recipientAvailable, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('entryTimestamp: $entryTimestamp, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('deliveryDurationMinutes: $deliveryDurationMinutes, ')
          ..write('durationAlertSent: $durationAlertSent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entryLogId,
      deliveryCompany,
      recipientHouseholdId,
      packageType,
      packageDescription,
      recipientContacted,
      recipientAvailable,
      specialInstructions,
      entryTimestamp,
      exitTimestamp,
      deliveryDurationMinutes,
      durationAlertSent,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryLog &&
          other.id == this.id &&
          other.entryLogId == this.entryLogId &&
          other.deliveryCompany == this.deliveryCompany &&
          other.recipientHouseholdId == this.recipientHouseholdId &&
          other.packageType == this.packageType &&
          other.packageDescription == this.packageDescription &&
          other.recipientContacted == this.recipientContacted &&
          other.recipientAvailable == this.recipientAvailable &&
          other.specialInstructions == this.specialInstructions &&
          other.entryTimestamp == this.entryTimestamp &&
          other.exitTimestamp == this.exitTimestamp &&
          other.deliveryDurationMinutes == this.deliveryDurationMinutes &&
          other.durationAlertSent == this.durationAlertSent &&
          other.createdAt == this.createdAt);
}

class DeliveryLogsCompanion extends UpdateCompanion<DeliveryLog> {
  final Value<String> id;
  final Value<String> entryLogId;
  final Value<String> deliveryCompany;
  final Value<String> recipientHouseholdId;
  final Value<String> packageType;
  final Value<String?> packageDescription;
  final Value<bool> recipientContacted;
  final Value<bool?> recipientAvailable;
  final Value<String?> specialInstructions;
  final Value<DateTime> entryTimestamp;
  final Value<DateTime?> exitTimestamp;
  final Value<int?> deliveryDurationMinutes;
  final Value<bool> durationAlertSent;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DeliveryLogsCompanion({
    this.id = const Value.absent(),
    this.entryLogId = const Value.absent(),
    this.deliveryCompany = const Value.absent(),
    this.recipientHouseholdId = const Value.absent(),
    this.packageType = const Value.absent(),
    this.packageDescription = const Value.absent(),
    this.recipientContacted = const Value.absent(),
    this.recipientAvailable = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.entryTimestamp = const Value.absent(),
    this.exitTimestamp = const Value.absent(),
    this.deliveryDurationMinutes = const Value.absent(),
    this.durationAlertSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveryLogsCompanion.insert({
    required String id,
    required String entryLogId,
    required String deliveryCompany,
    required String recipientHouseholdId,
    required String packageType,
    this.packageDescription = const Value.absent(),
    this.recipientContacted = const Value.absent(),
    this.recipientAvailable = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    required DateTime entryTimestamp,
    this.exitTimestamp = const Value.absent(),
    this.deliveryDurationMinutes = const Value.absent(),
    this.durationAlertSent = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryLogId = Value(entryLogId),
        deliveryCompany = Value(deliveryCompany),
        recipientHouseholdId = Value(recipientHouseholdId),
        packageType = Value(packageType),
        entryTimestamp = Value(entryTimestamp),
        createdAt = Value(createdAt);
  static Insertable<DeliveryLog> custom({
    Expression<String>? id,
    Expression<String>? entryLogId,
    Expression<String>? deliveryCompany,
    Expression<String>? recipientHouseholdId,
    Expression<String>? packageType,
    Expression<String>? packageDescription,
    Expression<bool>? recipientContacted,
    Expression<bool>? recipientAvailable,
    Expression<String>? specialInstructions,
    Expression<DateTime>? entryTimestamp,
    Expression<DateTime>? exitTimestamp,
    Expression<int>? deliveryDurationMinutes,
    Expression<bool>? durationAlertSent,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryLogId != null) 'entry_log_id': entryLogId,
      if (deliveryCompany != null) 'delivery_company': deliveryCompany,
      if (recipientHouseholdId != null)
        'recipient_household_id': recipientHouseholdId,
      if (packageType != null) 'package_type': packageType,
      if (packageDescription != null) 'package_description': packageDescription,
      if (recipientContacted != null) 'recipient_contacted': recipientContacted,
      if (recipientAvailable != null) 'recipient_available': recipientAvailable,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (entryTimestamp != null) 'entry_timestamp': entryTimestamp,
      if (exitTimestamp != null) 'exit_timestamp': exitTimestamp,
      if (deliveryDurationMinutes != null)
        'delivery_duration_minutes': deliveryDurationMinutes,
      if (durationAlertSent != null) 'duration_alert_sent': durationAlertSent,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveryLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryLogId,
      Value<String>? deliveryCompany,
      Value<String>? recipientHouseholdId,
      Value<String>? packageType,
      Value<String?>? packageDescription,
      Value<bool>? recipientContacted,
      Value<bool?>? recipientAvailable,
      Value<String?>? specialInstructions,
      Value<DateTime>? entryTimestamp,
      Value<DateTime?>? exitTimestamp,
      Value<int?>? deliveryDurationMinutes,
      Value<bool>? durationAlertSent,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DeliveryLogsCompanion(
      id: id ?? this.id,
      entryLogId: entryLogId ?? this.entryLogId,
      deliveryCompany: deliveryCompany ?? this.deliveryCompany,
      recipientHouseholdId: recipientHouseholdId ?? this.recipientHouseholdId,
      packageType: packageType ?? this.packageType,
      packageDescription: packageDescription ?? this.packageDescription,
      recipientContacted: recipientContacted ?? this.recipientContacted,
      recipientAvailable: recipientAvailable ?? this.recipientAvailable,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      entryTimestamp: entryTimestamp ?? this.entryTimestamp,
      exitTimestamp: exitTimestamp ?? this.exitTimestamp,
      deliveryDurationMinutes:
          deliveryDurationMinutes ?? this.deliveryDurationMinutes,
      durationAlertSent: durationAlertSent ?? this.durationAlertSent,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryLogId.present) {
      map['entry_log_id'] = Variable<String>(entryLogId.value);
    }
    if (deliveryCompany.present) {
      map['delivery_company'] = Variable<String>(deliveryCompany.value);
    }
    if (recipientHouseholdId.present) {
      map['recipient_household_id'] =
          Variable<String>(recipientHouseholdId.value);
    }
    if (packageType.present) {
      map['package_type'] = Variable<String>(packageType.value);
    }
    if (packageDescription.present) {
      map['package_description'] = Variable<String>(packageDescription.value);
    }
    if (recipientContacted.present) {
      map['recipient_contacted'] = Variable<bool>(recipientContacted.value);
    }
    if (recipientAvailable.present) {
      map['recipient_available'] = Variable<bool>(recipientAvailable.value);
    }
    if (specialInstructions.present) {
      map['special_instructions'] = Variable<String>(specialInstructions.value);
    }
    if (entryTimestamp.present) {
      map['entry_timestamp'] = Variable<DateTime>(entryTimestamp.value);
    }
    if (exitTimestamp.present) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp.value);
    }
    if (deliveryDurationMinutes.present) {
      map['delivery_duration_minutes'] =
          Variable<int>(deliveryDurationMinutes.value);
    }
    if (durationAlertSent.present) {
      map['duration_alert_sent'] = Variable<bool>(durationAlertSent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryLogsCompanion(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('deliveryCompany: $deliveryCompany, ')
          ..write('recipientHouseholdId: $recipientHouseholdId, ')
          ..write('packageType: $packageType, ')
          ..write('packageDescription: $packageDescription, ')
          ..write('recipientContacted: $recipientContacted, ')
          ..write('recipientAvailable: $recipientAvailable, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('entryTimestamp: $entryTimestamp, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('deliveryDurationMinutes: $deliveryDurationMinutes, ')
          ..write('durationAlertSent: $durationAlertSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConstructionPermitsTable extends ConstructionPermits
    with TableInfo<$ConstructionPermitsTable, ConstructionPermit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConstructionPermitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _permitReferenceMeta =
      const VerificationMeta('permitReference');
  @override
  late final GeneratedColumn<String> permitReference = GeneratedColumn<String>(
      'permit_reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectDescriptionMeta =
      const VerificationMeta('projectDescription');
  @override
  late final GeneratedColumn<String> projectDescription =
      GeneratedColumn<String>('project_description', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractorNameMeta =
      const VerificationMeta('contractorName');
  @override
  late final GeneratedColumn<String> contractorName = GeneratedColumn<String>(
      'contractor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractorContactMeta =
      const VerificationMeta('contractorContact');
  @override
  late final GeneratedColumn<String> contractorContact =
      GeneratedColumn<String>('contractor_contact', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorizedWorkersMeta =
      const VerificationMeta('authorizedWorkers');
  @override
  late final GeneratedColumn<String> authorizedWorkers =
      GeneratedColumn<String>('authorized_workers', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _approvedByMeta =
      const VerificationMeta('approvedBy');
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
      'approved_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        householdId,
        permitReference,
        projectDescription,
        contractorName,
        contractorContact,
        authorizedWorkers,
        status,
        approvedBy,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'construction_permits';
  @override
  VerificationContext validateIntegrity(Insertable<ConstructionPermit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('permit_reference')) {
      context.handle(
          _permitReferenceMeta,
          permitReference.isAcceptableOrUnknown(
              data['permit_reference']!, _permitReferenceMeta));
    } else if (isInserting) {
      context.missing(_permitReferenceMeta);
    }
    if (data.containsKey('project_description')) {
      context.handle(
          _projectDescriptionMeta,
          projectDescription.isAcceptableOrUnknown(
              data['project_description']!, _projectDescriptionMeta));
    } else if (isInserting) {
      context.missing(_projectDescriptionMeta);
    }
    if (data.containsKey('contractor_name')) {
      context.handle(
          _contractorNameMeta,
          contractorName.isAcceptableOrUnknown(
              data['contractor_name']!, _contractorNameMeta));
    } else if (isInserting) {
      context.missing(_contractorNameMeta);
    }
    if (data.containsKey('contractor_contact')) {
      context.handle(
          _contractorContactMeta,
          contractorContact.isAcceptableOrUnknown(
              data['contractor_contact']!, _contractorContactMeta));
    } else if (isInserting) {
      context.missing(_contractorContactMeta);
    }
    if (data.containsKey('authorized_workers')) {
      context.handle(
          _authorizedWorkersMeta,
          authorizedWorkers.isAcceptableOrUnknown(
              data['authorized_workers']!, _authorizedWorkersMeta));
    } else if (isInserting) {
      context.missing(_authorizedWorkersMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('approved_by')) {
      context.handle(
          _approvedByMeta,
          approvedBy.isAcceptableOrUnknown(
              data['approved_by']!, _approvedByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {permitReference},
      ];
  @override
  ConstructionPermit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConstructionPermit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      permitReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permit_reference'])!,
      projectDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}project_description'])!,
      contractorName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contractor_name'])!,
      contractorContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contractor_contact'])!,
      authorizedWorkers: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorized_workers'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      approvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approved_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ConstructionPermitsTable createAlias(String alias) {
    return $ConstructionPermitsTable(attachedDatabase, alias);
  }
}

class ConstructionPermit extends DataClass
    implements Insertable<ConstructionPermit> {
  final String id;
  final String tenantId;
  final String householdId;
  final String permitReference;
  final String projectDescription;
  final String contractorName;
  final String contractorContact;
  final String authorizedWorkers;
  final String status;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ConstructionPermit(
      {required this.id,
      required this.tenantId,
      required this.householdId,
      required this.permitReference,
      required this.projectDescription,
      required this.contractorName,
      required this.contractorContact,
      required this.authorizedWorkers,
      required this.status,
      this.approvedBy,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['household_id'] = Variable<String>(householdId);
    map['permit_reference'] = Variable<String>(permitReference);
    map['project_description'] = Variable<String>(projectDescription);
    map['contractor_name'] = Variable<String>(contractorName);
    map['contractor_contact'] = Variable<String>(contractorContact);
    map['authorized_workers'] = Variable<String>(authorizedWorkers);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || approvedBy != null) {
      map['approved_by'] = Variable<String>(approvedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConstructionPermitsCompanion toCompanion(bool nullToAbsent) {
    return ConstructionPermitsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      householdId: Value(householdId),
      permitReference: Value(permitReference),
      projectDescription: Value(projectDescription),
      contractorName: Value(contractorName),
      contractorContact: Value(contractorContact),
      authorizedWorkers: Value(authorizedWorkers),
      status: Value(status),
      approvedBy: approvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConstructionPermit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConstructionPermit(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      permitReference: serializer.fromJson<String>(json['permitReference']),
      projectDescription:
          serializer.fromJson<String>(json['projectDescription']),
      contractorName: serializer.fromJson<String>(json['contractorName']),
      contractorContact: serializer.fromJson<String>(json['contractorContact']),
      authorizedWorkers: serializer.fromJson<String>(json['authorizedWorkers']),
      status: serializer.fromJson<String>(json['status']),
      approvedBy: serializer.fromJson<String?>(json['approvedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'householdId': serializer.toJson<String>(householdId),
      'permitReference': serializer.toJson<String>(permitReference),
      'projectDescription': serializer.toJson<String>(projectDescription),
      'contractorName': serializer.toJson<String>(contractorName),
      'contractorContact': serializer.toJson<String>(contractorContact),
      'authorizedWorkers': serializer.toJson<String>(authorizedWorkers),
      'status': serializer.toJson<String>(status),
      'approvedBy': serializer.toJson<String?>(approvedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConstructionPermit copyWith(
          {String? id,
          String? tenantId,
          String? householdId,
          String? permitReference,
          String? projectDescription,
          String? contractorName,
          String? contractorContact,
          String? authorizedWorkers,
          String? status,
          Value<String?> approvedBy = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ConstructionPermit(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        householdId: householdId ?? this.householdId,
        permitReference: permitReference ?? this.permitReference,
        projectDescription: projectDescription ?? this.projectDescription,
        contractorName: contractorName ?? this.contractorName,
        contractorContact: contractorContact ?? this.contractorContact,
        authorizedWorkers: authorizedWorkers ?? this.authorizedWorkers,
        status: status ?? this.status,
        approvedBy: approvedBy.present ? approvedBy.value : this.approvedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ConstructionPermit copyWithCompanion(ConstructionPermitsCompanion data) {
    return ConstructionPermit(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      permitReference: data.permitReference.present
          ? data.permitReference.value
          : this.permitReference,
      projectDescription: data.projectDescription.present
          ? data.projectDescription.value
          : this.projectDescription,
      contractorName: data.contractorName.present
          ? data.contractorName.value
          : this.contractorName,
      contractorContact: data.contractorContact.present
          ? data.contractorContact.value
          : this.contractorContact,
      authorizedWorkers: data.authorizedWorkers.present
          ? data.authorizedWorkers.value
          : this.authorizedWorkers,
      status: data.status.present ? data.status.value : this.status,
      approvedBy:
          data.approvedBy.present ? data.approvedBy.value : this.approvedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConstructionPermit(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('householdId: $householdId, ')
          ..write('permitReference: $permitReference, ')
          ..write('projectDescription: $projectDescription, ')
          ..write('contractorName: $contractorName, ')
          ..write('contractorContact: $contractorContact, ')
          ..write('authorizedWorkers: $authorizedWorkers, ')
          ..write('status: $status, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      householdId,
      permitReference,
      projectDescription,
      contractorName,
      contractorContact,
      authorizedWorkers,
      status,
      approvedBy,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConstructionPermit &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.householdId == this.householdId &&
          other.permitReference == this.permitReference &&
          other.projectDescription == this.projectDescription &&
          other.contractorName == this.contractorName &&
          other.contractorContact == this.contractorContact &&
          other.authorizedWorkers == this.authorizedWorkers &&
          other.status == this.status &&
          other.approvedBy == this.approvedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConstructionPermitsCompanion extends UpdateCompanion<ConstructionPermit> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> householdId;
  final Value<String> permitReference;
  final Value<String> projectDescription;
  final Value<String> contractorName;
  final Value<String> contractorContact;
  final Value<String> authorizedWorkers;
  final Value<String> status;
  final Value<String?> approvedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConstructionPermitsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.permitReference = const Value.absent(),
    this.projectDescription = const Value.absent(),
    this.contractorName = const Value.absent(),
    this.contractorContact = const Value.absent(),
    this.authorizedWorkers = const Value.absent(),
    this.status = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConstructionPermitsCompanion.insert({
    required String id,
    required String tenantId,
    required String householdId,
    required String permitReference,
    required String projectDescription,
    required String contractorName,
    required String contractorContact,
    required String authorizedWorkers,
    required String status,
    this.approvedBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        householdId = Value(householdId),
        permitReference = Value(permitReference),
        projectDescription = Value(projectDescription),
        contractorName = Value(contractorName),
        contractorContact = Value(contractorContact),
        authorizedWorkers = Value(authorizedWorkers),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ConstructionPermit> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? householdId,
    Expression<String>? permitReference,
    Expression<String>? projectDescription,
    Expression<String>? contractorName,
    Expression<String>? contractorContact,
    Expression<String>? authorizedWorkers,
    Expression<String>? status,
    Expression<String>? approvedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (householdId != null) 'household_id': householdId,
      if (permitReference != null) 'permit_reference': permitReference,
      if (projectDescription != null) 'project_description': projectDescription,
      if (contractorName != null) 'contractor_name': contractorName,
      if (contractorContact != null) 'contractor_contact': contractorContact,
      if (authorizedWorkers != null) 'authorized_workers': authorizedWorkers,
      if (status != null) 'status': status,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConstructionPermitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? householdId,
      Value<String>? permitReference,
      Value<String>? projectDescription,
      Value<String>? contractorName,
      Value<String>? contractorContact,
      Value<String>? authorizedWorkers,
      Value<String>? status,
      Value<String?>? approvedBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ConstructionPermitsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      householdId: householdId ?? this.householdId,
      permitReference: permitReference ?? this.permitReference,
      projectDescription: projectDescription ?? this.projectDescription,
      contractorName: contractorName ?? this.contractorName,
      contractorContact: contractorContact ?? this.contractorContact,
      authorizedWorkers: authorizedWorkers ?? this.authorizedWorkers,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (permitReference.present) {
      map['permit_reference'] = Variable<String>(permitReference.value);
    }
    if (projectDescription.present) {
      map['project_description'] = Variable<String>(projectDescription.value);
    }
    if (contractorName.present) {
      map['contractor_name'] = Variable<String>(contractorName.value);
    }
    if (contractorContact.present) {
      map['contractor_contact'] = Variable<String>(contractorContact.value);
    }
    if (authorizedWorkers.present) {
      map['authorized_workers'] = Variable<String>(authorizedWorkers.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConstructionPermitsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('householdId: $householdId, ')
          ..write('permitReference: $permitReference, ')
          ..write('projectDescription: $projectDescription, ')
          ..write('contractorName: $contractorName, ')
          ..write('contractorContact: $contractorContact, ')
          ..write('authorizedWorkers: $authorizedWorkers, ')
          ..write('status: $status, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConstructionWorkerLogsTable extends ConstructionWorkerLogs
    with TableInfo<$ConstructionWorkerLogsTable, ConstructionWorkerLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConstructionWorkerLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryLogIdMeta =
      const VerificationMeta('entryLogId');
  @override
  late final GeneratedColumn<String> entryLogId = GeneratedColumn<String>(
      'entry_log_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _permitIdMeta =
      const VerificationMeta('permitId');
  @override
  late final GeneratedColumn<String> permitId = GeneratedColumn<String>(
      'permit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workerNameMeta =
      const VerificationMeta('workerName');
  @override
  late final GeneratedColumn<String> workerName = GeneratedColumn<String>(
      'worker_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workerIdNumberMeta =
      const VerificationMeta('workerIdNumber');
  @override
  late final GeneratedColumn<String> workerIdNumber = GeneratedColumn<String>(
      'worker_id_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTimestampMeta =
      const VerificationMeta('entryTimestamp');
  @override
  late final GeneratedColumn<DateTime> entryTimestamp =
      GeneratedColumn<DateTime>('entry_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _exitTimestampMeta =
      const VerificationMeta('exitTimestamp');
  @override
  late final GeneratedColumn<DateTime> exitTimestamp =
      GeneratedColumn<DateTime>('exit_timestamp', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _timeOnsiteMinutesMeta =
      const VerificationMeta('timeOnsiteMinutes');
  @override
  late final GeneratedColumn<int> timeOnsiteMinutes = GeneratedColumn<int>(
      'time_onsite_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentlyOnsiteMeta =
      const VerificationMeta('currentlyOnsite');
  @override
  late final GeneratedColumn<bool> currentlyOnsite = GeneratedColumn<bool>(
      'currently_onsite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("currently_onsite" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryLogId,
        permitId,
        workerName,
        workerIdNumber,
        entryTimestamp,
        exitTimestamp,
        timeOnsiteMinutes,
        currentlyOnsite,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'construction_worker_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConstructionWorkerLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_log_id')) {
      context.handle(
          _entryLogIdMeta,
          entryLogId.isAcceptableOrUnknown(
              data['entry_log_id']!, _entryLogIdMeta));
    } else if (isInserting) {
      context.missing(_entryLogIdMeta);
    }
    if (data.containsKey('permit_id')) {
      context.handle(_permitIdMeta,
          permitId.isAcceptableOrUnknown(data['permit_id']!, _permitIdMeta));
    } else if (isInserting) {
      context.missing(_permitIdMeta);
    }
    if (data.containsKey('worker_name')) {
      context.handle(
          _workerNameMeta,
          workerName.isAcceptableOrUnknown(
              data['worker_name']!, _workerNameMeta));
    } else if (isInserting) {
      context.missing(_workerNameMeta);
    }
    if (data.containsKey('worker_id_number')) {
      context.handle(
          _workerIdNumberMeta,
          workerIdNumber.isAcceptableOrUnknown(
              data['worker_id_number']!, _workerIdNumberMeta));
    } else if (isInserting) {
      context.missing(_workerIdNumberMeta);
    }
    if (data.containsKey('entry_timestamp')) {
      context.handle(
          _entryTimestampMeta,
          entryTimestamp.isAcceptableOrUnknown(
              data['entry_timestamp']!, _entryTimestampMeta));
    } else if (isInserting) {
      context.missing(_entryTimestampMeta);
    }
    if (data.containsKey('exit_timestamp')) {
      context.handle(
          _exitTimestampMeta,
          exitTimestamp.isAcceptableOrUnknown(
              data['exit_timestamp']!, _exitTimestampMeta));
    }
    if (data.containsKey('time_onsite_minutes')) {
      context.handle(
          _timeOnsiteMinutesMeta,
          timeOnsiteMinutes.isAcceptableOrUnknown(
              data['time_onsite_minutes']!, _timeOnsiteMinutesMeta));
    }
    if (data.containsKey('currently_onsite')) {
      context.handle(
          _currentlyOnsiteMeta,
          currentlyOnsite.isAcceptableOrUnknown(
              data['currently_onsite']!, _currentlyOnsiteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConstructionWorkerLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConstructionWorkerLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryLogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_log_id'])!,
      permitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}permit_id'])!,
      workerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}worker_name'])!,
      workerIdNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}worker_id_number'])!,
      entryTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}entry_timestamp'])!,
      exitTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}exit_timestamp']),
      timeOnsiteMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}time_onsite_minutes']),
      currentlyOnsite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}currently_onsite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ConstructionWorkerLogsTable createAlias(String alias) {
    return $ConstructionWorkerLogsTable(attachedDatabase, alias);
  }
}

class ConstructionWorkerLog extends DataClass
    implements Insertable<ConstructionWorkerLog> {
  final String id;
  final String entryLogId;
  final String permitId;
  final String workerName;
  final String workerIdNumber;
  final DateTime entryTimestamp;
  final DateTime? exitTimestamp;
  final int? timeOnsiteMinutes;
  final bool currentlyOnsite;
  final DateTime createdAt;
  const ConstructionWorkerLog(
      {required this.id,
      required this.entryLogId,
      required this.permitId,
      required this.workerName,
      required this.workerIdNumber,
      required this.entryTimestamp,
      this.exitTimestamp,
      this.timeOnsiteMinutes,
      required this.currentlyOnsite,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_log_id'] = Variable<String>(entryLogId);
    map['permit_id'] = Variable<String>(permitId);
    map['worker_name'] = Variable<String>(workerName);
    map['worker_id_number'] = Variable<String>(workerIdNumber);
    map['entry_timestamp'] = Variable<DateTime>(entryTimestamp);
    if (!nullToAbsent || exitTimestamp != null) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp);
    }
    if (!nullToAbsent || timeOnsiteMinutes != null) {
      map['time_onsite_minutes'] = Variable<int>(timeOnsiteMinutes);
    }
    map['currently_onsite'] = Variable<bool>(currentlyOnsite);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConstructionWorkerLogsCompanion toCompanion(bool nullToAbsent) {
    return ConstructionWorkerLogsCompanion(
      id: Value(id),
      entryLogId: Value(entryLogId),
      permitId: Value(permitId),
      workerName: Value(workerName),
      workerIdNumber: Value(workerIdNumber),
      entryTimestamp: Value(entryTimestamp),
      exitTimestamp: exitTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(exitTimestamp),
      timeOnsiteMinutes: timeOnsiteMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOnsiteMinutes),
      currentlyOnsite: Value(currentlyOnsite),
      createdAt: Value(createdAt),
    );
  }

  factory ConstructionWorkerLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConstructionWorkerLog(
      id: serializer.fromJson<String>(json['id']),
      entryLogId: serializer.fromJson<String>(json['entryLogId']),
      permitId: serializer.fromJson<String>(json['permitId']),
      workerName: serializer.fromJson<String>(json['workerName']),
      workerIdNumber: serializer.fromJson<String>(json['workerIdNumber']),
      entryTimestamp: serializer.fromJson<DateTime>(json['entryTimestamp']),
      exitTimestamp: serializer.fromJson<DateTime?>(json['exitTimestamp']),
      timeOnsiteMinutes: serializer.fromJson<int?>(json['timeOnsiteMinutes']),
      currentlyOnsite: serializer.fromJson<bool>(json['currentlyOnsite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryLogId': serializer.toJson<String>(entryLogId),
      'permitId': serializer.toJson<String>(permitId),
      'workerName': serializer.toJson<String>(workerName),
      'workerIdNumber': serializer.toJson<String>(workerIdNumber),
      'entryTimestamp': serializer.toJson<DateTime>(entryTimestamp),
      'exitTimestamp': serializer.toJson<DateTime?>(exitTimestamp),
      'timeOnsiteMinutes': serializer.toJson<int?>(timeOnsiteMinutes),
      'currentlyOnsite': serializer.toJson<bool>(currentlyOnsite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConstructionWorkerLog copyWith(
          {String? id,
          String? entryLogId,
          String? permitId,
          String? workerName,
          String? workerIdNumber,
          DateTime? entryTimestamp,
          Value<DateTime?> exitTimestamp = const Value.absent(),
          Value<int?> timeOnsiteMinutes = const Value.absent(),
          bool? currentlyOnsite,
          DateTime? createdAt}) =>
      ConstructionWorkerLog(
        id: id ?? this.id,
        entryLogId: entryLogId ?? this.entryLogId,
        permitId: permitId ?? this.permitId,
        workerName: workerName ?? this.workerName,
        workerIdNumber: workerIdNumber ?? this.workerIdNumber,
        entryTimestamp: entryTimestamp ?? this.entryTimestamp,
        exitTimestamp:
            exitTimestamp.present ? exitTimestamp.value : this.exitTimestamp,
        timeOnsiteMinutes: timeOnsiteMinutes.present
            ? timeOnsiteMinutes.value
            : this.timeOnsiteMinutes,
        currentlyOnsite: currentlyOnsite ?? this.currentlyOnsite,
        createdAt: createdAt ?? this.createdAt,
      );
  ConstructionWorkerLog copyWithCompanion(
      ConstructionWorkerLogsCompanion data) {
    return ConstructionWorkerLog(
      id: data.id.present ? data.id.value : this.id,
      entryLogId:
          data.entryLogId.present ? data.entryLogId.value : this.entryLogId,
      permitId: data.permitId.present ? data.permitId.value : this.permitId,
      workerName:
          data.workerName.present ? data.workerName.value : this.workerName,
      workerIdNumber: data.workerIdNumber.present
          ? data.workerIdNumber.value
          : this.workerIdNumber,
      entryTimestamp: data.entryTimestamp.present
          ? data.entryTimestamp.value
          : this.entryTimestamp,
      exitTimestamp: data.exitTimestamp.present
          ? data.exitTimestamp.value
          : this.exitTimestamp,
      timeOnsiteMinutes: data.timeOnsiteMinutes.present
          ? data.timeOnsiteMinutes.value
          : this.timeOnsiteMinutes,
      currentlyOnsite: data.currentlyOnsite.present
          ? data.currentlyOnsite.value
          : this.currentlyOnsite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConstructionWorkerLog(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('permitId: $permitId, ')
          ..write('workerName: $workerName, ')
          ..write('workerIdNumber: $workerIdNumber, ')
          ..write('entryTimestamp: $entryTimestamp, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('timeOnsiteMinutes: $timeOnsiteMinutes, ')
          ..write('currentlyOnsite: $currentlyOnsite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entryLogId,
      permitId,
      workerName,
      workerIdNumber,
      entryTimestamp,
      exitTimestamp,
      timeOnsiteMinutes,
      currentlyOnsite,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConstructionWorkerLog &&
          other.id == this.id &&
          other.entryLogId == this.entryLogId &&
          other.permitId == this.permitId &&
          other.workerName == this.workerName &&
          other.workerIdNumber == this.workerIdNumber &&
          other.entryTimestamp == this.entryTimestamp &&
          other.exitTimestamp == this.exitTimestamp &&
          other.timeOnsiteMinutes == this.timeOnsiteMinutes &&
          other.currentlyOnsite == this.currentlyOnsite &&
          other.createdAt == this.createdAt);
}

class ConstructionWorkerLogsCompanion
    extends UpdateCompanion<ConstructionWorkerLog> {
  final Value<String> id;
  final Value<String> entryLogId;
  final Value<String> permitId;
  final Value<String> workerName;
  final Value<String> workerIdNumber;
  final Value<DateTime> entryTimestamp;
  final Value<DateTime?> exitTimestamp;
  final Value<int?> timeOnsiteMinutes;
  final Value<bool> currentlyOnsite;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConstructionWorkerLogsCompanion({
    this.id = const Value.absent(),
    this.entryLogId = const Value.absent(),
    this.permitId = const Value.absent(),
    this.workerName = const Value.absent(),
    this.workerIdNumber = const Value.absent(),
    this.entryTimestamp = const Value.absent(),
    this.exitTimestamp = const Value.absent(),
    this.timeOnsiteMinutes = const Value.absent(),
    this.currentlyOnsite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConstructionWorkerLogsCompanion.insert({
    required String id,
    required String entryLogId,
    required String permitId,
    required String workerName,
    required String workerIdNumber,
    required DateTime entryTimestamp,
    this.exitTimestamp = const Value.absent(),
    this.timeOnsiteMinutes = const Value.absent(),
    this.currentlyOnsite = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryLogId = Value(entryLogId),
        permitId = Value(permitId),
        workerName = Value(workerName),
        workerIdNumber = Value(workerIdNumber),
        entryTimestamp = Value(entryTimestamp),
        createdAt = Value(createdAt);
  static Insertable<ConstructionWorkerLog> custom({
    Expression<String>? id,
    Expression<String>? entryLogId,
    Expression<String>? permitId,
    Expression<String>? workerName,
    Expression<String>? workerIdNumber,
    Expression<DateTime>? entryTimestamp,
    Expression<DateTime>? exitTimestamp,
    Expression<int>? timeOnsiteMinutes,
    Expression<bool>? currentlyOnsite,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryLogId != null) 'entry_log_id': entryLogId,
      if (permitId != null) 'permit_id': permitId,
      if (workerName != null) 'worker_name': workerName,
      if (workerIdNumber != null) 'worker_id_number': workerIdNumber,
      if (entryTimestamp != null) 'entry_timestamp': entryTimestamp,
      if (exitTimestamp != null) 'exit_timestamp': exitTimestamp,
      if (timeOnsiteMinutes != null) 'time_onsite_minutes': timeOnsiteMinutes,
      if (currentlyOnsite != null) 'currently_onsite': currentlyOnsite,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConstructionWorkerLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryLogId,
      Value<String>? permitId,
      Value<String>? workerName,
      Value<String>? workerIdNumber,
      Value<DateTime>? entryTimestamp,
      Value<DateTime?>? exitTimestamp,
      Value<int?>? timeOnsiteMinutes,
      Value<bool>? currentlyOnsite,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ConstructionWorkerLogsCompanion(
      id: id ?? this.id,
      entryLogId: entryLogId ?? this.entryLogId,
      permitId: permitId ?? this.permitId,
      workerName: workerName ?? this.workerName,
      workerIdNumber: workerIdNumber ?? this.workerIdNumber,
      entryTimestamp: entryTimestamp ?? this.entryTimestamp,
      exitTimestamp: exitTimestamp ?? this.exitTimestamp,
      timeOnsiteMinutes: timeOnsiteMinutes ?? this.timeOnsiteMinutes,
      currentlyOnsite: currentlyOnsite ?? this.currentlyOnsite,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryLogId.present) {
      map['entry_log_id'] = Variable<String>(entryLogId.value);
    }
    if (permitId.present) {
      map['permit_id'] = Variable<String>(permitId.value);
    }
    if (workerName.present) {
      map['worker_name'] = Variable<String>(workerName.value);
    }
    if (workerIdNumber.present) {
      map['worker_id_number'] = Variable<String>(workerIdNumber.value);
    }
    if (entryTimestamp.present) {
      map['entry_timestamp'] = Variable<DateTime>(entryTimestamp.value);
    }
    if (exitTimestamp.present) {
      map['exit_timestamp'] = Variable<DateTime>(exitTimestamp.value);
    }
    if (timeOnsiteMinutes.present) {
      map['time_onsite_minutes'] = Variable<int>(timeOnsiteMinutes.value);
    }
    if (currentlyOnsite.present) {
      map['currently_onsite'] = Variable<bool>(currentlyOnsite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConstructionWorkerLogsCompanion(')
          ..write('id: $id, ')
          ..write('entryLogId: $entryLogId, ')
          ..write('permitId: $permitId, ')
          ..write('workerName: $workerName, ')
          ..write('workerIdNumber: $workerIdNumber, ')
          ..write('entryTimestamp: $entryTimestamp, ')
          ..write('exitTimestamp: $exitTimestamp, ')
          ..write('timeOnsiteMinutes: $timeOnsiteMinutes, ')
          ..write('currentlyOnsite: $currentlyOnsite, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncidentReportsTable extends IncidentReports
    with TableInfo<$IncidentReportsTable, IncidentReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guardIdMeta =
      const VerificationMeta('guardId');
  @override
  late final GeneratedColumn<String> guardId = GeneratedColumn<String>(
      'guard_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _incidentTypeMeta =
      const VerificationMeta('incidentType');
  @override
  late final GeneratedColumn<String> incidentType = GeneratedColumn<String>(
      'incident_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _involvedPartiesMeta =
      const VerificationMeta('involvedParties');
  @override
  late final GeneratedColumn<String> involvedParties = GeneratedColumn<String>(
      'involved_parties', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photosMeta = const VerificationMeta('photos');
  @override
  late final GeneratedColumn<String> photos = GeneratedColumn<String>(
      'photos', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dispatchNotifiedMeta =
      const VerificationMeta('dispatchNotified');
  @override
  late final GeneratedColumn<bool> dispatchNotified = GeneratedColumn<bool>(
      'dispatch_notified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("dispatch_notified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dispatchResponseMeta =
      const VerificationMeta('dispatchResponse');
  @override
  late final GeneratedColumn<String> dispatchResponse = GeneratedColumn<String>(
      'dispatch_response', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolutionMeta =
      const VerificationMeta('resolution');
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
      'resolution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        guardId,
        incidentType,
        severity,
        location,
        description,
        involvedParties,
        photos,
        timestamp,
        dispatchNotified,
        dispatchResponse,
        resolution,
        status,
        resolvedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident_reports';
  @override
  VerificationContext validateIntegrity(Insertable<IncidentReport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('guard_id')) {
      context.handle(_guardIdMeta,
          guardId.isAcceptableOrUnknown(data['guard_id']!, _guardIdMeta));
    } else if (isInserting) {
      context.missing(_guardIdMeta);
    }
    if (data.containsKey('incident_type')) {
      context.handle(
          _incidentTypeMeta,
          incidentType.isAcceptableOrUnknown(
              data['incident_type']!, _incidentTypeMeta));
    } else if (isInserting) {
      context.missing(_incidentTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('involved_parties')) {
      context.handle(
          _involvedPartiesMeta,
          involvedParties.isAcceptableOrUnknown(
              data['involved_parties']!, _involvedPartiesMeta));
    }
    if (data.containsKey('photos')) {
      context.handle(_photosMeta,
          photos.isAcceptableOrUnknown(data['photos']!, _photosMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('dispatch_notified')) {
      context.handle(
          _dispatchNotifiedMeta,
          dispatchNotified.isAcceptableOrUnknown(
              data['dispatch_notified']!, _dispatchNotifiedMeta));
    }
    if (data.containsKey('dispatch_response')) {
      context.handle(
          _dispatchResponseMeta,
          dispatchResponse.isAcceptableOrUnknown(
              data['dispatch_response']!, _dispatchResponseMeta));
    }
    if (data.containsKey('resolution')) {
      context.handle(
          _resolutionMeta,
          resolution.isAcceptableOrUnknown(
              data['resolution']!, _resolutionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncidentReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentReport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      guardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guard_id'])!,
      incidentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}incident_type'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      involvedParties: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}involved_parties']),
      photos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photos']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      dispatchNotified: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}dispatch_notified'])!,
      dispatchResponse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dispatch_response']),
      resolution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolution']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $IncidentReportsTable createAlias(String alias) {
    return $IncidentReportsTable(attachedDatabase, alias);
  }
}

class IncidentReport extends DataClass implements Insertable<IncidentReport> {
  final String id;
  final String tenantId;
  final String guardId;
  final String incidentType;
  final String severity;
  final String location;
  final String description;
  final String? involvedParties;
  final String? photos;
  final DateTime timestamp;
  final bool dispatchNotified;
  final String? dispatchResponse;
  final String? resolution;
  final String status;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const IncidentReport(
      {required this.id,
      required this.tenantId,
      required this.guardId,
      required this.incidentType,
      required this.severity,
      required this.location,
      required this.description,
      this.involvedParties,
      this.photos,
      required this.timestamp,
      required this.dispatchNotified,
      this.dispatchResponse,
      this.resolution,
      required this.status,
      this.resolvedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['guard_id'] = Variable<String>(guardId);
    map['incident_type'] = Variable<String>(incidentType);
    map['severity'] = Variable<String>(severity);
    map['location'] = Variable<String>(location);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || involvedParties != null) {
      map['involved_parties'] = Variable<String>(involvedParties);
    }
    if (!nullToAbsent || photos != null) {
      map['photos'] = Variable<String>(photos);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['dispatch_notified'] = Variable<bool>(dispatchNotified);
    if (!nullToAbsent || dispatchResponse != null) {
      map['dispatch_response'] = Variable<String>(dispatchResponse);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IncidentReportsCompanion toCompanion(bool nullToAbsent) {
    return IncidentReportsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      guardId: Value(guardId),
      incidentType: Value(incidentType),
      severity: Value(severity),
      location: Value(location),
      description: Value(description),
      involvedParties: involvedParties == null && nullToAbsent
          ? const Value.absent()
          : Value(involvedParties),
      photos:
          photos == null && nullToAbsent ? const Value.absent() : Value(photos),
      timestamp: Value(timestamp),
      dispatchNotified: Value(dispatchNotified),
      dispatchResponse: dispatchResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(dispatchResponse),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      status: Value(status),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory IncidentReport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentReport(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      guardId: serializer.fromJson<String>(json['guardId']),
      incidentType: serializer.fromJson<String>(json['incidentType']),
      severity: serializer.fromJson<String>(json['severity']),
      location: serializer.fromJson<String>(json['location']),
      description: serializer.fromJson<String>(json['description']),
      involvedParties: serializer.fromJson<String?>(json['involvedParties']),
      photos: serializer.fromJson<String?>(json['photos']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      dispatchNotified: serializer.fromJson<bool>(json['dispatchNotified']),
      dispatchResponse: serializer.fromJson<String?>(json['dispatchResponse']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      status: serializer.fromJson<String>(json['status']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'guardId': serializer.toJson<String>(guardId),
      'incidentType': serializer.toJson<String>(incidentType),
      'severity': serializer.toJson<String>(severity),
      'location': serializer.toJson<String>(location),
      'description': serializer.toJson<String>(description),
      'involvedParties': serializer.toJson<String?>(involvedParties),
      'photos': serializer.toJson<String?>(photos),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'dispatchNotified': serializer.toJson<bool>(dispatchNotified),
      'dispatchResponse': serializer.toJson<String?>(dispatchResponse),
      'resolution': serializer.toJson<String?>(resolution),
      'status': serializer.toJson<String>(status),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  IncidentReport copyWith(
          {String? id,
          String? tenantId,
          String? guardId,
          String? incidentType,
          String? severity,
          String? location,
          String? description,
          Value<String?> involvedParties = const Value.absent(),
          Value<String?> photos = const Value.absent(),
          DateTime? timestamp,
          bool? dispatchNotified,
          Value<String?> dispatchResponse = const Value.absent(),
          Value<String?> resolution = const Value.absent(),
          String? status,
          Value<DateTime?> resolvedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      IncidentReport(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        guardId: guardId ?? this.guardId,
        incidentType: incidentType ?? this.incidentType,
        severity: severity ?? this.severity,
        location: location ?? this.location,
        description: description ?? this.description,
        involvedParties: involvedParties.present
            ? involvedParties.value
            : this.involvedParties,
        photos: photos.present ? photos.value : this.photos,
        timestamp: timestamp ?? this.timestamp,
        dispatchNotified: dispatchNotified ?? this.dispatchNotified,
        dispatchResponse: dispatchResponse.present
            ? dispatchResponse.value
            : this.dispatchResponse,
        resolution: resolution.present ? resolution.value : this.resolution,
        status: status ?? this.status,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  IncidentReport copyWithCompanion(IncidentReportsCompanion data) {
    return IncidentReport(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      guardId: data.guardId.present ? data.guardId.value : this.guardId,
      incidentType: data.incidentType.present
          ? data.incidentType.value
          : this.incidentType,
      severity: data.severity.present ? data.severity.value : this.severity,
      location: data.location.present ? data.location.value : this.location,
      description:
          data.description.present ? data.description.value : this.description,
      involvedParties: data.involvedParties.present
          ? data.involvedParties.value
          : this.involvedParties,
      photos: data.photos.present ? data.photos.value : this.photos,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      dispatchNotified: data.dispatchNotified.present
          ? data.dispatchNotified.value
          : this.dispatchNotified,
      dispatchResponse: data.dispatchResponse.present
          ? data.dispatchResponse.value
          : this.dispatchResponse,
      resolution:
          data.resolution.present ? data.resolution.value : this.resolution,
      status: data.status.present ? data.status.value : this.status,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentReport(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('guardId: $guardId, ')
          ..write('incidentType: $incidentType, ')
          ..write('severity: $severity, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('involvedParties: $involvedParties, ')
          ..write('photos: $photos, ')
          ..write('timestamp: $timestamp, ')
          ..write('dispatchNotified: $dispatchNotified, ')
          ..write('dispatchResponse: $dispatchResponse, ')
          ..write('resolution: $resolution, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      guardId,
      incidentType,
      severity,
      location,
      description,
      involvedParties,
      photos,
      timestamp,
      dispatchNotified,
      dispatchResponse,
      resolution,
      status,
      resolvedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentReport &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.guardId == this.guardId &&
          other.incidentType == this.incidentType &&
          other.severity == this.severity &&
          other.location == this.location &&
          other.description == this.description &&
          other.involvedParties == this.involvedParties &&
          other.photos == this.photos &&
          other.timestamp == this.timestamp &&
          other.dispatchNotified == this.dispatchNotified &&
          other.dispatchResponse == this.dispatchResponse &&
          other.resolution == this.resolution &&
          other.status == this.status &&
          other.resolvedAt == this.resolvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IncidentReportsCompanion extends UpdateCompanion<IncidentReport> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> guardId;
  final Value<String> incidentType;
  final Value<String> severity;
  final Value<String> location;
  final Value<String> description;
  final Value<String?> involvedParties;
  final Value<String?> photos;
  final Value<DateTime> timestamp;
  final Value<bool> dispatchNotified;
  final Value<String?> dispatchResponse;
  final Value<String?> resolution;
  final Value<String> status;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IncidentReportsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.guardId = const Value.absent(),
    this.incidentType = const Value.absent(),
    this.severity = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.involvedParties = const Value.absent(),
    this.photos = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.dispatchNotified = const Value.absent(),
    this.dispatchResponse = const Value.absent(),
    this.resolution = const Value.absent(),
    this.status = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidentReportsCompanion.insert({
    required String id,
    required String tenantId,
    required String guardId,
    required String incidentType,
    required String severity,
    required String location,
    required String description,
    this.involvedParties = const Value.absent(),
    this.photos = const Value.absent(),
    required DateTime timestamp,
    this.dispatchNotified = const Value.absent(),
    this.dispatchResponse = const Value.absent(),
    this.resolution = const Value.absent(),
    required String status,
    this.resolvedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        guardId = Value(guardId),
        incidentType = Value(incidentType),
        severity = Value(severity),
        location = Value(location),
        description = Value(description),
        timestamp = Value(timestamp),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<IncidentReport> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? guardId,
    Expression<String>? incidentType,
    Expression<String>? severity,
    Expression<String>? location,
    Expression<String>? description,
    Expression<String>? involvedParties,
    Expression<String>? photos,
    Expression<DateTime>? timestamp,
    Expression<bool>? dispatchNotified,
    Expression<String>? dispatchResponse,
    Expression<String>? resolution,
    Expression<String>? status,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (guardId != null) 'guard_id': guardId,
      if (incidentType != null) 'incident_type': incidentType,
      if (severity != null) 'severity': severity,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (involvedParties != null) 'involved_parties': involvedParties,
      if (photos != null) 'photos': photos,
      if (timestamp != null) 'timestamp': timestamp,
      if (dispatchNotified != null) 'dispatch_notified': dispatchNotified,
      if (dispatchResponse != null) 'dispatch_response': dispatchResponse,
      if (resolution != null) 'resolution': resolution,
      if (status != null) 'status': status,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidentReportsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? guardId,
      Value<String>? incidentType,
      Value<String>? severity,
      Value<String>? location,
      Value<String>? description,
      Value<String?>? involvedParties,
      Value<String?>? photos,
      Value<DateTime>? timestamp,
      Value<bool>? dispatchNotified,
      Value<String?>? dispatchResponse,
      Value<String?>? resolution,
      Value<String>? status,
      Value<DateTime?>? resolvedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return IncidentReportsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      guardId: guardId ?? this.guardId,
      incidentType: incidentType ?? this.incidentType,
      severity: severity ?? this.severity,
      location: location ?? this.location,
      description: description ?? this.description,
      involvedParties: involvedParties ?? this.involvedParties,
      photos: photos ?? this.photos,
      timestamp: timestamp ?? this.timestamp,
      dispatchNotified: dispatchNotified ?? this.dispatchNotified,
      dispatchResponse: dispatchResponse ?? this.dispatchResponse,
      resolution: resolution ?? this.resolution,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (guardId.present) {
      map['guard_id'] = Variable<String>(guardId.value);
    }
    if (incidentType.present) {
      map['incident_type'] = Variable<String>(incidentType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (involvedParties.present) {
      map['involved_parties'] = Variable<String>(involvedParties.value);
    }
    if (photos.present) {
      map['photos'] = Variable<String>(photos.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (dispatchNotified.present) {
      map['dispatch_notified'] = Variable<bool>(dispatchNotified.value);
    }
    if (dispatchResponse.present) {
      map['dispatch_response'] = Variable<String>(dispatchResponse.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentReportsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('guardId: $guardId, ')
          ..write('incidentType: $incidentType, ')
          ..write('severity: $severity, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('involvedParties: $involvedParties, ')
          ..write('photos: $photos, ')
          ..write('timestamp: $timestamp, ')
          ..write('dispatchNotified: $dispatchNotified, ')
          ..write('dispatchResponse: $dispatchResponse, ')
          ..write('resolution: $resolution, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VillageRulesTable extends VillageRules
    with TableInfo<$VillageRulesTable, VillageRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillageRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ruleCategoryMeta =
      const VerificationMeta('ruleCategory');
  @override
  late final GeneratedColumn<String> ruleCategory = GeneratedColumn<String>(
      'rule_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ruleTitleMeta =
      const VerificationMeta('ruleTitle');
  @override
  late final GeneratedColumn<String> ruleTitle = GeneratedColumn<String>(
      'rule_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ruleDescriptionMeta =
      const VerificationMeta('ruleDescription');
  @override
  late final GeneratedColumn<String> ruleDescription = GeneratedColumn<String>(
      'rule_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enforcementInstructionsMeta =
      const VerificationMeta('enforcementInstructions');
  @override
  late final GeneratedColumn<String> enforcementInstructions =
      GeneratedColumn<String>('enforcement_instructions', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        ruleCategory,
        ruleTitle,
        ruleDescription,
        enforcementInstructions,
        active,
        createdBy,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'village_rules';
  @override
  VerificationContext validateIntegrity(Insertable<VillageRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('rule_category')) {
      context.handle(
          _ruleCategoryMeta,
          ruleCategory.isAcceptableOrUnknown(
              data['rule_category']!, _ruleCategoryMeta));
    } else if (isInserting) {
      context.missing(_ruleCategoryMeta);
    }
    if (data.containsKey('rule_title')) {
      context.handle(_ruleTitleMeta,
          ruleTitle.isAcceptableOrUnknown(data['rule_title']!, _ruleTitleMeta));
    } else if (isInserting) {
      context.missing(_ruleTitleMeta);
    }
    if (data.containsKey('rule_description')) {
      context.handle(
          _ruleDescriptionMeta,
          ruleDescription.isAcceptableOrUnknown(
              data['rule_description']!, _ruleDescriptionMeta));
    } else if (isInserting) {
      context.missing(_ruleDescriptionMeta);
    }
    if (data.containsKey('enforcement_instructions')) {
      context.handle(
          _enforcementInstructionsMeta,
          enforcementInstructions.isAcceptableOrUnknown(
              data['enforcement_instructions']!, _enforcementInstructionsMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VillageRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VillageRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      ruleCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_category'])!,
      ruleTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_title'])!,
      ruleDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rule_description'])!,
      enforcementInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}enforcement_instructions']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VillageRulesTable createAlias(String alias) {
    return $VillageRulesTable(attachedDatabase, alias);
  }
}

class VillageRule extends DataClass implements Insertable<VillageRule> {
  final String id;
  final String tenantId;
  final String ruleCategory;
  final String ruleTitle;
  final String ruleDescription;
  final String? enforcementInstructions;
  final bool active;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VillageRule(
      {required this.id,
      required this.tenantId,
      required this.ruleCategory,
      required this.ruleTitle,
      required this.ruleDescription,
      this.enforcementInstructions,
      required this.active,
      required this.createdBy,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['rule_category'] = Variable<String>(ruleCategory);
    map['rule_title'] = Variable<String>(ruleTitle);
    map['rule_description'] = Variable<String>(ruleDescription);
    if (!nullToAbsent || enforcementInstructions != null) {
      map['enforcement_instructions'] =
          Variable<String>(enforcementInstructions);
    }
    map['active'] = Variable<bool>(active);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VillageRulesCompanion toCompanion(bool nullToAbsent) {
    return VillageRulesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      ruleCategory: Value(ruleCategory),
      ruleTitle: Value(ruleTitle),
      ruleDescription: Value(ruleDescription),
      enforcementInstructions: enforcementInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(enforcementInstructions),
      active: Value(active),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VillageRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VillageRule(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      ruleCategory: serializer.fromJson<String>(json['ruleCategory']),
      ruleTitle: serializer.fromJson<String>(json['ruleTitle']),
      ruleDescription: serializer.fromJson<String>(json['ruleDescription']),
      enforcementInstructions:
          serializer.fromJson<String?>(json['enforcementInstructions']),
      active: serializer.fromJson<bool>(json['active']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'ruleCategory': serializer.toJson<String>(ruleCategory),
      'ruleTitle': serializer.toJson<String>(ruleTitle),
      'ruleDescription': serializer.toJson<String>(ruleDescription),
      'enforcementInstructions':
          serializer.toJson<String?>(enforcementInstructions),
      'active': serializer.toJson<bool>(active),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VillageRule copyWith(
          {String? id,
          String? tenantId,
          String? ruleCategory,
          String? ruleTitle,
          String? ruleDescription,
          Value<String?> enforcementInstructions = const Value.absent(),
          bool? active,
          String? createdBy,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      VillageRule(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        ruleCategory: ruleCategory ?? this.ruleCategory,
        ruleTitle: ruleTitle ?? this.ruleTitle,
        ruleDescription: ruleDescription ?? this.ruleDescription,
        enforcementInstructions: enforcementInstructions.present
            ? enforcementInstructions.value
            : this.enforcementInstructions,
        active: active ?? this.active,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VillageRule copyWithCompanion(VillageRulesCompanion data) {
    return VillageRule(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      ruleCategory: data.ruleCategory.present
          ? data.ruleCategory.value
          : this.ruleCategory,
      ruleTitle: data.ruleTitle.present ? data.ruleTitle.value : this.ruleTitle,
      ruleDescription: data.ruleDescription.present
          ? data.ruleDescription.value
          : this.ruleDescription,
      enforcementInstructions: data.enforcementInstructions.present
          ? data.enforcementInstructions.value
          : this.enforcementInstructions,
      active: data.active.present ? data.active.value : this.active,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VillageRule(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('ruleCategory: $ruleCategory, ')
          ..write('ruleTitle: $ruleTitle, ')
          ..write('ruleDescription: $ruleDescription, ')
          ..write('enforcementInstructions: $enforcementInstructions, ')
          ..write('active: $active, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      ruleCategory,
      ruleTitle,
      ruleDescription,
      enforcementInstructions,
      active,
      createdBy,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VillageRule &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.ruleCategory == this.ruleCategory &&
          other.ruleTitle == this.ruleTitle &&
          other.ruleDescription == this.ruleDescription &&
          other.enforcementInstructions == this.enforcementInstructions &&
          other.active == this.active &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VillageRulesCompanion extends UpdateCompanion<VillageRule> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> ruleCategory;
  final Value<String> ruleTitle;
  final Value<String> ruleDescription;
  final Value<String?> enforcementInstructions;
  final Value<bool> active;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VillageRulesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.ruleCategory = const Value.absent(),
    this.ruleTitle = const Value.absent(),
    this.ruleDescription = const Value.absent(),
    this.enforcementInstructions = const Value.absent(),
    this.active = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillageRulesCompanion.insert({
    required String id,
    required String tenantId,
    required String ruleCategory,
    required String ruleTitle,
    required String ruleDescription,
    this.enforcementInstructions = const Value.absent(),
    this.active = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        ruleCategory = Value(ruleCategory),
        ruleTitle = Value(ruleTitle),
        ruleDescription = Value(ruleDescription),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<VillageRule> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? ruleCategory,
    Expression<String>? ruleTitle,
    Expression<String>? ruleDescription,
    Expression<String>? enforcementInstructions,
    Expression<bool>? active,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (ruleCategory != null) 'rule_category': ruleCategory,
      if (ruleTitle != null) 'rule_title': ruleTitle,
      if (ruleDescription != null) 'rule_description': ruleDescription,
      if (enforcementInstructions != null)
        'enforcement_instructions': enforcementInstructions,
      if (active != null) 'active': active,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillageRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? ruleCategory,
      Value<String>? ruleTitle,
      Value<String>? ruleDescription,
      Value<String?>? enforcementInstructions,
      Value<bool>? active,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return VillageRulesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      ruleCategory: ruleCategory ?? this.ruleCategory,
      ruleTitle: ruleTitle ?? this.ruleTitle,
      ruleDescription: ruleDescription ?? this.ruleDescription,
      enforcementInstructions:
          enforcementInstructions ?? this.enforcementInstructions,
      active: active ?? this.active,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (ruleCategory.present) {
      map['rule_category'] = Variable<String>(ruleCategory.value);
    }
    if (ruleTitle.present) {
      map['rule_title'] = Variable<String>(ruleTitle.value);
    }
    if (ruleDescription.present) {
      map['rule_description'] = Variable<String>(ruleDescription.value);
    }
    if (enforcementInstructions.present) {
      map['enforcement_instructions'] =
          Variable<String>(enforcementInstructions.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillageRulesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('ruleCategory: $ruleCategory, ')
          ..write('ruleTitle: $ruleTitle, ')
          ..write('ruleDescription: $ruleDescription, ')
          ..write('enforcementInstructions: $enforcementInstructions, ')
          ..write('active: $active, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnouncementsTable extends Announcements
    with TableInfo<$AnnouncementsTable, Announcement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAudienceMeta =
      const VerificationMeta('targetAudience');
  @override
  late final GeneratedColumn<String> targetAudience = GeneratedColumn<String>(
      'target_audience', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        title,
        message,
        priority,
        targetAudience,
        createdBy,
        createdAt,
        expiresAt,
        active
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'announcements';
  @override
  VerificationContext validateIntegrity(Insertable<Announcement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('target_audience')) {
      context.handle(
          _targetAudienceMeta,
          targetAudience.isAcceptableOrUnknown(
              data['target_audience']!, _targetAudienceMeta));
    } else if (isInserting) {
      context.missing(_targetAudienceMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Announcement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Announcement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      targetAudience: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_audience'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $AnnouncementsTable createAlias(String alias) {
    return $AnnouncementsTable(attachedDatabase, alias);
  }
}

class Announcement extends DataClass implements Insertable<Announcement> {
  final String id;
  final String tenantId;
  final String title;
  final String message;
  final String priority;
  final String targetAudience;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool active;
  const Announcement(
      {required this.id,
      required this.tenantId,
      required this.title,
      required this.message,
      required this.priority,
      required this.targetAudience,
      required this.createdBy,
      required this.createdAt,
      this.expiresAt,
      required this.active});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['priority'] = Variable<String>(priority);
    map['target_audience'] = Variable<String>(targetAudience);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  AnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return AnnouncementsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      title: Value(title),
      message: Value(message),
      priority: Value(priority),
      targetAudience: Value(targetAudience),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      active: Value(active),
    );
  }

  factory Announcement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Announcement(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      priority: serializer.fromJson<String>(json['priority']),
      targetAudience: serializer.fromJson<String>(json['targetAudience']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'priority': serializer.toJson<String>(priority),
      'targetAudience': serializer.toJson<String>(targetAudience),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'active': serializer.toJson<bool>(active),
    };
  }

  Announcement copyWith(
          {String? id,
          String? tenantId,
          String? title,
          String? message,
          String? priority,
          String? targetAudience,
          String? createdBy,
          DateTime? createdAt,
          Value<DateTime?> expiresAt = const Value.absent(),
          bool? active}) =>
      Announcement(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        title: title ?? this.title,
        message: message ?? this.message,
        priority: priority ?? this.priority,
        targetAudience: targetAudience ?? this.targetAudience,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        active: active ?? this.active,
      );
  Announcement copyWithCompanion(AnnouncementsCompanion data) {
    return Announcement(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      priority: data.priority.present ? data.priority.value : this.priority,
      targetAudience: data.targetAudience.present
          ? data.targetAudience.value
          : this.targetAudience,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Announcement(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('priority: $priority, ')
          ..write('targetAudience: $targetAudience, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, title, message, priority,
      targetAudience, createdBy, createdAt, expiresAt, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Announcement &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.title == this.title &&
          other.message == this.message &&
          other.priority == this.priority &&
          other.targetAudience == this.targetAudience &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.active == this.active);
}

class AnnouncementsCompanion extends UpdateCompanion<Announcement> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> title;
  final Value<String> message;
  final Value<String> priority;
  final Value<String> targetAudience;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  final Value<bool> active;
  final Value<int> rowid;
  const AnnouncementsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.priority = const Value.absent(),
    this.targetAudience = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnouncementsCompanion.insert({
    required String id,
    required String tenantId,
    required String title,
    required String message,
    required String priority,
    required String targetAudience,
    required String createdBy,
    required DateTime createdAt,
    this.expiresAt = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        title = Value(title),
        message = Value(message),
        priority = Value(priority),
        targetAudience = Value(targetAudience),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt);
  static Insertable<Announcement> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? priority,
    Expression<String>? targetAudience,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (priority != null) 'priority': priority,
      if (targetAudience != null) 'target_audience': targetAudience,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnouncementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? title,
      Value<String>? message,
      Value<String>? priority,
      Value<String>? targetAudience,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime?>? expiresAt,
      Value<bool>? active,
      Value<int>? rowid}) {
    return AnnouncementsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      targetAudience: targetAudience ?? this.targetAudience,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (targetAudience.present) {
      map['target_audience'] = Variable<String>(targetAudience.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnouncementsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('priority: $priority, ')
          ..write('targetAudience: $targetAudience, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operation,
        entityType,
        entityId,
        payload,
        timestamp,
        retryCount,
        status,
        errorMessage,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String operation;
  final String entityType;
  final String entityId;
  final String payload;
  final int timestamp;
  final int retryCount;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const SyncQueueEntry(
      {required this.id,
      required this.operation,
      required this.entityType,
      required this.entityId,
      required this.payload,
      required this.timestamp,
      required this.retryCount,
      required this.status,
      this.errorMessage,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['timestamp'] = Variable<int>(timestamp);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      timestamp: Value(timestamp),
      retryCount: Value(retryCount),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'timestamp': serializer.toJson<int>(timestamp),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SyncQueueEntry copyWith(
          {int? id,
          String? operation,
          String? entityType,
          String? entityId,
          String? payload,
          int? timestamp,
          int? retryCount,
          String? status,
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      SyncQueueEntry(
        id: id ?? this.id,
        operation: operation ?? this.operation,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        payload: payload ?? this.payload,
        timestamp: timestamp ?? this.timestamp,
        retryCount: retryCount ?? this.retryCount,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('timestamp: $timestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operation, entityType, entityId, payload,
      timestamp, retryCount, status, errorMessage, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.timestamp == this.timestamp &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<int> timestamp;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String entityType,
    required String entityId,
    required String payload,
    required int timestamp,
    this.retryCount = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
  })  : operation = Value(operation),
        entityType = Value(entityType),
        entityId = Value(entityId),
        payload = Value(payload),
        timestamp = Value(timestamp),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<int>? timestamp,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (timestamp != null) 'timestamp': timestamp,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? operation,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? payload,
      Value<int>? timestamp,
      Value<int>? retryCount,
      Value<String>? status,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('timestamp: $timestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntryLogsTable entryLogs = $EntryLogsTable(this);
  late final $RfidStickersTable rfidStickers = $RfidStickersTable(this);
  late final $PreRegisteredGuestsTable preRegisteredGuests =
      $PreRegisteredGuestsTable(this);
  late final $GuestLogsTable guestLogs = $GuestLogsTable(this);
  late final $DeliveryLogsTable deliveryLogs = $DeliveryLogsTable(this);
  late final $ConstructionPermitsTable constructionPermits =
      $ConstructionPermitsTable(this);
  late final $ConstructionWorkerLogsTable constructionWorkerLogs =
      $ConstructionWorkerLogsTable(this);
  late final $IncidentReportsTable incidentReports =
      $IncidentReportsTable(this);
  late final $VillageRulesTable villageRules = $VillageRulesTable(this);
  late final $AnnouncementsTable announcements = $AnnouncementsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        entryLogs,
        rfidStickers,
        preRegisteredGuests,
        guestLogs,
        deliveryLogs,
        constructionPermits,
        constructionWorkerLogs,
        incidentReports,
        villageRules,
        announcements,
        syncQueue
      ];
}

typedef $$EntryLogsTableCreateCompanionBuilder = EntryLogsCompanion Function({
  required String id,
  required String tenantId,
  required String guardId,
  required String entryType,
  required DateTime timestamp,
  Value<String?> vehicleInfo,
  Value<String?> personInfo,
  required String verificationMethod,
  required String verificationStatus,
  Value<String?> denialReason,
  Value<String?> notes,
  Value<bool> synced,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EntryLogsTableUpdateCompanionBuilder = EntryLogsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> guardId,
  Value<String> entryType,
  Value<DateTime> timestamp,
  Value<String?> vehicleInfo,
  Value<String?> personInfo,
  Value<String> verificationMethod,
  Value<String> verificationStatus,
  Value<String?> denialReason,
  Value<String?> notes,
  Value<bool> synced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EntryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryLogsTable> {
  $$EntryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardId => $composableBuilder(
      column: $table.guardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleInfo => $composableBuilder(
      column: $table.vehicleInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personInfo => $composableBuilder(
      column: $table.personInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get denialReason => $composableBuilder(
      column: $table.denialReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EntryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryLogsTable> {
  $$EntryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardId => $composableBuilder(
      column: $table.guardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleInfo => $composableBuilder(
      column: $table.vehicleInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personInfo => $composableBuilder(
      column: $table.personInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get denialReason => $composableBuilder(
      column: $table.denialReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EntryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryLogsTable> {
  $$EntryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get guardId =>
      $composableBuilder(column: $table.guardId, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get vehicleInfo => $composableBuilder(
      column: $table.vehicleInfo, builder: (column) => column);

  GeneratedColumn<String> get personInfo => $composableBuilder(
      column: $table.personInfo, builder: (column) => column);

  GeneratedColumn<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod, builder: (column) => column);

  GeneratedColumn<String> get verificationStatus => $composableBuilder(
      column: $table.verificationStatus, builder: (column) => column);

  GeneratedColumn<String> get denialReason => $composableBuilder(
      column: $table.denialReason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EntryLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntryLogsTable,
    EntryLog,
    $$EntryLogsTableFilterComposer,
    $$EntryLogsTableOrderingComposer,
    $$EntryLogsTableAnnotationComposer,
    $$EntryLogsTableCreateCompanionBuilder,
    $$EntryLogsTableUpdateCompanionBuilder,
    (EntryLog, BaseReferences<_$AppDatabase, $EntryLogsTable, EntryLog>),
    EntryLog,
    PrefetchHooks Function()> {
  $$EntryLogsTableTableManager(_$AppDatabase db, $EntryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> guardId = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> vehicleInfo = const Value.absent(),
            Value<String?> personInfo = const Value.absent(),
            Value<String> verificationMethod = const Value.absent(),
            Value<String> verificationStatus = const Value.absent(),
            Value<String?> denialReason = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryLogsCompanion(
            id: id,
            tenantId: tenantId,
            guardId: guardId,
            entryType: entryType,
            timestamp: timestamp,
            vehicleInfo: vehicleInfo,
            personInfo: personInfo,
            verificationMethod: verificationMethod,
            verificationStatus: verificationStatus,
            denialReason: denialReason,
            notes: notes,
            synced: synced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String guardId,
            required String entryType,
            required DateTime timestamp,
            Value<String?> vehicleInfo = const Value.absent(),
            Value<String?> personInfo = const Value.absent(),
            required String verificationMethod,
            required String verificationStatus,
            Value<String?> denialReason = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryLogsCompanion.insert(
            id: id,
            tenantId: tenantId,
            guardId: guardId,
            entryType: entryType,
            timestamp: timestamp,
            vehicleInfo: vehicleInfo,
            personInfo: personInfo,
            verificationMethod: verificationMethod,
            verificationStatus: verificationStatus,
            denialReason: denialReason,
            notes: notes,
            synced: synced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntryLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntryLogsTable,
    EntryLog,
    $$EntryLogsTableFilterComposer,
    $$EntryLogsTableOrderingComposer,
    $$EntryLogsTableAnnotationComposer,
    $$EntryLogsTableCreateCompanionBuilder,
    $$EntryLogsTableUpdateCompanionBuilder,
    (EntryLog, BaseReferences<_$AppDatabase, $EntryLogsTable, EntryLog>),
    EntryLog,
    PrefetchHooks Function()>;
typedef $$RfidStickersTableCreateCompanionBuilder = RfidStickersCompanion
    Function({
  required String id,
  required String tenantId,
  required String stickerCode,
  required String householdId,
  required String vehiclePlate,
  Value<String?> vehicleMake,
  required String status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RfidStickersTableUpdateCompanionBuilder = RfidStickersCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> stickerCode,
  Value<String> householdId,
  Value<String> vehiclePlate,
  Value<String?> vehicleMake,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RfidStickersTableFilterComposer
    extends Composer<_$AppDatabase, $RfidStickersTable> {
  $$RfidStickersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stickerCode => $composableBuilder(
      column: $table.stickerCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RfidStickersTableOrderingComposer
    extends Composer<_$AppDatabase, $RfidStickersTable> {
  $$RfidStickersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stickerCode => $composableBuilder(
      column: $table.stickerCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RfidStickersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RfidStickersTable> {
  $$RfidStickersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get stickerCode => $composableBuilder(
      column: $table.stickerCode, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => column);

  GeneratedColumn<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RfidStickersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RfidStickersTable,
    RfidSticker,
    $$RfidStickersTableFilterComposer,
    $$RfidStickersTableOrderingComposer,
    $$RfidStickersTableAnnotationComposer,
    $$RfidStickersTableCreateCompanionBuilder,
    $$RfidStickersTableUpdateCompanionBuilder,
    (
      RfidSticker,
      BaseReferences<_$AppDatabase, $RfidStickersTable, RfidSticker>
    ),
    RfidSticker,
    PrefetchHooks Function()> {
  $$RfidStickersTableTableManager(_$AppDatabase db, $RfidStickersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RfidStickersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RfidStickersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RfidStickersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> stickerCode = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> vehiclePlate = const Value.absent(),
            Value<String?> vehicleMake = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RfidStickersCompanion(
            id: id,
            tenantId: tenantId,
            stickerCode: stickerCode,
            householdId: householdId,
            vehiclePlate: vehiclePlate,
            vehicleMake: vehicleMake,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String stickerCode,
            required String householdId,
            required String vehiclePlate,
            Value<String?> vehicleMake = const Value.absent(),
            required String status,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RfidStickersCompanion.insert(
            id: id,
            tenantId: tenantId,
            stickerCode: stickerCode,
            householdId: householdId,
            vehiclePlate: vehiclePlate,
            vehicleMake: vehicleMake,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RfidStickersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RfidStickersTable,
    RfidSticker,
    $$RfidStickersTableFilterComposer,
    $$RfidStickersTableOrderingComposer,
    $$RfidStickersTableAnnotationComposer,
    $$RfidStickersTableCreateCompanionBuilder,
    $$RfidStickersTableUpdateCompanionBuilder,
    (
      RfidSticker,
      BaseReferences<_$AppDatabase, $RfidStickersTable, RfidSticker>
    ),
    RfidSticker,
    PrefetchHooks Function()>;
typedef $$PreRegisteredGuestsTableCreateCompanionBuilder
    = PreRegisteredGuestsCompanion Function({
  required String id,
  required String householdId,
  required String guestName,
  Value<String?> guestContact,
  Value<int?> durationHours,
  required String purpose,
  Value<String?> vehiclePlate,
  required String status,
  Value<DateTime?> checkedInAt,
  Value<String?> entryLogId,
  required String createdBy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PreRegisteredGuestsTableUpdateCompanionBuilder
    = PreRegisteredGuestsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> guestName,
  Value<String?> guestContact,
  Value<int?> durationHours,
  Value<String> purpose,
  Value<String?> vehiclePlate,
  Value<String> status,
  Value<DateTime?> checkedInAt,
  Value<String?> entryLogId,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PreRegisteredGuestsTableFilterComposer
    extends Composer<_$AppDatabase, $PreRegisteredGuestsTable> {
  $$PreRegisteredGuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guestName => $composableBuilder(
      column: $table.guestName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guestContact => $composableBuilder(
      column: $table.guestContact, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationHours => $composableBuilder(
      column: $table.durationHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkedInAt => $composableBuilder(
      column: $table.checkedInAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PreRegisteredGuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PreRegisteredGuestsTable> {
  $$PreRegisteredGuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guestName => $composableBuilder(
      column: $table.guestName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guestContact => $composableBuilder(
      column: $table.guestContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationHours => $composableBuilder(
      column: $table.durationHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkedInAt => $composableBuilder(
      column: $table.checkedInAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PreRegisteredGuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreRegisteredGuestsTable> {
  $$PreRegisteredGuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get guestName =>
      $composableBuilder(column: $table.guestName, builder: (column) => column);

  GeneratedColumn<String> get guestContact => $composableBuilder(
      column: $table.guestContact, builder: (column) => column);

  GeneratedColumn<int> get durationHours => $composableBuilder(
      column: $table.durationHours, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedInAt => $composableBuilder(
      column: $table.checkedInAt, builder: (column) => column);

  GeneratedColumn<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreRegisteredGuestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PreRegisteredGuestsTable,
    PreRegisteredGuest,
    $$PreRegisteredGuestsTableFilterComposer,
    $$PreRegisteredGuestsTableOrderingComposer,
    $$PreRegisteredGuestsTableAnnotationComposer,
    $$PreRegisteredGuestsTableCreateCompanionBuilder,
    $$PreRegisteredGuestsTableUpdateCompanionBuilder,
    (
      PreRegisteredGuest,
      BaseReferences<_$AppDatabase, $PreRegisteredGuestsTable,
          PreRegisteredGuest>
    ),
    PreRegisteredGuest,
    PrefetchHooks Function()> {
  $$PreRegisteredGuestsTableTableManager(
      _$AppDatabase db, $PreRegisteredGuestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreRegisteredGuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreRegisteredGuestsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreRegisteredGuestsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> guestName = const Value.absent(),
            Value<String?> guestContact = const Value.absent(),
            Value<int?> durationHours = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<String?> vehiclePlate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> checkedInAt = const Value.absent(),
            Value<String?> entryLogId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreRegisteredGuestsCompanion(
            id: id,
            householdId: householdId,
            guestName: guestName,
            guestContact: guestContact,
            durationHours: durationHours,
            purpose: purpose,
            vehiclePlate: vehiclePlate,
            status: status,
            checkedInAt: checkedInAt,
            entryLogId: entryLogId,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String guestName,
            Value<String?> guestContact = const Value.absent(),
            Value<int?> durationHours = const Value.absent(),
            required String purpose,
            Value<String?> vehiclePlate = const Value.absent(),
            required String status,
            Value<DateTime?> checkedInAt = const Value.absent(),
            Value<String?> entryLogId = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PreRegisteredGuestsCompanion.insert(
            id: id,
            householdId: householdId,
            guestName: guestName,
            guestContact: guestContact,
            durationHours: durationHours,
            purpose: purpose,
            vehiclePlate: vehiclePlate,
            status: status,
            checkedInAt: checkedInAt,
            entryLogId: entryLogId,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PreRegisteredGuestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PreRegisteredGuestsTable,
    PreRegisteredGuest,
    $$PreRegisteredGuestsTableFilterComposer,
    $$PreRegisteredGuestsTableOrderingComposer,
    $$PreRegisteredGuestsTableAnnotationComposer,
    $$PreRegisteredGuestsTableCreateCompanionBuilder,
    $$PreRegisteredGuestsTableUpdateCompanionBuilder,
    (
      PreRegisteredGuest,
      BaseReferences<_$AppDatabase, $PreRegisteredGuestsTable,
          PreRegisteredGuest>
    ),
    PreRegisteredGuest,
    PrefetchHooks Function()>;
typedef $$GuestLogsTableCreateCompanionBuilder = GuestLogsCompanion Function({
  required String id,
  required String entryLogId,
  required String guestName,
  required String householdId,
  required String purpose,
  required String verificationMethod,
  Value<bool> householdContacted,
  Value<String?> householdResponse,
  Value<DateTime?> exitTimestamp,
  Value<int?> visitDurationMinutes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GuestLogsTableUpdateCompanionBuilder = GuestLogsCompanion Function({
  Value<String> id,
  Value<String> entryLogId,
  Value<String> guestName,
  Value<String> householdId,
  Value<String> purpose,
  Value<String> verificationMethod,
  Value<bool> householdContacted,
  Value<String?> householdResponse,
  Value<DateTime?> exitTimestamp,
  Value<int?> visitDurationMinutes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GuestLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GuestLogsTable> {
  $$GuestLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guestName => $composableBuilder(
      column: $table.guestName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get householdContacted => $composableBuilder(
      column: $table.householdContacted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdResponse => $composableBuilder(
      column: $table.householdResponse,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get visitDurationMinutes => $composableBuilder(
      column: $table.visitDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GuestLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuestLogsTable> {
  $$GuestLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guestName => $composableBuilder(
      column: $table.guestName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get householdContacted => $composableBuilder(
      column: $table.householdContacted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdResponse => $composableBuilder(
      column: $table.householdResponse,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get visitDurationMinutes => $composableBuilder(
      column: $table.visitDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GuestLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuestLogsTable> {
  $$GuestLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => column);

  GeneratedColumn<String> get guestName =>
      $composableBuilder(column: $table.guestName, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get verificationMethod => $composableBuilder(
      column: $table.verificationMethod, builder: (column) => column);

  GeneratedColumn<bool> get householdContacted => $composableBuilder(
      column: $table.householdContacted, builder: (column) => column);

  GeneratedColumn<String> get householdResponse => $composableBuilder(
      column: $table.householdResponse, builder: (column) => column);

  GeneratedColumn<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => column);

  GeneratedColumn<int> get visitDurationMinutes => $composableBuilder(
      column: $table.visitDurationMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GuestLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GuestLogsTable,
    GuestLog,
    $$GuestLogsTableFilterComposer,
    $$GuestLogsTableOrderingComposer,
    $$GuestLogsTableAnnotationComposer,
    $$GuestLogsTableCreateCompanionBuilder,
    $$GuestLogsTableUpdateCompanionBuilder,
    (GuestLog, BaseReferences<_$AppDatabase, $GuestLogsTable, GuestLog>),
    GuestLog,
    PrefetchHooks Function()> {
  $$GuestLogsTableTableManager(_$AppDatabase db, $GuestLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuestLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuestLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuestLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryLogId = const Value.absent(),
            Value<String> guestName = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<String> verificationMethod = const Value.absent(),
            Value<bool> householdContacted = const Value.absent(),
            Value<String?> householdResponse = const Value.absent(),
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> visitDurationMinutes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GuestLogsCompanion(
            id: id,
            entryLogId: entryLogId,
            guestName: guestName,
            householdId: householdId,
            purpose: purpose,
            verificationMethod: verificationMethod,
            householdContacted: householdContacted,
            householdResponse: householdResponse,
            exitTimestamp: exitTimestamp,
            visitDurationMinutes: visitDurationMinutes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryLogId,
            required String guestName,
            required String householdId,
            required String purpose,
            required String verificationMethod,
            Value<bool> householdContacted = const Value.absent(),
            Value<String?> householdResponse = const Value.absent(),
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> visitDurationMinutes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GuestLogsCompanion.insert(
            id: id,
            entryLogId: entryLogId,
            guestName: guestName,
            householdId: householdId,
            purpose: purpose,
            verificationMethod: verificationMethod,
            householdContacted: householdContacted,
            householdResponse: householdResponse,
            exitTimestamp: exitTimestamp,
            visitDurationMinutes: visitDurationMinutes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GuestLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GuestLogsTable,
    GuestLog,
    $$GuestLogsTableFilterComposer,
    $$GuestLogsTableOrderingComposer,
    $$GuestLogsTableAnnotationComposer,
    $$GuestLogsTableCreateCompanionBuilder,
    $$GuestLogsTableUpdateCompanionBuilder,
    (GuestLog, BaseReferences<_$AppDatabase, $GuestLogsTable, GuestLog>),
    GuestLog,
    PrefetchHooks Function()>;
typedef $$DeliveryLogsTableCreateCompanionBuilder = DeliveryLogsCompanion
    Function({
  required String id,
  required String entryLogId,
  required String deliveryCompany,
  required String recipientHouseholdId,
  required String packageType,
  Value<String?> packageDescription,
  Value<bool> recipientContacted,
  Value<bool?> recipientAvailable,
  Value<String?> specialInstructions,
  required DateTime entryTimestamp,
  Value<DateTime?> exitTimestamp,
  Value<int?> deliveryDurationMinutes,
  Value<bool> durationAlertSent,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DeliveryLogsTableUpdateCompanionBuilder = DeliveryLogsCompanion
    Function({
  Value<String> id,
  Value<String> entryLogId,
  Value<String> deliveryCompany,
  Value<String> recipientHouseholdId,
  Value<String> packageType,
  Value<String?> packageDescription,
  Value<bool> recipientContacted,
  Value<bool?> recipientAvailable,
  Value<String?> specialInstructions,
  Value<DateTime> entryTimestamp,
  Value<DateTime?> exitTimestamp,
  Value<int?> deliveryDurationMinutes,
  Value<bool> durationAlertSent,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DeliveryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryLogsTable> {
  $$DeliveryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryCompany => $composableBuilder(
      column: $table.deliveryCompany,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipientHouseholdId => $composableBuilder(
      column: $table.recipientHouseholdId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageType => $composableBuilder(
      column: $table.packageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageDescription => $composableBuilder(
      column: $table.packageDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get recipientContacted => $composableBuilder(
      column: $table.recipientContacted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get recipientAvailable => $composableBuilder(
      column: $table.recipientAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deliveryDurationMinutes => $composableBuilder(
      column: $table.deliveryDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get durationAlertSent => $composableBuilder(
      column: $table.durationAlertSent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DeliveryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryLogsTable> {
  $$DeliveryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryCompany => $composableBuilder(
      column: $table.deliveryCompany,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipientHouseholdId => $composableBuilder(
      column: $table.recipientHouseholdId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageType => $composableBuilder(
      column: $table.packageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageDescription => $composableBuilder(
      column: $table.packageDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get recipientContacted => $composableBuilder(
      column: $table.recipientContacted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get recipientAvailable => $composableBuilder(
      column: $table.recipientAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deliveryDurationMinutes => $composableBuilder(
      column: $table.deliveryDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get durationAlertSent => $composableBuilder(
      column: $table.durationAlertSent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DeliveryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryLogsTable> {
  $$DeliveryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => column);

  GeneratedColumn<String> get deliveryCompany => $composableBuilder(
      column: $table.deliveryCompany, builder: (column) => column);

  GeneratedColumn<String> get recipientHouseholdId => $composableBuilder(
      column: $table.recipientHouseholdId, builder: (column) => column);

  GeneratedColumn<String> get packageType => $composableBuilder(
      column: $table.packageType, builder: (column) => column);

  GeneratedColumn<String> get packageDescription => $composableBuilder(
      column: $table.packageDescription, builder: (column) => column);

  GeneratedColumn<bool> get recipientContacted => $composableBuilder(
      column: $table.recipientContacted, builder: (column) => column);

  GeneratedColumn<bool> get recipientAvailable => $composableBuilder(
      column: $table.recipientAvailable, builder: (column) => column);

  GeneratedColumn<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions, builder: (column) => column);

  GeneratedColumn<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => column);

  GeneratedColumn<int> get deliveryDurationMinutes => $composableBuilder(
      column: $table.deliveryDurationMinutes, builder: (column) => column);

  GeneratedColumn<bool> get durationAlertSent => $composableBuilder(
      column: $table.durationAlertSent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DeliveryLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveryLogsTable,
    DeliveryLog,
    $$DeliveryLogsTableFilterComposer,
    $$DeliveryLogsTableOrderingComposer,
    $$DeliveryLogsTableAnnotationComposer,
    $$DeliveryLogsTableCreateCompanionBuilder,
    $$DeliveryLogsTableUpdateCompanionBuilder,
    (
      DeliveryLog,
      BaseReferences<_$AppDatabase, $DeliveryLogsTable, DeliveryLog>
    ),
    DeliveryLog,
    PrefetchHooks Function()> {
  $$DeliveryLogsTableTableManager(_$AppDatabase db, $DeliveryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryLogId = const Value.absent(),
            Value<String> deliveryCompany = const Value.absent(),
            Value<String> recipientHouseholdId = const Value.absent(),
            Value<String> packageType = const Value.absent(),
            Value<String?> packageDescription = const Value.absent(),
            Value<bool> recipientContacted = const Value.absent(),
            Value<bool?> recipientAvailable = const Value.absent(),
            Value<String?> specialInstructions = const Value.absent(),
            Value<DateTime> entryTimestamp = const Value.absent(),
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> deliveryDurationMinutes = const Value.absent(),
            Value<bool> durationAlertSent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveryLogsCompanion(
            id: id,
            entryLogId: entryLogId,
            deliveryCompany: deliveryCompany,
            recipientHouseholdId: recipientHouseholdId,
            packageType: packageType,
            packageDescription: packageDescription,
            recipientContacted: recipientContacted,
            recipientAvailable: recipientAvailable,
            specialInstructions: specialInstructions,
            entryTimestamp: entryTimestamp,
            exitTimestamp: exitTimestamp,
            deliveryDurationMinutes: deliveryDurationMinutes,
            durationAlertSent: durationAlertSent,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryLogId,
            required String deliveryCompany,
            required String recipientHouseholdId,
            required String packageType,
            Value<String?> packageDescription = const Value.absent(),
            Value<bool> recipientContacted = const Value.absent(),
            Value<bool?> recipientAvailable = const Value.absent(),
            Value<String?> specialInstructions = const Value.absent(),
            required DateTime entryTimestamp,
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> deliveryDurationMinutes = const Value.absent(),
            Value<bool> durationAlertSent = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveryLogsCompanion.insert(
            id: id,
            entryLogId: entryLogId,
            deliveryCompany: deliveryCompany,
            recipientHouseholdId: recipientHouseholdId,
            packageType: packageType,
            packageDescription: packageDescription,
            recipientContacted: recipientContacted,
            recipientAvailable: recipientAvailable,
            specialInstructions: specialInstructions,
            entryTimestamp: entryTimestamp,
            exitTimestamp: exitTimestamp,
            deliveryDurationMinutes: deliveryDurationMinutes,
            durationAlertSent: durationAlertSent,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeliveryLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeliveryLogsTable,
    DeliveryLog,
    $$DeliveryLogsTableFilterComposer,
    $$DeliveryLogsTableOrderingComposer,
    $$DeliveryLogsTableAnnotationComposer,
    $$DeliveryLogsTableCreateCompanionBuilder,
    $$DeliveryLogsTableUpdateCompanionBuilder,
    (
      DeliveryLog,
      BaseReferences<_$AppDatabase, $DeliveryLogsTable, DeliveryLog>
    ),
    DeliveryLog,
    PrefetchHooks Function()>;
typedef $$ConstructionPermitsTableCreateCompanionBuilder
    = ConstructionPermitsCompanion Function({
  required String id,
  required String tenantId,
  required String householdId,
  required String permitReference,
  required String projectDescription,
  required String contractorName,
  required String contractorContact,
  required String authorizedWorkers,
  required String status,
  Value<String?> approvedBy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ConstructionPermitsTableUpdateCompanionBuilder
    = ConstructionPermitsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> householdId,
  Value<String> permitReference,
  Value<String> projectDescription,
  Value<String> contractorName,
  Value<String> contractorContact,
  Value<String> authorizedWorkers,
  Value<String> status,
  Value<String?> approvedBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ConstructionPermitsTableFilterComposer
    extends Composer<_$AppDatabase, $ConstructionPermitsTable> {
  $$ConstructionPermitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permitReference => $composableBuilder(
      column: $table.permitReference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectDescription => $composableBuilder(
      column: $table.projectDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractorName => $composableBuilder(
      column: $table.contractorName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractorContact => $composableBuilder(
      column: $table.contractorContact,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorizedWorkers => $composableBuilder(
      column: $table.authorizedWorkers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ConstructionPermitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConstructionPermitsTable> {
  $$ConstructionPermitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permitReference => $composableBuilder(
      column: $table.permitReference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectDescription => $composableBuilder(
      column: $table.projectDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractorName => $composableBuilder(
      column: $table.contractorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractorContact => $composableBuilder(
      column: $table.contractorContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorizedWorkers => $composableBuilder(
      column: $table.authorizedWorkers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConstructionPermitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConstructionPermitsTable> {
  $$ConstructionPermitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get permitReference => $composableBuilder(
      column: $table.permitReference, builder: (column) => column);

  GeneratedColumn<String> get projectDescription => $composableBuilder(
      column: $table.projectDescription, builder: (column) => column);

  GeneratedColumn<String> get contractorName => $composableBuilder(
      column: $table.contractorName, builder: (column) => column);

  GeneratedColumn<String> get contractorContact => $composableBuilder(
      column: $table.contractorContact, builder: (column) => column);

  GeneratedColumn<String> get authorizedWorkers => $composableBuilder(
      column: $table.authorizedWorkers, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConstructionPermitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConstructionPermitsTable,
    ConstructionPermit,
    $$ConstructionPermitsTableFilterComposer,
    $$ConstructionPermitsTableOrderingComposer,
    $$ConstructionPermitsTableAnnotationComposer,
    $$ConstructionPermitsTableCreateCompanionBuilder,
    $$ConstructionPermitsTableUpdateCompanionBuilder,
    (
      ConstructionPermit,
      BaseReferences<_$AppDatabase, $ConstructionPermitsTable,
          ConstructionPermit>
    ),
    ConstructionPermit,
    PrefetchHooks Function()> {
  $$ConstructionPermitsTableTableManager(
      _$AppDatabase db, $ConstructionPermitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConstructionPermitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConstructionPermitsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConstructionPermitsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> permitReference = const Value.absent(),
            Value<String> projectDescription = const Value.absent(),
            Value<String> contractorName = const Value.absent(),
            Value<String> contractorContact = const Value.absent(),
            Value<String> authorizedWorkers = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> approvedBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConstructionPermitsCompanion(
            id: id,
            tenantId: tenantId,
            householdId: householdId,
            permitReference: permitReference,
            projectDescription: projectDescription,
            contractorName: contractorName,
            contractorContact: contractorContact,
            authorizedWorkers: authorizedWorkers,
            status: status,
            approvedBy: approvedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String householdId,
            required String permitReference,
            required String projectDescription,
            required String contractorName,
            required String contractorContact,
            required String authorizedWorkers,
            required String status,
            Value<String?> approvedBy = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConstructionPermitsCompanion.insert(
            id: id,
            tenantId: tenantId,
            householdId: householdId,
            permitReference: permitReference,
            projectDescription: projectDescription,
            contractorName: contractorName,
            contractorContact: contractorContact,
            authorizedWorkers: authorizedWorkers,
            status: status,
            approvedBy: approvedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConstructionPermitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConstructionPermitsTable,
    ConstructionPermit,
    $$ConstructionPermitsTableFilterComposer,
    $$ConstructionPermitsTableOrderingComposer,
    $$ConstructionPermitsTableAnnotationComposer,
    $$ConstructionPermitsTableCreateCompanionBuilder,
    $$ConstructionPermitsTableUpdateCompanionBuilder,
    (
      ConstructionPermit,
      BaseReferences<_$AppDatabase, $ConstructionPermitsTable,
          ConstructionPermit>
    ),
    ConstructionPermit,
    PrefetchHooks Function()>;
typedef $$ConstructionWorkerLogsTableCreateCompanionBuilder
    = ConstructionWorkerLogsCompanion Function({
  required String id,
  required String entryLogId,
  required String permitId,
  required String workerName,
  required String workerIdNumber,
  required DateTime entryTimestamp,
  Value<DateTime?> exitTimestamp,
  Value<int?> timeOnsiteMinutes,
  Value<bool> currentlyOnsite,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ConstructionWorkerLogsTableUpdateCompanionBuilder
    = ConstructionWorkerLogsCompanion Function({
  Value<String> id,
  Value<String> entryLogId,
  Value<String> permitId,
  Value<String> workerName,
  Value<String> workerIdNumber,
  Value<DateTime> entryTimestamp,
  Value<DateTime?> exitTimestamp,
  Value<int?> timeOnsiteMinutes,
  Value<bool> currentlyOnsite,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ConstructionWorkerLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConstructionWorkerLogsTable> {
  $$ConstructionWorkerLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permitId => $composableBuilder(
      column: $table.permitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerName => $composableBuilder(
      column: $table.workerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerIdNumber => $composableBuilder(
      column: $table.workerIdNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeOnsiteMinutes => $composableBuilder(
      column: $table.timeOnsiteMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get currentlyOnsite => $composableBuilder(
      column: $table.currentlyOnsite,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ConstructionWorkerLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConstructionWorkerLogsTable> {
  $$ConstructionWorkerLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permitId => $composableBuilder(
      column: $table.permitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerName => $composableBuilder(
      column: $table.workerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerIdNumber => $composableBuilder(
      column: $table.workerIdNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeOnsiteMinutes => $composableBuilder(
      column: $table.timeOnsiteMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get currentlyOnsite => $composableBuilder(
      column: $table.currentlyOnsite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ConstructionWorkerLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConstructionWorkerLogsTable> {
  $$ConstructionWorkerLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryLogId => $composableBuilder(
      column: $table.entryLogId, builder: (column) => column);

  GeneratedColumn<String> get permitId =>
      $composableBuilder(column: $table.permitId, builder: (column) => column);

  GeneratedColumn<String> get workerName => $composableBuilder(
      column: $table.workerName, builder: (column) => column);

  GeneratedColumn<String> get workerIdNumber => $composableBuilder(
      column: $table.workerIdNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get entryTimestamp => $composableBuilder(
      column: $table.entryTimestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get exitTimestamp => $composableBuilder(
      column: $table.exitTimestamp, builder: (column) => column);

  GeneratedColumn<int> get timeOnsiteMinutes => $composableBuilder(
      column: $table.timeOnsiteMinutes, builder: (column) => column);

  GeneratedColumn<bool> get currentlyOnsite => $composableBuilder(
      column: $table.currentlyOnsite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConstructionWorkerLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConstructionWorkerLogsTable,
    ConstructionWorkerLog,
    $$ConstructionWorkerLogsTableFilterComposer,
    $$ConstructionWorkerLogsTableOrderingComposer,
    $$ConstructionWorkerLogsTableAnnotationComposer,
    $$ConstructionWorkerLogsTableCreateCompanionBuilder,
    $$ConstructionWorkerLogsTableUpdateCompanionBuilder,
    (
      ConstructionWorkerLog,
      BaseReferences<_$AppDatabase, $ConstructionWorkerLogsTable,
          ConstructionWorkerLog>
    ),
    ConstructionWorkerLog,
    PrefetchHooks Function()> {
  $$ConstructionWorkerLogsTableTableManager(
      _$AppDatabase db, $ConstructionWorkerLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConstructionWorkerLogsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ConstructionWorkerLogsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConstructionWorkerLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryLogId = const Value.absent(),
            Value<String> permitId = const Value.absent(),
            Value<String> workerName = const Value.absent(),
            Value<String> workerIdNumber = const Value.absent(),
            Value<DateTime> entryTimestamp = const Value.absent(),
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> timeOnsiteMinutes = const Value.absent(),
            Value<bool> currentlyOnsite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConstructionWorkerLogsCompanion(
            id: id,
            entryLogId: entryLogId,
            permitId: permitId,
            workerName: workerName,
            workerIdNumber: workerIdNumber,
            entryTimestamp: entryTimestamp,
            exitTimestamp: exitTimestamp,
            timeOnsiteMinutes: timeOnsiteMinutes,
            currentlyOnsite: currentlyOnsite,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryLogId,
            required String permitId,
            required String workerName,
            required String workerIdNumber,
            required DateTime entryTimestamp,
            Value<DateTime?> exitTimestamp = const Value.absent(),
            Value<int?> timeOnsiteMinutes = const Value.absent(),
            Value<bool> currentlyOnsite = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConstructionWorkerLogsCompanion.insert(
            id: id,
            entryLogId: entryLogId,
            permitId: permitId,
            workerName: workerName,
            workerIdNumber: workerIdNumber,
            entryTimestamp: entryTimestamp,
            exitTimestamp: exitTimestamp,
            timeOnsiteMinutes: timeOnsiteMinutes,
            currentlyOnsite: currentlyOnsite,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConstructionWorkerLogsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConstructionWorkerLogsTable,
        ConstructionWorkerLog,
        $$ConstructionWorkerLogsTableFilterComposer,
        $$ConstructionWorkerLogsTableOrderingComposer,
        $$ConstructionWorkerLogsTableAnnotationComposer,
        $$ConstructionWorkerLogsTableCreateCompanionBuilder,
        $$ConstructionWorkerLogsTableUpdateCompanionBuilder,
        (
          ConstructionWorkerLog,
          BaseReferences<_$AppDatabase, $ConstructionWorkerLogsTable,
              ConstructionWorkerLog>
        ),
        ConstructionWorkerLog,
        PrefetchHooks Function()>;
typedef $$IncidentReportsTableCreateCompanionBuilder = IncidentReportsCompanion
    Function({
  required String id,
  required String tenantId,
  required String guardId,
  required String incidentType,
  required String severity,
  required String location,
  required String description,
  Value<String?> involvedParties,
  Value<String?> photos,
  required DateTime timestamp,
  Value<bool> dispatchNotified,
  Value<String?> dispatchResponse,
  Value<String?> resolution,
  required String status,
  Value<DateTime?> resolvedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$IncidentReportsTableUpdateCompanionBuilder = IncidentReportsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> guardId,
  Value<String> incidentType,
  Value<String> severity,
  Value<String> location,
  Value<String> description,
  Value<String?> involvedParties,
  Value<String?> photos,
  Value<DateTime> timestamp,
  Value<bool> dispatchNotified,
  Value<String?> dispatchResponse,
  Value<String?> resolution,
  Value<String> status,
  Value<DateTime?> resolvedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$IncidentReportsTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentReportsTable> {
  $$IncidentReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardId => $composableBuilder(
      column: $table.guardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get incidentType => $composableBuilder(
      column: $table.incidentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get involvedParties => $composableBuilder(
      column: $table.involvedParties,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photos => $composableBuilder(
      column: $table.photos, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dispatchNotified => $composableBuilder(
      column: $table.dispatchNotified,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dispatchResponse => $composableBuilder(
      column: $table.dispatchResponse,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$IncidentReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentReportsTable> {
  $$IncidentReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardId => $composableBuilder(
      column: $table.guardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get incidentType => $composableBuilder(
      column: $table.incidentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get involvedParties => $composableBuilder(
      column: $table.involvedParties,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photos => $composableBuilder(
      column: $table.photos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dispatchNotified => $composableBuilder(
      column: $table.dispatchNotified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dispatchResponse => $composableBuilder(
      column: $table.dispatchResponse,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$IncidentReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentReportsTable> {
  $$IncidentReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get guardId =>
      $composableBuilder(column: $table.guardId, builder: (column) => column);

  GeneratedColumn<String> get incidentType => $composableBuilder(
      column: $table.incidentType, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get involvedParties => $composableBuilder(
      column: $table.involvedParties, builder: (column) => column);

  GeneratedColumn<String> get photos =>
      $composableBuilder(column: $table.photos, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get dispatchNotified => $composableBuilder(
      column: $table.dispatchNotified, builder: (column) => column);

  GeneratedColumn<String> get dispatchResponse => $composableBuilder(
      column: $table.dispatchResponse, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IncidentReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IncidentReportsTable,
    IncidentReport,
    $$IncidentReportsTableFilterComposer,
    $$IncidentReportsTableOrderingComposer,
    $$IncidentReportsTableAnnotationComposer,
    $$IncidentReportsTableCreateCompanionBuilder,
    $$IncidentReportsTableUpdateCompanionBuilder,
    (
      IncidentReport,
      BaseReferences<_$AppDatabase, $IncidentReportsTable, IncidentReport>
    ),
    IncidentReport,
    PrefetchHooks Function()> {
  $$IncidentReportsTableTableManager(
      _$AppDatabase db, $IncidentReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> guardId = const Value.absent(),
            Value<String> incidentType = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> involvedParties = const Value.absent(),
            Value<String?> photos = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> dispatchNotified = const Value.absent(),
            Value<String?> dispatchResponse = const Value.absent(),
            Value<String?> resolution = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncidentReportsCompanion(
            id: id,
            tenantId: tenantId,
            guardId: guardId,
            incidentType: incidentType,
            severity: severity,
            location: location,
            description: description,
            involvedParties: involvedParties,
            photos: photos,
            timestamp: timestamp,
            dispatchNotified: dispatchNotified,
            dispatchResponse: dispatchResponse,
            resolution: resolution,
            status: status,
            resolvedAt: resolvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String guardId,
            required String incidentType,
            required String severity,
            required String location,
            required String description,
            Value<String?> involvedParties = const Value.absent(),
            Value<String?> photos = const Value.absent(),
            required DateTime timestamp,
            Value<bool> dispatchNotified = const Value.absent(),
            Value<String?> dispatchResponse = const Value.absent(),
            Value<String?> resolution = const Value.absent(),
            required String status,
            Value<DateTime?> resolvedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              IncidentReportsCompanion.insert(
            id: id,
            tenantId: tenantId,
            guardId: guardId,
            incidentType: incidentType,
            severity: severity,
            location: location,
            description: description,
            involvedParties: involvedParties,
            photos: photos,
            timestamp: timestamp,
            dispatchNotified: dispatchNotified,
            dispatchResponse: dispatchResponse,
            resolution: resolution,
            status: status,
            resolvedAt: resolvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IncidentReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IncidentReportsTable,
    IncidentReport,
    $$IncidentReportsTableFilterComposer,
    $$IncidentReportsTableOrderingComposer,
    $$IncidentReportsTableAnnotationComposer,
    $$IncidentReportsTableCreateCompanionBuilder,
    $$IncidentReportsTableUpdateCompanionBuilder,
    (
      IncidentReport,
      BaseReferences<_$AppDatabase, $IncidentReportsTable, IncidentReport>
    ),
    IncidentReport,
    PrefetchHooks Function()>;
typedef $$VillageRulesTableCreateCompanionBuilder = VillageRulesCompanion
    Function({
  required String id,
  required String tenantId,
  required String ruleCategory,
  required String ruleTitle,
  required String ruleDescription,
  Value<String?> enforcementInstructions,
  Value<bool> active,
  required String createdBy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$VillageRulesTableUpdateCompanionBuilder = VillageRulesCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> ruleCategory,
  Value<String> ruleTitle,
  Value<String> ruleDescription,
  Value<String?> enforcementInstructions,
  Value<bool> active,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$VillageRulesTableFilterComposer
    extends Composer<_$AppDatabase, $VillageRulesTable> {
  $$VillageRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleCategory => $composableBuilder(
      column: $table.ruleCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleTitle => $composableBuilder(
      column: $table.ruleTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleDescription => $composableBuilder(
      column: $table.ruleDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get enforcementInstructions => $composableBuilder(
      column: $table.enforcementInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$VillageRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $VillageRulesTable> {
  $$VillageRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleCategory => $composableBuilder(
      column: $table.ruleCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleTitle => $composableBuilder(
      column: $table.ruleTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleDescription => $composableBuilder(
      column: $table.ruleDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enforcementInstructions => $composableBuilder(
      column: $table.enforcementInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VillageRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillageRulesTable> {
  $$VillageRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get ruleCategory => $composableBuilder(
      column: $table.ruleCategory, builder: (column) => column);

  GeneratedColumn<String> get ruleTitle =>
      $composableBuilder(column: $table.ruleTitle, builder: (column) => column);

  GeneratedColumn<String> get ruleDescription => $composableBuilder(
      column: $table.ruleDescription, builder: (column) => column);

  GeneratedColumn<String> get enforcementInstructions => $composableBuilder(
      column: $table.enforcementInstructions, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VillageRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VillageRulesTable,
    VillageRule,
    $$VillageRulesTableFilterComposer,
    $$VillageRulesTableOrderingComposer,
    $$VillageRulesTableAnnotationComposer,
    $$VillageRulesTableCreateCompanionBuilder,
    $$VillageRulesTableUpdateCompanionBuilder,
    (
      VillageRule,
      BaseReferences<_$AppDatabase, $VillageRulesTable, VillageRule>
    ),
    VillageRule,
    PrefetchHooks Function()> {
  $$VillageRulesTableTableManager(_$AppDatabase db, $VillageRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillageRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillageRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillageRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> ruleCategory = const Value.absent(),
            Value<String> ruleTitle = const Value.absent(),
            Value<String> ruleDescription = const Value.absent(),
            Value<String?> enforcementInstructions = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VillageRulesCompanion(
            id: id,
            tenantId: tenantId,
            ruleCategory: ruleCategory,
            ruleTitle: ruleTitle,
            ruleDescription: ruleDescription,
            enforcementInstructions: enforcementInstructions,
            active: active,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String ruleCategory,
            required String ruleTitle,
            required String ruleDescription,
            Value<String?> enforcementInstructions = const Value.absent(),
            Value<bool> active = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VillageRulesCompanion.insert(
            id: id,
            tenantId: tenantId,
            ruleCategory: ruleCategory,
            ruleTitle: ruleTitle,
            ruleDescription: ruleDescription,
            enforcementInstructions: enforcementInstructions,
            active: active,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VillageRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VillageRulesTable,
    VillageRule,
    $$VillageRulesTableFilterComposer,
    $$VillageRulesTableOrderingComposer,
    $$VillageRulesTableAnnotationComposer,
    $$VillageRulesTableCreateCompanionBuilder,
    $$VillageRulesTableUpdateCompanionBuilder,
    (
      VillageRule,
      BaseReferences<_$AppDatabase, $VillageRulesTable, VillageRule>
    ),
    VillageRule,
    PrefetchHooks Function()>;
typedef $$AnnouncementsTableCreateCompanionBuilder = AnnouncementsCompanion
    Function({
  required String id,
  required String tenantId,
  required String title,
  required String message,
  required String priority,
  required String targetAudience,
  required String createdBy,
  required DateTime createdAt,
  Value<DateTime?> expiresAt,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$AnnouncementsTableUpdateCompanionBuilder = AnnouncementsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> title,
  Value<String> message,
  Value<String> priority,
  Value<String> targetAudience,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
  Value<bool> active,
  Value<int> rowid,
});

class $$AnnouncementsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));
}

class $$AnnouncementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));
}

class $$AnnouncementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$AnnouncementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnouncementsTable,
    Announcement,
    $$AnnouncementsTableFilterComposer,
    $$AnnouncementsTableOrderingComposer,
    $$AnnouncementsTableAnnotationComposer,
    $$AnnouncementsTableCreateCompanionBuilder,
    $$AnnouncementsTableUpdateCompanionBuilder,
    (
      Announcement,
      BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>
    ),
    Announcement,
    PrefetchHooks Function()> {
  $$AnnouncementsTableTableManager(_$AppDatabase db, $AnnouncementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnouncementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnouncementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnouncementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> targetAudience = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnouncementsCompanion(
            id: id,
            tenantId: tenantId,
            title: title,
            message: message,
            priority: priority,
            targetAudience: targetAudience,
            createdBy: createdBy,
            createdAt: createdAt,
            expiresAt: expiresAt,
            active: active,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String title,
            required String message,
            required String priority,
            required String targetAudience,
            required String createdBy,
            required DateTime createdAt,
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnouncementsCompanion.insert(
            id: id,
            tenantId: tenantId,
            title: title,
            message: message,
            priority: priority,
            targetAudience: targetAudience,
            createdBy: createdBy,
            createdAt: createdAt,
            expiresAt: expiresAt,
            active: active,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnnouncementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnnouncementsTable,
    Announcement,
    $$AnnouncementsTableFilterComposer,
    $$AnnouncementsTableOrderingComposer,
    $$AnnouncementsTableAnnotationComposer,
    $$AnnouncementsTableCreateCompanionBuilder,
    $$AnnouncementsTableUpdateCompanionBuilder,
    (
      Announcement,
      BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>
    ),
    Announcement,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String operation,
  required String entityType,
  required String entityId,
  required String payload,
  required int timestamp,
  Value<int> retryCount,
  required String status,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> operation,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payload,
  Value<int> timestamp,
  Value<int> retryCount,
  Value<String> status,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntry,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            operation: operation,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            timestamp: timestamp,
            retryCount: retryCount,
            status: status,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operation,
            required String entityType,
            required String entityId,
            required String payload,
            required int timestamp,
            Value<int> retryCount = const Value.absent(),
            required String status,
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            operation: operation,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            timestamp: timestamp,
            retryCount: retryCount,
            status: status,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntry,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntryLogsTableTableManager get entryLogs =>
      $$EntryLogsTableTableManager(_db, _db.entryLogs);
  $$RfidStickersTableTableManager get rfidStickers =>
      $$RfidStickersTableTableManager(_db, _db.rfidStickers);
  $$PreRegisteredGuestsTableTableManager get preRegisteredGuests =>
      $$PreRegisteredGuestsTableTableManager(_db, _db.preRegisteredGuests);
  $$GuestLogsTableTableManager get guestLogs =>
      $$GuestLogsTableTableManager(_db, _db.guestLogs);
  $$DeliveryLogsTableTableManager get deliveryLogs =>
      $$DeliveryLogsTableTableManager(_db, _db.deliveryLogs);
  $$ConstructionPermitsTableTableManager get constructionPermits =>
      $$ConstructionPermitsTableTableManager(_db, _db.constructionPermits);
  $$ConstructionWorkerLogsTableTableManager get constructionWorkerLogs =>
      $$ConstructionWorkerLogsTableTableManager(
          _db, _db.constructionWorkerLogs);
  $$IncidentReportsTableTableManager get incidentReports =>
      $$IncidentReportsTableTableManager(_db, _db.incidentReports);
  $$VillageRulesTableTableManager get villageRules =>
      $$VillageRulesTableTableManager(_db, _db.villageRules);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db, _db.announcements);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
