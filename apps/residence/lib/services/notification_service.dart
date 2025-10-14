import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification
  // ignore: avoid_print
  print('Background notification: ${message.notification?.title}');
}

/// Firebase Cloud Messaging notification service
class NotificationService {
  static NotificationService? _instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  /// Singleton instance
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    // Request permission (iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // Get FCM token and save to Supabase
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_saveFCMToken);

    // Initialize local notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification opened app from terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Save FCM token to Supabase
  Future<void> _saveFCMToken(String token) async {
    try {
      final supabase = SupabaseService.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      await supabase.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'] as String?,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    // Navigation will be handled by the app router
    // This method just provides the hook for navigation
    // ignore: avoid_print
    print('Notification tapped: type=$type, data=$data');

    // TODO: Implement navigation based on notification type
    // Example:
    // switch (type) {
    //   case 'sticker_approval':
    //     navigatorKey.currentState?.pushNamed('/stickers/${data['requestId']}');
    //     break;
    //   case 'guest_verification':
    //     navigatorKey.currentState?.pushNamed('/guests');
    //     break;
    //   case 'announcement':
    //     navigatorKey.currentState?.pushNamed('/announcements/${data['announcementId']}');
    //     break;
    // }
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse details) {
    final payload = details.payload;
    if (payload == null) return;

    // ignore: avoid_print
    print('Local notification tapped: payload=$payload');

    // TODO: Implement navigation based on payload
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
