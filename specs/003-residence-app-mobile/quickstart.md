# Developer Quickstart: Residence App - Household Management Mobile Application

**Feature**: Residence App - Household Management Mobile Application
**Platform**: Flutter 3.24+ (iOS, Android)
**Date**: 2025-10-10

---

## 🎯 Overview

The Residence App is a Flutter mobile application for household heads to manage household members, beneficial users, vehicle gate passes, guest scheduling, construction permits, and communication with admin officers.

---

## 📋 Prerequisites

- **Flutter**: 3.24+ with Dart 3
- **Xcode**: 15+ (for iOS development)
- **Android Studio**: Latest stable (for Android development)
- **Supabase Project**: Access to Village Tech v4 instance
- **Firebase Project**: For push notifications (FCM)

---

## 🚀 Quick Start

### 1. Clone & Navigate
```bash
cd village-tech-v4
git checkout 003-residence-app-mobile
cd apps/residence
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment
Create `.env`:
```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 4. Configure Firebase
- Download `google-services.json` (Android) and place in `android/app/`
- Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

### 5. Run Development App
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 🔑 Key Workflows

### 1. Add Household Member

```dart
// lib/services/household_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseholdService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ApiResult<HouseholdMember>> addHouseholdMember({
    required String fullName,
    required String relationship,
    String? contactNumber,
    String? email,
    DateTime? birthDate,
  }) async {
    try {
      final householdId = await _getHouseholdId();

      final data = await _supabase
          .from('household_members')
          .insert({
            'household_id': householdId,
            'full_name': fullName,
            'relationship': relationship,
            'contact_number': contactNumber,
            'email': email,
            'birth_date': birthDate?.toIso8601String(),
          })
          .select()
          .single();

      return ApiResult.success(HouseholdMember.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<String> _getHouseholdId() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('households')
        .select('id')
        .eq('household_head_id', userId)
        .single();
    return data['id'];
  }
}
```

### 2. Request Vehicle Sticker

```dart
// lib/services/sticker_service.dart
class StickerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ApiResult<RequestStickerResult>> requestSticker({
    required String ownerType, // 'household_member' or 'beneficial_user'
    required String ownerId,
    required String vehiclePlate,
    String? vehicleMake,
    String? vehicleColor,
  }) async {
    try {
      // 1. Check allocation limit
      final allocation = await _checkAllocation();
      if (allocation.available <= 0) {
        return ApiResult.failure(
          'Sticker allocation limit reached',
          code: 'ALLOCATION_EXCEEDED',
        );
      }

      // 2. Create sticker request
      final householdId = await _getHouseholdId();
      final data = await _supabase
          .from('sticker_requests')
          .insert({
            'household_id': householdId,
            'requested_by': _supabase.auth.currentUser!.id,
            'owner_type': ownerType,
            'owner_id': ownerId,
            'vehicle_plate': vehiclePlate,
            'vehicle_make': vehicleMake,
            'vehicle_color': vehicleColor,
            'status': 'pending',
          })
          .select()
          .single();

      return ApiResult.success(RequestStickerResult(
        requestId: data['id'],
        remainingAllocation: allocation.available - 1,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<StickerAllocation> _checkAllocation() async {
    final tenantId = await _getTenantId();
    final householdId = await _getHouseholdId();

    // Get total allocation from program
    final program = await _supabase
        .from('sticker_programs')
        .select('stickers_per_household')
        .eq('tenant_id', tenantId)
        .eq('active', true)
        .single();

    // Get used stickers
    final used = await _supabase
        .from('rfid_stickers')
        .select('*', const FetchOptions(count: CountOption.exact, head: true))
        .eq('household_id', householdId)
        .eq('status', 'active');

    return StickerAllocation(
      total: program['stickers_per_household'],
      used: used.count ?? 0,
      available: program['stickers_per_household'] - (used.count ?? 0),
    );
  }
}
```

### 3. Add Beneficial User with Photo Upload

```dart
// lib/services/beneficial_user_service.dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

class BeneficialUserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ApiResult<BeneficialUser>> addBeneficialUser({
    required String fullName,
    required String contactNumber,
    String? email,
    required String relationship,
    File? idPhoto,
  }) async {
    try {
      String? idPhotoUrl;

      // 1. Upload photo if provided
      if (idPhoto != null) {
        idPhotoUrl = await _uploadPhoto(idPhoto);
      }

      // 2. Create beneficial user record
      final householdId = await _getHouseholdId();
      final data = await _supabase
          .from('beneficial_users')
          .insert({
            'household_id': householdId,
            'full_name': fullName,
            'contact_number': contactNumber,
            'email': email,
            'relationship': relationship,
            'id_photo_url': idPhotoUrl,
            'status': 'active',
          })
          .select()
          .single();

      return ApiResult.success(BeneficialUser.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<String> _uploadPhoto(File photoFile) async {
    // 1. Compress image
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      photoFile.absolute.path,
      '${photoFile.absolute.path}_compressed.jpg',
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
    );

    // 2. Upload to Supabase Storage
    final userId = _supabase.auth.currentUser!.id;
    final tenantId = await _getTenantId();
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$tenantId/beneficial-users/$fileName';

    await _supabase.storage
        .from('user-photos')
        .upload(path, compressedFile!);

    // 3. Get signed URL (24-hour expiration)
    final signedUrl = await _supabase.storage
        .from('user-photos')
        .createSignedUrl(path, 86400);

    return signedUrl;
  }
}
```

