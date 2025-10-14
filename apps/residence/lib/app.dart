import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

/// Main app widget with routing
class ResidenceApp extends ConsumerWidget {
  const ResidenceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Village Tech - Residence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }
      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/';
      }
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Home route
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Household members routes
      GoRoute(
        path: '/household-members',
        builder: (context, state) => const HouseholdMembersListScreen(),
      ),

      // Stickers routes
      GoRoute(
        path: '/stickers',
        builder: (context, state) => const StickerAllocationScreen(),
      ),

      // Beneficial users routes
      GoRoute(
        path: '/beneficial-users',
        builder: (context, state) => const BeneficialUsersListScreen(),
      ),

      // Guests routes
      GoRoute(
        path: '/guests',
        builder: (context, state) => const ScheduledGuestsScreen(),
      ),

      // Permits routes
      GoRoute(
        path: '/permits',
        builder: (context, state) => const PermitsListScreen(),
      ),

      // Announcements routes
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),

      // Messages routes
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesListScreen(),
      ),

      // Village rules routes
      GoRoute(
        path: '/village-rules',
        builder: (context, state) => const VillageRulesScreen(),
      ),

      // Settings routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

// Placeholder screens (to be implemented in user story phases)

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Screen - To be implemented'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen - To be implemented in Phase 9'),
      ),
    );
  }
}

class HouseholdMembersListScreen extends StatelessWidget {
  const HouseholdMembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Household Members - To be implemented in Phase 3'),
      ),
    );
  }
}

class StickerAllocationScreen extends StatelessWidget {
  const StickerAllocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sticker Allocation - To be implemented in Phase 4'),
      ),
    );
  }
}

class BeneficialUsersListScreen extends StatelessWidget {
  const BeneficialUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Beneficial Users - To be implemented in Phase 5'),
      ),
    );
  }
}

class ScheduledGuestsScreen extends StatelessWidget {
  const ScheduledGuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Scheduled Guests - To be implemented in Phase 6'),
      ),
    );
  }
}

class PermitsListScreen extends StatelessWidget {
  const PermitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Permits - To be implemented in Phase 7'),
      ),
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Announcements - To be implemented in Phase 8'),
      ),
    );
  }
}

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Messages - To be implemented in Phase 8'),
      ),
    );
  }
}

class VillageRulesScreen extends StatelessWidget {
  const VillageRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Village Rules - To be implemented in Phase 8'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings - To be implemented in Phase 9'),
      ),
    );
  }
}
