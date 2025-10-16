import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../models/household_member.dart';
import '../../providers/household_provider.dart';
import '../../utils/validators.dart';

/// Add household member form screen
/// Allows household head to add a new household member
class AddHouseholdMemberScreen extends ConsumerStatefulWidget {
  const AddHouseholdMemberScreen({super.key});

  @override
  ConsumerState<AddHouseholdMemberScreen> createState() =>
      _AddHouseholdMemberScreenState();
}

class _AddHouseholdMemberScreenState
    extends ConsumerState<AddHouseholdMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedRelationship = RelationshipType.child;
  DateTime? _selectedBirthDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Household Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required('Full name is required'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Relationship
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items: RelationshipType.all.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(
                    RelationshipType.displayNames[relationship] ?? relationship,
                  ),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedRelationship = value!;
                      });
                    },
              validator: Validators.required('Relationship is required'),
            ),
            const SizedBox(height: 16),

            // Contact Number
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Number (Optional)',
                hintText: 'e.g., 09171234567',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.phone()(value);
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                hintText: 'e.g., example@email.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.email()(value);
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Birth Date
            InkWell(
              onTap: _isSubmitting ? null : _selectBirthDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birth Date (Optional)',
                  prefixIcon: Icon(Icons.cake),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? _formatDate(_selectedBirthDate!)
                      : 'Select birth date',
                  style: TextStyle(
                    color: _selectedBirthDate != null
                        ? Colors.black87
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Member',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Select Birth Date',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'AddHouseholdMember');
      return;
    }

    final fullName = _nameController.text.trim();
    final contactNumber = _contactController.text.trim().isEmpty
        ? null
        : _contactController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();

    developer.log('Starting household member submission...', name: 'AddHouseholdMember');
    developer.log('Full Name: $fullName', name: 'AddHouseholdMember');
    developer.log('Relationship: $_selectedRelationship', name: 'AddHouseholdMember');
    developer.log('Contact Number: $contactNumber', name: 'AddHouseholdMember');
    developer.log('Email: $email', name: 'AddHouseholdMember');
    developer.log('Birth Date: $_selectedBirthDate', name: 'AddHouseholdMember');

    setState(() {
      _isSubmitting = true;
    });

    final result = await ref.read(householdMembersProvider.notifier).addMember(
          fullName: fullName,
          relationship: _selectedRelationship,
          contactNumber: contactNumber,
          email: email,
          birthDate: _selectedBirthDate,
        );

    if (!mounted) return;

    developer.log('Household member submission completed', name: 'AddHouseholdMember');
    developer.log('Success: ${result.success}', name: 'AddHouseholdMember');
    developer.log('Error: ${result.error}', name: 'AddHouseholdMember');

    setState(() {
      _isSubmitting = false;
    });

    if (result.success) {
      developer.log('Member added successfully: $fullName', name: 'AddHouseholdMember');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fullName added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      developer.log('ERROR adding member: ${result.error}', name: 'AddHouseholdMember');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to add member'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitForm,
          ),
        ),
      );
    }
  }
}
