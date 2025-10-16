import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Supabase client configuration and initialization
/// Sentinel App - Backend integration with multi-tenant RLS support
class SupabaseClientWrapper {
  SupabaseClientWrapper._();

  static final SupabaseClientWrapper _instance = SupabaseClientWrapper._();
  static SupabaseClientWrapper get instance => _instance;

  late final SupabaseClient _supabaseClient;
  final Logger _logger = Logger();

  /// Initialize Supabase with environment configuration
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
    bool debugMode = false,
  }) async {
    try {
      _logger.i('Initializing Supabase client...');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      _supabaseClient = Supabase.instance.client;
      _logger.i('Supabase client initialized successfully');

    } catch (e) {
      _logger.e('Failed to initialize Supabase client: $e');
      rethrow;
    }
  }

  /// Get the Supabase client instance
  SupabaseClient get client => _supabaseClient;

  /// Get current authenticated user
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabaseClient.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null && currentSession != null;

  /// Get tenant ID from JWT claims
  String? get tenantId {
    final session = currentSession;
    if (session == null) return null;
    final claims = session.user.appMetadata;
    return claims['tenant_id'] as String?;
  }

  /// Get user role from JWT claims
  String? get userRole {
    final session = currentSession;
    if (session == null) return null;
    final claims = session.user.appMetadata;
    return claims['role'] as String?;
  }

  /// Check if current user has guard role
  bool get isGuard => userRole == 'guard';

  /// Sign in guard with email and password
  Future<AuthResponse> signInGuard({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Signing in guard: $email');
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('Guard signed in successfully');
      return response;
    } catch (e) {
      _logger.e('Guard sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Error during sign out: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  /// Get current JWT token
  String? get currentJWT => currentSession?.accessToken;

  /// Dispose resources
  void dispose() {
    _logger.i('Disposing Supabase client resources');
  }
}