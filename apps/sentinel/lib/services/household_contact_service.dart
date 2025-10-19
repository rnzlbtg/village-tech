import 'dart:async';

/// Household contact service for communicating with household heads
class HouseholdContactService {
  // Mock data - will be replaced with actual household service
  final Map<String, HouseholdContact> _mockContacts = {
    'household-1': HouseholdContact(
      id: 'household-1',
      headName: 'John Doe',
      headPhone: '+1234567890',
      headEmail: 'john.doe@email.com',
      address: '123 Main St, Unit 101',
      alternateContact: 'Jane Doe',
      alternatePhone: '+0987654321',
    ),
    'household-2': HouseholdContact(
      id: 'household-2',
      headName: 'Jane Smith',
      headPhone: '+2345678901',
      headEmail: 'jane.smith@email.com',
      address: '456 Oak Ave, Unit 102',
      alternateContact: 'Bob Smith',
      alternatePhone: '+3456789012',
    ),
    'household-3': HouseholdContact(
      id: 'household-3',
      headName: 'Bob Johnson',
      headPhone: '+3456789012',
      headEmail: 'bob.johnson@email.com',
      address: '789 Pine Rd, Unit 201',
      alternateContact: 'Alice Johnson',
      alternatePhone: '+4567890123',
    ),
    'household-4': HouseholdContact(
      id: 'household-4',
      headName: 'Alice Brown',
      headPhone: '+4567890123',
      headEmail: 'alice.brown@email.com',
      address: '321 Elm St, Unit 202',
      alternateContact: 'Charlie Brown',
      alternatePhone: '+5678901234',
    ),
  };

  final List<ContactRecord> _contactHistory = [];

  /// Get household contact information
  Future<HouseholdContact?> getHouseholdContact(String householdId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockContacts[householdId];
  }

  /// Search household contacts by name or address
  Future<List<HouseholdContact>> searchHouseholdContacts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final results = _mockContacts.values.where((contact) =>
      contact.headName.toLowerCase().contains(query.toLowerCase()) ||
      contact.address.toLowerCase().contains(query.toLowerCase()) ||
      contact.alternateContact.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return results;
  }

  /// Call household head
  Future<ContactResult> callHouseholdHead(String householdId, {String? guestName}) async {
    final contact = _mockContacts[householdId];
    if (contact == null) {
      return ContactResult.success(
        type: ContactType.call,
        contactInfo: contact?.headPhone ?? '',
        timestamp: DateTime.now(),
        message: 'Contact not found',
        success: false,
      );
    }

    // Simulate call initiation
    await Future.delayed(const Duration(seconds: 1));

    final record = ContactRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: householdId,
      contactType: ContactType.call,
      contactPerson: contact.headName,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      guestName: guestName,
      initiatedBy: 'guard-1', // Mock guard ID
      success: true,
      message: 'Call initiated to ${contact.headName} at ${contact.headPhone}',
    );

    _contactHistory.add(record);

