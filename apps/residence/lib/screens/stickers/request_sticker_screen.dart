import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../models/household_member.dart';
import '../../models/sticker_request.dart';
import '../../providers/household_provider.dart';
import '../../providers/sticker_provider.dart';
import '../../utils/validators.dart';

/// Request sticker form screen
/// Allows household head to request a vehicle sticker
class RequestStickerScreen extends ConsumerStatefulWidget {
  const RequestStickerScreen({super.key});

  @override
  ConsumerState<RequestStickerScreen> createState() =>
      _RequestStickerScreenState();
}

class _RequestStickerScreenState extends ConsumerState<RequestStickerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehiclePlateController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  String _ownerType = OwnerType.householdMember;
  String? _selectedOwnerId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _vehicleMakeController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final householdState = ref.watch(householdMembersProvider);
    final stickerState = ref.watch(stickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Vehicle Sticker'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Allocation status banner
            if (stickerState.allocation != null)
              _buildAllocationBanner(stickerState.allocation!),

            const SizedBox(height: 24),

            // Owner Type Selection
            Text(
              'Vehicle Owner',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'household_member',
                  label: Text('Household Member'),
                  icon: Icon(Icons.people),
                ),
                ButtonSegment(
                  value: 'beneficial_user',
                  label: Text('Beneficial User'),
                  icon: Icon(Icons.person_add),
                ),
              ],
              selected: {_ownerType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _ownerType = newSelection.first;
                  _selectedOwnerId = null; // Reset selection
                });
              },
            ),
            const SizedBox(height: 16),

            // Owner Selection Dropdown
            if (_ownerType == OwnerType.householdMember &&
                householdState.members.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedOwnerId,
                decoration: const InputDecoration(
                  labelText: 'Select Household Member',
                  prefixIcon: Icon(Icons.person),
                ),
                items: householdState.members.map((member) {
                  return DropdownMenuItem(
                    value: member.id,
                    child: Text(member.fullName),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedOwnerId = value;
                        });
                      },
                validator: Validators.required('Please select an owner'),
              ),

            if (_ownerType == OwnerType.beneficialUser)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add a beneficial user first before requesting a sticker for them.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            if (householdState.members.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add household members first before requesting stickers.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Vehicle Information Section
            Text(
              'Vehicle Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Vehicle Plate
            TextFormField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Plate Number',
                hintText: 'e.g., ABC1234',
                prefixIcon: Icon(Icons.confirmation_number),
                helperText: 'Plate number will be automatically capitalized',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.required('Vehicle plate is required'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Vehicle Make
            TextFormField(
              controller: _vehicleMakeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Make/Model (Optional)',
                hintText: 'e.g., Toyota Corolla',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Vehicle Color
            TextFormField(
              controller: _vehicleColorController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Color (Optional)',
                hintText: 'e.g., White',
                prefixIcon: Icon(Icons.palette),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ||
                      householdState.members.isEmpty ||
                      (stickerState.allocation?.isExceeded ?? false)
                  ? null
                  : _submitForm,
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
                      'Submit Request',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 16),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'What happens next?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Your request will be reviewed by the admin\n'
                    '2. You\'ll receive a notification once approved\n'
                    '3. Pick up your sticker at the admin office\n'
                    '4. Sign for the sticker upon collection',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationBanner(allocation) {
    final color = allocation.isExceeded
        ? Colors.red
        : allocation.isAlmostFull
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            allocation.isExceeded ? Icons.warning : Icons.check_circle,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sticker Allocation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${allocation.used} of ${allocation.total} used • ${allocation.available} available',
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed for sticker request', name: 'RequestSticker');
      return;
    }

    if (_selectedOwnerId == null) {
      developer.log('No owner selected for sticker request', name: 'RequestSticker');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an owner'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final vehiclePlate = _vehiclePlateController.text.trim();
    final vehicleMake = _vehicleMakeController.text.trim().isEmpty
        ? null
        : _vehicleMakeController.text.trim();
    final vehicleColor = _vehicleColorController.text.trim().isEmpty
        ? null
        : _vehicleColorController.text.trim();

    developer.log('Starting sticker request submission...', name: 'RequestSticker');
    developer.log('Owner Type: $_ownerType', name: 'RequestSticker');
    developer.log('Owner ID: $_selectedOwnerId', name: 'RequestSticker');
    developer.log('Vehicle Plate: $vehiclePlate', name: 'RequestSticker');
    developer.log('Vehicle Make: $vehicleMake', name: 'RequestSticker');
    developer.log('Vehicle Color: $vehicleColor', name: 'RequestSticker');

    setState(() {
      _isSubmitting = true;
    });

    final result = await ref.read(stickerProvider.notifier).requestSticker(
          ownerType: _ownerType,
          ownerId: _selectedOwnerId!,
          vehiclePlate: vehiclePlate,
          vehicleMake: vehicleMake,
          vehicleColor: vehicleColor,
        );

    if (!mounted) return;

    developer.log('Sticker request submission completed', name: 'RequestSticker');
    developer.log('Success: ${result.success}', name: 'RequestSticker');
    developer.log('Error: ${result.error}', name: 'RequestSticker');
    developer.log('Error Code: ${result.code}', name: 'RequestSticker');

    setState(() {
      _isSubmitting = false;
    });

    if (result.success) {
      developer.log('Sticker request submitted successfully for plate: $vehiclePlate', name: 'RequestSticker');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sticker request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      final isAllocationError = result.code == 'ALLOCATION_EXCEEDED';

      developer.log('ERROR submitting sticker request: ${result.error}', name: 'RequestSticker');
      developer.log('Is allocation error: $isAllocationError', name: 'RequestSticker');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isAllocationError ? Icons.warning : Icons.error,
                color: isAllocationError ? Colors.orange : Colors.red,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Request Failed')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.error ?? 'Failed to submit request'),
              if (isAllocationError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Contact the admin office to request additional sticker allocation.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!isAllocationError)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _submitForm();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
