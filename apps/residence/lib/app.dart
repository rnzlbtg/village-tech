import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/household_members/household_members_list_screen.dart';
import 'screens/household_members/add_household_member_screen.dart';
import 'screens/household_members/edit_household_member_screen.dart';
import 'screens/stickers/sticker_allocation_screen.dart';
import 'screens/stickers/request_sticker_screen.dart';
import 'screens/stickers/pending_requests_screen.dart';
import 'screens/stickers/sticker_details_screen.dart';
import 'screens/beneficial_users/beneficial_users_list_screen.dart';
import 'screens/beneficial_users/add_beneficial_user_screen.dart';
import 'screens/beneficial_users/edit_beneficial_user_screen.dart';
import 'screens/guests/scheduled_guests_screen.dart';
import 'screens/guests/schedule_guest_screen.dart';
import 'screens/guests/edit_guest_screen.dart';
import 'screens/guests/guest_details_screen.dart';
import 'screens/permits/permits_list_screen.dart';
import 'screens/permits/submit_permit_screen.dart';
import 'screens/permits/permit_details_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/announcements/announcements_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/notification_service.dart';

/// Main app widget with routing
class ResidenceApp extends ConsumerWidget {
  const ResidenceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Village Tech - Residence',
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Build light theme with Village Tech color scheme
  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF105640); // Rich forest green
    const secondaryColor = Color(0xFF2D7D5C); // Lighter green
    const accentColor = Color(0xFFF59E0B); // Warm amber

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryColor.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Build dark theme with Village Tech color scheme
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF2D7D5C); // Lighter green for dark mode
    const secondaryColor = Color(0xFF105640); // Rich forest green
    const accentColor = Color(0xFFF59E0B); // Warm amber

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  final router = GoRouter(
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
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddHouseholdMemberScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final memberId = state.pathParameters['id']!;
              return EditHouseholdMemberScreen(memberId: memberId);
            },
          ),
        ],
      ),

      // Stickers routes
      GoRoute(
        path: '/stickers',
        builder: (context, state) => const StickerAllocationScreen(),
        routes: [
          GoRoute(
            path: 'request',
            builder: (context, state) => const RequestStickerScreen(),
          ),
          GoRoute(
            path: 'requests',
            builder: (context, state) => const PendingRequestsScreen(),
          ),
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final requestId = state.pathParameters['id']!;
              return StickerDetailsScreen(requestId: requestId);
            },
          ),
        ],
      ),

      // Beneficial users routes
      GoRoute(
        path: '/beneficial-users',
        builder: (context, state) => const BeneficialUsersListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddBeneficialUserScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final userId = state.pathParameters['id']!;
              return EditBeneficialUserScreen(userId: userId);
            },
          ),
        ],
      ),

      // Guests routes
      GoRoute(
        path: '/guests',
        builder: (context, state) => const ScheduledGuestsScreen(),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => const ScheduleGuestScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final guestId = state.pathParameters['id']!;
              return EditGuestScreen(guestId: guestId);
            },
          ),
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final guestId = state.pathParameters['id']!;
              return GuestDetailsScreen(guestId: guestId);
            },
          ),
        ],
      ),

      // Permits routes
      GoRoute(
        path: '/permits',
        builder: (context, state) => const PermitsListScreen(),
        routes: [
          GoRoute(
            path: 'submit',
            builder: (context, state) => const SubmitPermitScreen(),
          ),
          GoRoute(
            path: 'details/:id',
            builder: (context, state) {
              final permitId = state.pathParameters['id']!;
              return PermitDetailsScreen(permitId: permitId);
            },
          ),
        ],
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

      // Settings route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Profile route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );

  // Setup notification navigation callback
  NotificationService.instance.setNavigationCallback((type, data) {
    switch (type) {
      case 'sticker_approval':
        final requestId = data['requestId'] as String?;
        if (requestId != null) {
          router.push('/stickers/details/$requestId');
        }
        break;
      case 'guest_verification':
        router.push('/guests');
        break;
      case 'announcement':
        final announcementId = data['announcementId'] as String?;
        if (announcementId != null) {
          router.push('/announcements/$announcementId');
        }
        break;
      default:
        // Unknown notification type
        break;
    }
  });

  return router;
});


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

