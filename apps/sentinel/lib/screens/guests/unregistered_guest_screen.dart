import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guest.dart' hide TimeOfDay;
import '../../providers/guest_provider.dart';
import '../../services/household_contact_service.dart';
import '../../shared/theme/app_theme.dart';

/// Unregistered Guest Screen - Handle guests without prior registration
class UnregisteredGuestScreen extends ConsumerStatefulWidget {
  const UnregisteredGuestScreen({super.key});

  @override
  ConsumerState<UnregisteredGuestScreen> createState() => _UnregisteredGuestScreenState();
}

class _UnregisteredGuestScreenState extends ConsumerState<UnregisteredGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _purposeController = TextEditingController();
  final _vehicleInfoController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedHouseholdId = '';
  bool _isContactingHousehold = false;
  bool _isRegistering = false;
  ContactRecord? _lastContactRecord;
  Guest? _registeredGuest;

  // Mock household data
  final List<Map<String, String>> _mockHouseholds = [
    {'id': 'household-1', 'name': 'John Doe - Unit 101'},
    {'id': 'household-2', 'name': 'Jane Smith - Unit 102'},
    {'id': 'household-3', 'name': 'Bob Johnson - Unit 201'},
    {'id': 'household-4', 'name': 'Alice Brown - Unit 202'},
  ];

  List<Map<String, String>> _searchResults = [];

  @override
  void dispose() {
    _guestNameController.dispose();
    _phoneNumberController.dispose();
    _purposeController.dispose();
    _vehicleInfoController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unregistered Guest'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isRegistering ? null : _registerAndCheckIn,
            child: const Text(
              'Register & Check In',
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
              // Warning banner
              _buildWarningBanner(),
              const SizedBox(height: 24),

              // Guest Information Section
              _buildSectionHeader('Guest Information', Icons.person),
              const SizedBox(height: 16),
              _buildGuestNameField(),
              const SizedBox(height: 16),
              _buildPhoneNumberField(),
              const SizedBox(height: 16),
              _buildPurposeField(),
              const SizedBox(height: 16),
              _buildVehicleInfoField(),

              const SizedBox(height: 24),

              // Household Search Section
              _buildSectionHeader('Find Hosting Household', Icons.search),
              const SizedBox(height: 16),
              _buildHouseholdSearch(),
              const SizedBox(height: 16),
              if (_selectedHouseholdId.isNotEmpty) _buildSelectedHousehold(),

              const SizedBox(height: 24),

              // Contact Household Section
              if (_selectedHouseholdId.isNotEmpty) ...[
                _buildSectionHeader('Contact Household', Icons.phone),
                const SizedBox(height: 16),
                if (_lastContactRecord != null) _buildLastContactInfo(),
                _buildContactButtons(),
                const SizedBox(height: 24),
              ],

              // Notes Section
              _buildSectionHeader('Additional Notes', Icons.note),
              const SizedBox(height: 16),
              _buildNotesField(),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Unregistered Guest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This guest does not have a prior registration. Please verify their identity and contact the hosting household before proceeding.',
            style: TextStyle(
              color: Colors.orange[700],
            ),
          ),
        ],
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
        return null;
      },
      textInputAction: TextInputAction.next,
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
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildHouseholdSearch() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for Household',
            hintText: 'Enter household name or unit number...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults.clear();
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 12),
        if (_searchResults.isNotEmpty)
          _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final household = _searchResults[index];
          final isSelected = household['id'] == _selectedHouseholdId;

          return ListTile(
            title: Text(household['name']!),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            selected: isSelected,
            selectedTileColor: Colors.green.withOpacity(0.1),
            onTap: () => _selectHousehold(household),
          );
        },
      ),
    );
  }

  Widget _buildSelectedHousehold() {
    final selectedHousehold = _mockHouseholds.firstWhere(
      (h) => h['id'] == _selectedHouseholdId,
      orElse: () => {'id': '', 'name': ''},
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: ${selectedHousehold['name']}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedHouseholdId = '';
                _lastContactRecord = null;
              });
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildLastContactInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _lastContactRecord!.contactType == ContactType.call
                ? Icons.call
                : Icons.sms,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatContactType(_lastContactRecord!.contactType)} completed at ${_formatTime(_lastContactRecord!.timestamp)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isContactingHousehold ? null : _callHousehold,
            icon: const Icon(Icons.call, size: 16),
            label: Text(_isContactingHousehold ? 'Calling...' : 'Call Household'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isContactingHousehold ? null : _sendSMS,
            icon: const Icon(Icons.sms, size: 16),
            label: Text(_isContactingHousehold ? 'Sending...' : 'Send SMS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Any special instructions or observations...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_isRegistering || _selectedHouseholdId.isEmpty) ? null : _registerAndCheckIn,
            icon: _isRegistering
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.person_add),
            label: Text(_isRegistering ? 'Registering...' : 'Register & Check In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final results = _mockHouseholds.where((household) =>
        household['name']!.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _selectHousehold(Map<String, String> household) {
    setState(() {
      _selectedHouseholdId = household['id']!;
      _searchResults.clear();
      _searchController.clear();
    });
  }

  Future<void> _callHousehold() async {
    setState(() {
      _isContactingHousehold = true;
    });

    try {
      // Mock contact service call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isContactingHousehold = false;
        _lastContactRecord = ContactRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          householdId: _selectedHouseholdId,
          contactType: ContactType.call,
          contactPerson: 'Household Head',
          contactInfo: '+1234567890',
          timestamp: DateTime.now(),
          guestName: _guestNameController.text.trim(),
          initiatedBy: 'guard-1',
          success: true,
          message: 'Call completed successfully',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call placed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isContactingHousehold = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendSMS() async {
    setState(() {
      _isContactingHousehold = true;
    });

    try {
      // Mock SMS service call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isContactingHousehold = false;
        _lastContactRecord = ContactRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          householdId: _selectedHouseholdId,
          contactType: ContactType.sms,
          contactPerson: 'Household Head',
          contactInfo: '+1234567890',
          timestamp: DateTime.now(),
          guestName: _guestNameController.text.trim(),
          initiatedBy: 'guard-1',
          success: true,
          message: 'SMS sent successfully',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isContactingHousehold = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerAndCheckIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      // Register the guest
      final guest = await ref.read(guestProvider.notifier).registerGuest(
        guestName: _guestNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        purpose: _purposeController.text.trim(),
        scheduledDate: DateTime.now(),
        expectedArrival: _formatTimeOfDay(TimeOfDay.now()),
        expectedDeparture: _formatTimeOfDay(TimeOfDay(
          hour: TimeOfDay.now().hour + 2,
          minute: TimeOfDay.now().minute,
        )),
        householdId: _selectedHouseholdId,
        vehicleInfo: _vehicleInfoController.text.trim().isEmpty
            ? null
            : _vehicleInfoController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Check in the guest immediately
      await ref.read(guestProvider.notifier).checkInGuest(guest.id);

      setState(() {
        _registeredGuest = guest;
        _isRegistering = false;
      });

      if (mounted) {
        _showSuccessDialog(guest);
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });

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

  void _showSuccessDialog(Guest guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Registered & Checked In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ ${guest.guestName} has been successfully registered and checked in.'),
            const SizedBox(height: 12),
            Text('Phone: ${guest.phoneNumber}'),
            Text('Purpose: ${guest.purpose}'),
            if (guest.vehicleInfo != null) Text('Vehicle: ${guest.vehicleInfo}'),
            if (_lastContactRecord != null) ...[
              const SizedBox(height: 12),
              Text('Household contacted: ${_formatContactType(_lastContactRecord!.contactType)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatContactType(ContactType type) {
    switch (type) {
      case ContactType.call:
        return 'Call';
      case ContactType.sms:
        return 'SMS';
      case ContactType.approval:
        return 'Approval';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}