import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/theme/app_theme.dart';
import '../../widgets/shared/loading_indicator.dart';
import '../../widgets/shared/error_display.dart';
import '../../services/manual_verification_service.dart';
import '../../widgets/forms/resident_info_card.dart';
import '../../widgets/forms/entry_decision_dialog.dart';
import '../../models/rfid_sticker.dart';
import '../../models/entry_log.dart';
import '../../core/providers/service_providers.dart';

/// Manual verification screen provider
final manualVerificationServiceProvider = Provider<ManualVerificationService>((ref) {
  return ManualVerificationService(
    supabaseService: ref.watch(supabaseServiceProvider),
    cacheService: ref.watch(cacheServiceProvider),
    entryService: ref.watch(entryServiceProvider),
  );
});

/// Manual verification screen
class ManualVerificationScreen extends ConsumerStatefulWidget {
  const ManualVerificationScreen({super.key});

  @override
  ConsumerState<ManualVerificationScreen> createState() => _ManualVerificationScreenState();
}

class _ManualVerificationScreenState extends ConsumerState<ManualVerificationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _destinationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<ManualSearchResult> _searchResults = [];
  ManualSearchResult? _selectedResident;
  String _selectedSearchType = 'name'; // 'name', 'phone', 'address', 'rfid'

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _destinationController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _searchResidents(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    if (!ref.read(manualVerificationServiceProvider).validateSearchQuery(query)) {
      setState(() {
        _error = 'Invalid search query. Please enter 2-100 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _selectedResident = null;
    });

    try {
      List<ManualSearchResult> results = [];

      switch (_selectedSearchType) {
        case 'name':
        case 'address':
          results = await ref.read(manualVerificationServiceProvider).searchResidents(query: query);
          break;
        case 'phone':
          results = await ref.read(manualVerificationServiceProvider).searchByPhone(query);
          break;
        case 'rfid':
          final resident = await ref.read(manualVerificationServiceProvider).getResidentByRfidCode(query);
          if (resident != null) {
            results = [resident];
          }
          break;
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectResident(ManualSearchResult resident) {
    HapticFeedback.lightImpact();

    // Populate destination with resident's address
    if (_destinationController.text.trim().isEmpty) {
      _destinationController.text = resident.address;
    }

    setState(() {
      _selectedResident = resident;
    });
  }

  Future<void> _verifyEntry() async {
    if (_selectedResident == null) {
      _showError('Please select a resident to verify');
      return;
    }

    if (_destinationController.text.trim().isEmpty) {
      _showError('Please enter the destination');
      return;
    }

    // Show verification dialog
    _showVerificationDialog();
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EntryDecisionDialog(
        sticker: RfidSticker(
          id: 'manual',
          tenantId: '',
          stickerCode: 'Manual',
          residentId: _selectedResident!.residentId ?? '',
          status: RfidStatus.active,
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 365)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        destination: _destinationController.text.trim(),
        purpose: _purposeController.text.trim().isEmpty ? null : _purposeController.text.trim(),
        onDecision: (allowed, {notes, reason}) async {
          Navigator.of(context).pop();

          if (allowed) {
            await _processAllowedEntry(notes);
          } else {
            await _processDeniedEntry(reason, notes);
          }
        },
      ),
    );
  }

  Future<void> _processAllowedEntry(String? notes) async {
    setState(() => _isLoading = true);

    try {
      final result = await ref.read(manualVerificationServiceProvider).verifyResident(
        resident: _selectedResident!,
        destination: _destinationController.text.trim(),
        purpose: _purposeController.text.trim().isEmpty ? null : _purposeController.text.trim(),
        verificationMethod: 'manual',
        notes: notes,
      );

      if (result.success) {
        _showSuccess('Entry verified and logged successfully');
        Navigator.of(context).pop(result.entryLog);
      } else {
        _showError(result.error ?? 'Failed to verify entry');
      }
    } catch (e) {
      _showError('Error processing entry: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processDeniedEntry(String? reason, String? notes) async {
    // Handle denied entry - could log as denied or just navigate back
    _showSuccess('Entry denied: ${reason ?? 'Manual denial'}');
    Navigator.of(context).pop();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetSearch() {
    setState(() {
      _selectedResident = null;
      _searchResults.clear();
      _error = null;
    });
    _searchController.clear();
    _destinationController.clear();
    _purposeController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Manual Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // TODO: Show verification history
              _showVerificationHistory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Search section
              _buildSearchSection(),

              const SizedBox(height: 16),

              // Selected resident info
              if (_selectedResident != null) ...[
                _buildSelectedResidentSection(),
                const SizedBox(height: 16),
              ],

              // Destination and purpose
              _buildDestinationSection(),

              const SizedBox(height: 16),

              // Results section
              Expanded(
                child: _buildResultsSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Resident',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Search type selector
        _buildSearchTypeSelector(),

        const SizedBox(height: 12),

        Form(
          key: _formKey,
          child: TextFormField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter search criteria...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: _resetSearch)
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (value) {
              if (value.trim().length >= 2) {
                _searchResidents(value);
              } else {
                setState(() {
                  _searchResults.clear();
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Search by ${_getSearchTypeDescription(_selectedSearchType)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSearchTypeChip('name', 'Name'),
          _buildSearchTypeChip('address', 'Address'),
          _buildSearchTypeChip('phone', 'Phone'),
          _buildSearchTypeChip('rfid', 'RFID'),
        ],
      ),
    );
  }

  Widget _buildSearchTypeChip(String type, String label) {
    final isSelected = _selectedSearchType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSearchType = type;
            _searchResults.clear();
            _selectedResident = null;
            if (_searchController.text.isNotEmpty) {
              _searchResidents(_searchController.text);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _getSearchTypeDescription(String type) {
    switch (type) {
      case 'name':
        return 'resident name';
      case 'address':
        return 'unit address';
      case 'phone':
        return 'phone number';
      case 'rfid':
        return 'RFID code';
      default:
        return 'name or address';
    }
  }

  Widget _buildSelectedResidentSection() {
    if (_selectedResident == null) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: ResidentInfoCard(
        sticker: RfidSticker(
          id: _selectedResident!.id,
          tenantId: '',
          stickerCode: _selectedResident!.rfidCode ?? 'Manual',
          residentId: _selectedResident!.residentId ?? '',
          status: RfidStatus.active,
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 365)),
          vehicleInfo: _selectedResident!.vehicleInfo,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        showActions: false,
      ),
    );
  }

  Widget _buildDestinationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entry Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Destination field
        TextFormField(
          controller: _destinationController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Destination',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: 'Unit address or location',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.location_on, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Purpose field
        TextFormField(
          controller: _purposeController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Purpose (Optional)',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: 'Visit purpose or reason',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.label, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),

        // Verify button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _isLoading
                ? const ButtonLoadingIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Verify Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return ErrorDisplay(
        error: _error!,
        iconColor: Colors.white,
        onRetry: () => _searchResidents(_searchController.text),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.trim().length >= 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No residents found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different search terms or check spelling',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter search criteria',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search by name, address, phone, or RFID',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final resident = _searchResults[index];
        final isSelected = _selectedResident?.id == resident.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 8 : 2,
          color: isSelected ? AppTheme.successColor.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: AppTheme.successColor, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _selectResident(resident),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resident.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resident.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (resident.vehicleInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resident.vehicleInfo!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last entry: ${_formatDateTime(resident.lastEntry)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      if (resident.rfidCode != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.credit_card,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'RFID: ${resident.rfidCode}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showVerificationHistory() {
    // TODO: Implement verification history dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification history coming soon')),
    );
  }
}