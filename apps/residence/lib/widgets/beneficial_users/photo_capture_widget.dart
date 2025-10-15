import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Photo capture widget with camera and gallery options
class PhotoCaptureWidget extends StatefulWidget {
  final File? initialPhoto;
  final String? initialPhotoUrl;
  final ValueChanged<File?> onPhotoChanged;
  final String label;

  const PhotoCaptureWidget({
    super.key,
    this.initialPhoto,
    this.initialPhotoUrl,
    required this.onPhotoChanged,
    this.label = 'ID Photo',
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedPhoto = widget.initialPhoto;
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _selectedPhoto != null || widget.initialPhotoUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Photo preview or placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: hasPhoto
              ? Stack(
                  children: [
                    // Photo display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildPhotoDisplay(),
                    ),

                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _removePhoto,
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No photo selected',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build photo display
  Widget _buildPhotoDisplay() {
    if (_selectedPhoto != null) {
      // Display newly selected photo
      return Image.file(
        _selectedPhoto!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (widget.initialPhotoUrl != null) {
      // Display existing photo from URL
      return Image.network(
        widget.initialPhotoUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Failed to load photo',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  /// Pick photo from camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedPhoto = File(photo.path);
        });
        widget.onPhotoChanged(_selectedPhoto);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to capture photo: $e');
    }
  }

  /// Pick photo from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedPhoto = File(photo.path);
        });
        widget.onPhotoChanged(_selectedPhoto);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to select photo: $e');
    }
  }

  /// Remove selected photo
  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
    widget.onPhotoChanged(null);
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
