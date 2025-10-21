import 'package:supabase_flutter/supabase_flutter.dart';

/// Household contact model
class HouseholdContact {
  final String id;
  final String householdId;
  final String name;
  final String? phoneNumber;
  final String? emailAddress;
  final String? relation;
  final bool isPrimaryContact;

  HouseholdContact({
    required this.id,
    required this.householdId,
    required this.name,
    this.phoneNumber,
    this.emailAddress,
    this.relation,
    this.isPrimaryContact = false,
  });

  factory HouseholdContact.fromJson(Map<String, dynamic> json) {
    return HouseholdContact(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String?,
      emailAddress: json['email_address'] as String?,
      relation: json['relation'] as String?,
      isPrimaryContact: json['is_primary_contact'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'name': name,
      'phone_number': phoneNumber,
      'email_address': emailAddress,
      'relation': relation,
      'is_primary_contact': isPrimaryContact,
    };
  }
}

/// Household model
class Household {
  final String id;
  final String householdName;
  final String residenceUnitId;
  final String? primaryContactPhone;
  final String? primaryContactEmail;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String status;

  Household({
    required this.id,
    required this.householdName,
    required this.residenceUnitId,
    this.primaryContactPhone,
    this.primaryContactEmail,
    required this.moveInDate,
    this.moveOutDate,
    required this.status,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      householdName: json['household_name'] as String,
      residenceUnitId: json['residence_unit_id'] as String,
      primaryContactPhone: json['primary_contact_phone'] as String?,
      primaryContactEmail: json['primary_contact_email'] as String?,
      moveInDate: DateTime.parse(json['move_in_date'] as String),
      moveOutDate: json['move_out_date'] != null
          ? DateTime.parse(json['move_out_date'] as String)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_name': householdName,
      'residence_unit_id': residenceUnitId,
      'primary_contact_phone': primaryContactPhone,
      'primary_contact_email': primaryContactEmail,
      'move_in_date': moveInDate.toIso8601String(),
      'move_out_date': moveOutDate?.toIso8601String(),
      'status': status,
    };
  }
}

/// Service for managing household data and contact with Supabase backend
class SupabaseHouseholdService {
  final SupabaseClient _supabase;
  final String _householdsTable = 'households';
  final String _contactLogsTable = 'household_contact_logs';

  SupabaseHouseholdService(this._supabase);

  /// Get all active households for the current tenant
  Future<List<Household>> getActiveHouseholds() async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .select('*')
          .eq('status', 'active')
          .order('household_name', ascending: true);

      return response.map((json) => Household.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch households: $e');
    }
  }

  /// Get household by ID
  Future<Household?> getHouseholdById(String householdId) async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .select('*')
          .eq('id', householdId)
          .maybeSingle();

      if (response == null) return null;

      return Household.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch household: $e');
    }
  }

  /// Search households by name or contact info
  Future<List<Household>> searchHouseholds(String query) async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .select('*')
          .or('household_name.ilike.%$query%,primary_contact_phone.ilike.%$query%')
          .eq('status', 'active')
          .order('household_name', ascending: true);

      return response.map((json) => Household.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to search households: $e');
    }
  }

  /// Get household contacts (mock data for now, can be extended)
  Future<List<HouseholdContact>> getHouseholdContacts(String householdId) async {
    try {
      // This would typically come from a household_members table
      // For now, we'll return basic contact info from the household
      final household = await getHouseholdById(householdId);
      if (household == null) return [];

      final contacts = <HouseholdContact>[];

      if (household.primaryContactPhone != null) {
        contacts.add(HouseholdContact(
          id: '${householdId}_primary',
          householdId: householdId,
          name: household.householdName,
          phoneNumber: household.primaryContactPhone,
          emailAddress: household.primaryContactEmail,
          relation: 'Primary Contact',
          isPrimaryContact: true,
        ));
      }

      return contacts;
    } catch (e) {
      throw Exception('Failed to fetch household contacts: $e');
    }
  }

  /// Create a contact log entry when contacting a household
  Future<void> logHouseholdContact({
    required String householdId,
    required String contactType,
    required String contactDirection,
    String? messageContent,
    String? contactResult,
    String? contactPersonName,
    String? contactPersonRelation,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      final tenantId = currentUser?.userMetadata?['tenant_id'] as String?;

      await _supabase.from(_contactLogsTable).insert({
        'household_id': householdId,
        'tenant_id': tenantId,
        'contact_type': contactType, // 'phone_call', 'sms', 'email', 'in_person'
        'contact_direction': contactDirection, // 'outgoing', 'incoming'
        'contact_result': contactResult,
        'message_content': messageContent,
        'contact_person_name': contactPersonName,
        'contact_person_relation': contactPersonRelation,
        'contact_timestamp': DateTime.now().toIso8601String(),
        'created_by': currentUser?.id,
      });
    } catch (e) {
      throw Exception('Failed to log household contact: $e');
    }
  }

  /// Get recent contact logs for a household
  Future<List<Map<String, dynamic>>> getHouseholdContactLogs(String householdId) async {
    try {
      final response = await _supabase
          .from(_contactLogsTable)
          .select('*')
          .eq('household_id', householdId)
          .order('contact_timestamp', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch contact logs: $e');
    }
  }

  /// Search for households that match a phone number
  Future<List<Household>> searchHouseholdsByPhone(String phoneNumber) async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .select('*')
          .eq('primary_contact_phone', phoneNumber)
          .eq('status', 'active');

      return response.map((json) => Household.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to search households by phone: $e');
    }
  }

  /// Create a new household (for admin use)
  Future<Household> createHousehold({
    required String householdName,
    required String residenceUnitId,
    String? primaryContactPhone,
    String? primaryContactEmail,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      final tenantId = currentUser?.userMetadata?['tenant_id'] as String?;

      final householdData = {
        'tenant_id': tenantId,
        'residence_unit_id': residenceUnitId,
        'household_name': householdName,
        'primary_contact_phone': primaryContactPhone,
        'primary_contact_email': primaryContactEmail,
        'move_in_date': DateTime.now().toIso8601String(),
        'status': 'active',
        'created_by': currentUser?.id,
      };

      final response = await _supabase
          .from(_householdsTable)
          .insert(householdData)
          .select()
          .single();

      return Household.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create household: $e');
    }
  }

  /// Update household information
  Future<Household> updateHousehold(Household household) async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .update(household.toJson())
          .eq('id', household.id)
          .select()
          .single();

      return Household.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update household: $e');
    }
  }

  /// Get households for a specific residence unit
  Future<List<Household>> getHouseholdsByUnit(String residenceUnitId) async {
    try {
      final response = await _supabase
          .from(_householdsTable)
          .select('*')
          .eq('residence_unit_id', residenceUnitId)
          .eq('status', 'active')
          .order('household_name', ascending: true);

      return response.map((json) => Household.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch households for unit: $e');
    }
  }
}