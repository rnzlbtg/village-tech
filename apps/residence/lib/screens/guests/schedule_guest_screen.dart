import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../utils/validators.dart';

/// Schedule guest form with date/time pickers, visit type, purpose, vehicle plate
class ScheduleGuestScreen extends ConsumerStatefulWidget {
  const ScheduleGuestScreen({super.key});

  @override
  ConsumerState<ScheduleGuestScreen> createState() =>
      _ScheduleGuestScreenState();
}

class _ScheduleGuestScreenState extends ConsumerState<ScheduleGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _purposeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  String _selectedVisitType = GuestVisitType.dayTrip;
  DateTime? _visitStart;
  DateTime? _visitEnd;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _guestNameController.dispose();
    _contactNumberController.dispose();
    _purposeController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Guest'),
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
                    value: GuestVisitType.dayTrip,
                    groupValue: _selectedVisitType,
                    onChanged: (value) {
                      setState(() {
                        _selectedVisitType = value!;
                        // Auto-set end time to same day
                        if (_visitStart != null) {
                          _visitEnd = DateTime(
                            _visitStart!.year,
                            _visitStart!.month,
                            _visitStart!.day,
                            23,
                            59,
                          );
                        }
                      });
                    },
                    title: const Text('Day Trip'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: GuestVisitType.multiDay,
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
                  errorStyle: TextStyle(fontSize: 12),
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
                  errorStyle: TextStyle(fontSize: 12),
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
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedVisitType == GuestVisitType.dayTrip
                          ? 'Day trips end on the same day at 11:59 PM'
                          : 'Multi-day visits can last up to 30 days',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
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
                  : const Text('Schedule Guest'),
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

          // Auto-set end time for day trips
          if (_selectedVisitType == GuestVisitType.dayTrip) {
            _visitEnd = DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
            );
          }
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

    final success = await notifier.scheduleGuest(
      guestName: _guestNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim().isEmpty
          ? null
          : _contactNumberController.text.trim(),
      visitType: _selectedVisitType,
      visitStart: _visitStart!,
      visitEnd: _visitEnd!,
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
        const SnackBar(content: Text('Guest scheduled successfully')),
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
