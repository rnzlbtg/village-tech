import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentinel/core/storage/database.dart';
import 'package:sentinel/core/storage/tables.dart';

/// Conflict Resolution Service
/// Handles data conflicts between local and server during synchronization
class ConflictResolution {
  ConflictResolution._();
  static final ConflictResolution _instance = ConflictResolution._();
  static ConflictResolution get instance => _instance;

  final Logger _logger = Logger();

  /// Resolve conflicts for entry logs
  Future<ConflictResolutionResult> resolveEntryLogConflict({
    required EntryLog localEntry,
    required Map<String, dynamic> serverEntry,
    required ConflictStrategy strategy,
  }) async {
    try {
      _logger.i('Resolving entry log conflict for ${localEntry.id} using $strategy');

      switch (strategy) {
        case ConflictStrategy.clientWins:
          return _resolveClientWins(localEntry, serverEntry, 'entry_logs');

        case ConflictStrategy.serverWins:
          return _resolveServerWins(localEntry, serverEntry, 'entry_logs');

        case ConflictStrategy.lastModifiedWins:
          return _resolveLastModifiedWins(localEntry, serverEntry, 'entry_logs');

        case ConflictStrategy.merge:
          return _mergeEntryLogs(localEntry, serverEntry);

        case ConflictStrategy.manual:
          return ConflictResolutionResult(
            resolution: ConflictResolutionType.manual,
            resolvedData: localEntry,
            requiresUserAction: true,
            conflictDetails: _buildConflictDetails(localEntry, serverEntry),
          );

        default:
          throw ArgumentError('Unknown conflict strategy: $strategy');
      }
    } catch (e) {
      _logger.e('Error resolving entry log conflict: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Resolve conflicts for guest logs
  Future<ConflictResolutionResult> resolveGuestLogConflict({
    required GuestLog localLog,
    required Map<String, dynamic> serverLog,
    required ConflictStrategy strategy,
  }) async {
    try {
      _logger.i('Resolving guest log conflict for ${localLog.id} using $strategy');

      switch (strategy) {
        case ConflictStrategy.clientWins:
          return _resolveClientWins(localLog, serverLog, 'guest_logs');

        case ConflictStrategy.serverWins:
          return _resolveServerWins(localLog, serverLog, 'guest_logs');

        case ConflictStrategy.lastModifiedWins:
          return _resolveLastModifiedWins(localLog, serverLog, 'guest_logs');

        case ConflictStrategy.merge:
          return _mergeGuestLogs(localLog, serverLog);

        case ConflictStrategy.manual:
          return ConflictResolutionResult(
            resolution: ConflictResolutionType.manual,
            resolvedData: localLog,
            requiresUserAction: true,
            conflictDetails: _buildConflictDetails(localLog, serverLog),
          );

        default:
          throw ArgumentError('Unknown conflict strategy: $strategy');
      }
    } catch (e) {
      _logger.e('Error resolving guest log conflict: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Resolve conflicts for delivery logs
  Future<ConflictResolutionResult> resolveDeliveryLogConflict({
    required DeliveryLog localLog,
    required Map<String, dynamic> serverLog,
    required ConflictStrategy strategy,
  }) async {
    try {
      _logger.i('Resolving delivery log conflict for ${localLog.id} using $strategy');

      switch (strategy) {
        case ConflictStrategy.clientWins:
          return _resolveClientWins(localLog, serverLog, 'delivery_logs');

        case ConflictStrategy.serverWins:
          return _resolveServerWins(localLog, serverLog, 'delivery_logs');

        case ConflictStrategy.lastModifiedWins:
          return _resolveLastModifiedWins(localLog, serverLog, 'delivery_logs');

        case ConflictStrategy.merge:
          return _mergeDeliveryLogs(localLog, serverLog);

        case ConflictStrategy.manual:
          return ConflictResolutionResult(
            resolution: ConflictResolutionType.manual,
            resolvedData: localLog,
            requiresUserAction: true,
            conflictDetails: _buildConflictDetails(localLog, serverLog),
          );

        default:
          throw ArgumentError('Unknown conflict strategy: $strategy');
      }
    } catch (e) {
      _logger.e('Error resolving delivery log conflict: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Resolve conflicts for incident reports
  Future<ConflictResolutionResult> resolveIncidentReportConflict({
    required IncidentReport localReport,
    required Map<String, dynamic> serverReport,
    required ConflictStrategy strategy,
  }) async {
    try {
      _logger.i('Resolving incident report conflict for ${localReport.id} using $strategy');

      switch (strategy) {
        case ConflictStrategy.clientWins:
          return _resolveClientWins(localReport, serverReport, 'incident_reports');

        case ConflictStrategy.serverWins:
          return _resolveServerWins(localReport, serverReport, 'incident_reports');

        case ConflictStrategy.lastModifiedWins:
          return _resolveLastModifiedWins(localReport, serverReport, 'incident_reports');

        case ConflictStrategy.merge:
          return _mergeIncidentReports(localReport, serverReport);

        case ConflictStrategy.manual:
          return ConflictResolutionResult(
            resolution: ConflictResolutionType.manual,
            resolvedData: localReport,
            requiresUserAction: true,
            conflictDetails: _buildConflictDetails(localReport, serverReport),
          );

        default:
          throw ArgumentError('Unknown conflict strategy: $strategy');
      }
    } catch (e) {
      _logger.e('Error resolving incident report conflict: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Client wins resolution - local data overwrites server
  ConflictResolutionResult _resolveClientWins(
    dynamic localData,
    Map<String, dynamic> serverData,
    String entityType,
  ) {
    _logger.d('Client wins: keeping local data for $entityType');

    return ConflictResolutionResult(
      resolution: ConflictResolutionType.clientWins,
      resolvedData: localData,
      actionRequired: ConflictAction.updateServer,
    );
  }

  /// Server wins resolution - server data overwrites local
  ConflictResolutionResult _resolveServerWins(
    dynamic localData,
    Map<String, dynamic> serverData,
    String entityType,
  ) {
    _logger.d('Server wins: accepting server data for $entityType');

    return ConflictResolutionResult(
      resolution: ConflictResolutionType.serverWins,
      resolvedData: serverData,
      actionRequired: ConflictAction.updateLocal,
    );
  }

  /// Last modified wins resolution
  ConflictResolutionResult _resolveLastModifiedWins(
    dynamic localData,
    Map<String, dynamic> serverData,
    String entityType,
  ) {
    DateTime localModified;
    DateTime serverModified;

    try {
      if (localData is EntryLog) {
        localModified = localData.updatedAt;
        serverModified = DateTime.parse(serverData['updated_at']);
      } else if (localData is GuestLog) {
        localModified = localData.createdAt; // GuestLogs don't have updatedAt
        serverModified = DateTime.parse(serverData['created_at']);
      } else if (localData is DeliveryLog) {
        localModified = localData.createdAt;
        serverModified = DateTime.parse(serverData['created_at']);
      } else if (localData is IncidentReport) {
        localModified = localData.updatedAt;
        serverModified = DateTime.parse(serverData['updated_at']);
      } else {
        throw ArgumentError('Unsupported data type: ${localData.runtimeType}');
      }

      final winner = localModified.isAfter(serverModified) ? localData : serverData;
      final resolutionType = localModified.isAfter(serverModified)
          ? ConflictResolutionType.clientWins
          : ConflictResolutionType.serverWins;

      _logger.d('Last modified wins: $resolutionType for $entityType');

      return ConflictResolutionResult(
        resolution: resolutionType,
        resolvedData: winner,
        actionRequired: resolutionType == ConflictResolutionType.clientWins
            ? ConflictAction.updateServer
            : ConflictAction.updateLocal,
      );
    } catch (e) {
      _logger.e('Error determining last modified winner: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: 'Could not compare timestamps: $e',
      );
    }
  }

  /// Merge entry logs
  ConflictResolutionResult _mergeEntryLogs(
    EntryLog localEntry,
    Map<String, dynamic> serverEntry,
  ) {
    try {
      _logger.d('Merging entry logs for ${localEntry.id}');

      // Create merged data - prefer local for notes, preserve server for verification status
      final mergedData = <String, dynamic>{
        'id': localEntry.id,
        'tenant_id': localEntry.tenantId,
        'guard_id': localEntry.guardId,
        'entry_type': localEntry.entryType,
        'timestamp': localEntry.timestamp.toIso8601String(),
        'vehicle_info': localEntry.vehicleInfo,
        'person_info': localEntry.personInfo,
        'verification_method': localEntry.verificationMethod,
        'verification_status': serverEntry['verification_status'], // Prefer server status
        'denial_reason': localEntry.denialReason,
        'notes': localEntry.notes, // Prefer local notes
        'synced': true,
        'created_at': localEntry.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return ConflictResolutionResult(
        resolution: ConflictResolutionType.merged,
        resolvedData: mergedData,
        actionRequired: ConflictAction.updateBoth,
      );
    } catch (e) {
      _logger.e('Error merging entry logs: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Merge guest logs
  ConflictResolutionResult _mergeGuestLogs(
    GuestLog localLog,
    Map<String, dynamic> serverLog,
  ) {
    try {
      _logger.d('Merging guest logs for ${localLog.id}');

      // For guest logs, prefer more complete data
      final mergedData = <String, dynamic>{
        'id': localLog.id,
        'entry_log_id': localLog.entryLogId,
        'guest_name': localLog.guestName,
        'household_id': localLog.householdId,
        'purpose': localLog.purpose,
        'verification_method': localLog.verificationMethod,
        'household_contacted': localLog.householdContacted || serverLog['household_contacted'],
        'household_response': localLog.householdResponse ?? serverLog['household_response'],
        'exit_timestamp': localLog.exitTimestamp?.toIso8601String() ?? serverLog['exit_timestamp'],
        'visit_duration_minutes': localLog.visitDurationMinutes ?? serverLog['visit_duration_minutes'],
        'created_at': localLog.createdAt.toIso8601String(),
      };

      return ConflictResolutionResult(
        resolution: ConflictResolutionType.merged,
        resolvedData: mergedData,
        actionRequired: ConflictAction.updateBoth,
      );
    } catch (e) {
      _logger.e('Error merging guest logs: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Merge delivery logs
  ConflictResolutionResult _mergeDeliveryLogs(
    DeliveryLog localLog,
    Map<String, dynamic> serverLog,
  ) {
    try {
      _logger.d('Merging delivery logs for ${localLog.id}');

      // For delivery logs, prefer most recent status information
      final mergedData = <String, dynamic>{
        'id': localLog.id,
        'entry_log_id': localLog.entryLogId,
        'delivery_company': localLog.deliveryCompany,
        'recipient_household_id': localLog.recipientHouseholdId,
        'package_type': localLog.packageType,
        'package_description': localLog.packageDescription ?? serverLog['package_description'],
        'recipient_contacted': localLog.recipientContacted || serverLog['recipient_contacted'],
        'recipient_available': localLog.recipientAvailable ?? serverLog['recipient_available'],
        'special_instructions': localLog.specialInstructions ?? serverLog['special_instructions'],
        'entry_timestamp': localLog.entryTimestamp.toIso8601String(),
        'exit_timestamp': localLog.exitTimestamp?.toIso8601String() ?? serverLog['exit_timestamp'],
        'delivery_duration_minutes': localLog.deliveryDurationMinutes ?? serverLog['delivery_duration_minutes'],
        'duration_alert_sent': localLog.durationAlertSent || serverLog['duration_alert_sent'],
        'created_at': localLog.createdAt.toIso8601String(),
      };

      return ConflictResolutionResult(
        resolution: ConflictResolutionType.merged,
        resolvedData: mergedData,
        actionRequired: ConflictAction.updateBoth,
      );
    } catch (e) {
      _logger.e('Error merging delivery logs: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Merge incident reports
  ConflictResolutionResult _mergeIncidentReports(
    IncidentReport localReport,
    Map<String, dynamic> serverReport,
  ) {
    try {
      _logger.d('Merging incident reports for ${localReport.id}');

      // For incident reports, combine information and prefer latest updates
      final mergedData = <String, dynamic>{
        'id': localReport.id,
        'tenant_id': localReport.tenantId,
        'guard_id': localReport.guardId,
        'incident_type': localReport.incidentType,
        'severity': localReport.severity,
        'location': localReport.location,
        'description': localReport.description,
        'involved_parties': localReport.involvedParties,
        'photos': localReport.photos,
        'timestamp': localReport.timestamp.toIso8601String(),
        'dispatch_notified': localReport.dispatchNotified || serverReport['dispatch_notified'],
        'dispatch_response': localReport.dispatchResponse ?? serverReport['dispatch_response'],
        'resolution': localReport.resolution ?? serverReport['resolution'],
        'status': localReport.status, // Prefer local status
        'resolved_at': localReport.resolvedAt?.toIso8601String() ?? serverReport['resolved_at'],
        'created_at': localReport.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      return ConflictResolutionResult(
        resolution: ConflictResolutionType.merged,
        resolvedData: mergedData,
        actionRequired: ConflictAction.updateBoth,
      );
    } catch (e) {
      _logger.e('Error merging incident reports: $e');
      return ConflictResolutionResult(
        resolution: ConflictResolutionType.error,
        error: e.toString(),
      );
    }
  }

  /// Build conflict details for manual resolution
  Map<String, dynamic> _buildConflictDetails(dynamic localData, Map<String, dynamic> serverData) {
    return {
      'localData': localData is EntryLog
          ? _entryLogToJson(localData)
          : localData is GuestLog
              ? _guestLogToJson(localData)
              : localData is DeliveryLog
                  ? _deliveryLogToJson(localData)
                  : localData is IncidentReport
                      ? _incidentReportToJson(localData)
                      : localData.toString(),
      'serverData': serverData,
      'conflictFields': _identifyConflictFields(localData, serverData),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Identify fields that conflict between local and server data
  List<String> _identifyConflictFields(dynamic localData, Map<String, dynamic> serverData) {
    final conflicts = <String>[];

    try {
      Map<String, dynamic> localMap;

      if (localData is EntryLog) {
        localMap = _entryLogToJson(localData);
      } else if (localData is GuestLog) {
        localMap = _guestLogToJson(localData);
      } else if (localData is DeliveryLog) {
        localMap = _deliveryLogToJson(localData);
      } else if (localData is IncidentReport) {
        localMap = _incidentReportToJson(localData);
      } else {
        return conflicts;
      }

      // Compare fields
      for (final entry in localMap.entries) {
        final key = entry.key;
        final localValue = entry.value;
        final serverValue = serverData[key];

        if (localValue != serverValue) {
          conflicts.add(key);
        }
      }
    } catch (e) {
      _logger.e('Error identifying conflict fields: $e');
    }

    return conflicts;
  }

  // Convert data classes to JSON for comparison
  Map<String, dynamic> _entryLogToJson(EntryLog entry) {
    return {
      'id': entry.id,
      'tenant_id': entry.tenantId,
      'guard_id': entry.guardId,
      'entry_type': entry.entryType,
      'timestamp': entry.timestamp.toIso8601String(),
      'vehicle_info': entry.vehicleInfo,
      'person_info': entry.personInfo,
      'verification_method': entry.verificationMethod,
      'verification_status': entry.verificationStatus,
      'denial_reason': entry.denialReason,
      'notes': entry.notes,
      'synced': entry.synced,
      'created_at': entry.createdAt.toIso8601String(),
      'updated_at': entry.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _guestLogToJson(GuestLog log) {
    return {
      'id': log.id,
      'entry_log_id': log.entryLogId,
      'guest_name': log.guestName,
      'household_id': log.householdId,
      'purpose': log.purpose,
      'verification_method': log.verificationMethod,
      'household_contacted': log.householdContacted,
      'household_response': log.householdResponse,
      'exit_timestamp': log.exitTimestamp?.toIso8601String(),
      'visit_duration_minutes': log.visitDurationMinutes,
      'created_at': log.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _deliveryLogToJson(DeliveryLog log) {
    return {
      'id': log.id,
      'entry_log_id': log.entryLogId,
      'delivery_company': log.deliveryCompany,
      'recipient_household_id': log.recipientHouseholdId,
      'package_type': log.packageType,
      'package_description': log.packageDescription,
      'recipient_contacted': log.recipientContacted,
      'recipient_available': log.recipientAvailable,
      'special_instructions': log.specialInstructions,
      'entry_timestamp': log.entryTimestamp.toIso8601String(),
      'exit_timestamp': log.exitTimestamp?.toIso8601String(),
      'delivery_duration_minutes': log.deliveryDurationMinutes,
      'duration_alert_sent': log.durationAlertSent,
      'created_at': log.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _incidentReportToJson(IncidentReport report) {
    return {
      'id': report.id,
      'tenant_id': report.tenantId,
      'guard_id': report.guardId,
      'incident_type': report.incidentType,
      'severity': report.severity,
      'location': report.location,
      'description': report.description,
      'involved_parties': report.involvedParties,
      'photos': report.photos,
      'timestamp': report.timestamp.toIso8601String(),
      'dispatch_notified': report.dispatchNotified,
      'dispatch_response': report.dispatchResponse,
      'resolution': report.resolution,
      'status': report.status,
      'resolved_at': report.resolvedAt?.toIso8601String(),
      'created_at': report.createdAt.toIso8601String(),
      'updated_at': report.updatedAt.toIso8601String(),
    };
  }

  /// Get default conflict strategy for entity type
  ConflictStrategy getDefaultStrategy(String entityType) {
    switch (entityType) {
      case 'entry_logs':
        return ConflictStrategy.lastModifiedWins;
      case 'guest_logs':
        return ConflictStrategy.merge;
      case 'delivery_logs':
        return ConflictStrategy.merge;
      case 'incident_reports':
        return ConflictStrategy.lastModifiedWins;
      default:
        return ConflictStrategy.serverWins;
    }
  }

  /// Determine conflict strategy based on context
  ConflictStrategy determineStrategy({
    required String entityType,
    required DateTime localModified,
    required DateTime serverModified,
    ConflictStrategy? userPreference,
  }) {
    // User preference takes precedence
    if (userPreference != null) {
      return userPreference;
    }

    // For critical security data, prefer server
    if (entityType == 'entry_logs') {
      return ConflictStrategy.serverWins;
    }

    // For recent local changes, prefer client
    final timeDiff = DateTime.now().difference(localModified);
    if (timeDiff.inMinutes < 5) { // Recent local change
      return ConflictStrategy.clientWins;
    }

    // Default to last modified wins
    return ConflictStrategy.lastModifiedWins;
  }
}

/// Conflict resolution result
class ConflictResolutionResult {
  final ConflictResolutionType resolution;
  final dynamic resolvedData;
  final ConflictAction? actionRequired;
  final bool requiresUserAction;
  final Map<String, dynamic>? conflictDetails;
  final String? error;

  const ConflictResolutionResult({
    required this.resolution,
    this.resolvedData,
    this.actionRequired,
    this.requiresUserAction = false,
    this.conflictDetails,
    this.error,
  });

  @override
  String toString() {
    return 'ConflictResolutionResult(resolution: $resolution, requiresUserAction: $requiresUserAction)';
  }
}

/// Conflict resolution type
enum ConflictResolutionType {
  clientWins,
  serverWins,
  merged,
  manual,
  error,
}

/// Conflict action required
enum ConflictAction {
  updateLocal,
  updateServer,
  updateBoth,
  deleteLocal,
  deleteServer,
  none,
}

/// Conflict strategy
enum ConflictStrategy {
  clientWins,
  serverWins,
  lastModifiedWins,
  merge,
  manual,
}