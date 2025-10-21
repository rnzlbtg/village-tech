import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guest.dart';
import '../services/supabase_guest_service.dart';

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

/// Guest notifier for state management
class GuestNotifier extends StateNotifier<GuestState> {
  final SupabaseGuestService _guestService;

  GuestNotifier(this._guestService) : super(GuestState());

  /// Load today's guests
  Future<void> loadTodayGuests() async {
    print('🔍 DEBUG: Loading today\'s guests...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guests = await _guestService.getTodayGuests();
      print('🔍 DEBUG: Loaded ${guests.length} today\'s guests');
      for (var guest in guests) {
        print('   - ${guest.guestName} (tenant: ${guest.tenantId}, status: ${guest.status})');
      }

      state = state.copyWith(
        guests: guests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('🔍 DEBUG: Failed to load today\'s guests: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load guests: $e',
      );
    }
  }

  /// Load all guests with optional filtering
  Future<void> loadAllGuests({
    GuestStatus? status,
    String? householdId,
  }) async {
    print('🔍 DEBUG: Loading all guests (status: $status, householdId: $householdId)...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Guest> guests;

      if (status != null) {
        print('🔍 DEBUG: Loading guests by status: $status');
        guests = await _guestService.getGuestsByStatus(status);
      } else if (householdId != null) {
        print('🔍 DEBUG: Loading guests by household: $householdId');
        guests = await _guestService.getGuestsByHousehold(householdId);
      } else {
        print('🔍 DEBUG: Loading all guests...');
        guests = await _guestService.getGuests();
      }

      print('🔍 DEBUG: Loaded ${guests.length} total guests');
      for (var guest in guests) {
        print('   - ${guest.guestName} (tenant: ${guest.tenantId}, status: ${guest.status})');
      }

      state = state.copyWith(
        guests: guests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('🔍 DEBUG: Failed to load all guests: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load guests: $e',
      );
    }
  }

  /// Load active guests (expected or checked in)
  Future<void> loadActiveGuests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final guests = await _guestService.getActiveGuests();
      state = state.copyWith(
        guests: guests,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load active guests: $e',
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
    required String householdId,
    String? vehicleInfo,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final tenantId = currentUser?.userMetadata?['tenant_id'] as String?;

      if (tenantId == null) {
        throw Exception('User not authenticated or tenant not found');
      }

      final guest = Guest(
        id: _generateId(),
        tenantId: tenantId,
        householdId: householdId,
        guestName: guestName,
        phoneNumber: phoneNumber,
        purpose: purpose,
        scheduledDate: scheduledDate,
        status: GuestStatus.expected,
        vehicleInfo: vehicleInfo,
        notes: notes,
        approvedByGuardId: currentUser?.id,
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
  Future<void> checkInGuest(String guestId, {
    String? verificationMethod,
    double? temperatureCelsius,
    String? guardNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedGuest = await _guestService.checkInGuest(
        guestId,
        verificationMethod: verificationMethod,
        temperatureCelsius: temperatureCelsius,
        guardNotes: guardNotes,
      );

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
  Future<void> checkOutGuest(String guestId, {String? guardNotes}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedGuest = await _guestService.checkOutGuest(
        guestId,
        guardNotes: guardNotes,
      );

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
  Future<void> cancelGuest(String guestId, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedGuest = await _guestService.cancelGuest(guestId, reason: reason);

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
      final savedGuest = await _guestService.updateGuest(updatedGuest);

      // Update local state
      final updatedGuests = state.guests.map((g) =>
          g.id == guest.id ? savedGuest : g).toList();
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
    print('🔍 DEBUG: GuestNotifier - refreshGuests() called');
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

  /// Get expected guests
  List<Guest> get expectedGuests => state.guests.where((guest) => guest.isExpected).toList();

  /// Get overdue guests (checked in guests with past visit dates)
  List<Guest> get overdueGuests => state.guests.where((guest) =>
    guest.isCheckedIn && guest.scheduledDate.isBefore(DateTime.now())
  ).toList();

  /// Generate unique ID for new guests
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Provider for Supabase guest service
final supabaseGuestServiceProvider = Provider<SupabaseGuestService>((ref) {
  return SupabaseGuestService(Supabase.instance.client);
});

/// Provider for guest state management
final guestProvider = StateNotifierProvider<GuestNotifier, GuestState>((ref) {
  return GuestNotifier(ref.watch(supabaseGuestServiceProvider));
});

/// Search provider for guest search functionality
final guestSearchProvider = StateProvider<String>((ref) => '');

/// Filter provider for guest filtering
final guestFilterProvider = StateProvider<GuestStatus?>((ref) => null);

/// Stream provider for real-time guest updates by status
final guestStreamProvider = StreamProvider.family<List<Guest>, GuestStatus>((ref, status) {
  final service = ref.watch(supabaseGuestServiceProvider);
  return service.streamGuestsByStatus(status);
});

/// Stream provider for all guests real-time updates
final allGuestsStreamProvider = StreamProvider<List<Guest>>((ref) {
  final service = ref.watch(supabaseGuestServiceProvider);
  return service.streamAllGuests();
});

/// Statistics provider for guest analytics
final guestStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(supabaseGuestServiceProvider);
  return await service.getGuestStatistics();
});