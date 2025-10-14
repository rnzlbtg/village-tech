import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Get household ID for current user
  Future<String?> getHouseholdId() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final data = await client
          .from('households')
          .select('id')
          .eq('household_head_id', userId)
          .maybeSingle();

      return data?['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
