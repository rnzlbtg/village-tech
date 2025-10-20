import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guard.dart';
import '../../services/supabase_service.dart';

/// Authentication state
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final Guard? guard;
  final String? error;
  final String? tenantId;

  const AuthState({
    required this.status,
    this.user,
    this.guard,
    this.error,
    this.tenantId,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Guard? guard,
    String? error,
    String? tenantId,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      guard: guard ?? this.guard,
      error: clearError ? null : (error ?? this.error),
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.guard == guard &&
        other.error == error &&
        other.tenantId == tenantId;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, guard, error, tenantId);
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, guard: $guard, error: $error, tenantId: $tenantId)';
  }
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  late final StreamSubscription _authSubscription;

  AuthStateNotifier(this._supabaseService) : super(const AuthState(status: AuthStatus.initial)) {
    _initialize();
  }

  /// Initialize authentication state
  Future<void> _initialize() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      debugPrint('🔧 AUTH INITIALIZATION: Starting SupabaseService initialization');

      // Initialize Supabase service
      await _supabaseService.initialize();

      debugPrint('✅ AUTH INITIALIZATION: SupabaseService initialized successfully');

      // Listen to auth changes
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final User? user = data.session?.user;
        if (user != null) {
          _handleUserAuthenticated(user);
        } else {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            guard: null,
            tenantId: null,
            clearError: true,
          );
        }
      });

      // Check current session
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        await _handleUserAuthenticated(currentUser);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize authentication: $e',
      );
    }
  }

  /// Handle user authentication
  Future<void> _handleUserAuthenticated(User user) async {
    try {
      // Auto-detect tenant ID
      final tenantId = await _detectTenantId(user);

      if (tenantId != null) {
        // Set tenant context
        _supabaseService.setCurrentTenant(tenantId);

        // Get user profile
        final userProfileData = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('email', user.email!)
            .eq('tenant_id', tenantId)
            .maybeSingle();

        final guard = userProfileData != null ? Guard.fromJson({
          'id': userProfileData['id'] ?? '',
          'tenant_id': userProfileData['tenant_id'] ?? tenantId,
          'email': userProfileData['email'] ?? user.email ?? '',
          'full_name': userProfileData['full_name'] ?? userProfileData['name'] ?? 'Unknown',
          'role': userProfileData['role'] ?? 'guard_officer',
          'phone': userProfileData['phone'],
          'employee_id': userProfileData['employee_id'],
          'is_active': userProfileData['is_active'] ?? true,
          'created_at': userProfileData['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': userProfileData['updated_at'] ?? DateTime.now().toIso8601String(),
        }) : null;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          guard: guard,
          tenantId: tenantId,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, clearError: true);

      debugPrint('🔐 AUTH PROVIDER: Starting sign in process for $email');

      // Ensure SupabaseService is initialized
      if (!_supabaseService.isInitialized) {
        debugPrint('🔧 AUTH PROVIDER: SupabaseService not initialized, initializing now...');
        await _supabaseService.initialize();
        debugPrint('✅ AUTH PROVIDER: SupabaseService initialized successfully');
      }

      // Use Supabase service to sign in
      final response = await _supabaseService.signInGuard(
        email: email,
        password: password,
        tenantId: 'auto', // Will be auto-detected in the service
      );

      if (response.success && response.data != null) {
        final userData = response.data!;
        final userProfileData = userData['userProfile'] as Map<String, dynamic>;

        // Log tenant detection process
        final appMetadata = userData['user']?['app_metadata'] as Map<String, dynamic>?;
        final metadataTenantId = appMetadata?['tenant_id'] as String?;
        debugPrint('🔍 TENANT DETECTION - Metadata tenant ID: $metadataTenantId');

        final tenantId = metadataTenantId ?? userProfileData['tenant_id'] as String?;

        if (tenantId != null) {
          debugPrint('✅ TENANT DETECTED: $tenantId for user $email');
          _supabaseService.setCurrentTenant(tenantId);

          // Convert user data back to User object
          final userMap = userData['user'] as Map<String, dynamic>;
          final user = User(
            id: userMap['id'] as String,
            email: userMap['email'] as String?,
            aud: userMap['aud'] as String? ?? '',
            role: userMap['role'] as String? ?? '',
            appMetadata: userMap['app_metadata'] as Map<String, dynamic>? ?? {},
            userMetadata: userMap['user_metadata'] as Map<String, dynamic>? ?? {},
            createdAt: userMap['created_at'] as String? ?? '',
          );

          // Store user profile data as guard data (reusing the field)
          final guardData = userProfileData.isNotEmpty ? Guard.fromJson({
            'id': userProfileData['id'] ?? '',
            'tenant_id': userProfileData['tenant_id'] ?? tenantId,
            'email': userProfileData['email'] ?? user.email ?? '',
            'full_name': userProfileData['full_name'] ?? userProfileData['name'] ?? 'Unknown',
            'role': userProfileData['role'] ?? 'guard_officer',
            'phone': userProfileData['phone'],
            'employee_id': userProfileData['employee_id'],
            'is_active': userProfileData['is_active'] ?? true,
            'created_at': userProfileData['created_at'] ?? DateTime.now().toIso8601String(),
            'updated_at': userProfileData['updated_at'] ?? DateTime.now().toIso8601String(),
          }) : null;

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            guard: guardData,
            tenantId: tenantId,
            clearError: true,
          );

          final userName = userProfileData['full_name'] ?? userProfileData['name'] ?? 'Unknown';
          final userRole = userProfileData['role'] ?? 'Unknown';
          debugPrint('✅ AUTH PROVIDER: Authentication successful for $userName ($userRole)');
          return true;
        } else {
          debugPrint('❌ TENANT DETECTION FAILED: Could not determine tenant context for $email');
          state = state.copyWith(
            status: AuthStatus.error,
            error: 'Could not determine tenant context for this user',
          );
          return false;
        }
      } else {
        debugPrint('❌ AUTH PROVIDER: Sign in failed - ${response.error ?? 'Unknown error'}');
        state = state.copyWith(
          status: AuthStatus.error,
          error: response.error ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      debugPrint('💥 AUTH PROVIDER: Exception during sign in - $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Login failed: $e',
      );
      return false;
    }
  }

  /// Auto-detect tenant ID from user metadata or guard relationship
  Future<String?> _detectTenantId(User user) async {
    try {
      // Method 1: Check user metadata first (preferred)
      final tenantId = user.appMetadata['tenant_id'] as String?;
      if (tenantId != null) {
        return tenantId;
      }

      // Method 2: Query via guard relationship (fallback)
      return await _getTenantViaGuard(user.email!);
    } catch (e) {
      debugPrint('Error detecting tenant ID: $e');
      return null;
    }
  }

  /// Get tenant ID via user profile relationship
  Future<String?> _getTenantViaGuard(String email) async {
    try {
      debugPrint('🔍 FALLBACK: Querying tenant ID via user profile relationship for $email');

      final userProfileData = await Supabase.instance.client
          .from('user_profiles')
          .select('tenant_id')
          .eq('email', email)
          .maybeSingle();

      final tenantId = userProfileData?['tenant_id'] as String?;
      debugPrint('🔍 FALLBACK: User profile query result - Tenant ID: $tenantId');

      return tenantId;
    } catch (e) {
      debugPrint('❌ FALLBACK: Error getting tenant via user profile - $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        guard: null,
        tenantId: null,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Sign out failed: $e',
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set tenant ID
  void setTenantId(String tenantId) {
    state = state.copyWith(tenantId: tenantId);
    _supabaseService.setCurrentTenant(tenantId);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}