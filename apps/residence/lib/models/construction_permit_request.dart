/// Construction permit request model
class ConstructionPermitRequest {
  final String id;
  final String householdId;
  final String projectType;
  final String description;
  final String contractorName;
  final String contractorContact;
  final DateTime startDate;
  final DateTime endDate;
  final int estimatedWorkers;
  final String status;
  final double? feeAmount;
  final bool? feePaid;
  final String? permitReference;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConstructionPermitRequest({
    required this.id,
    required this.householdId,
    required this.projectType,
    required this.description,
    required this.contractorName,
    required this.contractorContact,
    required this.startDate,
    required this.endDate,
    required this.estimatedWorkers,
    required this.status,
    this.feeAmount,
    this.feePaid,
    this.permitReference,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory ConstructionPermitRequest.fromJson(Map<String, dynamic> json) {
    return ConstructionPermitRequest(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      projectType: json['project_type'] as String,
      // Map project_description to description
      description: json['project_description'] as String? ?? json['description'] as String? ?? '',
      contractorName: json['contractor_name'] as String? ?? '',
      contractorContact: json['contractor_contact'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      // Map estimated_end_date to endDate
      endDate: DateTime.parse(json['estimated_end_date'] as String? ?? json['end_date'] as String),
      estimatedWorkers: json['estimated_workers'] as int? ?? 0,
      // Map permit_status to status
      status: json['permit_status'] as String? ?? json['status'] as String? ?? 'pending',
      // Map road_fee_amount to feeAmount
      feeAmount: (json['road_fee_amount'] ?? json['fee_amount']) != null
          ? ((json['road_fee_amount'] ?? json['fee_amount']) as num).toDouble()
          : null,
      feePaid: json['fee_paid'] as bool?,
      permitReference: json['permit_reference'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'project_type': projectType,
      'description': description,
      'contractor_name': contractorName,
      'contractor_contact': contractorContact,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'estimated_workers': estimatedWorkers,
      'status': status,
      'fee_amount': feeAmount,
      'fee_paid': feePaid,
      'permit_reference': permitReference,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  ConstructionPermitRequest copyWith({
    String? id,
    String? householdId,
    String? projectType,
    String? description,
    String? contractorName,
    String? contractorContact,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedWorkers,
    String? status,
    double? feeAmount,
    bool? feePaid,
    String? permitReference,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConstructionPermitRequest(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      projectType: projectType ?? this.projectType,
      description: description ?? this.description,
      contractorName: contractorName ?? this.contractorName,
      contractorContact: contractorContact ?? this.contractorContact,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      estimatedWorkers: estimatedWorkers ?? this.estimatedWorkers,
      status: status ?? this.status,
      feeAmount: feeAmount ?? this.feeAmount,
      feePaid: feePaid ?? this.feePaid,
      permitReference: permitReference ?? this.permitReference,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Project type display name
  String get projectTypeDisplay {
    switch (projectType.toLowerCase()) {
      case 'renovation':
        return 'Renovation';
      case 'addition':
        return 'Addition';
      case 'repair':
        return 'Repair';
      case 'landscaping':
        return 'Landscaping';
      case 'other':
        return 'Other';
      default:
        return projectType;
    }
  }

  /// Status display name
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'fee_pending':
        return 'Fee Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'on_hold':
        return 'On Hold';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Check if pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if fee pending
  bool get isFeePending => status.toLowerCase() == 'fee_pending';

  /// Check if approved
  bool get isApproved => status.toLowerCase() == 'approved';

  /// Check if rejected
  bool get isRejected => status.toLowerCase() == 'rejected';

  /// Check if cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Check if on hold
  bool get isOnHold => status.toLowerCase() == 'on_hold';

  /// Check if in progress
  bool get isInProgress => status.toLowerCase() == 'in_progress';

  /// Check if completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Check if project is active (approved and within date range)
  bool get isActive {
    if (!isApproved) return false;
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if project is upcoming (approved and start date is in future)
  bool get isUpcoming {
    if (!isApproved) return false;
    return startDate.isAfter(DateTime.now());
  }

  /// Check if project is past (end date in past or completed)
  bool get isPast {
    if (isCompleted) return true;
    return endDate.isBefore(DateTime.now());
  }

  /// Days until start
  int? get daysUntilStart {
    if (!isUpcoming) return null;
    return startDate.difference(DateTime.now()).inDays;
  }

  /// Days remaining
  int? get daysRemaining {
    if (!isActive) return null;
    return endDate.difference(DateTime.now()).inDays;
  }
}

/// Construction permit project type constants
class PermitProjectType {
  static const String renovation = 'renovation';
  static const String addition = 'addition';
  static const String repair = 'repair';
  static const String landscaping = 'landscaping';
  static const String other = 'other';

  static const List<String> all = [
    renovation,
    addition,
    repair,
    landscaping,
    other,
  ];

  static const Map<String, String> displayNames = {
    renovation: 'Renovation',
    addition: 'Addition',
    repair: 'Repair',
    landscaping: 'Landscaping',
    other: 'Other',
  };
}

/// Construction permit status constants
class PermitStatus {
  static const String pending = 'pending';
  static const String feePending = 'fee_pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
  static const String onHold = 'on_hold';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';

  static const List<String> all = [
    pending,
    feePending,
    approved,
    rejected,
    cancelled,
    onHold,
    inProgress,
    completed,
  ];

  static const Map<String, String> displayNames = {
    pending: 'Pending',
    feePending: 'Fee Pending',
    approved: 'Approved',
    rejected: 'Rejected',
    cancelled: 'Cancelled',
    onHold: 'On Hold',
    inProgress: 'In Progress',
    completed: 'Completed',
  };
}
