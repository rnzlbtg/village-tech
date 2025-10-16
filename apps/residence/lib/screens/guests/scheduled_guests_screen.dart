import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/guests/guest_card.dart';

/// Scheduled guests list screen with upcoming/active/past tabs
class ScheduledGuestsScreen extends ConsumerStatefulWidget {
  const ScheduledGuestsScreen({super.key});

  @override
  ConsumerState<ScheduledGuestsScreen> createState() =>
      _ScheduledGuestsScreenState();
}

class _ScheduledGuestsScreenState
    extends ConsumerState<ScheduledGuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestProvider);
    final notifier = ref.read(guestProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Guests'),
        actions: [
          if (state.isOffline)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_off, size: 20),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Upcoming (${state.upcomingCount})',
              icon: const Icon(Icons.schedule, size: 18),
            ),
            Tab(
              text: 'Active (${state.activeCount})',
              icon: const Icon(Icons.check_circle, size: 18),
            ),
            Tab(
              text: 'Past (${state.pastCount})',
              icon: const Icon(Icons.history, size: 18),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refreshGuests(),
        child: state.isLoading && state.guests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildGuestList(state.upcomingGuests, 'upcoming'),
                  _buildGuestList(state.activeGuests, 'active'),
                  _buildGuestList(state.pastGuests, 'past'),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSchedule,
        icon: const Icon(Icons.add),
        label: const Text('Schedule Guest'),
      ),
    );
  }

  /// Build guest list for tab
  Widget _buildGuestList(List<Guest> guests, String listType) {
    if (guests.isEmpty) {
      return _buildEmptyState(listType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guests.length,
      itemBuilder: (context, index) {
        final guest = guests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GuestCard(
            guest: guest,
            onTap: () => _navigateToDetails(guest),
            onEdit: guest.isScheduled ? () => _navigateToEdit(guest.id) : null,
            onCancel: guest.isScheduled ? () => _confirmCancel(guest) : null,
            onCheckIn: guest.isActive && guest.isScheduled
                ? () => _checkIn(guest.id)
                : null,
            onCheckOut: guest.isCheckedIn ? () => _checkOut(guest.id) : null,
          ),
        );
      },
    );
  }

  /// Build empty state for list type
  Widget _buildEmptyState(String listType) {
    IconData icon;
    String title;
    String subtitle;

    switch (listType) {
      case 'upcoming':
        icon = Icons.event_available;
        title = 'No upcoming guests';
        subtitle = 'Schedule guests to see them here';
        break;
      case 'active':
        icon = Icons.people;
        title = 'No active guests';
        subtitle = 'Guests currently visiting will appear here';
        break;
      case 'past':
        icon = Icons.history;
        title = 'No past visits';
        subtitle = 'Completed guest visits will appear here';
        break;
      default:
        icon = Icons.event_busy;
        title = 'No guests';
        subtitle = '';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to schedule screen
  void _navigateToSchedule() {
    context.push('/guests/schedule');
  }

  /// Navigate to edit screen
  void _navigateToEdit(String guestId) {
    context.push('/guests/edit/$guestId');
  }

  /// Navigate to details screen
  void _navigateToDetails(Guest guest) {
    context.push('/guests/details/${guest.id}');
  }

  /// Check in guest
  Future<void> _checkIn(String guestId) async {
    final notifier = ref.read(guestProvider.notifier);
    final success = await notifier.checkInGuest(guestId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest checked in successfully')),
      );
    } else {
      final errorMessage = ref.read(guestProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  /// Check out guest
  Future<void> _checkOut(String guestId) async {
    final notifier = ref.read(guestProvider.notifier);
    final success = await notifier.checkOutGuest(guestId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest checked out successfully')),
      );
    } else {
      final errorMessage = ref.read(guestProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  /// Confirm cancel guest visit
  Future<void> _confirmCancel(Guest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Guest Visit'),
        content: Text(
          'Are you sure you want to cancel the visit for ${guest.guestName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(guestProvider.notifier);
      final success = await notifier.cancelGuestVisit(guest.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest visit cancelled')),
        );
      } else {
        final errorMessage = ref.read(guestProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    }
  }
}
