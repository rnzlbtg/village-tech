import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../widgets/shared/error_display.dart';
import '../../widgets/forms/guest_card.dart';
import '../dashboard/dashboard_screen.dart';
import '../../services/supabase_guest_service.dart';

/// Guest List Screen - Displays today's guests with search and filtering
class GuestListScreen extends ConsumerStatefulWidget {
  const GuestListScreen({super.key});

  @override
  ConsumerState<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends ConsumerState<GuestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  GuestStatus? _statusFilter;
  bool _showOnlyToday = true;

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: GuestListScreen - initState() called');
    _searchController.addListener(_onSearchChanged);
    // Load today's guests on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: GuestListScreen - Calling loadTodayGuests()');
      ref.read(guestProvider.notifier).loadTodayGuests();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestState = ref.watch(guestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/guests/register');
            },
            tooltip: 'Register New Guest',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔍 DEBUG: GuestListScreen - Refresh button pressed');
              ref.read(guestProvider.notifier).refreshGuests();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              _debugAccess();
            },
            tooltip: 'Debug Access',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildStatusTabs(),
          Expanded(
            child: _buildGuestList(guestState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/guests/register');
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Register Guest'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by guest name, phone, or household...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Today Only'),
                  selected: _showOnlyToday,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyToday = selected;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<GuestStatus?>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter by Status',
                onSelected: (status) {
                  setState(() {
                    _statusFilter = status;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...GuestStatus.values.map(
                    (status) => PopupMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _buildStatusChip(null, 'All'),
            const SizedBox(width: 8),
            _buildStatusChip(GuestStatus.expected, 'Expected'),
            const SizedBox(width: 8),
            _buildStatusChip(GuestStatus.checkedIn, 'Checked In'),
            const SizedBox(width: 8),
            _buildStatusChip(GuestStatus.checkedOut, 'Checked Out'),
            const SizedBox(width: 8),
            _buildStatusChip(GuestStatus.cancelled, 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(GuestStatus? status, String label) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildGuestList(GuestState guestState) {
    print('🔍 DEBUG: GuestListScreen - _buildGuestList called');
    print('   Is loading: ${guestState.isLoading}');
    print('   Has error: ${guestState.error != null}');
    print('   Total guests: ${guestState.guests.length}');
    print('   Last updated: ${guestState.lastUpdated}');

    if (guestState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading guests...'),
          ],
        ),
      );
    }

    if (guestState.error != null) {
      print('🔍 DEBUG: GuestListScreen - Error state: ${guestState.error}');
      return Center(
        child: ErrorDisplay(
          error: guestState.error!,
          onRetry: () {
            ref.read(guestProvider.notifier).refreshGuests();
          },
        ),
      );
    }

    final filteredGuests = _filterGuests(guestState.guests);
    print('🔍 DEBUG: GuestListScreen - Filtered guests: ${filteredGuests.length}');

    if (filteredGuests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(guestProvider.notifier).refreshGuests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        itemCount: filteredGuests.length,
        itemBuilder: (context, index) {
          final guest = filteredGuests[index];
          return _buildCompactGuestCard(guest);
        },
      ),
    );
  }

  List<Guest> _filterGuests(List<Guest> guests) {
    var filtered = guests;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((guest) =>
          guest.guestName.toLowerCase().contains(_searchQuery) ||
          guest.phoneNumber.toLowerCase().contains(_searchQuery) ||
          guest.purpose.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    // Filter by status
    if (_statusFilter != null) {
      filtered = filtered.where((guest) => guest.status == _statusFilter).toList();
    }

    // Filter by today only
    if (_showOnlyToday) {
      filtered = filtered.where((guest) => guest.isForToday).toList();
    }

    // Sort by scheduled date
    filtered.sort((a, b) {
      return a.scheduledDate.compareTo(b.scheduledDate);
    });

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No guests found' : 'No guests for today',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Register a new guest to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/guests/register');
              },
              icon: const Icon(Icons.add),
              label: const Text('Register Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showGuestDetails(Guest guest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCompactGuestDetailsSheet(guest),
    );
  }

  Widget _buildCompactGuestDetailsSheet(Guest guest) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Guest info header
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _getStatusColor(guest.status).withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 25,
                      color: _getStatusColor(guest.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.guestName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(guest.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            guest.statusDisplayText,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(guest.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Details section
              _buildDetailRow('Phone', guest.phoneNumber, Icons.phone),
              _buildDetailRow('Purpose', guest.purpose, Icons.info),
              _buildDetailRow('Scheduled Date', _formatDate(guest.scheduledDate), Icons.calendar_today),
              if (guest.vehicleInfo != null)
                _buildDetailRow('Vehicle', guest.vehicleInfo!, Icons.directions_car),
              if (guest.notes != null)
                _buildDetailRow('Notes', guest.notes!, Icons.note),
              if (guest.actualArrival != null)
                _buildDetailRow('Actual Arrival', _formatDateTime(guest.actualArrival!), Icons.login),
              if (guest.actualDeparture != null)
                _buildDetailRow('Actual Departure', _formatDateTime(guest.actualDeparture!), Icons.logout),

              const SizedBox(height: 16),

              // Action buttons
              _buildCompactActionButtons(guest),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButtons(Guest guest) {
    return Column(
      children: [
        if (guest.isExpected) ...[
          // Check In button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _checkInGuest(guest),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Check In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _cancelGuest(guest),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        if (guest.isCheckedIn) ...[
          // Check Out button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _checkOutGuest(guest),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Check Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        if (guest.isCheckedOut || guest.isCancelled) ...[
          // Close button for completed guests
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _checkInGuest(Guest guest) async {
    try {
      await ref.read(guestProvider.notifier).checkInGuest(guest.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${guest.guestName} checked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check in guest: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkOutGuest(Guest guest) async {
    try {
      await ref.read(guestProvider.notifier).checkOutGuest(guest.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${guest.guestName} checked out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check out guest: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelGuest(Guest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Guest Registration'),
        content: Text('Are you sure you want to cancel the registration for ${guest.guestName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(guestProvider.notifier).cancelGuest(guest.id);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${guest.guestName} registration cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel registration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(GuestStatus status) {
    switch (status) {
      case GuestStatus.expected:
        return Colors.orange;
      case GuestStatus.checkedIn:
        return Colors.green;
      case GuestStatus.checkedOut:
        return Colors.blue;
      case GuestStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Debug user access and show detailed information
  Future<void> _debugAccess() async {
    try {
      final guestService = ref.read(supabaseGuestServiceProvider);
      final debugInfo = await guestService.debugUserAccess();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Debug User Access'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (debugInfo.containsKey('error')) ...[
                    Text('Error: ${debugInfo['error']}',
                         style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                  ],
                  if (debugInfo.containsKey('userId')) ...[
                    Text('User ID: ${debugInfo['userId']}'),
                    Text('Email: ${debugInfo['email']}'),
                    Text('Tenant ID: ${debugInfo['tenantId']}'),
                    const SizedBox(height: 16),
                  ],
                  if (debugInfo.containsKey('directTableAccess')) ...[
                    const Text('Direct Table Access:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Success: ${debugInfo['directTableAccess']['success']}'),
                    Text('Count: ${debugInfo['directTableAccess']['count']}'),
                    if (debugInfo['directTableAccess']['error'] != null)
                      Text('Error: ${debugInfo['directTableAccess']['error']}',
                           style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    if (debugInfo['directTableAccess']['data'].isNotEmpty)
                      for (var item in debugInfo['directTableAccess']['data'])
                        Text('  - ${item['guest_name']} (tenant: ${item['tenant_id']})'),
                    const SizedBox(height: 16),
                  ],
                  if (debugInfo.containsKey('viewAccess')) ...[
                    const Text('View Access:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Success: ${debugInfo['viewAccess']['success']}'),
                    Text('Count: ${debugInfo['viewAccess']['count']}'),
                    if (debugInfo['viewAccess']['error'] != null)
                      Text('Error: ${debugInfo['viewAccess']['error']}',
                           style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    if (debugInfo['viewAccess']['data'].isNotEmpty)
                      for (var item in debugInfo['viewAccess']['data'])
                        Text('  - ${item['guest_name']} (tenant: ${item['tenant_id']})'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build compact guest card widget
  Widget _buildCompactGuestCard(Guest guest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _showGuestDetails(guest),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main guest info row
              Row(
                children: [
                  // Guest avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(guest.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: _getStatusColor(guest.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Guest name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.guestName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(guest.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                guest.statusDisplayText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getStatusColor(guest.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(guest.scheduledDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Quick action button
                  _buildQuickActionButton(guest),
                ],
              ),
              // Purpose and phone info
              if (guest.purpose.isNotEmpty || guest.phoneNumber.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (guest.purpose.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                guest.purpose,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (guest.phoneNumber.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guest.phoneNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build quick action button for guest card
  Widget _buildQuickActionButton(Guest guest) {
    if (guest.isExpected) {
      return InkWell(
        onTap: () => _checkInGuest(guest),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(width: 4),
              Text(
                'Check In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (guest.isCheckedIn) {
      return InkWell(
        onTap: () => _checkOutGuest(guest),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(width: 4),
              Text(
                'Check Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          guest.statusDisplayText,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}