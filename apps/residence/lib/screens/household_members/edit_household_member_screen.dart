import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/household_member.dart';
import '../../providers/household_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/shared/loading_widget.dart';

/// Edit household member form screen
/// Allows household head to update household member details
class EditHouseholdMemberScreen extends ConsumerStatefulWidget {
  final String memberId;

  const EditHouseholdMemberScreen({
    super.key,
    required this.memberId,
  });

  @override
  ConsumerState<EditHouseholdMemberScreen> createState() =>
      _EditHouseholdMemberScreenState();
}

class _EditHouseholdMemberScreenState
    extends ConsumerState<EditHouseholdMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRelationship;
  DateTime? _selectedBirthDate;
  bool _isSubmitting = false;
  HouseholdMember? _member;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  void _loadMember() {
    final state = ref.read(householdMembersProvider);
    _member = state.members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => throw Exception('Member not found'),
    );

    _nameController.text = _member!.fullName;
    _contactController.text = _member!.contactNumber ?? '';
    _emailController.text = _member!.email ?? '';
    _selectedRelationship = _member!.relationship;
    _selectedBirthDate = _member!.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_member == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading member details...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Household Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Member info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(_member!.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editing Member',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _member!.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                      'Save Changes',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'N/A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await ref.read(householdMembersProvider.notifier).updateMember(
          memberId: widget.memberId,
          fullName: _nameController.text.trim(),
          relationship: _selectedRelationship,
          contactNumber: _contactController.text.trim().isEmpty
              ? null
              : _contactController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          birthDate: _selectedBirthDate,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update member'),
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
