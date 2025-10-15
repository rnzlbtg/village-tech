import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/beneficial_user.dart';
import '../../providers/beneficial_user_provider.dart';
import '../../widgets/beneficial_users/photo_capture_widget.dart';
import '../../utils/validators.dart';

/// Add beneficial user form with photo capture
class AddBeneficialUserScreen extends ConsumerStatefulWidget {
  const AddBeneficialUserScreen({super.key});

  @override
  ConsumerState<AddBeneficialUserScreen> createState() =>
      _AddBeneficialUserScreenState();
}

class _AddBeneficialUserScreenState
    extends ConsumerState<AddBeneficialUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRelationship = BeneficialUserRelationship.helper;
  File? _selectedPhoto;
  bool _isUploading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Beneficial User'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo capture
            PhotoCaptureWidget(
              onPhotoChanged: (photo) {
                setState(() {
                  _selectedPhoto = photo;
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
              items: BeneficialUserRelationship.all.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(
                    BeneficialUserRelationship.displayNames[relationship]!,
                  ),
                );
              }).toList(),
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
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Beneficial users are non-residents with vehicle access privileges.',
                      style: TextStyle(fontSize: 13),
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
                  : const Text('Add Beneficial User'),
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

    final success = await notifier.addUser(
      fullName: _fullNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      relationship: _selectedRelationship,
      idPhoto: _selectedPhoto,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficial user added successfully')),
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
