import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../utils/validators.dart';

/// Edit guest schedule form with date/time updates
class EditGuestScreen extends ConsumerStatefulWidget {
  final String guestId;

  const EditGuestScreen({
    super.key,
    required this.guestId,
  });

  @override
  ConsumerState<EditGuestScreen> createState() => _EditGuestScreenState();
}

class _EditGuestScreenState extends ConsumerState<EditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _purposeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  String _selectedVisitType = 'day_trip';
  DateTime? _visitStart;
  DateTime? _visitEnd;
  bool _isSubmitting = false;
  bool _isLoading = true;
  Guest? _guest;

  @override
  void initState() {
    super.initState();
    _loadGuest();
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _contactNumberController.dispose();
    _purposeController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  /// Load guest data
  Future<void> _loadGuest() async {
    final state = ref.read(guestProvider);
    final guest = state.guests.firstWhere(
      (g) => g.id == widget.guestId,
      orElse: () => throw Exception('Guest not found'),
    );

    setState(() {
      _guest = guest;
      _guestNameController.text = guest.guestName;
      _contactNumberController.text = guest.contactNumber ?? '';
      _purposeController.text = guest.purpose ?? '';
      _vehiclePlateController.text = guest.vehiclePlate ?? '';
      _selectedVisitType = guest.visitType;
      _visitStart = guest.visitStart;
      _visitEnd = guest.visitEnd;
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

    if (_guest == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Guest'),
        ),
        body: const Center(
          child: Text('Guest not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Guest Schedule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Guest name
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(
                labelText: 'Guest Name',
                hintText: 'Enter guest full name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required('Guest name is required'),
            ),

            const SizedBox(height: 16),

            // Contact number (optional)
            TextFormField(
              controller: _contactNumberController,
              decoration: const InputDecoration(
                labelText: 'Contact Number (Optional)',
                hintText: 'Enter contact number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                return Validators.phone()(value);
              },
            ),

            const SizedBox(height: 16),

            // Visit type radio buttons
            const Text(
              'Visit Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'day_trip',
                    groupValue: _selectedVisitType,
                    onChanged: (value) {
                      setState(() {
                        _selectedVisitType = value!;
                      });
                    },
                    title: const Text('Day Trip'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'multi_day',
                    groupValue: _selectedVisitType,
                    onChanged: (value) {
                      setState(() {
                        _selectedVisitType = value!;
                      });
                    },
                    title: const Text('Multi-Day'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Visit start date/time
            InkWell(
              onTap: () => _selectStartDateTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Visit Start',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _visitStart != null
                      ? _formatDateTime(_visitStart!)
                      : 'Select start date and time',
                  style: TextStyle(
                    color: _visitStart != null ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Visit end date/time
            InkWell(
              onTap: () => _selectEndDateTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Visit End',
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(
                  _visitEnd != null
                      ? _formatDateTime(_visitEnd!)
                      : 'Select end date and time',
                  style: TextStyle(
                    color: _visitEnd != null ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Purpose
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose (Optional)',
                hintText: 'e.g., Family visit, Delivery, etc.',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Vehicle plate
            TextFormField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Plate (Optional)',
                hintText: 'Enter vehicle plate number',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
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

  /// Select start date and time
  Future<void> _selectStartDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _visitStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitStart ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _visitStart = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// Select end date and time
  Future<void> _selectEndDateTime(BuildContext context) async {
    final initialDate = _visitEnd ??
        (_visitStart?.add(const Duration(days: 1)) ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _visitStart ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitEnd ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _visitEnd = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute $period';
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_visitStart == null || _visitEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select visit start and end times'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final notifier = ref.read(guestProvider.notifier);

    final success = await notifier.updateGuestSchedule(
      guestId: widget.guestId,
      guestName: _guestNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim().isEmpty
          ? null
          : _contactNumberController.text.trim(),
      visitType: _selectedVisitType,
      visitStart: _visitStart,
      visitEnd: _visitEnd,
      purpose: _purposeController.text.trim().isEmpty
          ? null
          : _purposeController.text.trim(),
      vehiclePlate: _vehiclePlateController.text.trim().isEmpty
          ? null
          : _vehiclePlateController.text.trim().toUpperCase(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest schedule updated successfully')),
      );
      context.pop();
    } else {
      final errorMessage = ref.read(guestProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
