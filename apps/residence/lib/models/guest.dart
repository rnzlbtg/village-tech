/// Guest model for scheduled visits
class Guest {
  final String id;
  final String householdId;
  final String guestName;
  final String? contactNumber;
  final String visitType;
  final DateTime visitStart;
  final DateTime visitEnd;
  final String? purpose;
  final String? vehiclePlate;
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Guest({
    required this.id,
    required this.householdId,
    required this.guestName,
    this.contactNumber,
    required this.visitType,
    required this.visitStart,
    required this.visitEnd,
    this.purpose,
    this.vehiclePlate,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      guestName: json['guest_name'] as String,
      contactNumber: json['contact_number'] as String?,
      visitType: json['visit_type'] as String,
      visitStart: DateTime.parse(json['visit_start'] as String),
      visitEnd: DateTime.parse(json['visit_end'] as String),
      purpose: json['purpose'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      status: json['status'] as String,
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
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
      'guest_name': guestName,
      'contact_number': contactNumber,
      'visit_type': visitType,
      'visit_start': visitStart.toIso8601String(),
      'visit_end': visitEnd.toIso8601String(),
      'purpose': purpose,
      'vehicle_plate': vehiclePlate,
      'status': status,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  Guest copyWith({
    String? id,
    String? householdId,
    String? guestName,
    String? contactNumber,
    String? visitType,
    DateTime? visitStart,
    DateTime? visitEnd,
    String? purpose,
    String? vehiclePlate,
    String? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guest(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      guestName: guestName ?? this.guestName,
      contactNumber: contactNumber ?? this.contactNumber,
      visitType: visitType ?? this.visitType,
      visitStart: visitStart ?? this.visitStart,
      visitEnd: visitEnd ?? this.visitEnd,
      purpose: purpose ?? this.purpose,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Visit type display name
  String get visitTypeDisplay {
    switch (visitType.toLowerCase()) {
      case 'day_trip':
        return 'Day Trip';
      case 'multi_day':
        return 'Multi-Day';
      default:
        return visitType;
    }
  }

  /// Status display name
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'checked_in':
        return 'Checked In';
      case 'checked_out':
        return 'Checked Out';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Check if visit is scheduled
  bool get isScheduled => status.toLowerCase() == 'scheduled';

  /// Check if guest is checked in
  bool get isCheckedIn => status.toLowerCase() == 'checked_in';

  /// Check if guest is checked out
  bool get isCheckedOut => status.toLowerCase() == 'checked_out';

  /// Check if visit is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Check if visit is upcoming (scheduled and visit start is in the future)
  bool get isUpcoming {
    if (!isScheduled) return false;
    return visitStart.isAfter(DateTime.now());
  }

  /// Check if visit is active (scheduled and currently within visit window)
  bool get isActive {
    if (!isScheduled && !isCheckedIn) return false;
    final now = DateTime.now();
    return now.isAfter(visitStart) && now.isBefore(visitEnd);
  }

  /// Check if visit is past (visit end is in the past or checked out)
  bool get isPast {
    if (isCheckedOut) return true;
    return visitEnd.isBefore(DateTime.now());
  }

  /// Get duration of visit in hours
  int get durationInHours {
    return visitEnd.difference(visitStart).inHours;
  }

  /// Get duration of visit in days
  int get durationInDays {
    return visitEnd.difference(visitStart).inDays;
  }

  /// Get time until visit starts (in duration)
  Duration? get timeUntilStart {
    if (!isUpcoming) return null;
    return visitStart.difference(DateTime.now());
  }

  /// Get formatted countdown string
  String get countdownString {
    final duration = timeUntilStart;
    if (duration == null) return '';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Check if visit is a day trip
  bool get isDayTrip => visitType.toLowerCase() == 'day_trip';

  /// Check if visit is multi-day
  bool get isMultiDay => visitType.toLowerCase() == 'multi_day';

  /// Get guest initials
  String get initials {
    final names = guestName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return guestName.substring(0, 1).toUpperCase();
  }
}

/// Guest visit type constants
class GuestVisitType {
  static const String dayTrip = 'day_trip';
  static const String multiDay = 'multi_day';

  static const List<String> all = [dayTrip, multiDay];

  static const Map<String, String> displayNames = {
    dayTrip: 'Day Trip',
    multiDay: 'Multi-Day',
  };
}

/// Guest status constants
class GuestStatus {
  static const String scheduled = 'scheduled';
  static const String checkedIn = 'checked_in';
  static const String checkedOut = 'checked_out';
  static const String cancelled = 'cancelled';

  static const List<String> all = [scheduled, checkedIn, checkedOut, cancelled];

  static const Map<String, String> displayNames = {
    scheduled: 'Scheduled',
    checkedIn: 'Checked In',
    checkedOut: 'Checked Out',
    cancelled: 'Cancelled',
  };
}
