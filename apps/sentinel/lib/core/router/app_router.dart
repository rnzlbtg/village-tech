import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/splash/splash_screen.dart';
import '../../utils/constants.dart';
import '../providers/service_providers.dart' as providers;
import '../providers/auth_provider.dart' as auth;
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/rfid_scanning/rfid_scan_screen.dart';
import '../../screens/guests/guest_list_screen.dart';
import '../../screens/deliveries/delivery_list_screen.dart';
import '../../screens/incidents/incident_list_screen.dart';
import '../../screens/rules/village_rules_screen.dart';
import '../../screens/announcements/announcements_screen.dart';
import '../../screens/construction/construction_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(providers.authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: Environment.isDebug,
    redirect: (context, state) {
      final isAuthenticated = authState.status == auth.AuthStatus.authenticated;
      final isAuthRoute = state.uri.path.startsWith('/login');
      final isSplashRoute = state.uri.path == AppRoutes.splash;

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        return AppRoutes.login;
      }

      // If authenticated and on auth route, redirect to dashboard
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app routes (require authentication)
      ShellRoute(
        builder: (context, state, child) {
          return DashboardScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardHomeScreen(),
          ),

          // RFID Scanning
          GoRoute(
            path: AppRoutes.rfidScan,
            name: 'rfid_scan',
            builder: (context, state) => const RfidScanScreen(),
          ),

          // Guest Management
          GoRoute(
            path: AppRoutes.guestList,
            name: 'guest_list',
            builder: (context, state) => const GuestListScreen(),
          ),

          // Delivery Management
          GoRoute(
            path: AppRoutes.deliveries,
            name: 'deliveries',
            builder: (context, state) => const DeliveryListScreen(),
          ),

          // Construction Management
          GoRoute(
            path: AppRoutes.construction,
            name: 'construction',
            builder: (context, state) => const ConstructionScreen(),
          ),

          // Incident Reporting
          GoRoute(
            path: AppRoutes.incidents,
            name: 'incidents',
            builder: (context, state) => const IncidentListScreen(),
          ),

          // Village Rules
          GoRoute(
            path: AppRoutes.rules,
            name: 'rules',
            builder: (context, state) => const VillageRulesScreen(),
          ),

          // Announcements
          GoRoute(
            path: AppRoutes.announcements,
            name: 'announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});