import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import 'auth_provider.dart' as auth;
import '../../models/guard.dart';
import '../../services/offline_cache_service.dart';
import '../../services/entry_service.dart';
import '../../services/nfc_service.dart';
import '../../services/manual_verification_service.dart';
import '../../services/household_contact_service.dart';
import '../../services/rfid_performance_service.dart';
import '../../services/rfid_error_handler.dart';

// Service Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final cacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});

final entryServiceProvider = Provider<EntryService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return EntryService(supabaseService: supabaseService, cacheService: cacheService);
});

final nfcServiceProvider = Provider<NfcService>((ref) {
  return NfcService();
});

final manualVerificationServiceProvider = Provider<ManualVerificationService>((ref) {
  final entryService = ref.watch(entryServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return ManualVerificationService(
    entryService: entryService,
    cacheService: cacheService,
    supabaseService: ref.watch(supabaseServiceProvider),
  );
});

final householdContactServiceProvider = Provider<HouseholdContactService>((ref) {
  return HouseholdContactService();
});

final rfidPerformanceServiceProvider = Provider<RfidPerformanceService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return RfidPerformanceService(
    supabaseService: supabaseService,
    cacheService: cacheService,
  );
});

final rfidErrorHandlerProvider = Provider<RfidErrorHandler>((ref) {
  final performanceService = ref.watch(rfidPerformanceServiceProvider);
  return RfidErrorHandler(performanceService: performanceService);
});

// Utility Providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Authentication State Provider
final authStateProvider = StateNotifierProvider<auth.AuthStateNotifier, auth.AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return auth.AuthStateNotifier(supabaseService);
});

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

// Current Guard Provider
final currentGuardProvider = StateProvider<Guard?>((ref) => null);

// Tenant ID Provider
final tenantIdProvider = StateProvider<String?>((ref) => null);