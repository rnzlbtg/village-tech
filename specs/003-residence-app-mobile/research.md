# Research Findings: Residence App - Household Management Mobile Application

**Feature**: Residence App - Household Management Mobile Application
**Date**: 2025-10-10
**Research Phase**: Phase 0 (Technical Discovery)

---

## Research Questions

Based on Constitution Check and spec requirements, the following technical unknowns need resolution:

1. **Photo Upload Strategy**: How to efficiently upload photos for beneficial user ID verification with compression and offline support?
2. **Offline Caching**: How to cache household data for offline viewing when network is unavailable?
3. **Photo Security**: How to securely store and access user-uploaded photos with tenant isolation?
4. **Push Notifications**: How to implement push notifications for sticker approvals and announcements?

---

## 1. Photo Upload Strategy for Beneficial User ID Verification

### Decision

Use **Supabase Storage** for photo uploads with client-side image compression via **flutter_image_compress** package.

### Rationale

- Supabase Storage provides secure, scalable file storage with RLS policies
- Client-side compression reduces upload time and bandwidth usage on mobile networks
- flutter_image_compress supports iOS and Android with native performance
- Signed upload URLs prevent direct public access while allowing authenticated uploads

### Implementation Pattern

```dart
// lib/services/photo_upload_service.dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadBeneficialUserPhoto({
    required String userId,
    required File photoFile,
  }) async {
    // 1. Compress image (reduce to max 1MB, 1920x1080 resolution)
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      photoFile.absolute.path,
      '${photoFile.absolute.path}_compressed.jpg',
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
    );

    // 2. Upload to Supabase Storage
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '${_getTenantId()}/beneficial-users/$fileName';

    await _supabase.storage
        .from('user-photos')
        .upload(path, compressedFile!);

    // 3. Get signed URL (valid for 24 hours for verification)
    final signedUrl = await _supabase.storage
        .from('user-photos')
        .createSignedUrl(path, 86400);

    return signedUrl;
  }

  String _getTenantId() {
    final user = _supabase.auth.currentUser;
    return user?.appMetadata['tenant_id'] as String;
  }
}
```

### Offline Handling

- Queue photo uploads in local database (Hive)
- Retry uploads when connectivity is restored
- Show upload progress and retry status in UI

### Storage Bucket Configuration

```sql
-- Supabase Storage: user-photos bucket
CREATE POLICY "Household heads can upload photos for their tenant"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text
);

CREATE POLICY "Admins and household heads can view photos for their tenant"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text
);
```

---

## 2. Offline Caching Strategy for Household Data

### Decision

Use **Hive** for lightweight key-value caching of household member lists, sticker allocations, and guest schedules.

### Rationale

- Hive is fast, lightweight, and works on all Flutter platforms (iOS, Android, Web)
- No schema migrations required (unlike Drift/SQLite)
- Supports automatic encryption with AES-256 (secure storage for sensitive data)
- Works offline-first by default
- Minimal boilerplate compared to SQLite

### Implementation Pattern

```dart
// lib/services/offline_cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  static const String householdBox = 'household_data';
  static const String stickersBox = 'sticker_data';
  static const String guestsBox = 'guest_data';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(householdBox);
    await Hive.openBox(stickersBox);
    await Hive.openBox(guestsBox);
  }

  // Cache household members
  Future<void> cacheHouseholdMembers(List<HouseholdMember> members) async {
    final box = Hive.box(householdBox);
    await box.put('members', members.map((m) => m.toJson()).toList());
  }

  List<HouseholdMember>? getCachedHouseholdMembers() {
    final box = Hive.box(householdBox);
    final data = box.get('members') as List?;
    return data?.map((json) => HouseholdMember.fromJson(json)).toList();
  }

  // Cache sticker allocation
  Future<void> cacheStickerAllocation(int available, int used, int total) async {
    final box = Hive.box(stickersBox);
    await box.put('allocation', {
      'available': available,
      'used': used,
      'total': total,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }

  // Cache guest list
  Future<void> cacheGuestList(List<Guest> guests) async {
    final box = Hive.box(guestsBox);
    await box.put('guests', guests.map((g) => g.toJson()).toList());
  }
}
```

### Sync Strategy

1. On app launch: Load cached data immediately for instant UI rendering
2. Background: Fetch fresh data from Supabase and update cache
3. On network restore: Sync local changes (queued operations) to backend

### Cache Invalidation

- Invalidate cache after 1 hour for household data
- Invalidate guest cache after 15 minutes (guests are time-sensitive)
- Clear all cache on logout

---

## 3. Photo Security and Access Control

### Decision

Use **Supabase Storage RLS policies** with **signed URLs** (24-hour expiration) for secure photo access.

### Rationale

