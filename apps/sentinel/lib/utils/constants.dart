
class Environment {
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'Sentinel');
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String supabaseServiceRoleKey = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const String flutterEnv = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'development');
  static const String logLevel = String.fromEnvironment('LOG_LEVEL', defaultValue: 'debug');

  // Feature flags
  static const bool enableRfid = String.fromEnvironment('ENABLE_RFID', defaultValue: 'true') == 'true';
  static const bool enableOfflineMode = String.fromEnvironment('ENABLE_OFFLINE_MODE', defaultValue: 'true') == 'true';
  static const bool enablePushNotifications = String.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: 'true') == 'true';
  static const bool enableBiometricAuth = String.fromEnvironment('ENABLE_BIOMETRIC_AUTH', defaultValue: 'true') == 'true';
  static const bool enableBackgroundSync = String.fromEnvironment('ENABLE_BACKGROUND_SYNC', defaultValue: 'true') == 'true';

  // Debug settings
  static const bool isDebug = String.fromEnvironment('DEBUG_MODE', defaultValue: 'true') == 'true';
  static const bool enableLogging = String.fromEnvironment('ENABLE_LOGGING', defaultValue: 'true') == 'true';

  // Development settings
  static const bool useEmulator = String.fromEnvironment('DEV_USE_EMULATOR', defaultValue: 'false') == 'true';
  static const bool skipEncryption = String.fromEnvironment('DEV_SKIP_ENCRYPTION', defaultValue: 'false') == 'true';
  static const bool mockOfflineMode = String.fromEnvironment('DEV_MOCK_OFFLINE_MODE', defaultValue: 'false') == 'true';

  // Environment checks
  static bool get isDevelopment => flutterEnv == 'development';
  static bool get isProduction => flutterEnv == 'production';
  static bool get isTesting => flutterEnv == 'testing';

  // API configuration
  static int get apiTimeout => _parseEnvironmentInt('API_TIMEOUT_SECONDS', 30);
  static int get apiRetryCount => _parseEnvironmentInt('API_RETRY_COUNT', 3);

  // Sync configuration
  static int get syncIntervalMinutes => _parseEnvironmentInt('SYNC_INTERVAL_MINUTES', 15);
  static int get maxRetryAttempts => _parseEnvironmentInt('MAX_RETRY_ATTEMPTS', 5);
  static int get syncBatchSize => _parseEnvironmentInt('SYNC_BATCH_SIZE', 50);

  // NFC configuration
  static int get nfcSessionTimeoutSeconds => _parseEnvironmentInt('NFC_SESSION_TIMEOUT_SECONDS', 5);
  static const bool nfcAutoStop = String.fromEnvironment('NFC_AUTO_STOP', defaultValue: 'true') == 'true';

  // Security configuration
  static int get sessionTimeoutMinutes => _parseEnvironmentInt('SESSION_TIMEOUT_MINUTES', 30);
  static int get maxLoginAttempts => _parseEnvironmentInt('MAX_LOGIN_ATTEMPTS', 3);
  static int get encryptionKeyVersion => _parseEnvironmentInt('ENCRYPTION_KEY_VERSION', 1);

  // Helper method for parsing environment integers
  static int _parseEnvironmentInt(String key, int defaultValue) {
    final value = String.fromEnvironment(key, defaultValue: defaultValue.toString());
    return int.tryParse(value) ?? defaultValue;
  }

  // Notification configuration
  static const String fcmTopicPrefix = String.fromEnvironment('FCM_TOPIC_PREFIX', defaultValue: 'sentinel_');
  static const String notificationChannelId = String.fromEnvironment('NOTIFICATION_CHANNEL_ID', defaultValue: 'sentinel_notifications');
  static const String notificationChannelName = String.fromEnvironment('NOTIFICATION_CHANNEL_NAME', defaultValue: 'Sentinel Notifications');
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String rfidScan = '/rfid-scan';
  static const String guestList = '/guests';
  static const String guestRegistration = '/guests/register';
  static const String deliveries = '/deliveries';
  static const String construction = '/construction';
  static const String incidents = '/incidents';
  static const String rules = '/rules';
  static const String announcements = '/announcements';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class AppConstants {
  static const String appName = 'Sentinel';
  static const String appVersion = '1.0.0';

  // Performance requirements
  static const int rfidScanTimeoutMs = 5000;
  static const int guestProcessingTimeoutMs = 30000;
  static const int maxEntriesPerHour = 50;

  // Data retention
  static const Duration guestDataRetention = Duration(days: 90);
  static const Duration deliveryDataRetention = Duration(days: 365);
  static const Duration incidentDataRetention = Duration(days: 1825); // 5 years

  // Validation rules
  static const int maxGuestsPerHouseholdPerDay = 10;
  static const int maxGuestRegistrationDaysInAdvance = 30;
  static const Duration guestAutoCancelWindow = Duration(hours: 2);
  static const Duration maxDeliveryTimeStandard = Duration(hours: 4);
  static const Duration maxDeliveryTimePerishable = Duration(hours: 1);
  static const int maxConstructionPermitDurationDays = 90;
}

class ApiEndpoints {
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authBiometric = '/auth/biometric';

  static const String rfidVerify = '/rfid/verify';
  static const String rfidStickers = '/rfid/stickers';

  static const String guests = '/guests';
  static const String guestCheckIn = '/guests';
  static const String guestCheckOut = '/guests';

  static const String entries = '/entries';
  static const String entriesToday = '/entries/today';
  static const String entriesExit = '/entries';

  static const String deliveries = '/deliveries';
  static const String deliveriesComplete = '/deliveries';

  static const String constructionPermits = '/construction/permits';
  static const String constructionVerify = '/construction/permits';

  static const String incidents = '/incidents';
  static const String incidentsResolve = '/incidents';
  static const String incidentsPhotos = '/incidents';

  static const String rules = '/rules';
  static const String announcements = '/announcements';
  static const String announcementsAcknowledge = '/announcements';

  static const String syncPending = '/sync/pending';
  static const String syncOperations = '/sync/operations';
  static const String syncStatus = '/sync/status';
}