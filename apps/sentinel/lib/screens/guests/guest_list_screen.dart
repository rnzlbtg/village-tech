import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../widgets/shared/error_display.dart';
import '../../widgets/forms/guest_card.dart';
import '../dashboard/dashboard_screen.dart';

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
    _searchController.addListener(_onSearchChanged);
    // Load today's guests on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
              ref.read(guestProvider.notifier).refreshGuests();
            },
            tooltip: 'Refresh',
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
            _buildStatusChip(GuestStatus.pending, 'Pending'),
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

    if (filteredGuests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(guestProvider.notifier).refreshGuests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredGuests.length,
        itemBuilder: (context, index) {
          final guest = filteredGuests[index];
          return GuestCard(
            guest: guest,
            onTap: () {
              _showGuestDetails(guest);
            },
            onCheckIn: guest.isPending ? () => _checkInGuest(guest) : null,
            onCheckOut: guest.isCheckedIn ? () => _checkOutGuest(guest) : null,
            onCancel: guest.isPending ? () => _cancelGuest(guest) : null,
          );
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

    // Sort by scheduled date and time
    filtered.sort((a, b) {
      final dateComparison = a.scheduledDate.compareTo(b.scheduledDate);
      if (dateComparison != 0) return dateComparison;

      return a.expectedArrivalTime.hour.compareTo(b.expectedArrivalTime.hour);
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildGuestDetailsSheet(guest),
    );
  }

  Widget _buildGuestDetailsSheet(Guest guest) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Guest info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.guestName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          guest.statusDisplayText,
                          style: TextStyle(
                            color: _getStatusColor(guest.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('Phone', guest.phoneNumber, Icons.phone),
                    _buildDetailRow('Purpose', guest.purpose, Icons.info),
                    _buildDetailRow('Scheduled Date',
                        _formatDate(guest.scheduledDate), Icons.calendar_today),
                    _buildDetailRow('Expected Arrival',
                        guest.expectedArrival, Icons.access_time),
                    _buildDetailRow('Expected Departure',
                        guest.expectedDeparture, Icons.access_time),
                    if (guest.vehicleInfo != null)
                      _buildDetailRow('Vehicle', guest.vehicleInfo!, Icons.directions_car),
                    if (guest.notes != null)
                      _buildDetailRow('Notes', guest.notes!, Icons.note),
                    if (guest.actualArrival != null)
                      _buildDetailRow('Actual Arrival',
                          _formatDateTime(guest.actualArrival!), Icons.login),
                    if (guest.actualDeparture != null)
                      _buildDetailRow('Actual Departure',
                          _formatDateTime(guest.actualDeparture!), Icons.logout),
                  ],
                ),
              ),

              // Action buttons
              _buildActionButtons(guest),
            ],
          ),
        );
      },
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

  Widget _buildActionButtons(Guest guest) {
    return Column(
      children: [
        if (guest.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _checkInGuest(guest),
              icon: const Icon(Icons.login),
              label: const Text('Check In Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (guest.isCheckedIn) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _checkOutGuest(guest),
              icon: const Icon(Icons.logout),
              label: const Text('Check Out Guest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (guest.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelGuest(guest),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Registration'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],

        // Close button
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ),
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
      case GuestStatus.pending:
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
}