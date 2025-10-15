import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../services/supabase_service.dart';

/// Authentication state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  final _supabase = SupabaseService.instance.client;

  void _init() {
    // Initialize with current user
    state = AuthState(user: _supabase.auth.currentUser);

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      state = AuthState(user: data.session?.user);
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = AuthState(user: response.user);
    } on AuthException catch (e) {
      // Handle Supabase-specific auth errors
      developer.log('AuthException: ${e.message}', name: 'AuthProvider', error: e);
      String errorMessage = 'Authentication failed';

      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Please verify your email address';
      } else if (e.message.contains('network') || e.message.contains('fetch')) {
        errorMessage = 'Network error. Please check your connection';
      } else {
        errorMessage = e.message;
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
      // Handle other errors (network, etc.)
      developer.log('Sign in error: $e', name: 'AuthProvider', error: e);
      String errorMessage = 'An error occurred';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('network') ||
          e.toString().contains('fetch') ||
          e.toString().contains('AuthRetryableFetch')) {
        errorMessage = 'Network error. Please check your internet connection';
      } else {
        errorMessage = e.toString();
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _supabase.auth.resetPasswordForEmail(email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
