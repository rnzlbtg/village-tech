import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/auth/supabase_client.dart';
import 'shared/theme/app_theme.dart';

/// Main entry point for Sentinel App
/// Gate Guard Access Control Mobile Application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  final logger = Logger();
  logger.i('Starting Sentinel App...');

  try {
    // Initialize Supabase
    await SupabaseClientWrapper.instance.initialize();

    logger.i('Supabase initialized successfully');

    // Run the app
    runApp(
      ProviderScope(
        child: const SentinelApp(),
      ),
    );

  } catch (e, stackTrace) {
    logger.e('Failed to initialize app: $e', error: e, stackTrace: stackTrace);

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize app\n\nError: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}