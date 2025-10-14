import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'supabase_service.dart';

/// Photo upload service with compression
/// Handles image compression and upload to Supabase Storage
class PhotoUploadService {
  static PhotoUploadService? _instance;

  PhotoUploadService._();

  /// Singleton instance
  static PhotoUploadService get instance {
    _instance ??= PhotoUploadService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Upload beneficial user ID photo
  /// Compresses image to max 1MB, 1920x1080 resolution, quality 85
  /// Returns signed URL valid for 24 hours
  Future<String> uploadBeneficialUserPhoto({
    required File photoFile,
    required String userId,
  }) async {
    // 1. Compress image
    final compressedFile = await _compressImage(photoFile);

    // 2. Upload to Supabase Storage
    final tenantId = SupabaseService.instance.tenantId;
    if (tenantId == null) {
      throw Exception('Tenant ID not found in user metadata');
    }

    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$tenantId/beneficial-users/$fileName';

    await _supabase.storage.from('user-photos').upload(
          path,
          compressedFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // 3. Get signed URL (24-hour expiration)
    final signedUrl = await _supabase.storage.from('user-photos').createSignedUrl(
          path,
          86400, // 24 hours in seconds
        );

    // 4. Clean up temporary compressed file
    await compressedFile.delete();

    return signedUrl;
  }

  /// Compress image to target size and resolution
  Future<File> _compressImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      throw Exception('Image compression failed');
    }

    return File(compressedFile.path);
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Delete photo from storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      // Extract path from signed URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket and path
      // URL format: https://.../storage/v1/object/sign/user-photos/{path}
      final bucketIndex = pathSegments.indexOf('user-photos');
      if (bucketIndex == -1) {
        throw Exception('Invalid photo URL format');
      }

      final path = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from('user-photos').remove([path]);
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting photo: $e');
      rethrow;
    }
  }
}
