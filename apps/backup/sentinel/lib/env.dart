import 'package:envied/envied.dart';

part 'generated/env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static const String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static const String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'SUPABASE_SERVICE_ROLE_KEY', obfuscate: true)
  static const String supabaseServiceRoleKey = _Env.supabaseServiceRoleKey;

  @EnviedField(varName: 'ENVIRONMENT')
  static const String environment = _Env.environment;

  @EnviedField(varName: 'ENABLE_RFID')
  static const bool enableRfid = _Env.enableRfid;

  @EnviedField(varName: 'ENABLE_OFFLINE_MODE')
  static const bool enableOfflineMode = _Env.enableOfflineMode;

  @EnviedField(varName: 'ENABLE_PUSH_NOTIFICATIONS')
  static const bool enablePushNotifications = _Env.enablePushNotifications;

  @EnviedField(varName: 'ENABLE_BIOMETRIC_AUTH')
  static const bool enableBiometricAuth = _Env.enableBiometricAuth;

  @EnviedField(varName: 'ENABLE_BACKGROUND_SYNC')
  static const bool enableBackgroundSync = _Env.enableBackgroundSync;

  @EnviedField(varName: 'DEBUG_MODE')
  static const bool debugMode = _Env.debugMode;

  @EnviedField(varName: 'ENABLE_LOGGING')
  static const bool enableLogging = _Env.enableLogging;

  @EnviedField(varName: 'LOG_LEVEL')
  static const String logLevel = _Env.logLevel;

  @EnviedField(varName: 'SYNC_INTERVAL_MINUTES')
  static const int syncIntervalMinutes = _Env.syncIntervalMinutes;

  @EnviedField(varName: 'MAX_RETRY_ATTEMPTS')
  static const int maxRetryAttempts = _Env.maxRetryAttempts;

  @EnviedField(varName: 'SYNC_BATCH_SIZE')
  static const int syncBatchSize = _Env.syncBatchSize;

  @EnviedField(varName: 'NFC_SESSION_TIMEOUT_SECONDS')
  static const int nfcSessionTimeoutSeconds = _Env.nfcSessionTimeoutSeconds;

  @EnviedField(varName: 'NFC_AUTO_STOP')
  static const bool nfcAutoStop = _Env.nfcAutoStop;

  @EnviedField(varName: 'FCM_TOPIC_PREFIX')
  static const String fcmTopicPrefix = _Env.fcmTopicPrefix;

  @EnviedField(varName: 'NOTIFICATION_CHANNEL_ID')
  static const String notificationChannelId = _Env.notificationChannelId;

  @EnviedField(varName: 'NOTIFICATION_CHANNEL_NAME')
  static const String notificationChannelName = _Env.notificationChannelName;

  @EnviedField(varName: 'SESSION_TIMEOUT_MINUTES')
  static const int sessionTimeoutMinutes = _Env.sessionTimeoutMinutes;

  @EnviedField(varName: 'MAX_LOGIN_ATTEMPTS')
  static const int maxLoginAttempts = _Env.maxLoginAttempts;

  @EnviedField(varName: 'ENCRYPTION_KEY_VERSION')
  static const int encryptionKeyVersion = _Env.encryptionKeyVersion;

  @EnviedField(varName: 'API_TIMEOUT_SECONDS')
  static const int apiTimeoutSeconds = _Env.apiTimeoutSeconds;

  @EnviedField(varName: 'API_RETRY_COUNT')
  static const int apiRetryCount = _Env.apiRetryCount;

  @EnviedField(varName: 'API_BASE_URL')
  static const String? apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'DEV_USE_EMULATOR')
  static const bool devUseEmulator = _Env.devUseEmulator;

  @EnviedField(varName: 'DEV_SKIP_ENCRYPTION')
  static const bool devSkipEncryption = _Env.devSkipEncryption;

  @EnviedField(varName: 'DEV_MOCK_OFFLINE_MODE')
  static const bool devMockOfflineMode = _Env.devMockOfflineMode;
}