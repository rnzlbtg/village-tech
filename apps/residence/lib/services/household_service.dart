import '../models/household_member.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';

/// Household service
/// Handles household member CRUD operations
class HouseholdService {
  static HouseholdService? _instance;

  HouseholdService._();

  /// Singleton instance
  static HouseholdService get instance {
    _instance ??= HouseholdService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Get household ID for current user
  Future<String> _getHouseholdId() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = await _supabase
          .from('households')
          .select('id')
          .eq('household_head_id', userId)
          .single();

      return data['id'] as String;
    } catch (e) {
      throw Exception('Failed to get household ID: $e');
    }
  }

  /// Add household member
  Future<ApiResult<HouseholdMember>> addHouseholdMember({
    required String fullName,
    required String relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
  }) async {
    try {
      final householdId = await _getHouseholdId();

      // Split full_name into first_name and last_name
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : fullName;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final data = await _supabase.from('household_members').insert({
        'household_id': householdId,
        'first_name': firstName,
        'last_name': lastName,
        'relationship': relationship,
        'phone_number': contactNumber,
        'email': email,
        'date_of_birth': birthDate?.toIso8601String().split('T')[0],
      }).select().single();

      final member = HouseholdMember.fromJson(data);
      return ApiResult.success(member);
    } catch (e) {
      return ApiResult.failure(
        'Failed to add household member: ${e.toString()}',
        code: 'ADD_MEMBER_ERROR',
      );
    }
  }

  /// Update household member
  Future<ApiResult<HouseholdMember>> updateHouseholdMember({
    required String memberId,
    String? fullName,
    String? relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) {
        // Split full_name into first_name and last_name
        final nameParts = fullName!.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : fullName;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        updateData['first_name'] = firstName;
        updateData['last_name'] = lastName;
      }
      if (relationship != null) updateData['relationship'] = relationship;
      if (contactNumber != null) updateData['phone_number'] = contactNumber;
      if (email != null) updateData['email'] = email;
      if (birthDate != null) {
        updateData['date_of_birth'] = birthDate.toIso8601String().split('T')[0];
      }

      if (updateData.isEmpty) {
        return ApiResult.failure(
          'No fields to update',
          code: 'NO_UPDATES',
        );
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('household_members')
          .update(updateData)
          .eq('id', memberId)
          .select()
          .single();

      final member = HouseholdMember.fromJson(data);
      return ApiResult.success(member);
    } catch (e) {
      return ApiResult.failure(
        'Failed to update household member: ${e.toString()}',
        code: 'UPDATE_MEMBER_ERROR',
      );
    }
  }

  /// Remove household member
  /// This will also deactivate associated stickers (handled by database trigger)
  Future<ApiResult<void>> removeHouseholdMember({
    required String memberId,
  }) async {
    try {
      await _supabase.from('household_members').delete().eq('id', memberId);

      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        'Failed to remove household member: ${e.toString()}',
        code: 'REMOVE_MEMBER_ERROR',
      );
    }
  }

  /// Fetch all household members
  Future<ApiResult<List<HouseholdMember>>> fetchHouseholdMembers() async {
    try {
      final householdId = await _getHouseholdId();

      final data = await _supabase
          .from('household_members')
          .select()
          .eq('household_id', householdId)
          .order('relationship', ascending: true)
          .order('first_name', ascending: true)
          .order('last_name', ascending: true);

      final members = (data as List)
          .map((json) => HouseholdMember.fromJson(json))
          .toList();

      return ApiResult.success(members);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch household members: ${e.toString()}',
        code: 'FETCH_MEMBERS_ERROR',
      );
    }
  }

  /// Fetch single household member
  Future<ApiResult<HouseholdMember>> fetchHouseholdMember({
    required String memberId,
  }) async {
    try {
      final data = await _supabase
          .from('household_members')
          .select()
          .eq('id', memberId)
          .single();

      final member = HouseholdMember.fromJson(data);
      return ApiResult.success(member);
    } catch (e) {
      return ApiResult.failure(
        'Failed to fetch household member: ${e.toString()}',
        code: 'FETCH_MEMBER_ERROR',
      );
    }
  }

  /// Check if member has active stickers
  /// Used for cascade delete warning
  Future<ApiResult<bool>> hasActiveStickers({
    required String memberId,
  }) async {
    try {
      final data = await _supabase
          .from('rfid_stickers')
          .select('id')
          .eq('owner_type', 'household_member')
          .eq('owner_id', memberId)
          .eq('status', 'active')
          .limit(1);

      return ApiResult.success((data as List).isNotEmpty);
    } catch (e) {
      return ApiResult.failure(
        'Failed to check active stickers: ${e.toString()}',
        code: 'CHECK_STICKERS_ERROR',
      );
    }
  }
}
