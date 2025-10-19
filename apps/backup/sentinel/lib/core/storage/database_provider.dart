import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../auth/auth_provider.dart';
import 'database.dart';

/// Database provider for dependency injection using Riverpod
/// Handles database lifecycle management and initialization
final databaseProvider = Provider<AppDatabase>((ref) {
  final logger = Logger();
  logger.d('Creating AppDatabase instance');

  final database = AppDatabase();

  // Ensure database is disposed when provider is disposed
  ref.onDispose(() {
    logger.d('Disposing AppDatabase');
    database.close();
  });

  return database;
});

/// Async database initialization provider
/// Ensures database is properly initialized before use
final databaseInitProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);
  final logger = Logger();

  try {
    logger.i('Initializing database...');
    await DatabaseProvider.initialize();
    logger.i('Database initialization completed successfully');
  } catch (e) {
    logger.e('Database initialization failed: $e');
    rethrow;
  }
});

/// Database ready provider
/// Combines database with auth state for tenant-aware operations
final databaseReadyProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final databaseInitState = ref.watch(databaseInitProvider);

  // Database is ready when auth is authenticated and database is initialized
  return authState.status == AuthStatus.authenticated &&
         databaseInitState.hasValue &&
         !databaseInitState.isLoading;
});

/// Tenant-scoped database provider
/// Provides database access with tenant context
final tenantDatabaseProvider = Provider<TenantDatabase>((ref) {
  final database = ref.watch(databaseProvider);
  final authState = ref.watch(authProvider);
  final tenantId = authState.tenantId;

  if (tenantId == null) {
    throw StateError('Tenant ID is not available. User must be authenticated.');
  }

  return TenantDatabase(database, tenantId);
});

/// Wrapper class for tenant-scoped database operations
/// Ensures all database operations are properly scoped to the current tenant
class TenantDatabase {
  final AppDatabase _database;
  final String tenantId;
  final Logger _logger = Logger();

  TenantDatabase(this._database, this.tenantId);

  /// Get the underlying database instance
  AppDatabase get database => _database;

  /// Get current tenant ID
  String get currentTenantId => tenantId;

  /// Generate unique ID for database records
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${tenantId}_${_generateRandomString(8)}';
  }

  /// Generate random string for ID
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  }