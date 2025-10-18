import 'dart:io';
import '../models/beneficial_user.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';
import 'photo_upload_service.dart';
import 'offline_cache_service.dart';

/// Beneficial user service
/// Handles CRUD operations for beneficial users with photo upload
class BeneficialUserService {
  static BeneficialUserService? _instance;

  BeneficialUserService._();

  /// Singleton instance
  static BeneficialUserService get instance {
    _instance ??= BeneficialUserService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;
  final _photoService = PhotoUploadService.instance;
  final _cacheService = OfflineCacheService.instance;

  static const _cacheKey = 'beneficial_users';

  /// Add beneficial user with optional photo
  Future<ApiResult<BeneficialUser>> addBeneficialUser({
    required String fullName,
    required String contactNumber,
    String? email,
    required String relationship,
    File? idPhoto,
    String? status = 'active',
  }) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      String? photoUrl;
      if (idPhoto != null) {
        // Upload photo first
        photoUrl = await _photoService.uploadBeneficialUserPhoto(
          photoFile: idPhoto,
          userId: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      final data = await _supabase.from('beneficial_users').insert({
        'household_id': householdId,
        'full_name': fullName,
        'contact_number': contactNumber,
        'email': email,
        'relationship': relationship,
        'id_photo_url': photoUrl,
        'status': status,
      }).select().single();

      final user = BeneficialUser.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Update beneficial user with optional photo update
  Future<ApiResult<BeneficialUser>> updateBeneficialUser({
    required String userId,
    String? fullName,
    String? contactNumber,
    String? email,
    String? relationship,
    File? newIdPhoto,
    String? oldPhotoUrl,
    String? status,
  }) async {
    try {
      String? photoUrl = oldPhotoUrl;

      // If new photo provided, delete old and upload new
      if (newIdPhoto != null) {
        // Delete old photo if exists
        if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
          try {
            await _photoService.deletePhoto(oldPhotoUrl);
          } catch (e) {
            // Continue even if delete fails
            // ignore: avoid_print
            print('Warning: Could not delete old photo: $e');
          }
        }

        // Upload new photo
        photoUrl = await _photoService.uploadBeneficialUserPhoto(
          photoFile: newIdPhoto,
          userId: userId,
        );
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (contactNumber != null) updateData['contact_number'] = contactNumber;
      if (email != null) updateData['email'] = email;
      if (relationship != null) updateData['relationship'] = relationship;
      if (photoUrl != null) updateData['id_photo_url'] = photoUrl;
      if (status != null) updateData['status'] = status;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('beneficial_users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      final user = BeneficialUser.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Remove beneficial user (deactivate)
  /// Cascade behavior: Deactivates associated vehicle stickers
  Future<ApiResult<void>> removeBeneficialUser(String userId) async {
    try {
      // Check for active stickers
      final hasStickers = await hasActiveStickers(userId);
      if (hasStickers) {
        // Deactivate all stickers for this beneficial user
        await _supabase
            .from('rfid_stickers')
            .update({
              'status': 'deactivated',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('owner_id', userId)
            .eq('owner_type', 'beneficial_user');
      }

      // Get photo URL before deletion
      final response = await _supabase
          .from('beneficial_users')
          .select('id_photo_url')
          .eq('id', userId)
          .single();

      final photoUrl = response['id_photo_url'] as String?;

      // Delete beneficial user record
      await _supabase.from('beneficial_users').delete().eq('id', userId);

      // Delete photo if exists
      if (photoUrl != null && photoUrl.isNotEmpty) {
        try {
          await _photoService.deletePhoto(photoUrl);
        } catch (e) {
          // Continue even if photo delete fails
          // ignore: avoid_print
          print('Warning: Could not delete photo: $e');
        }
      }

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch all beneficial users for household
  Future<ApiResult<List<BeneficialUser>>> fetchBeneficialUsers() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('beneficial_users')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

      final users = (data as List).map((json) => BeneficialUser.fromJson(json)).toList();

      // Cache the results
      await _cacheService.put(_cacheKey, data);

      return ApiResult.success(users);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch beneficial users from cache
  Future<List<BeneficialUser>?> fetchBeneficialUsersFromCache() async {
    try {
      final cached = await _cacheService.get(_cacheKey);
      if (cached == null) return null;

      final users = (cached as List).map((json) => BeneficialUser.fromJson(json)).toList();
      return users;
    } catch (e) {
      return null;
    }
  }

  /// Check if beneficial user has active stickers
  Future<bool> hasActiveStickers(String userId) async {
    try {
      final data = await _supabase
          .from('rfid_stickers')
          .select('id')
          .eq('owner_id', userId)
          .eq('owner_type', 'beneficial_user')
          .eq('status', 'active')
          .limit(1);

      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Fetch beneficial users by status
  Future<ApiResult<List<BeneficialUser>>> fetchBeneficialUsersByStatus(
    String status,
  ) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('beneficial_users')
          .select()
          .eq('household_id', householdId)
          .eq('status', status)
          .order('created_at', ascending: false);

      final users = (data as List).map((json) => BeneficialUser.fromJson(json)).toList();

      return ApiResult.success(users);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch beneficial users by relationship
  Future<ApiResult<List<BeneficialUser>>> fetchBeneficialUsersByRelationship(
    String relationship,
  ) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('beneficial_users')
          .select()
          .eq('household_id', householdId)
          .eq('relationship', relationship)
          .order('created_at', ascending: false);

      final users = (data as List).map((json) => BeneficialUser.fromJson(json)).toList();

      return ApiResult.success(users);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Toggle beneficial user status (active/inactive)
  Future<ApiResult<BeneficialUser>> toggleStatus(String userId) async {
    try {
      // Get current status
      final response = await _supabase
          .from('beneficial_users')
          .select('status')
          .eq('id', userId)
          .single();

      final currentStatus = response['status'] as String;
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

      // Update status
      final data = await _supabase
          .from('beneficial_users')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      final user = BeneficialUser.fromJson(data);

      // Clear cache to force refresh
      await _cacheService.delete(_cacheKey);

      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
