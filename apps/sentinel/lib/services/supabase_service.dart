import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';

import '../models/guard.dart';
import '../models/rfid_sticker.dart';
import '../models/entry_log.dart';
import '../models/guard_session.dart';
import '../utils/constants.dart';

/// Supabase API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse(
      success: false,
      error: error,
      message: message,
    );
  }
}

/// Supabase service for backend integration
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _supabase;
  late final SupabaseClient _supabaseServiceRole;
  bool _isInitialized = false;
  String? _currentTenantId;

  /// Getters
  bool get isInitialized => _isInitialized;
  String? get currentTenantId => _currentTenantId;

  /// Initialize Supabase client
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Supabase Flutter
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );

      _supabase = Supabase.instance.client;

      // Initialize service role client for admin operations
      if (Environment.supabaseServiceRoleKey.isNotEmpty) {
        _supabaseServiceRole = SupabaseClient(
          Environment.supabaseUrl,
          Environment.supabaseServiceRoleKey,
        );
      }

      _isInitialized = true;
      debugPrint('Supabase service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Set current tenant context for RLS
  void setCurrentTenant(String tenantId) {
    _currentTenantId = tenantId;
    _supabase.rpc('set_tenant_context', params: {'tenant_id': tenantId});
  }

  /// Clear current tenant context
  void clearCurrentTenant() {
    _currentTenantId = null;
  }

  // ==================== AUTHENTICATION ====================

  /// Sign in guard
  Future<ApiResponse<Map<String, dynamic>>> signInGuard({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    try {
      setCurrentTenant(tenantId);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get guard profile
        final guardData = await _supabase
            .from('guards')
            .select()
            .eq('email', email)
            .eq('tenant_id', tenantId)
            .single();

        return ApiResponse.success({
          'user': response.user!.toJson(),
          'guard': guardData,
        }, message: 'Sign in successful');
      } else {
        return ApiResponse.error('Sign in failed', message: 'Invalid credentials');
      }
    } on PostgrestException catch (e) {
      return ApiResponse.error('Database error: ${e.message}');
    } on AuthException catch (e) {
      return ApiResponse.error('Authentication error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Sign out guard
  Future<ApiResponse<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      clearCurrentTenant();
      return ApiResponse.success(null, message: 'Sign out successful');
    } on AuthException catch (e) {
      return ApiResponse.error('Sign out error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // ==================== GUARD OPERATIONS ====================

  /// Get guard profile
  Future<ApiResponse<Guard>> getGuardProfile(String guardId) async {
    try {
      final response = await _supabase
          .from('guards')
          .select()
          .eq('id', guardId)
          .single();

      final guard = Guard.fromJson(response);
      return ApiResponse.success(guard);
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to get guard profile: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Update guard profile
  Future<ApiResponse<Guard>> updateGuardProfile(Guard guard) async {
    try {
      final response = await _supabase
          .from('guards')
          .update(guard.toJson())
          .eq('id', guard.id)
          .select()
          .single();

      final updatedGuard = Guard.fromJson(response);
      return ApiResponse.success(updatedGuard, message: 'Profile updated successfully');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to update profile: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ==================== RFID OPERATIONS ====================

  /// Verify RFID sticker
  Future<ApiResponse<RfidSticker>> verifyRfidSticker(String stickerCode) async {
    try {
      final response = await _supabase
          .from('rfid_stickers')
          .select()
          .eq('sticker_code', stickerCode)
          .eq('status', 'active')
          .single();

      final sticker = RfidSticker.fromJson(response);

      // Update last used time
      await _supabase
          .from('rfid_stickers')
          .update({'last_used_at': DateTime.now().toIso8601String()})
          .eq('id', sticker.id);

      return ApiResponse.success(sticker, message: 'RFID sticker verified successfully');
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return ApiResponse.error('RFID sticker not found or inactive');
      }
      return ApiResponse.error('Failed to verify RFID: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get RFID stickers for tenant
  Future<ApiResponse<List<RfidSticker>>> getRfidStickers({
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      // Check if tenant ID is available
      if (_currentTenantId == null) {
        return ApiResponse.error('No tenant context set');
      }

      // Build the query with all filters before ordering
      var queryBuilder = _supabase
          .from('rfid_stickers')
          .select()
          .eq('tenant_id', _currentTenantId!);

      // Apply status filter if provided
      if (status != null) {
        queryBuilder = queryBuilder.eq('status', status);
      }

      // Apply ordering and pagination (these return PostgrestTransformBuilder)
      final query = queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;
      final stickers = (response as List)
          .map((json) => RfidSticker.fromJson(json))
          .toList();

      return ApiResponse.success(stickers);
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to get RFID stickers: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ==================== ENTRY LOG OPERATIONS ====================

  /// Create entry log
  Future<ApiResponse<EntryLog>> createEntryLog(EntryLog entryLog) async {
    try {
      final response = await _supabase
          .from('entry_logs')
          .insert(entryLog.toJson())
          .select()
          .single();

      final createdLog = EntryLog.fromJson(response);
      return ApiResponse.success(createdLog, message: 'Entry log created successfully');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to create entry log: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Update entry log (record exit)
  Future<ApiResponse<EntryLog>> updateEntryLog(EntryLog entryLog) async {
    try {
      final response = await _supabase
          .from('entry_logs')
          .update(entryLog.toJson())
          .eq('id', entryLog.id)
          .select()
          .single();

      final updatedLog = EntryLog.fromJson(response);
      return ApiResponse.success(updatedLog, message: 'Entry log updated successfully');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to update entry log: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get today's entries
  Future<ApiResponse<List<EntryLog>>> getTodayEntries({
    String? entryType,
    String? verificationStatus,
    int limit = 100,
  }) async {
    try {
      // Check if tenant ID is available
      if (_currentTenantId == null) {
        return ApiResponse.error('No tenant context set');
      }

      // Build the query with all filters before ordering
      var queryBuilder = _supabase
          .from('entry_logs')
          .select()
          .eq('tenant_id', _currentTenantId!)
          .gte('entry_time', DateTime.now().toIso8601String().substring(0, 10));

      // Apply entry type filter if provided
      if (entryType != null) {
        queryBuilder = queryBuilder.eq('entry_type', entryType);
      }

      // Apply verification status filter if provided
      if (verificationStatus != null) {
        queryBuilder = queryBuilder.eq('verification_status', verificationStatus);
      }

      // Apply ordering and limit (these return PostgrestTransformBuilder)
      final query = queryBuilder
          .order('entry_time', ascending: false)
          .limit(limit);

      final response = await query;
      final entries = (response as List)
          .map((json) => EntryLog.fromJson(json))
          .toList();

      return ApiResponse.success(entries);
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to get today\'s entries: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ==================== GUARD SESSION OPERATIONS ====================

  /// Create guard session
  Future<ApiResponse<GuardSession>> createGuardSession(GuardSession session) async {
    try {
      final response = await _supabase
          .from('guard_sessions')
          .insert(session.toJson())
          .select()
          .single();

      final createdSession = GuardSession.fromJson(response);
      return ApiResponse.success(createdSession, message: 'Session created successfully');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to create session: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// End guard session
  Future<ApiResponse<GuardSession>> endGuardSession(String sessionId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('guard_sessions')
          .update({
            'logout_time': now,
            'is_active': false,
            'updated_at': now,
          })
          .eq('id', sessionId)
          .select()
          .single();

      final endedSession = GuardSession.fromJson(response);
      return ApiResponse.success(endedSession, message: 'Session ended successfully');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to end session: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get active sessions for tenant
  Future<ApiResponse<List<GuardSession>>> getActiveSessions() async {
    try {
      // Check if tenant ID is available
      if (_currentTenantId == null) {
        return ApiResponse.error('No tenant context set');
      }

      final response = await _supabase
          .from('guard_sessions')
          .select('*, guards!inner(full_name, role)')
          .eq('tenant_id', _currentTenantId!)
          .eq('is_active', true)
          .order('login_time', ascending: false);

      final sessions = (response as List)
          .map((json) {
            // Extract guard data
            final guardData = {
              'id': json['id'],
              'guard_id': json['guard_id'],
              'tenant_id': json['tenant_id'],
              'login_time': json['login_time'],
              'logout_time': json['logout_time'],
              'device_info': json['device_info'],
              'ip_address': json['ip_address'],
              'user_agent': json['user_agent'],
              'is_active': json['is_active'],
              'session_token_hash': json['session_token_hash'],
              'created_at': json['created_at'],
              'updated_at': json['updated_at'],
            };
            return GuardSession.fromJson(guardData);
          })
          .toList();

      return ApiResponse.success(sessions);
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to get active sessions: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Get pending sync operations
  Future<ApiResponse<List<Map<String, dynamic>>>> getPendingSyncOperations() async {
    try {
      // Check if tenant ID is available
      if (_currentTenantId == null) {
        return ApiResponse.error('No tenant context set');
      }

      final response = await _supabase
          .from('sync_queue')
          .select()
          .eq('tenant_id', _currentTenantId!)
          .eq('status', 'pending')
          .order('priority', ascending: false)
          .order('created_at', ascending: true)
          .limit(50);

      return ApiResponse.success(response as List<Map<String, dynamic>>);
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to get sync operations: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Complete sync operation
  Future<ApiResponse<void>> completeSyncOperation(String operationId) async {
    try {
      await _supabase
          .from('sync_queue')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', operationId);

      return ApiResponse.success(null, message: 'Sync operation completed');
    } on PostgrestException catch (e) {
      return ApiResponse.error('Failed to complete sync operation: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // ==================== HEALTH CHECK ====================

  /// Check Supabase connection
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final startTime = DateTime.now();

      // Simple query to test connection
      await _supabase.from('guards').select('count').limit(1);

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return ApiResponse.success({
        'status': 'healthy',
        'response_time_ms': responseTime,
        'timestamp': endTime.toIso8601String(),
        'tenant_id': _currentTenantId,
      });
    } catch (e) {
      return ApiResponse.error('Health check failed: $e');
    }
  }

  /// Dispose service
  void dispose() {
    _isInitialized = false;
    _currentTenantId = null;
    debugPrint('Supabase service disposed');
  }
}