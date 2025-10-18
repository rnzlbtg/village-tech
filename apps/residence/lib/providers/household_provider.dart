import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/household_member.dart';
import '../services/household_service.dart';
import '../services/offline_cache_service.dart';
import '../utils/api_result.dart';

/// Household members state
class HouseholdMembersState {
  final List<HouseholdMember> members;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  HouseholdMembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  HouseholdMembersState copyWith({
    List<HouseholdMember>? members,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) {
    return HouseholdMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Household members provider
class HouseholdMembersNotifier extends StateNotifier<HouseholdMembersState> {
  HouseholdMembersNotifier() : super(HouseholdMembersState()) {
    _loadMembers();
  }

  final _householdService = HouseholdService.instance;
  final _cacheService = OfflineCacheService.instance;

  /// Load household members (from cache first, then fetch fresh data)
  Future<void> _loadMembers() async {
    // Load from cache first for instant UI
    final cachedMembers = _cacheService.getCachedHouseholdMembers();
    if (cachedMembers != null && cachedMembers.isNotEmpty) {
      state = state.copyWith(
        members: cachedMembers.map((json) => HouseholdMember.fromJson(json)).toList(),
        isOffline: true,
      );
    }

    // Fetch fresh data from network
    await refreshMembers();
  }

  /// Refresh household members from network
  Future<void> refreshMembers() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _householdService.fetchHouseholdMembers();

    if (result.success && result.data != null) {
      // Update state
      state = state.copyWith(
        members: result.data!,
        isLoading: false,
        isOffline: false,
      );

      // Cache the data
      await _cacheService.cacheHouseholdMembers(result.data!.map((m) => m.toJson()).toList());
    } else {
      // Use cached data if available
      final cachedMembers = _cacheService.getCachedHouseholdMembers();
      if (cachedMembers != null && cachedMembers.isNotEmpty) {
        state = state.copyWith(
          members: cachedMembers.map((json) => HouseholdMember.fromJson(json)).toList(),
          isLoading: false,
          isOffline: true,
          error: 'Using offline data: ${result.error}',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    }
  }

  /// Add household member
  Future<ApiResult<HouseholdMember>> addMember({
    required String fullName,
    required String relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
  }) async {
    final result = await _householdService.addHouseholdMember(
      fullName: fullName,
      relationship: relationship,
      contactNumber: contactNumber,
      email: email,
      birthDate: birthDate,
    );

    if (result.success && result.data != null) {
      // Add to state
      state = state.copyWith(
        members: [...state.members, result.data!],
      );

      // Update cache
      await _cacheService.cacheHouseholdMembers(state.members.map((m) => m.toJson()).toList());
    }

    return result;
  }

  /// Update household member
  Future<ApiResult<HouseholdMember>> updateMember({
    required String memberId,
    String? fullName,
    String? relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
  }) async {
    final result = await _householdService.updateHouseholdMember(
      memberId: memberId,
      fullName: fullName,
      relationship: relationship,
      contactNumber: contactNumber,
      email: email,
      birthDate: birthDate,
    );

    if (result.success && result.data != null) {
      // Update state
      final updatedMembers = state.members.map((member) {
        return member.id == memberId ? result.data! : member;
      }).toList();

      state = state.copyWith(members: updatedMembers);

      // Update cache
      await _cacheService.cacheHouseholdMembers(state.members.map((m) => m.toJson()).toList());
    }

    return result;
  }

  /// Remove household member
  Future<ApiResult<void>> removeMember({
    required String memberId,
  }) async {
    final result = await _householdService.removeHouseholdMember(
      memberId: memberId,
    );

    if (result.success) {
      // Remove from state
      final updatedMembers =
          state.members.where((member) => member.id != memberId).toList();

      state = state.copyWith(members: updatedMembers);

      // Update cache
      await _cacheService.cacheHouseholdMembers(state.members.map((m) => m.toJson()).toList());
    }

    return result;
  }

  /// Check if member has active stickers
  Future<ApiResult<bool>> hasActiveStickers({
    required String memberId,
  }) async {
    return await _householdService.hasActiveStickers(memberId: memberId);
  }
}

/// Household members provider
final householdMembersProvider =
    StateNotifierProvider<HouseholdMembersNotifier, HouseholdMembersState>(
  (ref) => HouseholdMembersNotifier(),
);
