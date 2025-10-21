import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env.local
  try {
    await dotenv.load(fileName: '.env.local');
    debugPrint('✅ ENVIRONMENT: Loaded .env.local file');
  } catch (e) {
    debugPrint('❌ ENVIRONMENT: Failed to load .env.local file: $e');
  }

  debugPrint('🚀 APP STARTUP: Initializing Sentinel App');

  // Check environment variables
  debugPrint('🔍 ENVIRONMENT CHECK');
  debugPrint('🔍 SUPABASE_URL: ${Environment.supabaseUrl.isNotEmpty ? 'SET' : 'EMPTY'}');
  debugPrint('🔍 SUPABASE_ANON_KEY: ${Environment.supabaseAnonKey.isNotEmpty ? 'SET' : 'EMPTY'}');

  if (Environment.supabaseUrl.isEmpty || Environment.supabaseAnonKey.isEmpty) {
    debugPrint('');
    debugPrint('❌ CONFIGURATION ERROR: Supabase credentials not found!');
    debugPrint('');
    debugPrint('📝 TO FIX THIS ISSUE:');
    debugPrint('1. Create a .env file in the sentinel app directory');
    debugPrint('2. Copy the content from .env.example');
    debugPrint('3. Fill in your actual Supabase URL and keys');
    debugPrint('');
    debugPrint('📄 Example .env file content:');
    debugPrint('SUPABASE_URL=https://your-project-id.supabase.co');
    debugPrint('SUPABASE_ANON_KEY=your-anon-key-here');
    debugPrint('SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here');
    debugPrint('');

    // Don't crash in development - just show the helpful message above
    if (!Environment.isDebug) {
      throw Exception('Supabase credentials not configured. Please check your .env file.');
    }
  }

  // Only initialize Supabase if credentials are available
  if (Environment.supabaseUrl.isNotEmpty && Environment.supabaseAnonKey.isNotEmpty) {
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );

      debugPrint('✅ SUPABASE INITIALIZED SUCCESSFULLY');
    } catch (e) {
      debugPrint('❌ SUPABASE INITIALIZATION FAILED: $e');
      debugPrint('❌ Please check your .env file and ensure SUPABASE_URL and SUPABASE_ANON_KEY are set correctly');
      if (!Environment.isDebug) {
        rethrow;
      }
    }
  } else {
    debugPrint('⚠️ SKIP SUPABASE INITIALIZATION: Missing credentials');
  }

  debugPrint('🚀 APP STARTUP: Starting Sentinel App');
  runApp(
    const ProviderScope(
      child: SentinelApp(),
    ),
  );
}
