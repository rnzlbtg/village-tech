import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart' hide TimeOfDay;
import '../../providers/guest_provider.dart';
import '../../shared/theme/app_theme.dart';

/// Guest Registration Screen - Form for registering new guests
class GuestRegistrationScreen extends ConsumerStatefulWidget {
  const GuestRegistrationScreen({super.key});

  @override
  ConsumerState<GuestRegistrationScreen> createState() => _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends ConsumerState<GuestRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _purposeController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduledDate = DateTime.now();
  String _selectedHouseholdId = '';
  TimeOfDay _expectedArrival = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _expectedDeparture = const TimeOfDay(hour: 12, minute: 0);
  bool _includeVehicleInfo = false;

  // Mock household data - will be replaced with actual household service
  final List<Map<String, String>> _mockHouseholds = [
    {'id': 'household-1', 'name': 'John Doe - Unit 101'},
    {'id': 'household-2', 'name': 'Jane Smith - Unit 102'},
    {'id': 'household-3', 'name': 'Bob Johnson - Unit 201'},
    {'id': 'household-4', 'name': 'Alice Brown - Unit 202'},
  ];

  @override
  void dispose() {
    _guestNameController.dispose();
    _phoneNumberController.dispose();
    _purposeController.dispose();
    _vehicleInfoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Guest'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text(
              'Register',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest Information Section
              _buildSectionHeader('Guest Information', Icons.person),
              const SizedBox(height: 16),
              _buildGuestNameField(),
              const SizedBox(height: 16),
              _buildPhoneNumberField(),
              const SizedBox(height: 16),
              _buildPurposeField(),

              const SizedBox(height: 24),

              // Visit Details Section
              _buildSectionHeader('Visit Details', Icons.calendar_today),
              const SizedBox(height: 16),
              _buildHouseholdSelector(),
              const SizedBox(height: 16),
              _buildScheduledDateSelector(),
              const SizedBox(height: 16),
              _buildTimeSelectors(),

              const SizedBox(height: 24),

              // Optional Information Section
              _buildSectionHeader('Optional Information', Icons.info_outline),
              const SizedBox(height: 16),
              _buildVehicleInfoToggle(),
              if (_includeVehicleInfo) ...[
                const SizedBox(height: 16),
                _buildVehicleInfoField(),
              ],
              const SizedBox(height: 16),
              _buildNotesField(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: guestState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: guestState.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Registering...'),
                          ],
                        )
                      : const Text(
                          'Register Guest',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestNameField() {
    return TextFormField(
      controller: _guestNameController,
      decoration: InputDecoration(
        labelText: 'Guest Name *',
        hintText: 'Enter guest\'s full name',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Guest name is required';
        }
        if (value.trim().length < 2) {
          return 'Guest name must be at least 2 characters';
        }
        if (value.trim().length > 100) {
          return 'Guest name must be less than 100 characters';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phoneNumberController,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: 'Enter guest\'s phone number',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }
        if (!RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPurposeField() {
    return TextFormField(
      controller: _purposeController,
      decoration: InputDecoration(
        labelText: 'Purpose of Visit *',
        hintText: 'e.g., Family visit, Delivery, Maintenance',
        prefixIcon: const Icon(Icons.info),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Purpose of visit is required';
        }
        if (value.trim().length < 3) {
          return 'Purpose must be at least 3 characters';
        }
        if (value.trim().length > 200) {
          return 'Purpose must be less than 200 characters';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildHouseholdSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedHouseholdId.isEmpty ? null : _selectedHouseholdId,
      decoration: InputDecoration(
        labelText: 'Hosting Household *',
        hintText: 'Select household',
        prefixIcon: const Icon(Icons.home),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _mockHouseholds.map((household) {
        return DropdownMenuItem<String>(
          value: household['id'],
          child: Text(household['name']!),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a hosting household';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedHouseholdId = value ?? '';
        });
      },
    );
  }

  Widget _buildScheduledDateSelector() {
    return InkWell(
      onTap: _selectScheduledDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheduled Date *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_scheduledDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectArrivalTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Arrival *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_expectedArrival),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _selectDepartureTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Departure *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_expectedDeparture),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoToggle() {
    return SwitchListTile(
      title: const Text('Include Vehicle Information'),
      subtitle: const Text('Add vehicle details for the guest'),
      value: _includeVehicleInfo,
      onChanged: (value) {
        setState(() {
          _includeVehicleInfo = value;
          if (!value) {
            _vehicleInfoController.clear();
          }
        });
      },
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildVehicleInfoField() {
    return TextFormField(
      controller: _vehicleInfoController,
      decoration: InputDecoration(
        labelText: 'Vehicle Information',
        hintText: 'e.g., Toyota Camry - ABC 1234',
        prefixIcon: const Icon(Icons.directions_car),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (_includeVehicleInfo && (value != null && value.isNotEmpty)) {
          if (value!.length > 200) {
            return 'Vehicle information must be less than 200 characters';
          }
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Special Notes',
        hintText: 'Any special instructions or notes',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 3,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value.length > 500) {
            return 'Notes must be less than 500 characters';
          }
        }
        return null;
      },
      textInputAction: TextInputAction.done,
    );
  }

  Future<void> _selectScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectArrivalTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _expectedArrival,
    );

    if (time != null) {
      setState(() {
        _expectedArrival = time;
        // Ensure departure time is after arrival time
        if (_expectedDeparture.hour < _expectedArrival.hour ||
            (_expectedDeparture.hour == _expectedArrival.hour && _expectedDeparture.minute <= _expectedArrival.minute)) {
          _expectedDeparture = TimeOfDay(
            hour: (_expectedArrival.hour + 2) % 24,
            minute: _expectedArrival.minute,
          );
        }
      });
    }
  }

  Future<void> _selectDepartureTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _expectedDeparture,
    );

    if (time != null) {
      setState(() {
        _expectedDeparture = time;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHouseholdId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hosting household'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(guestProvider.notifier).registerGuest(
        guestName: _guestNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        purpose: _purposeController.text.trim(),
        scheduledDate: _scheduledDate,
        expectedArrival: _formatTime(_expectedArrival),
        expectedDeparture: _formatTime(_expectedDeparture),
        householdId: _selectedHouseholdId,
        vehicleInfo: _includeVehicleInfo ? _vehicleInfoController.text.trim() : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guest registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register guest: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}