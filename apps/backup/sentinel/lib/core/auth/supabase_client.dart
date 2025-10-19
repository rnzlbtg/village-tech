import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../env.dart';

/// Supabase client configuration and initialization
/// Sentinel App - Backend integration with multi-tenant RLS support
class SupabaseClientWrapper {
  SupabaseClientWrapper._();

  static final SupabaseClientWrapper _instance = SupabaseClientWrapper._();
  static SupabaseClientWrapper get instance => _instance;

  late final SupabaseClient _supabaseClient;
  final Logger _logger = Logger();

  /// Initialize Supabase with environment variables
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Supabase client with environment variables...');

      // Validate environment variables
      if (Env.supabaseUrl.isEmpty) {
        throw Exception('SUPABASE_URL environment variable is required');
      }
      if (Env.supabaseAnonKey.isEmpty) {
        throw Exception('SUPABASE_ANON_KEY environment variable is required');
      }

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        debug: Env.debugMode,
      );

      _supabaseClient = Supabase.instance.client;
      _logger.i('Supabase client initialized successfully');

      // Listen to auth state changes for logging and session management
      _supabaseClient.auth.onAuthStateChange.listen(_onAuthStateChange);

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

  /// Get JWT token expiration time
  DateTime? get tokenExpiration {
    final session = currentSession;
    if (session == null) return null;

    // Decode JWT token to get expiration (simplified version)
    // In production, you might want to use a proper JWT decoder
    final token = session.accessToken;
    if (token == null) return null;

    try {
      // This is a simplified approach - consider using flutter_jwt for production
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));

      final claims = jsonDecode(decoded);
      final exp = claims['exp'];

      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    } catch (e) {
      _logger.w('Failed to decode token expiration: $e');
    }

    return null;
  }

  /// Check if token is expired or will expire soon
  bool isTokenExpired({Duration buffer = const Duration(minutes: 5)}) {
    final expiration = tokenExpiration;
    if (expiration == null) return true;

    return DateTime.now().add(buffer).isAfter(expiration);
  }

  /// Validate JWT token and session
  Future<bool> validateTokenAndSession() async {
    try {
      if (!isAuthenticated) {
        return false;
      }

      // Check token expiration
      if (isTokenExpired()) {
        _logger.w('JWT token is expired');
        return false;
      }

      // Validate tenant_id in token
      if (tenantId == null || tenantId!.isEmpty) {
        _logger.e('No tenant_id found in JWT token');
        return false;
      }

      // Validate user role
      if (userRole == null || (userRole != 'guard' && userRole != 'admin')) {
        _logger.e('Invalid or missing user role in JWT token');
        return false;
      }

      return true;
    } catch (e) {
      _logger.e('Token validation failed: $e');
      return false;
    }
  }

  /// Refresh JWT token if needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      if (!isAuthenticated) {
        return false;
      }

      // Refresh token if expired or will expire soon
      if (isTokenExpired()) {
        final response = await _supabaseClient.auth.refreshSession();

        if (response.session != null) {
          _logger.i('JWT token refreshed successfully');
          return true;
        } else {
          _logger.e('JWT token refresh failed: no session returned');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }

  /// Get tenant-specific headers for API requests
  Map<String, String> getTenantHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (tenantId != null) {
      headers['X-Tenant-ID'] = tenantId!;
    }

    if (userRole != null) {
      headers['X-Guard-Role'] = userRole!;
    }

    // Add authorization header if we have a valid token
    final token = currentJWT;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Validate RLS policy compliance for database operations
  Future<bool> validateRLSPolicy({
    required String tableName,
    String? operation = 'SELECT',
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      // Check authentication
      if (!await validateTokenAndSession()) {
        _logger.e('RLS validation failed: Invalid authentication');
        return false;
      }

      // Check tenant isolation
      final currentTenantId = tenantId;
      if (currentTenantId == null) {
        _logger.e('RLS validation failed: No tenant context');
        return false;
      }

      // Log RLS validation for debugging
      if (Env.enableLogging) {
        _logger.d('RLS validation passed for table: $tableName, operation: $operation, tenant: $currentTenantId');
      }

      return true;
    } catch (e) {
      _logger.e('RLS policy validation error: $e');
      return false;
    }
  }

  /// Simple database query - TODO: Implement proper RLS when needed
  Future<List<Map<String, dynamic>>> simpleQuery(String tableName) async {
    try {
      final response = await _supabaseClient.from(tableName).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Simple query failed: $e');
      rethrow;
    }
  }

  /// Simple insert operation - TODO: Implement proper RLS when needed
  Future<void> simpleInsert(String tableName, Map<String, dynamic> data) async {
    try {
      await _supabaseClient.from(tableName).insert(data);
    } catch (e) {
      _logger.e('Simple insert failed: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _logger.i('Disposing Supabase client resources');
  }

  /// Handle authentication state changes
  void _onAuthStateChange(AuthState data) {
    final event = data.event.name;
    final userId = data.session?.user.id;
    final tenantId = data.session?.user.userMetadata?['tenant_id'];

    if (Env.enableLogging) {
      _logger.i('Auth state changed: $event for user: $userId, tenant: $tenantId');
    }
  }
}