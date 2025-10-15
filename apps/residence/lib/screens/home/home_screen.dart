import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/household_provider.dart';
import '../../providers/sticker_provider.dart';
import '../../providers/beneficial_user_provider.dart';
import '../../providers/guest_provider.dart';
import '../../providers/permit_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/announcement_provider.dart';

/// Home dashboard screen with quick access cards to all features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdState = ref.watch(householdMembersProvider);
    final stickerState = ref.watch(stickerProvider);
    final beneficialState = ref.watch(beneficialUsersProvider);
    final guestState = ref.watch(guestProvider);
    final permitState = ref.watch(permitProvider);
    final messagingState = ref.watch(messagingProvider);
    final announcementState = ref.watch(announcementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Tech'),
        actions: [
          // Unread messages badge
          if (messagingState.unreadCount > 0)
            IconButton(
              icon: Badge(
                label: Text(messagingState.unreadCount.toString()),
                child: const Icon(Icons.message),
              ),
              onPressed: () => context.push('/messages'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome section
            _buildWelcomeCard(),
            const SizedBox(height: 16),

            // High priority announcements
            if (announcementState.urgentAnnouncements.isNotEmpty ||
                announcementState.highAnnouncements.isNotEmpty)
              _buildAnnouncementsCard(context, announcementState),

            const SizedBox(height: 16),

            // Quick access grid
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildQuickAccessCard(
                  context,
                  icon: Icons.people,
                  title: 'Members',
                  subtitle: '${householdState.members.length} members',
                  color: const Color(0xFF105640),
                  onTap: () => context.push('/household-members'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.local_parking,
                  title: 'Stickers',
                  subtitle: '${stickerState.allocation?.available ?? 0} available',
                  color: const Color(0xFF2D7D5C),
                  onTap: () => context.push('/stickers'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.person_add,
                  title: 'Beneficial',
                  subtitle: '${beneficialState.activeCount} active',
                  color: const Color(0xFFF59E0B),
                  onTap: () => context.push('/beneficial-users'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.event,
                  title: 'Guests',
                  subtitle: '${guestState.upcomingCount} upcoming',
                  color: Colors.blue,
                  onTap: () => context.push('/guests'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.construction,
                  title: 'Permits',
                  subtitle: '${permitState.pendingCount} pending',
                  color: Colors.orange,
                  onTap: () => context.push('/permits'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.announcement,
                  title: 'Announcements',
                  subtitle: '${announcementState.announcements.length} total',
                  color: Colors.purple,
                  onTap: () => context.push('/announcements'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.message,
                  title: 'Messages',
                  subtitle: '${messagingState.unreadCount} unread',
                  color: Colors.green,
                  onTap: () => context.push('/messages'),
                ),
                _buildQuickAccessCard(
                  context,
                  icon: Icons.rule,
                  title: 'Rules',
                  subtitle: 'View rules',
                  color: Colors.indigo,
                  onTap: () => context.push('/village-rules'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Home!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your household and community access',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard(
      BuildContext context, AnnouncementState state) {
    final importantAnnouncements = [
      ...state.urgentAnnouncements,
      ...state.highAnnouncements
    ].take(2).toList();

    return Card(
      color: Colors.red[50],
      child: InkWell(
        onTap: () => context.push('/announcements'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.priority_high, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Important Announcements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...importantAnnouncements.map((announcement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: announcement.isUrgent
                                ? Colors.red
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              const Text(
                'Tap to view all announcements',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(householdMembersProvider.notifier).refreshMembers(),
      ref.read(stickerProvider.notifier).refreshData(),
      ref.read(beneficialUsersProvider.notifier).refreshUsers(),
      ref.read(guestProvider.notifier).refreshGuests(),
      ref.read(permitProvider.notifier).refreshPermits(),
      ref.read(messagingProvider.notifier).refreshMessages(),
      ref.read(announcementProvider.notifier).refreshAnnouncements(),
    ]);
  }
}

/// App drawer widget for navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF105640),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.home, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Village Tech',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Residence App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Household Members'),
            onTap: () {
              Navigator.pop(context);
              context.push('/household-members');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_parking),
            title: const Text('Vehicle Stickers'),
            onTap: () {
              Navigator.pop(context);
              context.push('/stickers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Beneficial Users'),
            onTap: () {
              Navigator.pop(context);
              context.push('/beneficial-users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Guests'),
            onTap: () {
              Navigator.pop(context);
              context.push('/guests');
            },
          ),
          ListTile(
            leading: const Icon(Icons.construction),
            title: const Text('Construction Permits'),
            onTap: () {
              Navigator.pop(context);
              context.push('/permits');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcements'),
            onTap: () {
              Navigator.pop(context);
              context.push('/announcements');
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              context.push('/messages');
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('Village Rules'),
            onTap: () {
              Navigator.pop(context);
              context.push('/village-rules');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}
