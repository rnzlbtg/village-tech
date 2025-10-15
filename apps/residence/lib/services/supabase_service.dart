import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// Supabase client singleton service
/// Manages Supabase initialization and provides access to the client
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    await dotenv.load();

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _client = Supabase.instance.client;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => client.auth.currentUser?.id;

  /// Get tenant ID from user metadata
  String? get tenantId {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return user.appMetadata['tenant_id'] as String?;
  }

  /// Get household ID from user metadata (synchronous)
  String? get householdId {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return user.appMetadata['household_id'] as String?;
  }

  /// Get household ID for current user (async version)
  Future<String?> getHouseholdId() async {
    final userId = currentUserId;
    developer.log('getHouseholdId called for user: $userId', name: 'SupabaseService');

    if (userId == null) {
      developer.log('No current user ID', name: 'SupabaseService');
      return null;
    }

    try {
      // First check if user is household head
      developer.log('Checking if user is household head...', name: 'SupabaseService');
      final headData = await client
          .from('households')
          .select('id')
          .eq('household_head_id', userId)
          .maybeSingle();

      developer.log('Household head query result: $headData', name: 'SupabaseService');

      if (headData != null) {
        final householdId = headData['id'] as String?;
        developer.log('Found household as head: $householdId', name: 'SupabaseService');
        return householdId;
      }

      // User is not a household head
      developer.log('User is not a household head', name: 'SupabaseService');
      return null;
    } catch (e) {
      developer.log('Error getting household ID: $e', name: 'SupabaseService', error: e);
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
