import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest.dart';
import '../services/guest_service.dart';

/// Guest state
class GuestState {
  final List<Guest> guests;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;

  GuestState({
    this.guests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  GuestState copyWith({
    List<Guest>? guests,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
  }) {
    return GuestState(
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// Filter upcoming guests
  List<Guest> get upcomingGuests {
    return guests.where((guest) => guest.isUpcoming).toList();
  }

  /// Filter active guests
  List<Guest> get activeGuests {
    return guests.where((guest) => guest.isActive).toList();
  }

  /// Filter past guests
  List<Guest> get pastGuests {
    return guests.where((guest) => guest.isPast).toList();
  }

  /// Get guests by status
  List<Guest> filterByStatus(String status) {
    return guests.where((guest) => guest.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Get upcoming count
  int get upcomingCount => upcomingGuests.length;

  /// Get active count
  int get activeCount => activeGuests.length;

  /// Get past count
  int get pastCount => pastGuests.length;
}

/// Guest provider
class GuestNotifier extends StateNotifier<GuestState> {
  final GuestService _service = GuestService.instance;

  GuestNotifier() : super(GuestState()) {
    _loadInitialData();
  }

  /// Load initial data from cache, then refresh from network
  Future<void> _loadInitialData() async {
    // Load from cache first
    final cachedGuests = await _service.fetchGuestsFromCache();
    if (cachedGuests != null && cachedGuests.isNotEmpty) {
      state = state.copyWith(guests: cachedGuests, isOffline: true);
    }

    // Then refresh from network
    await refreshGuests();
  }

  /// Refresh guests from network
  Future<void> refreshGuests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.fetchScheduledGuests();

    if (result.isSuccess) {
      state = state.copyWith(
        guests: result.data!,
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

  /// Schedule a guest
  Future<bool> scheduleGuest({
    required String guestName,
    String? contactNumber,
    required String visitType,
    required DateTime visitStart,
    required DateTime visitEnd,
    String? purpose,
    String? vehiclePlate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.scheduleGuest(
      guestName: guestName,
      contactNumber: contactNumber,
      visitType: visitType,
      visitStart: visitStart,
      visitEnd: visitEnd,
      purpose: purpose,
      vehiclePlate: vehiclePlate,
    );

    if (result.isSuccess) {
      await refreshGuests();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Update guest schedule
  Future<bool> updateGuestSchedule({
    required String guestId,
    String? guestName,
    String? contactNumber,
    String? visitType,
    DateTime? visitStart,
    DateTime? visitEnd,
    String? purpose,
    String? vehiclePlate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.updateGuestSchedule(
      guestId: guestId,
      guestName: guestName,
      contactNumber: contactNumber,
      visitType: visitType,
      visitStart: visitStart,
      visitEnd: visitEnd,
      purpose: purpose,
      vehiclePlate: vehiclePlate,
    );

    if (result.isSuccess) {
      await refreshGuests();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Cancel guest visit
  Future<bool> cancelGuestVisit(String guestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.cancelGuestVisit(guestId);

    if (result.isSuccess) {
      await refreshGuests();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Check in guest
  Future<bool> checkInGuest(String guestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.checkInGuest(guestId);

    if (result.isSuccess) {
      await refreshGuests();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Check out guest
  Future<bool> checkOutGuest(String guestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.checkOutGuest(guestId);

    if (result.isSuccess) {
      await refreshGuests();
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

/// Guest state provider
final guestProvider = StateNotifierProvider<GuestNotifier, GuestState>((ref) {
  return GuestNotifier();
});