### 4. Schedule Guest Visit

```dart
// lib/services/guest_service.dart
class GuestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ApiResult<Guest>> scheduleGuest({
    required String guestName,
    String? guestContact,
    required DateTime visitStart,
    required DateTime visitEnd,
    required String visitType, // 'day_trip' or 'multi_day'
    String? purpose,
    String? vehiclePlate,
  }) async {
    try {
      // 1. Validate visit times
      if (visitStart.isAfter(visitEnd)) {
        return ApiResult.failure(
          'Visit start time must be before end time',
          code: 'VALIDATION_ERROR',
        );
      }

      // 2. Create guest registration
      final householdId = await _getHouseholdId();
      final data = await _supabase
          .from('pre_registered_guests')
          .insert({
            'household_id': householdId,
            'registered_by': _supabase.auth.currentUser!.id,
            'guest_name': guestName,
            'guest_contact': guestContact,
            'visit_start': visitStart.toIso8601String(),
            'visit_end': visitEnd.toIso8601String(),
            'visit_type': visitType,
            'purpose': purpose,
            'vehicle_plate': vehiclePlate,
            'status': 'scheduled',
          })
          .select()
          .single();

      return ApiResult.success(Guest.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
```

### 5. Submit Construction Permit Request

```dart
// lib/services/permit_service.dart
class PermitService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ApiResult<PermitResult>> submitConstructionPermit({
    required String projectType,
    required String projectDescription,
    required String contractorName,
    required String contractorContact,
    required DateTime startDate,
    required DateTime endDate,
    required int estimatedWorkers,
  }) async {
    try {
      // 1. Validate dates
      if (startDate.isAfter(endDate)) {
        return ApiResult.failure(
          'Start date must be before end date',
          code: 'VALIDATION_ERROR',
        );
      }

      // 2. Create permit request
      final householdId = await _getHouseholdId();
      final data = await _supabase
          .from('construction_permit_requests')
          .insert({
            'household_id': householdId,
            'requested_by': _supabase.auth.currentUser!.id,
            'project_type': projectType,
            'project_description': projectDescription,
            'contractor_name': contractorName,
            'contractor_contact': contractorContact,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'estimated_workers': estimatedWorkers,
            'status': 'pending',
            'payment_status': 'unpaid',
          })
          .select()
          .single();

      return ApiResult.success(PermitResult(
        permitId: data['id'],
        permitReference: 'PERMIT-${data['id'].toString().substring(0, 8)}',
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
```

### 6. Setup Push Notifications

```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request permission (iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Get FCM token and save to Supabase
    final token = await _fcm.getToken();
    await _saveFCMToken(token!);

    // 3. Initialize local notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(initializationSettings);

    // 4. Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _saveFCMToken(String token) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('user_fcm_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] as String?;

    switch (type) {
      case 'sticker_approval':
        // Navigate to sticker details
        break;
      case 'guest_verification':
        // Navigate to guest management
        break;
      case 'announcement':
        // Navigate to announcements
        break;
    }
  }
}
```

---

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Coverage
flutter test --coverage
```

---

## 🔐 Security Best Practices

### 1. Always Use auth.currentUser
```dart
final userId = supabase.auth.currentUser!.id;
// Not session-based auth
```

### 2. Validate Household Scope
```dart
Future<String> _getHouseholdId() async {
  final userId = supabase.auth.currentUser!.id;
  final data = await supabase
      .from('households')
      .select('id')
      .eq('household_head_id', userId)
      .single();
  return data['id'];
}
```

### 3. Use Signed URLs for Photos
```dart
final signedUrl = await supabase.storage
    .from('user-photos')
    .createSignedUrl(path, 86400); // 24-hour expiration
```

---

## 🚨 Troubleshooting

### RLS Policies Blocking
**Issue**: Cannot read/write household data

**Solution**:
1. Verify user role in JWT: `user.appMetadata['role']`
2. Check household_head_id matches current user
3. Use Supabase dashboard to test RLS policies

### Photo Upload Failing
**Issue**: Upload times out or fails

**Solution**:
1. Check image is compressed (< 5MB)
2. Verify Storage bucket exists and RLS allows INSERT
3. Check tenant_id matches in folder path

### Push Notifications Not Received
**Issue**: Notifications not arriving

**Solution**:
1. Check FCM token is saved in `user_fcm_tokens`
2. Verify Firebase project configuration
3. Test with Firebase Console test notification
4. Check notification permissions are granted

---

## 📚 Additional Resources

- [Feature Specification](./spec.md)
- [Data Model](./data-model.md)
- [API Contracts](./contracts/README.md)
- [Research Findings](./research.md)

---

## 🎯 Next Steps

1. ✅ Complete Phase 0 research (DONE)
2. ✅ Complete Phase 1 design artifacts (DONE)
3. ⏳ Phase 2: Generate tasks.md via `/speckit.tasks` command
4. ⏳ Implement household member management (Priority P1)
5. ⏳ Implement vehicle sticker requests (Priority P1)

---

**Last Updated**: 2025-10-10
**Version**: 1.0.0
**Maintained By**: Residence App Team
