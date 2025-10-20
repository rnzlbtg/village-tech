import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest.dart';

/// Guest state for state management
class GuestState {
  final List<Guest> guests;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  GuestState({
    this.guests = const [],
    this.isLoading = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  GuestState copyWith({
    List<Guest>? guests,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return GuestState(
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestState &&
          runtimeType == other.runtimeType &&
          guests == other.guests &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      guests.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      lastUpdated.hashCode;
}

/// Mock Guest Service for testing - will be replaced with actual implementation
class MockGuestService {
  Future<List<Guest>> getTodayGuests() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return [
      Guest(
        id: '1',
        tenantId: 'tenant-1',
        householdId: 'household-1',
        guestName: 'John Doe',
        phoneNumber: '+1234567890',
        purpose: 'Visiting family',
        scheduledDate: DateTime.now(),
        expectedArrival: '10:00',
        expectedDeparture: '12:00',
        status: GuestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Guest(
        id: '2',
        tenantId: 'tenant-1',
        householdId: 'household-2',
        guestName: 'Jane Smith',
        phoneNumber: '+0987654321',
        purpose: 'Delivery',
        scheduledDate: DateTime.now(),
        expectedArrival: '14:00',
        expectedDeparture: '15:00',
        status: GuestStatus.checkedIn,
        actualArrival: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  Future<List<Guest>> getGuests({
    DateTime? startDate,
    DateTime? endDate,
    String? householdId,
    GuestStatus? status,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return getTodayGuests();
  }

  Future<List<Guest>> searchGuests(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allGuests = await getTodayGuests();
    return allGuests.where((guest) =>
        guest.guestName.toLowerCase().contains(query.toLowerCase()) ||
        guest.phoneNumber.toLowerCase().contains(query.toLowerCase()) ||
        guest.purpose.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<Guest> createGuest(Guest guest) async {
    await Future.delayed(const Duration(seconds: 1));
    return guest;
  }

  Future<Guest> updateGuest(Guest guest) async {
    await Future.delayed(const Duration(seconds: 1));
    return guest;
  }

  Future<void> deleteGuest(String guestId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

/// Guest notifier for state management
class GuestNotifier extends StateNotifier<GuestState> {
  final MockGuestService _guestService;

  GuestNotifier(this._guestService) : super(GuestState());

  /// Load today's guests
  Future<void> loadTodayGuests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guests = await _guestService.getTodayGuests();
      state = state.copyWith(
        guests: guests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load guests: $e',
      );
    }
  }

  /// Load all guests with optional filtering
  Future<void> loadAllGuests({
    DateTime? startDate,
    DateTime? endDate,
    String? householdId,
    GuestStatus? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guests = await _guestService.getGuests(
        startDate: startDate,
        endDate: endDate,
        householdId: householdId,
        status: status,
      );

      state = state.copyWith(
        guests: guests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load guests: $e',
      );
    }
  }

  /// Search guests by name, phone, or household
  Future<List<Guest>> searchGuests(String query) async {
    try {
      return await _guestService.searchGuests(query);
    } catch (e) {
      throw Exception('Failed to search guests: $e');
    }
  }

  /// Register a new guest
  Future<Guest> registerGuest({
    required String guestName,
    required String phoneNumber,
    required String purpose,
    required DateTime scheduledDate,
    required String expectedArrival,
    required String expectedDeparture,
    required String householdId,
    String? vehicleInfo,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guest = Guest(
        id: _generateId(),
        tenantId: 'tenant-1', // Mock tenant ID
        householdId: householdId,
        guestName: guestName,
        phoneNumber: phoneNumber,
        purpose: purpose,
        scheduledDate: scheduledDate,
        expectedArrival: expectedArrival,
        expectedDeparture: expectedDeparture,
        status: GuestStatus.pending,
        vehicleInfo: vehicleInfo,
        notes: notes,
        approvedByGuardId: 'guard-1', // Mock guard ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Validate guest data
      final guestErrors = guest.validate();
      if (guestErrors.isNotEmpty) {
        throw Exception(guestErrors.first);
      }

      final savedGuest = await _guestService.createGuest(guest);

      // Update state with new guest
      final updatedGuests = [...state.guests, savedGuest];
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      return savedGuest;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to register guest: $e',
      );
      rethrow;
    }
  }

  /// Check in a guest
  Future<void> checkInGuest(String guestId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guest = state.guests.firstWhere((g) => g.id == guestId);
      final updatedGuest = guest.copyWith(
        status: GuestStatus.checkedIn,
        actualArrival: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _guestService.updateGuest(updatedGuest);

      // Update local state
      final updatedGuests = state.guests.map((g) =>
          g.id == guestId ? updatedGuest : g).toList();
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check in guest: $e',
      );
      rethrow;
    }
  }

  /// Check out a guest
  Future<void> checkOutGuest(String guestId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guest = state.guests.firstWhere((g) => g.id == guestId);
      final updatedGuest = guest.copyWith(
        status: GuestStatus.checkedOut,
        actualDeparture: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _guestService.updateGuest(updatedGuest);

      // Update local state
      final updatedGuests = state.guests.map((g) =>
          g.id == guestId ? updatedGuest : g).toList();
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check out guest: $e',
      );
      rethrow;
    }
  }

  /// Cancel a guest registration
  Future<void> cancelGuest(String guestId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guest = state.guests.firstWhere((g) => g.id == guestId);
      final updatedGuest = guest.copyWith(
        status: GuestStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await _guestService.updateGuest(updatedGuest);

      // Update local state
      final updatedGuests = state.guests.map((g) =>
          g.id == guestId ? updatedGuest : g).toList();
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel guest: $e',
      );
      rethrow;
    }
  }

  /// Update guest information
  Future<void> updateGuest(Guest guest) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedGuest = guest.copyWith(updatedAt: DateTime.now());
      await _guestService.updateGuest(updatedGuest);

      // Update local state
      final updatedGuests = state.guests.map((g) =>
          g.id == guest.id ? updatedGuest : g).toList();
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update guest: $e',
      );
      rethrow;
    }
  }

  /// Delete a guest
  Future<void> deleteGuest(String guestId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _guestService.deleteGuest(guestId);

      // Update local state
      final updatedGuests = state.guests.where((g) => g.id != guestId).toList();
      state = state.copyWith(
        guests: updatedGuests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete guest: $e',
      );
      rethrow;
    }
  }

  /// Refresh guests from server
  Future<void> refreshGuests() async {
    await loadTodayGuests();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get guests for today
  List<Guest> get todayGuests => state.guests.where((guest) => guest.isForToday).toList();

  /// Get checked in guests
  List<Guest> get checkedInGuests => state.guests.where((guest) => guest.isCheckedIn).toList();

  /// Get pending guests
  List<Guest> get pendingGuests => state.guests.where((guest) => guest.isPending).toList();

  /// Get overdue guests
  List<Guest> get overdueGuests => state.guests.where((guest) => guest.isOverdue).toList();

  /// Generate unique ID for new guests
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Provider for guest service
final guestServiceProvider = Provider<MockGuestService>((ref) {
  return MockGuestService();
});

/// Provider for guest state management
final guestProvider = StateNotifierProvider<GuestNotifier, GuestState>((ref) {
  return GuestNotifier(ref.watch(guestServiceProvider));
});

/// Search provider for guest search functionality
final guestSearchProvider = StateProvider<String>((ref) => '');

/// Filter provider for guest filtering
final guestFilterProvider = StateProvider<GuestStatus?>((ref) => null);