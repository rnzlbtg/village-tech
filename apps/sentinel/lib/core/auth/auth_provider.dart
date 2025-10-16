import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'supabase_client.dart';
import 'guard_session.dart';

/// Authentication states for the Sentinel App
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state model
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.tenantId,
    this.guardProfile,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  final String? tenantId;
  final GuardProfile? guardProfile;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? tenantId,
    GuardProfile? guardProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      tenantId: tenantId ?? this.tenantId,
      guardProfile: guardProfile ?? this.guardProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error &&
        other.tenantId == tenantId &&
        other.guardProfile == guardProfile;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        error.hashCode ^
        tenantId.hashCode ^
        guardProfile.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, tenantId: $tenantId)';
  }
}

/// Authentication provider using Riverpod
/// Manages guard authentication state and sessions
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._supabaseClient) : super(const AuthState());

  final SupabaseClientWrapper _supabaseClient;
  final Logger _logger = Logger();

  /// Initialize authentication state
  Future<void> initialize() async {
    try {
      state = const AuthState(status: AuthStatus.loading);

      // Listen to auth state changes
      _supabaseClient.authStateChanges.listen((AuthState data) {
        _handleAuthStateChange(data);
      });

      // Check current auth state
      final currentUser = _supabaseClient.currentUser;
      final currentSession = _supabaseClient.currentSession;

      if (currentUser != null && currentSession != null) {
        final tenantId = _supabaseClient.tenantId;

        // Load guard profile if tenant is available
        GuardProfile? guardProfile;
        if (tenantId != null) {
          guardProfile = await _loadGuardProfile(currentUser.id, tenantId);
        }

        state = AuthState(
          status: AuthStatus.authenticated,
          user: currentUser,
          tenantId: tenantId,
          guardProfile: guardProfile,
        );

        _logger.i('Authentication initialized successfully for guard: ${currentUser.email}');
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
        _logger.i('No active session found');
      }

    } catch (e) {
      _logger.e('Failed to initialize authentication: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: 'Authentication initialization failed',
      );
    }
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthState authData) {
    final session = authData.session;

    if (session == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      _logger.i('User signed out');
    } else {
      _logger.i('Auth state changed: ${authData.event}');
    }
  }

  /// Sign in guard with email and password
  Future<void> signInGuard({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState(status: AuthStatus.loading);

      final response = await _supabaseClient.signInGuard(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      final tenantId = _supabaseClient.tenantId;
      if (tenantId == null) {
        throw Exception('Guard account is not assigned to any tenant');
      }

      // Load guard profile
      final guardProfile = await _loadGuardProfile(user.id, tenantId);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        tenantId: tenantId,
        guardProfile: guardProfile,
      );

      _logger.i('Guard signed in successfully: ${user.email}');

    } catch (e) {
      _logger.e('Guard sign in failed: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Sign out current guard
  Future<void> signOut() async {
    try {
      await _supabaseClient.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
      _logger.i('Guard signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: 'Sign out failed',
      );
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.resetPassword(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _logger.e('Password reset failed: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: 'Password reset failed',
      );
      rethrow;
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _supabaseClient.refreshSession();
      _logger.i('Session refreshed successfully');
    } catch (e) {
      _logger.e('Session refresh failed: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: 'Session refresh failed',
      );
    }
  }

  /// Update guard profile
  Future<void> updateGuardProfile(GuardProfile profile) async {
    try {
      // Update local state
      state = state.copyWith(guardProfile: profile);

      // TODO: Update in Supabase database
      // await _supabaseClient.client.from('guards').update(profile.toMap()).eq('id', profile.id);

      _logger.i('Guard profile updated successfully');
    } catch (e) {
      _logger.e('Failed to update guard profile: $e');
      state = AuthState(
        status: AuthStatus.error,
        error: 'Failed to update profile',
      );
    }
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    }
  }

  /// Load guard profile from database
  Future<GuardProfile?> _loadGuardProfile(String userId, String tenantId) async {
    try {
      // TODO: Implement actual guard profile loading from Supabase
      // final response = await _supabaseClient.client
      //     .from('guards')
      //     .select()
      //     .eq('user_id', userId)
      //     .eq('tenant_id', tenantId)
      //     .single();

      // For now, return a mock profile
      return GuardProfile(
        id: userId,
        email: 'guard@example.com',
        name: 'Security Guard',
        tenantId: tenantId,
        role: 'guard',
        assignedGate: 'Main Gate',
      );

    } catch (e) {
      _logger.w('Failed to load guard profile: $e');
      return null;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred';
    }
  }
}

// Riverpod providers
final supabaseClientProvider = Provider<SupabaseClientWrapper>((ref) {
  return SupabaseClientWrapper.instance;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthNotifier(supabaseClient);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

final guardProfileProvider = Provider<GuardProfile?>((ref) {
  return ref.watch(authProvider).guardProfile;
});

final tenantIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).tenantId;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});