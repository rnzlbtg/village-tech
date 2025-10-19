import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/rfid_verification/presentation/screens/rfid_scan_screen.dart';
import '../../features/guest_management/presentation/screens/guest_search_screen.dart';
import '../../features/delivery_tracking/presentation/screens/delivery_entry_screen.dart';
import '../../features/incident_reporting/presentation/screens/incident_report_screen.dart';
import '../../features/village_info/presentation/screens/village_rules_screen.dart';
import '../../features/village_info/presentation/screens/announcements_screen.dart';

/// Router configuration provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    redirectLimit: 10,
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoginPage = state.fullPath == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }

      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isLoginPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Login route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Home route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // RFID Verification
      GoRoute(
        path: '/rfid-scan',
        name: 'rfid-scan',
        builder: (context, state) => const RfidScanScreen(),
      ),

      // Guest Management
      GoRoute(
        path: '/guest-search',
        name: 'guest-search',
        builder: (context, state) => const GuestSearchScreen(),
      ),

      // Delivery Tracking
      GoRoute(
        path: '/delivery-entry',
        name: 'delivery-entry',
        builder: (context, state) => const DeliveryEntryScreen(),
      ),

      // Incident Reporting
      GoRoute(
        path: '/incident-report',
        name: 'incident-report',
        builder: (context, state) => const IncidentReportScreen(),
      ),

      // Village Rules
      GoRoute(
        path: '/village-rules',
        name: 'village-rules',
        builder: (context, state) => const VillageRulesScreen(),
      ),

      // Announcements
      GoRoute(
        path: '/announcements',
        name: 'announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you requested could not be found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Navigation utility class
class NavigationUtils {
  static void navigateToRfidScan(BuildContext context) {
    context.push('/rfid-scan');
  }

  static void navigateToGuestSearch(BuildContext context) {
    context.push('/guest-search');
  }

  static void navigateToDeliveryEntry(BuildContext context) {
    context.push('/delivery-entry');
  }

  static void navigateToIncidentReport(BuildContext context) {
    context.push('/incident-report');
  }

  static void navigateToVillageRules(BuildContext context) {
    context.push('/village-rules');
  }

  static void navigateToAnnouncements(BuildContext context) {
    context.push('/announcements');
  }

  static void goHome(BuildContext context) {
    context.go('/home');
  }

  static void logout(BuildContext context) {
    context.go('/login');
  }
}