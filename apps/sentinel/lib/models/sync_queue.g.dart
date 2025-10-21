// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncQueue _$SyncQueueFromJson(Map<String, dynamic> json) => SyncQueue(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  operation: $enumDecode(_$SyncOperationEnumMap, json['operation']),
  entityType: json['entityType'] as String,
  entityId: json['entityId'] as String,
  payload: json['payload'] as Map<String, dynamic>,
  priority: $enumDecode(_$SyncPriorityEnumMap, json['priority']),
  retryCount: (json['retryCount'] as num).toInt(),
  maxRetries: (json['maxRetries'] as num).toInt(),
  scheduledFor: DateTime.parse(json['scheduledFor'] as String),
  lastAttemptAt: json['lastAttemptAt'] == null
      ? null
      : DateTime.parse(json['lastAttemptAt'] as String),
  nextAttemptAt: DateTime.parse(json['nextAttemptAt'] as String),
  status: $enumDecode(_$SyncStatusEnumMap, json['status']),
  errorMessage: json['errorMessage'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SyncQueueToJson(SyncQueue instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'operation': _$SyncOperationEnumMap[instance.operation]!,
  'entityType': instance.entityType,
  'entityId': instance.entityId,
  'payload': instance.payload,
  'priority': _$SyncPriorityEnumMap[instance.priority]!,
  'retryCount': instance.retryCount,
  'maxRetries': instance.maxRetries,
  'scheduledFor': instance.scheduledFor.toIso8601String(),
  'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
  'nextAttemptAt': instance.nextAttemptAt.toIso8601String(),
  'status': _$SyncStatusEnumMap[instance.status]!,
  'errorMessage': instance.errorMessage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'CREATE',
  SyncOperation.update: 'UPDATE',
  SyncOperation.delete: 'DELETE',
};

const _$SyncPriorityEnumMap = {
  SyncPriority.critical: 'critical',
  SyncPriority.high: 'high',
  SyncPriority.normal: 'normal',
  SyncPriority.low: 'low',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.processing: 'processing',
  SyncStatus.completed: 'completed',
  SyncStatus.failed: 'failed',
  SyncStatus.cancelled: 'cancelled',
};