    return ContactResult.success(
      type: ContactType.call,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      message: 'Call placed successfully',
      success: true,
      recordId: record.id,
    );
  }

  /// Send SMS to household
  Future<ContactResult> sendSMS(String householdId, String message, {String? guestName}) async {
    final contact = _mockContacts[householdId];
    if (contact == null) {
      return ContactResult.success(
        type: ContactType.sms,
        contactInfo: '',
        timestamp: DateTime.now(),
        message: 'Contact not found',
        success: false,
      );
    }

    // Simulate SMS sending
    await Future.delayed(const Duration(seconds: 2));

    final record = ContactRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: householdId,
      contactType: ContactType.sms,
      contactPerson: contact.headName,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      guestName: guestName,
      initiatedBy: 'guard-1',
      success: true,
      message: 'SMS sent: $message',
    );

    _contactHistory.add(record);

    return ContactResult.success(
      type: ContactType.sms,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      message: 'SMS sent successfully',
      success: true,
      recordId: record.id,
    );
  }

  /// Record contact attempt with approval
  Future<ContactResult> recordApproval(String householdId, ApprovalType approvalType, {
    String? guestName,
    String? notes,
  }) async {
    final contact = _mockContacts[householdId];
    if (contact == null) {
      return ContactResult.success(
        type: ContactType.approval,
        contactInfo: '',
        timestamp: DateTime.now(),
        message: 'Contact not found',
        success: false,
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final record = ContactRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: householdId,
      contactType: ContactType.approval,
      contactPerson: contact.headName,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      guestName: guestName,
      initiatedBy: 'guard-1',
      success: true,
      approvalType: approvalType,
      notes: notes,
      message: 'Approval recorded: ${approvalType.name}',
    );

    _contactHistory.add(record);

    return ContactResult.success(
      type: ContactType.approval,
      contactInfo: contact.headPhone,
      timestamp: DateTime.now(),
      message: 'Approval recorded successfully',
      success: true,
      recordId: record.id,
    );
  }

  /// Get contact history for a household
  Future<List<ContactRecord>> getContactHistory(String householdId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _contactHistory
        .where((record) => record.householdId == householdId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get all contact history
  Future<List<ContactRecord>> getAllContactHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_contactHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Check if contact is preferred (based on history)
  ContactPreference getContactPreference(String householdId) {
    final history = _contactHistory
        .where((record) => record.householdId == householdId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (history.isEmpty) {
      return ContactPreference.both;
    }

    final callCount = history
        .where((record) => record.contactType == ContactType.call && record.success)
        .length;

    final smsCount = history
        .where((record) => record.contactType == ContactType.sms && record.success)
        .length;

    if (callCount > smsCount * 2) {
      return ContactPreference.call;
    } else if (smsCount > callCount * 2) {
      return ContactPreference.sms;
    }

    return ContactPreference.both;
  }

  /// Get contact statistics
  Future<ContactStatistics> getContactStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final totalContacts = _contactHistory.length;
    final successfulContacts = _contactHistory.where((r) => r.success).length;
    final callContacts = _contactHistory.where((r) => r.contactType == ContactType.call).length;
    final smsContacts = _contactHistory.where((r) => r.contactType == ContactType.sms).length;
    final approvalContacts = _contactHistory.where((r) => r.contactType == ContactType.approval).length;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayContacts = _contactHistory
        .where((record) => record.timestamp.isAfter(todayStart))
        .length;

    final lastWeek = today.subtract(const Duration(days: 7));
    final weeklyContacts = _contactHistory
        .where((record) => record.timestamp.isAfter(lastWeek))
        .length;

    return ContactStatistics(
      totalContacts: totalContacts,
      successfulContacts: successfulContacts,
      callContacts: callContacts,
      smsContacts: smsContacts,
      approvalContacts: approvalContacts,
      todayContacts: todayContacts,
      weeklyContacts: weeklyContacts,
      successRate: totalContacts > 0 ? (successfulContacts / totalContacts) * 100 : 0,
    );
  }
}

/// Household contact information
class HouseholdContact {
  final String id;
  final String headName;
  final String headPhone;
  final String headEmail;
  final String address;
  final String alternateContact;
  final String alternatePhone;

  const HouseholdContact({
    required this.id,
    required this.headName,
    required this.headPhone,
    required this.headEmail,
    required this.address,
    required this.alternateContact,
    required this.alternatePhone,
  });

  @override
  String toString() {
    return 'HouseholdContact(id: $id, headName: $headName, address: $address)';
  }
}

/// Contact record for tracking communication history
class ContactRecord {
  final String id;
  final String householdId;
  final ContactType contactType;
  final String contactPerson;
  final String contactInfo;
  final DateTime timestamp;
  final String? guestName;
  final String initiatedBy;
  final bool success;
  final String message;
  final ApprovalType? approvalType;
  final String? notes;

  const ContactRecord({
    required this.id,
    required this.householdId,
    required this.contactType,
    required this.contactPerson,
    required this.contactInfo,
    required this.timestamp,
    this.guestName,
    required this.initiatedBy,
    required this.success,
    required this.message,
    this.approvalType,
    this.notes,
  });

  @override
  String toString() {
    return 'ContactRecord(id: $id, type: $contactType, person: $contactPerson, success: $success)';
  }
}

/// Contact type enumeration
enum ContactType {
  call,
  sms,
  approval,
}

/// Approval type enumeration
enum ApprovalType {
  approved,
  denied,
  needsMoreInfo,
}

/// Contact preference enumeration
enum ContactPreference {
  call,
  sms,
  both,
}

/// Contact result for contact operations
class ContactResult {
  final ContactType type;
  final String contactInfo;
  final DateTime timestamp;
  final String message;
  final bool success;
  final String? recordId;
  final String? error;

  const ContactResult({
    required this.type,
    required this.contactInfo,
    required this.timestamp,
    required this.message,
    required this.success,
    this.recordId,
    this.error,
  });

  factory ContactResult.success({
    required ContactType type,
    required String contactInfo,
    required DateTime timestamp,
    required String message,
    required bool success,
    String? recordId,
  }) {
    return ContactResult(
      type: type,
      contactInfo: contactInfo,
      timestamp: timestamp,
      message: message,
      success: success,
      recordId: recordId,
    );
  }

  factory ContactResult.error({
    required ContactType type,
    required String message,
    String? error,
  }) {
    return ContactResult(
      type: type,
      contactInfo: '',
      timestamp: DateTime.now(),
      message: message,
      success: false,
      error: error,
    );
  }
}

/// Contact statistics for reporting
class ContactStatistics {
  final int totalContacts;
  final int successfulContacts;
  final int callContacts;
  final int smsContacts;
  final int approvalContacts;
  final int todayContacts;
  final int weeklyContacts;
  final double successRate;

  const ContactStatistics({
    required this.totalContacts,
    required this.successfulContacts,
    required this.callContacts,
    required this.smsContacts,
    required this.approvalContacts,
    required this.todayContacts,
    required this.weeklyContacts,
    required this.successRate,
  });

  @override
  String toString() {
    return 'ContactStatistics(total: $totalContacts, success: $successRate%)';
  }
}