- RLS policies ensure tenant-scoped isolation (households can only access their tenant's photos)
- Signed URLs prevent unauthorized access to photos
- Short expiration (24 hours) minimizes security risk if URL is leaked
- Admin can view photos for verification without public exposure

### Security Architecture

**Storage Bucket**: `user-photos`
**Folder Structure**: `{tenant_id}/beneficial-users/{user_id}_{timestamp}.jpg`

**RLS Policies**:

```sql
-- Policy 1: Household heads can upload photos
CREATE POLICY "Household heads upload photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text AND
  (auth.jwt() ->> 'role')::text = 'household_head'
);

-- Policy 2: Admins and household heads can view photos
CREATE POLICY "Admins and household heads view photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text AND
  (auth.jwt() ->> 'role')::text IN ('admin_head', 'admin_officer', 'household_head')
);

-- Policy 3: Only household head who uploaded can delete
CREATE POLICY "Household heads delete own photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text AND
  (auth.jwt() ->> 'role')::text = 'household_head'
);
```

### Signed URL Generation

```dart
// Generate signed URL with 24-hour expiration
final signedUrl = await supabase.storage
    .from('user-photos')
    .createSignedUrl(photoPath, 86400); // 24 hours = 86400 seconds
```

### Privacy Considerations

- Photos are stored with UUIDs, not PII in file names
- Signed URLs expire after 24 hours
- No public access to photos (all access requires authentication)
- Admins can audit photo access via Storage logs

---

## 4. Push Notifications Implementation

### Decision

Use **Firebase Cloud Messaging (FCM)** via **firebase_messaging** package for push notifications.

### Rationale

- FCM is the de facto standard for Flutter push notifications
- Works reliably on both iOS and Android
- Integrates with Supabase via Edge Functions
- Supports notification channels (Android) and critical alerts (iOS)
- Free tier supports unlimited notifications

### Implementation Pattern

**Step 1: Initialize FCM in Flutter app**

```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token and save to Supabase
    final token = await _fcm.getToken();
    await _saveFCMToken(token!);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background notifications
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
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
    // Show local notification when app is in foreground
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle notification when app is in background
  print('Background notification: ${message.notification?.title}');
}
```

**Step 2: Create database table for FCM tokens**

```sql
-- Store FCM tokens per user
CREATE TABLE user_fcm_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fcm_token text NOT NULL,
  platform text NOT NULL, -- 'ios' or 'android'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, platform)
);

CREATE INDEX idx_user_fcm_tokens_user ON user_fcm_tokens(user_id);
```

**Step 3: Create Supabase Edge Function to send notifications**

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { userId, title, body, data } = await req.json()

  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Get FCM token for user
  const { data: tokens } = await supabaseAdmin
    .from('user_fcm_tokens')
    .select('fcm_token')
    .eq('user_id', userId)

  // Send FCM notification
  const fcmUrl = 'https://fcm.googleapis.com/fcm/send'
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')!

  for (const token of tokens || []) {
    await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: token.fcm_token,
        notification: { title, body },
        data: data || {},
      }),
    })
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

**Step 4: Trigger notifications on database events**

```sql
-- Trigger notification when sticker request is approved
CREATE OR REPLACE FUNCTION notify_sticker_approved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    -- Call Edge Function to send notification
    PERFORM net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/send-notification',
      headers := jsonb_build_object('Authorization', 'Bearer ' || current_setting('request.jwt.claim.token')),
      body := jsonb_build_object(
        'userId', (SELECT household_head_id FROM households WHERE id = NEW.household_id),
        'title', 'Sticker Request Approved',
        'body', 'Your vehicle sticker request has been approved. Please collect at admin office.',
        'data', jsonb_build_object('requestId', NEW.id, 'type', 'sticker_approval')
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_sticker_approved
AFTER UPDATE ON sticker_requests
FOR EACH ROW
EXECUTE FUNCTION notify_sticker_approved();
```

### Notification Channels

- **Sticker Approvals**: High priority (shows banner even when app is in background)
- **Guest Verifications**: Critical (requires immediate action)
- **Announcements**: Normal priority
- **Construction Permits**: Normal priority

### Testing Strategy

1. Use Firebase Console to send test notifications
2. Test foreground, background, and terminated app states
3. Verify notifications arrive within 2 minutes (SC-008)
4. Test notification actions (tap to open app, deep link to relevant screen)

---

## Architecture Decisions Summary

| Concern | Technology | Rationale |
|---------|-----------|-----------|
| Photo Upload | Supabase Storage + flutter_image_compress | Client-side compression, secure storage with RLS |
| Offline Caching | Hive | Lightweight, no migrations, works offline-first |
| Photo Security | Storage RLS + Signed URLs (24h expiration) | Tenant-scoped isolation, time-limited access |
| Push Notifications | FCM (firebase_messaging) | Industry standard, reliable delivery, free tier |

---

## Next Steps

1. ✅ Research complete
2. ⏳ Create data-model.md with household_members, beneficial_users, sticker_requests, pre_registered_guests
3. ⏳ Create contracts/ with Server Actions for household management, beneficial user management, sticker requests, guest scheduling
4. ⏳ Create quickstart.md with Flutter development setup and workflows

---

**Research Version**: 1.0.0
**Reviewed By**: AI Planning Agent
**Approved For**: Implementation Planning (Phase 1)
