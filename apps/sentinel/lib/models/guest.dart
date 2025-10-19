import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'guest.g.dart';

/// Guest status enumeration
enum GuestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('checked_in')
  checkedIn,
  @JsonValue('checked_out')
  checkedOut,
  @JsonValue('cancelled')
  cancelled,
}

/// Guest model for pre-registered visitor management
@HiveType(typeId: 3)
@JsonSerializable()
class Guest extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'tenant_id')
  final String tenantId;

  @HiveField(2)
  @JsonKey(name: 'household_id')
  final String householdId;

  @HiveField(3)
  @JsonKey(name: 'guest_name')
  final String guestName;

  @HiveField(4)
  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  @HiveField(5)
  @JsonKey(name: 'purpose')
  final String purpose;

  @HiveField(6)
  @JsonKey(name: 'scheduled_date')
  final DateTime scheduledDate;

  @HiveField(7)
  @JsonKey(name: 'expected_arrival')
  final String expectedArrival; // TimeOfDay stored as string

  @HiveField(8)
  @JsonKey(name: 'expected_departure')
  final String expectedDeparture; // TimeOfDay stored as string

  @HiveField(9)
  @JsonKey(name: 'status')
  final GuestStatus status;

  @HiveField(10)
  @JsonKey(name: 'vehicle_info')
  final String? vehicleInfo;

  @HiveField(11)
  @JsonKey(name: 'notes')
  final String? notes;

  @HiveField(12)
  @JsonKey(name: 'approved_by_guard_id')
  final String? approvedByGuardId;

  @HiveField(13)
  @JsonKey(name: 'actual_arrival')
  final DateTime? actualArrival;

  @HiveField(14)
  @JsonKey(name: 'actual_departure')
  final DateTime? actualDeparture;

  @HiveField(15)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(16)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Guest({
    required this.id,
    required this.tenantId,
    required this.householdId,
    required this.guestName,
    required this.phoneNumber,
    required this.purpose,
    required this.scheduledDate,
    required this.expectedArrival,
    required this.expectedDeparture,
    required this.status,
    this.vehicleInfo,
    this.notes,
    this.approvedByGuardId,
    this.actualArrival,
    this.actualDeparture,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Guest from JSON
  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);

  /// Convert Guest to JSON
  Map<String, dynamic> toJson() => _$GuestToJson(this);

  /// Create a copy with updated fields
  Guest copyWith({
    String? id,
    String? tenantId,
    String? householdId,
    String? guestName,
    String? phoneNumber,
    String? purpose,
    DateTime? scheduledDate,
    String? expectedArrival,
    String? expectedDeparture,
    GuestStatus? status,
    String? vehicleInfo,
    String? notes,
    String? approvedByGuardId,
    DateTime? actualArrival,
    DateTime? actualDeparture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guest(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      householdId: householdId ?? this.householdId,
      guestName: guestName ?? this.guestName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      purpose: purpose ?? this.purpose,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      expectedArrival: expectedArrival ?? this.expectedArrival,
      expectedDeparture: expectedDeparture ?? this.expectedDeparture,
      status: status ?? this.status,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      notes: notes ?? this.notes,
      approvedByGuardId: approvedByGuardId ?? this.approvedByGuardId,
      actualArrival: actualArrival ?? this.actualArrival,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get expected arrival time as TimeOfDay
  TimeOfDay get expectedArrivalTime {
    final parts = expectedArrival.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get expected departure time as TimeOfDay
  TimeOfDay get expectedDepartureTime {
    final parts = expectedDeparture.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Check if guest is currently checked in
  bool get isCheckedIn => status == GuestStatus.checkedIn;

  /// Check if guest has been checked out
  bool get isCheckedOut => status == GuestStatus.checkedOut;

  /// Check if guest visit is still pending
  bool get isPending => status == GuestStatus.pending;

  /// Check if guest visit is cancelled
  bool get isCancelled => status == GuestStatus.cancelled;

  /// Check if guest has arrived but not departed
  bool get isOnSite => isCheckedIn && actualArrival != null && actualDeparture == null;

  /// Calculate duration of visit (if completed)
  Duration? get visitDuration {
    if (actualArrival != null && actualDeparture != null) {
      return actualDeparture!.difference(actualArrival!);
    }
    return null;
  }

  /// Check if guest is late for expected arrival
  bool get isLate {
    if (actualArrival != null) {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        expectedArrivalTime.hour,
        expectedArrivalTime.minute,
      );
      return actualArrival!.isAfter(scheduledDateTime);
    }
    return false;
  }

  /// Check if guest is overdue for expected departure
  bool get isOverdue {
    if (isOnSite) {
      final now = DateTime.now();
      final scheduledDepartureDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        expectedDepartureTime.hour,
        expectedDepartureTime.minute,
      );
      return now.isAfter(scheduledDepartureDateTime);
    }
    return false;
  }

  /// Check if guest registration is for today
  bool get isForToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
           scheduledDate.month == now.month &&
           scheduledDate.day == now.day;
  }

  /// Check if guest registration is for future date
  bool get isFuture {
    final now = DateTime.now();
    return scheduledDate.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Check if guest registration is for past date
  bool get isPast {
    final now = DateTime.now();
    return scheduledDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Get display status text
  String get statusDisplayText {
    switch (status) {
      case GuestStatus.pending:
        return 'Pending';
      case GuestStatus.checkedIn:
        return 'Checked In';
      case GuestStatus.checkedOut:
        return 'Checked Out';
      case GuestStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Validate guest data
  List<String> validate() {
    final errors = <String>[];

    // Guest name validation
    if (guestName.trim().isEmpty) {
      errors.add('Guest name is required');
    } else if (guestName.trim().length < 2) {
      errors.add('Guest name must be at least 2 characters');
    } else if (guestName.trim().length > 100) {
      errors.add('Guest name must be less than 100 characters');
    }

    // Phone number validation
    if (phoneNumber.trim().isEmpty) {
      errors.add('Phone number is required');
    } else if (!RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(phoneNumber)) {
      errors.add('Phone number format is invalid');
    }

    // Purpose validation
    if (purpose.trim().isEmpty) {
      errors.add('Purpose of visit is required');
    } else if (purpose.trim().length < 3) {
      errors.add('Purpose must be at least 3 characters');
    } else if (purpose.trim().length > 200) {
      errors.add('Purpose must be less than 200 characters');
    }

    // Household ID validation
    if (householdId.trim().isEmpty) {
      errors.add('Household is required');
    }

    // Scheduled date validation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDay = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    if (scheduledDay.isBefore(today)) {
      errors.add('Scheduled date cannot be in the past');
    }

    // Check if scheduled date is more than 30 days in advance
    if (scheduledDay.difference(today).inDays > 30) {
      errors.add('Guest registration cannot be more than 30 days in advance');
    }

    // Vehicle info validation (if provided)
    if (vehicleInfo != null && vehicleInfo!.trim().isNotEmpty) {
      if (vehicleInfo!.trim().length > 200) {
        errors.add('Vehicle information must be less than 200 characters');
      }
    }

    // Notes validation (if provided)
    if (notes != null && notes!.trim().isNotEmpty) {
      if (notes!.trim().length > 500) {
        errors.add('Notes must be less than 500 characters');
      }
    }

    return errors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Guest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Guest{id: $id, guestName: $guestName, status: $status, scheduledDate: $scheduledDate}';
  }
}

/// TimeOfDay utility class for guest scheduling
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  /// Convert TimeOfDay to string format (HH:MM)
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Create TimeOfDay from string format (HH:MM)
  static TimeOfDay fromTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => toTimeString();
}

/// Guest validation helper
class GuestValidator {
  /// Validate guest registration for business rules
  static List<String> validateBusinessRules({
    required DateTime scheduledDate,
    required String householdId,
    required List<Guest> existingGuests,
  }) {
    final errors = <String>[];

    // Check maximum 10 guests per household per day
    final guestsForHouseholdOnDate = existingGuests.where((guest) =>
        guest.householdId == householdId &&
        guest.scheduledDate.year == scheduledDate.year &&
        guest.scheduledDate.month == scheduledDate.month &&
        guest.scheduledDate.day == scheduledDate.day &&
        guest.status != GuestStatus.cancelled
    ).length;

    if (guestsForHouseholdOnDate >= 10) {
      errors.add('Maximum 10 guests per household per day');
    }

    return errors;
  }

  /// Check if guest should be auto-cancelled (no show)
  static bool shouldAutoCancel(Guest guest) {
    if (guest.status != GuestStatus.pending) return false;

    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      guest.scheduledDate.year,
      guest.scheduledDate.month,
      guest.scheduledDate.day,
      guest.expectedArrivalTime.hour,
      guest.expectedArrivalTime.minute,
    );

    // Auto-cancel if not arrived within 2 hours of expected time
    return now.difference(scheduledDateTime).inHours > 2;
  }
}