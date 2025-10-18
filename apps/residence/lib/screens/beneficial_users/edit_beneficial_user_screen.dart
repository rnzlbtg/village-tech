import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/beneficial_user.dart';
import '../../providers/beneficial_user_provider.dart';
import '../../widgets/beneficial_users/photo_capture_widget.dart';
import '../../utils/validators.dart';

/// Edit beneficial user form with photo update
class EditBeneficialUserScreen extends ConsumerStatefulWidget {
  final String userId;

  const EditBeneficialUserScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<EditBeneficialUserScreen> createState() =>
      _EditBeneficialUserScreenState();
}

class _EditBeneficialUserScreenState
    extends ConsumerState<EditBeneficialUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRelationship = 'helper';
  File? _newPhoto;
  String? _existingPhotoUrl;
  bool _isUploading = false;
  bool _isLoading = true;
  BeneficialUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Load user data
  Future<void> _loadUser() async {
    final state = ref.read(beneficialUsersProvider);
    final user = state.users.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => throw Exception('User not found'),
    );

    setState(() {
      _user = user;
      _fullNameController.text = user.fullName;
      _contactNumberController.text = user.contactNumber;
      _emailController.text = user.email ?? '';
      _selectedRelationship = user.relationship;
      _existingPhotoUrl = user.idPhotoUrl;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Beneficial User'),
        ),
        body: const Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Beneficial User'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo capture with existing photo
            PhotoCaptureWidget(
              initialPhotoUrl: _existingPhotoUrl,
              onPhotoChanged: (photo) {
                setState(() {
                  _newPhoto = photo;
                });
              },
              label: 'ID Photo (Optional)',
            ),

            const SizedBox(height: 24),

            // Full name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required('Full name is required'),
            ),

            const SizedBox(height: 16),

            // Contact number
            TextFormField(
              controller: _contactNumberController,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                hintText: 'Enter contact number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.compose([
                Validators.required('Contact number is required'),
                Validators.phone(),
              ]),
            ),

            const SizedBox(height: 16),

            // Email (optional)
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                return Validators.email()(value);
              },
            ),

            const SizedBox(height: 16),

            // Relationship dropdown
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                prefixIcon: Icon(Icons.people),
              ),
              items: const [
                DropdownMenuItem(value: 'helper', child: Text('Helper')),
                DropdownMenuItem(value: 'family', child: Text('Family')),
                DropdownMenuItem(value: 'friend', child: Text('Friend')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                }
              },
              validator: Validators.required('Relationship is required'),
            ),

            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _newPhoto != null
                          ? 'A new photo will be uploaded and replace the existing one.'
                          : 'Upload a new photo to replace the existing one.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isUploading ? null : _handleSubmit,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final notifier = ref.read(beneficialUsersProvider.notifier);

    final success = await notifier.updateUser(
      userId: widget.userId,
      fullName: _fullNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      relationship: _selectedRelationship,
      newIdPhoto: _newPhoto,
      oldPhotoUrl: _existingPhotoUrl,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficial user updated successfully')),
      );
      context.pop();
    } else {
      final errorMessage = ref.read(beneficialUsersProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
