import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/auth/auth_provider.dart';
import 'shared/theme/app_theme.dart';

/// Main application widget
/// Sentinel App - Gate Guard Access Control Mobile Application
class SentinelApp extends ConsumerWidget {
  const SentinelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Sentinel - Gate Guard Access Control',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: _buildHome(authState),
        );
      },
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.loading:
        return const _LoadingScreen();
      case AuthStatus.authenticated:
        return const _MainScreen();
      case AuthStatus.unauthenticated:
        return const _LoginScreen();
      case AuthStatus.error:
        return _ErrorScreen(error: authState.error);
      default:
        return const _LoadingScreen();
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.security,
                size: 60,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sentinel',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gate Guard Access Control',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MainScreen extends StatelessWidget {
  const _MainScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Sentinel',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Gate Guard Access Control System',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Sentinel Login',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to access the system',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // TODO: Implement login form
              const Text('Login form will be implemented here'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Initialization Error',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'An unknown error occurred',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}