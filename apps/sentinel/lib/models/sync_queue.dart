import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'sync_queue.g.dart';

/// Sync Queue model for offline operations management
@JsonSerializable()
class SyncQueue {
  final String id;
  final String tenantId;
  final SyncOperation operation;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final SyncPriority priority;
  final int retryCount;
  final int maxRetries;
  final DateTime scheduledFor;
  final DateTime? lastAttemptAt;
  final DateTime nextAttemptAt;
  final SyncStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncQueue({
    required this.id,
    required this.tenantId,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.priority,
    required this.retryCount,
    required this.maxRetries,
    required this.scheduledFor,
    this.lastAttemptAt,
    required this.nextAttemptAt,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new sync operation
  factory SyncQueue.create({
    required String tenantId,
    required SyncOperation operation,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    SyncPriority priority = SyncPriority.normal,
    int maxRetries = 5,
    DateTime? scheduledFor,
  }) {
    final now = DateTime.now();
    return SyncQueue(
      id: const Uuid().v4(),
      tenantId: tenantId,
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      priority: priority,
      retryCount: 0,
      maxRetries: maxRetries,
      scheduledFor: scheduledFor ?? now,
      lastAttemptAt: null,
      nextAttemptAt: scheduledFor ?? now,
      status: SyncStatus.pending,
      errorMessage: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create sync queue from JSON
  factory SyncQueue.fromJson(Map<String, dynamic> json) => _$SyncQueueFromJson(json);

  /// Convert sync queue to JSON
  Map<String, dynamic> toJson() => _$SyncQueueToJson(this);

  /// Create a copy with updated fields
  SyncQueue copyWith({
    String? id,
    String? tenantId,
    SyncOperation? operation,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? payload,
    SyncPriority? priority,
    int? retryCount,
    int? maxRetries,
    DateTime? scheduledFor,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    SyncStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncQueue(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as processing
  SyncQueue markAsProcessing() {
    return copyWith(
      status: SyncStatus.processing,
      lastAttemptAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as completed
  SyncQueue markAsCompleted() {
    return copyWith(
      status: SyncStatus.completed,
      lastAttemptAt: DateTime.now(),
      errorMessage: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as failed and schedule retry
  SyncQueue markAsFailed(String error) {
    final newRetryCount = retryCount + 1;
    final hasMoreRetries = newRetryCount < maxRetries;

    // Calculate exponential backoff delay
    final retryDelay = _calculateRetryDelay(newRetryCount);
    final nextAttempt = DateTime.now().add(retryDelay);

    return copyWith(
      status: hasMoreRetries ? SyncStatus.pending : SyncStatus.failed,
      retryCount: newRetryCount,
      lastAttemptAt: DateTime.now(),
      nextAttemptAt: nextAttempt,
      errorMessage: error,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as cancelled
  SyncQueue markAsCancelled(String? reason) {
    return copyWith(
      status: SyncStatus.cancelled,
      errorMessage: reason,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate retry delay with exponential backoff
  Duration _calculateRetryDelay(int attemptNumber) {
    // Exponential backoff: 1min, 2min, 4min, 8min, 16min (capped at 1 hour)
    final baseDelay = Duration(minutes: 1);
    final maxDelay = Duration(hours: 1);

    final exponentialDelay = baseDelay * (1 << (attemptNumber - 1).clamp(0, 6));
    return exponentialDelay.compareTo(maxDelay) < 0 ? exponentialDelay : maxDelay;
  }

  /// Check if operation can be retried
  bool get canRetry => retryCount < maxRetries && status == SyncStatus.pending;

  /// Check if operation is ready to be processed
  bool get isReadyToProcess =>
      status == SyncStatus.pending &&
      DateTime.now().isAfter(nextAttemptAt);

  /// Check if operation is expired (too old)
  bool get isExpired {
    const maxAge = Duration(days: 7); // Maximum 7 days old
    return DateTime.now().difference(createdAt) > maxAge;
  }

  /// Get priority value for sorting
  int get priorityValue {
    switch (priority) {
      case SyncPriority.critical:
        return 4;
      case SyncPriority.high:
        return 3;
      case SyncPriority.normal:
        return 2;
      case SyncPriority.low:
        return 1;
    }
  }

  /// Get operation display name
  String get operationDisplayName {
    switch (operation) {
      case SyncOperation.create:
        return 'Create';
      case SyncOperation.update:
        return 'Update';
      case SyncOperation.delete:
        return 'Delete';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.processing:
        return 'Processing';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case SyncPriority.critical:
        return 'Critical';
      case SyncPriority.high:
        return 'High';
      case SyncPriority.normal:
        return 'Normal';
      case SyncPriority.low:
        return 'Low';
    }
  }

  /// Validate sync queue data
  bool isValidData() {
    return _validateTenantId(tenantId) &&
        _validateEntityType(entityType) &&
        _validateEntityId(entityId) &&
        _validatePayload(payload);
  }

  bool _validateTenantId(String id) {
    return id.trim().isNotEmpty;
  }

  bool _validateEntityType(String type) {
    final validTypes = ['guard', 'rfid_sticker', 'entry_log', 'guard_session', 'guest', 'delivery', 'incident'];
    return validTypes.contains(type.toLowerCase());
  }

  bool _validateEntityId(String id) {
    return id.trim().isNotEmpty;
  }

  bool _validatePayload(Map<String, dynamic> payload) {
    return payload.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SyncQueue(id: $id, operation: $operation, entityType: $entityType, status: $status, priority: $priority)';
  }
}

/// Sync operation enumeration
enum SyncOperation {
  @JsonValue('CREATE')
  create('Create', 'Create new entity'),

  @JsonValue('UPDATE')
  update('Update', 'Update existing entity'),

  @JsonValue('DELETE')
  delete('Delete', 'Delete entity');

  const SyncOperation(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get operation from string value
  static SyncOperation fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CREATE':
        return SyncOperation.create;
      case 'UPDATE':
        return SyncOperation.update;
      case 'DELETE':
        return SyncOperation.delete;
      default:
        throw ArgumentError('Invalid SyncOperation: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case SyncOperation.create:
        return 'CREATE';
      case SyncOperation.update:
        return 'UPDATE';
      case SyncOperation.delete:
        return 'DELETE';
    }
  }
}

/// Sync priority enumeration
enum SyncPriority {
  @JsonValue('critical')
  critical('Critical', 'Immediate processing required'),

  @JsonValue('high')
  high('High', 'Process as soon as possible'),

  @JsonValue('normal')
  normal('Normal', 'Standard processing'),

  @JsonValue('low')
  low('Low', 'Process when resources available');

  const SyncPriority(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get priority from string value
  static SyncPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return SyncPriority.critical;
      case 'high':
        return SyncPriority.high;
      case 'normal':
        return SyncPriority.normal;
      case 'low':
        return SyncPriority.low;
      default:
        throw ArgumentError('Invalid SyncPriority: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case SyncPriority.critical:
        return 'critical';
      case SyncPriority.high:
        return 'high';
      case SyncPriority.normal:
        return 'normal';
      case SyncPriority.low:
        return 'low';
    }
  }
}

/// Sync status enumeration
enum SyncStatus {
  @JsonValue('pending')
  pending('Pending', 'Waiting to be processed'),

  @JsonValue('processing')
  processing('Processing', 'Currently being processed'),

  @JsonValue('completed')
  completed('Completed', 'Successfully processed'),

  @JsonValue('failed')
  failed('Failed', 'Processing failed, may retry'),

  @JsonValue('cancelled')
  cancelled('Cancelled', 'Operation cancelled');

  const SyncStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get status from string value
  static SyncStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return SyncStatus.pending;
      case 'processing':
        return SyncStatus.processing;
      case 'completed':
        return SyncStatus.completed;
      case 'failed':
        return SyncStatus.failed;
      case 'cancelled':
        return SyncStatus.cancelled;
      default:
        throw ArgumentError('Invalid SyncStatus: $value');
    }
  }

  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.processing:
        return 'processing';
      case SyncStatus.completed:
        return 'completed';
      case SyncStatus.failed:
        return 'failed';
      case SyncStatus.cancelled:
        return 'cancelled';
    }
  }
}

/// Sync queue validation errors
enum SyncQueueValidationError {
  tenantIdInvalid,
  entityTypeInvalid,
  entityIdInvalid,
  payloadInvalid,
  operationInvalid,
  priorityInvalid,
  maxRetriesInvalid,
}

/// Sync queue validation result
class SyncQueueValidationResult {
  final bool isValid;
  final List<SyncQueueValidationError> errors;

  const SyncQueueValidationResult(this.isValid, this.errors);

  factory SyncQueueValidationResult.success() {
    return const SyncQueueValidationResult(true, []);
  }

  factory SyncQueueValidationResult.failure(List<SyncQueueValidationError> errors) {
    return SyncQueueValidationResult(false, errors);
  }
}

/// Sync batch operation result
class SyncBatchResult {
  final int total;
  final int processed;
  final int successful;
  final int failed;
  final List<String> errors;
  final Duration duration;

  const SyncBatchResult({
    required this.total,
    required this.processed,
    required this.successful,
    required this.failed,
    required this.errors,
    required this.duration,
  });

  /// Get success rate
  double get successRate => processed > 0 ? successful / processed : 0.0;

  /// Check if batch was successful
  bool get isSuccessful => failed == 0 && processed == total;

  @override
  String toString() {
    return 'SyncBatchResult(total: $total, processed: $processed, successful: $successful, failed: $failed, duration: ${duration.inMilliseconds}ms)';
  }
}