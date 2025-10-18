import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/construction_permit_request.dart';
import '../services/permit_service.dart';

/// Permit state
class PermitState {
  final List<ConstructionPermitRequest> permits;
  final bool isLoading;
  final String? errorMessage;

  PermitState({
    this.permits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PermitState copyWith({
    List<ConstructionPermitRequest>? permits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PermitState(
      permits: permits ?? this.permits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Filter pending permits
  List<ConstructionPermitRequest> get pendingPermits {
    return permits.where((permit) => permit.isPending).toList();
  }

  /// Filter approved permits
  List<ConstructionPermitRequest> get approvedPermits {
    return permits.where((permit) => permit.isApproved).toList();
  }

  /// Filter completed permits
  List<ConstructionPermitRequest> get completedPermits {
    return permits.where((permit) => permit.isCompleted).toList();
  }

  /// Filter fee pending permits
  List<ConstructionPermitRequest> get feePendingPermits {
    return permits.where((permit) => permit.isFeePending).toList();
  }

  /// Filter rejected permits
  List<ConstructionPermitRequest> get rejectedPermits {
    return permits.where((permit) => permit.isRejected).toList();
  }

  /// Filter cancelled permits
  List<ConstructionPermitRequest> get cancelledPermits {
    return permits.where((permit) => permit.isCancelled).toList();
  }

  /// Filter on hold permits
  List<ConstructionPermitRequest> get onHoldPermits {
    return permits.where((permit) => permit.isOnHold).toList();
  }

  /// Filter in progress permits
  List<ConstructionPermitRequest> get inProgressPermits {
    return permits.where((permit) => permit.isInProgress).toList();
  }

  /// Get permits by status
  List<ConstructionPermitRequest> filterByStatus(String status) {
    return permits
        .where((permit) => permit.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  /// Get pending count
  int get pendingCount => pendingPermits.length;

  /// Get approved count
  int get approvedCount => approvedPermits.length;

  /// Get completed count
  int get completedCount => completedPermits.length;

  /// Get rejected count
  int get rejectedCount => rejectedPermits.length;

  /// Get cancelled count
  int get cancelledCount => cancelledPermits.length;

  /// Get on hold count
  int get onHoldCount => onHoldPermits.length;

  /// Get in progress count
  int get inProgressCount => inProgressPermits.length;
}

/// Permit provider
class PermitNotifier extends StateNotifier<PermitState> {
  final PermitService _service = PermitService.instance;

  PermitNotifier() : super(PermitState()) {
    refreshPermits();
  }

  /// Refresh permits from network
  Future<void> refreshPermits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.fetchPermitRequests();

    if (result.isSuccess) {
      state = state.copyWith(
        permits: result.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
    }
  }

  /// Submit construction permit
  Future<bool> submitPermit({
    required String projectType,
    required String description,
    required String contractorName,
    required String contractorContact,
    required DateTime startDate,
    required DateTime endDate,
    required int estimatedWorkers,
    List<String>? authorizedWorkers,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.submitConstructionPermit(
      projectType: projectType,
      description: description,
      contractorName: contractorName,
      contractorContact: contractorContact,
      startDate: startDate,
      endDate: endDate,
      estimatedWorkers: estimatedWorkers,
      authorizedWorkers: authorizedWorkers,
    );

    if (result.isSuccess) {
      await refreshPermits();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Cancel permit request
  Future<bool> cancelPermit(String permitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.cancelPermitRequest(permitId);

    if (result.isSuccess) {
      await refreshPermits();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Mark permit as completed
  Future<bool> markAsCompleted(String permitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.markAsCompleted(permitId);

    if (result.isSuccess) {
      await refreshPermits();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Permit state provider
final permitProvider =
    StateNotifierProvider<PermitNotifier, PermitState>((ref) {
  return PermitNotifier();
});
