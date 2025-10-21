import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/service_providers.dart';
import '../../core/router/app_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../utils/constants.dart';

class DashboardScreen extends ConsumerWidget {
  final Widget? child;

  const DashboardScreen({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child ?? const DashboardHomeScreen(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_getPageTitle(context)),
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryColor,
      elevation: 0,
    );
  }

  String _getPageTitle(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.toString();
      if (location.startsWith(AppRoutes.dashboard)) return 'Dashboard';
      if (location.startsWith(AppRoutes.rfidScan)) return 'RFID Scanning';
      if (location.startsWith(AppRoutes.guestList)) return 'Guest Management';
      if (location.startsWith(AppRoutes.deliveries)) return 'Deliveries';
      if (location.startsWith(AppRoutes.construction)) return 'Construction';
      if (location.startsWith(AppRoutes.incidents)) return 'Incidents';
      if (location.startsWith(AppRoutes.rules)) return 'Village Rules';
      if (location.startsWith(AppRoutes.announcements)) return 'Announcements';
      return 'Sentinel';
    } catch (e) {
      return 'Sentinel';
    }
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, ref),
          const Divider(height: 1),
          _buildNavigationItems(context),
          const Divider(height: 1),
          _buildBottomActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    debugPrint('🔍 AuthState: $authState');

    // Extract user details from userMetadata
    final userMetadata = authState.user?.userMetadata ?? {};
    final firstName = userMetadata['first_name'] as String? ?? 'Guard';
    final lastName = userMetadata['last_name'] as String? ?? '';
    final guardName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

    // Format role from snake_case to Title Case
    final rawRole = userMetadata['role'] as String? ?? 'Officer';
    final userRole = rawRole.split('_').map((word) =>
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');

    return DrawerHeader(
      decoration: const BoxDecoration(color: AppTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security, size: 32, color: Colors.white),
          const SizedBox(height: 4),
          const Text(
            'Sentinel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Gate Guard System',
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          // User info
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        guardName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        userRole,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Column(
      children: [
        _buildNavItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          route: AppRoutes.dashboard,
        ),
        _buildNavItem(
          context,
          icon: Icons.nfc,
          title: 'RFID Scanning',
          route: AppRoutes.rfidScan,
        ),
        _buildNavItem(
          context,
          icon: Icons.people,
          title: 'Guest Management',
          route: AppRoutes.guestList,
        ),
        _buildNavItem(
          context,
          icon: Icons.local_shipping,
          title: 'Deliveries',
          route: AppRoutes.deliveries,
        ),
        _buildNavItem(
          context,
          icon: Icons.construction,
          title: 'Construction',
          route: AppRoutes.construction,
        ),
        _buildNavItem(
          context,
          icon: Icons.report,
          title: 'Incidents',
          route: AppRoutes.incidents,
        ),
        _buildNavItem(
          context,
          icon: Icons.gavel,
          title: 'Village Rules',
          route: AppRoutes.rules,
        ),
        _buildNavItem(
          context,
          icon: Icons.announcement,
          title: 'Announcements',
          route: AppRoutes.announcements,
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = _isCurrentRoute(context, route);

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        if (!isSelected) {
          context.go(route);
        }
      },
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: Icon(Icons.person, color: Colors.grey[600], size: 20),
          title: const Text('Profile', style: TextStyle(fontSize: 14)),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Navigate to profile
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.settings, color: Colors.grey[600], size: 20),
          title: const Text('Settings', style: TextStyle(fontSize: 14)),
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Navigate to settings
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
          ListTile(
          dense: true,
          leading: const Icon(Icons.logout, color: Colors.red, size: 20),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          onTap: () async {
            Navigator.of(context).pop();
            // Cache auth notifier before widget disposal
            final authNotifier = ref.read(authStateProvider.notifier);

            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Logging out...'),
                  ],
                ),
              ),
            );

            try {
              // Call the signOut method from the cached auth notifier
              await authNotifier.signOut();

              // Close loading dialog and navigate to login
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog
                context.go(AppRoutes.login);
              }
            } catch (e) {
              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ],
    );
  }

  bool _isCurrentRoute(BuildContext context, String route) {
    try {
      final location = GoRouterState.of(context).uri.toString();
      return location.startsWith(route);
    } catch (e) {
      return false;
    }
  }
}

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authStateProvider);

                      // Extract user details from userMetadata
                      final userMetadata = authState.user?.userMetadata ?? {};
                      final firstName = userMetadata['first_name'] as String? ?? 'Guard';
                      final lastName = userMetadata['last_name'] as String? ?? '';
                      final guardName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

                      return Text(
                        'Welcome back, $guardName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today is ${DateTime.now().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Active Guests',
                          '12',
                          Icons.people,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Pending Deliveries',
                          '5',
                          Icons.local_shipping,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Active Alerts',
                          '2',
                          Icons.warning,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  context,
                  'Scan RFID',
                  Icons.nfc,
                  AppRoutes.rfidScan,
                  Colors.blue,
                ),
                _buildQuickActionCard(
                  context,
                  'Register Guest',
                  Icons.person_add,
                  AppRoutes.guestRegistration,
                  Colors.green,
                ),
                _buildQuickActionCard(
                  context,
                  'Check Deliveries',
                  Icons.local_shipping,
                  AppRoutes.deliveries,
                  Colors.orange,
                ),
                _buildQuickActionCard(
                  context,
                  'Report Incident',
                  Icons.report,
                  AppRoutes.incidents,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.check,
                    iconColor: Colors.green,
                    title: 'Guest Check-in',
                    subtitle: 'John Smith - Guest #1234',
                    time: '2 min ago',
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    icon: Icons.nfc,
                    iconColor: Colors.blue,
                    title: 'RFID Scan',
                    subtitle: 'Resident entered - Unit A-101',
                    time: '15 min ago',
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    icon: Icons.local_shipping,
                    iconColor: Colors.orange,
                    title: 'Delivery Arrived',
                    subtitle: 'Package for Household B-205',
                    time: '1 hour ago',
                  ),
                ],
              ),
            ),

            // Add bottom padding to ensure content doesn't get cut off
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
