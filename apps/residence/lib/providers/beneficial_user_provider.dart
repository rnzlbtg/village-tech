import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/beneficial_user.dart';
import '../services/beneficial_user_service.dart';

/// Beneficial users state
class BeneficialUsersState {
  final List<BeneficialUser> users;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;

  BeneficialUsersState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  BeneficialUsersState copyWith({
    List<BeneficialUser>? users,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
  }) {
    return BeneficialUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// Filter users by status
  List<BeneficialUser> filterByStatus(String status) {
    return users.where((user) => user.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Filter users by relationship
  List<BeneficialUser> filterByRelationship(String relationship) {
    return users.where((user) => user.relationship.toLowerCase() == relationship.toLowerCase()).toList();
  }

  /// Get active users count
  int get activeCount => users.where((user) => user.isActive).length;

  /// Get inactive users count
  int get inactiveCount => users.where((user) => user.isInactive).length;

  /// Get users with photos count
  int get usersWithPhotosCount => users.where((user) => user.hasPhoto).length;
}

/// Beneficial users provider
class BeneficialUsersNotifier extends StateNotifier<BeneficialUsersState> {
  final BeneficialUserService _service = BeneficialUserService.instance;

  BeneficialUsersNotifier() : super(BeneficialUsersState()) {
    _loadInitialData();
  }

  /// Load initial data from cache, then refresh from network
  Future<void> _loadInitialData() async {
    // Load from cache first
    final cachedUsers = await _service.fetchBeneficialUsersFromCache();
    if (cachedUsers != null && cachedUsers.isNotEmpty) {
      state = state.copyWith(users: cachedUsers, isOffline: true);
    }

    // Then refresh from network
    await refreshUsers();
  }

  /// Refresh beneficial users from network
  Future<void> refreshUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.fetchBeneficialUsers();

    if (result.isSuccess) {
      state = state.copyWith(
        users: result.data!,
        isLoading: false,
        isOffline: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
        isOffline: true,
      );
    }
  }

  /// Add beneficial user with optional photo
  Future<bool> addUser({
    required String fullName,
    required String contactNumber,
    String? email,
    required String relationship,
    File? idPhoto,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.addBeneficialUser(
      fullName: fullName,
      contactNumber: contactNumber,
      email: email,
      relationship: relationship,
      idPhoto: idPhoto,
    );

    if (result.isSuccess) {
      await refreshUsers();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Update beneficial user with optional photo update
  Future<bool> updateUser({
    required String userId,
    String? fullName,
    String? contactNumber,
    String? email,
    String? relationship,
    File? newIdPhoto,
    String? oldPhotoUrl,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.updateBeneficialUser(
      userId: userId,
      fullName: fullName,
      contactNumber: contactNumber,
      email: email,
      relationship: relationship,
      newIdPhoto: newIdPhoto,
      oldPhotoUrl: oldPhotoUrl,
      status: status,
    );

    if (result.isSuccess) {
      await refreshUsers();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Remove beneficial user
  Future<bool> removeUser(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.removeBeneficialUser(userId);

    if (result.isSuccess) {
      await refreshUsers();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Toggle user status (active/inactive)
  Future<bool> toggleUserStatus(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.toggleStatus(userId);

    if (result.isSuccess) {
      await refreshUsers();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Check if user has active stickers
  Future<bool> hasActiveStickers(String userId) async {
    return await _service.hasActiveStickers(userId);
  }

  /// Filter users by status
  void filterByStatus(String status) {
    // This doesn't modify state, just provides filtered data
    // Use state.filterByStatus(status) from the UI
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Beneficial users state provider
final beneficialUsersProvider =
    StateNotifierProvider<BeneficialUsersNotifier, BeneficialUsersState>((ref) {
  return BeneficialUsersNotifier();
});
