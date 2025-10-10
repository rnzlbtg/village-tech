# API Contracts - Residence App Mobile

**Version**: 1.0.0
**Date**: 2025-10-10
**Architecture**: Flutter + Supabase Direct Client Access

---

## Overview

The Residence App uses **Supabase client direct access** for queries and **Supabase RPC functions** for complex mutations, following Flutter best practices with Riverpod state management.

---

## Supabase RPC Contracts

### 1. Household Member Management

#### `add_household_member(data: AddMemberInput): Promise<Result>`

**Input Schema**:
```dart
class AddMemberInput {
  final String fullName;
  final String relationship; // 'head', 'spouse', 'child', 'parent', 'other'
  final String? contactNumber;
  final String? email;
  final DateTime? birthDate;
}
```

**Process**:
1. Validate user is household head
2. Insert household_member record
3. Return member ID

**Authorization**: Household head only (for own household)

---

#### `update_household_member(memberId: uuid, data: UpdateMemberInput): Promise<Result>`

**Input Schema**:
```dart
class UpdateMemberInput {
  final String? fullName;
  final String? relationship;
  final String? contactNumber;
  final String? email;
  final DateTime? birthDate;
}
```

**Authorization**: Household head only (for own household members)

---

#### `remove_household_member(memberId: uuid): Promise<Result>`

**Process**:
1. Validate user is household head
2. Deactivate associated stickers
3. Delete member record

**Authorization**: Household head only (for own household members)

---

### 2. Beneficial User Management

#### `add_beneficial_user(data: AddBeneficialUserInput): Promise<Result>`

**Input Schema**:
```dart
class AddBeneficialUserInput {
  final String fullName;
  final String contactNumber;
  final String? email;
  final String relationship; // 'helper', 'family', 'friend'
  final String? idPhotoUrl; // Uploaded via Supabase Storage
}
```

**Process**:
1. Validate user is household head
2. Check sticker allocation limit (beneficial users count towards limit)
3. Insert beneficial_users record
4. Return user ID

**Authorization**: Household head only

---

#### `update_beneficial_user(userId: uuid, data: UpdateBeneficialUserInput): Promise<Result>`

**Input Schema**:
```dart
class UpdateBeneficialUserInput {
  final String? fullName;
  final String? contactNumber;
  final String? email;
  final String? relationship;
  final String? idPhotoUrl;
}
```

**Authorization**: Household head only (for own beneficial users)

---

#### `remove_beneficial_user(userId: uuid): Promise<Result>`

**Process**:
1. Validate user is household head
2. Deactivate status to 'inactive'
3. Deactivate associated stickers

**Authorization**: Household head only (for own beneficial users)

---

### 3. Sticker Request Management

#### `request_sticker(data: RequestStickerInput): Promise<Result>`

**Input Schema**:
```dart
class RequestStickerInput {
  final String ownerType; // 'household_member', 'beneficial_user'
  final String ownerId; // UUID of member or beneficial user
  final String vehiclePlate;
  final String? vehicleMake;
  final String? vehicleColor;
}
```

**Process**:
1. Validate user is household head
2. Check household hasn't exceeded sticker allocation
3. Create sticker_requests record with status 'pending'
4. Send notification to admin

**Output**:
```dart
class RequestStickerResult {
  final bool success;
  final String requestId;
  final int remainingAllocation;
}
```

**Authorization**: Household head only

---

#### `cancel_sticker_request(requestId: uuid): Promise<Result>`

**Process**:
1. Validate request is pending
2. Update status to 'cancelled'

**Authorization**: Household head only (for own requests)

---

### 4. Guest Scheduling

#### `schedule_guest(data: ScheduleGuestInput): Promise<Result>`

**Input Schema**:
```dart
class ScheduleGuestInput {
  final String guestName;
  final String? guestContact;
  final DateTime visitStart;
  final DateTime visitEnd;
  final String visitType; // 'day_trip', 'multi_day'
  final String? purpose;
  final String? vehiclePlate;
}
```

**Process**:
1. Validate user is household head
2. Validate visit_start < visit_end
3. Create pre_registered_guests record
4. Send guest list update to Sentinel App

**Authorization**: Household head only

---

#### `update_guest_schedule(guestId: uuid, data: UpdateGuestInput): Promise<Result>`

**Input Schema**:
```dart
class UpdateGuestInput {
  final String? guestName;
  final String? guestContact;
  final DateTime? visitStart;
  final DateTime? visitEnd;
  final String? visitType;
  final String? purpose;
  final String? vehiclePlate;
}
```

**Authorization**: Household head only (for own scheduled guests)

---

#### `cancel_guest_visit(guestId: uuid): Promise<Result>`

**Process**:
1. Validate guest is scheduled
2. Update status to 'cancelled'

**Authorization**: Household head only (for own scheduled guests)

---

### 5. Construction Permit Requests

#### `submit_construction_permit(data: SubmitPermitInput): Promise<Result>`

**Input Schema**:
```dart
class SubmitPermitInput {
  final String projectType; // 'renovation', 'construction', 'repair', 'landscaping'
  final String projectDescription;
  final String contractorName;
  final String contractorContact;
  final DateTime startDate;
  final DateTime endDate;
  final int estimatedWorkers;
}
```

**Process**:
1. Validate user is household head
2. Create construction_permit_requests record with status 'pending'
3. Notify admin for fee computation

**Output**:
```dart
class SubmitPermitResult {
  final bool success;
  final String permitId;
  final String permitReference;
}
```

**Authorization**: Household head only

---

#### `cancel_permit_request(permitId: uuid): Promise<Result>`

**Process**:
1. Validate permit is pending or fee_pending
2. Update status to 'cancelled'

**Authorization**: Household head only (for own permit requests)

---

### 6. Communication

#### `send_message_to_admin(data: SendMessageInput): Promise<Result>`

**Input Schema**:
```dart
class SendMessageInput {
  final String? subject;
  final String content;
}
```

**Process**:
1. Validate user is household head
2. Create messages record with type 'household_to_admin'
3. Send notification to admin officers

**Authorization**: Household head only

---

## Direct Supabase Queries (Flutter)

### Fetch Household Members
```dart
final members = await supabase
    .from('household_members')
    .select()
    .eq('household_id', householdId)
    .order('relationship', ascending: true);
```

### Fetch Beneficial Users
```dart
final beneficialUsers = await supabase
    .from('beneficial_users')
    .select()
    .eq('household_id', householdId)
    .eq('status', 'active')
    .order('full_name', ascending: true);
```

### Fetch Sticker Allocation
```dart
// Get total allocation from program
final program = await supabase
    .from('sticker_programs')
    .select('stickers_per_household')
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .single();

// Get used stickers
final used = await supabase
    .from('rfid_stickers')
    .select('*', const FetchOptions(count: CountOption.exact, head: true))
    .eq('household_id', householdId)
    .eq('status', 'active');

final allocation = StickerAllocation(
  total: program['stickers_per_household'],
  used: used.count ?? 0,
  available: program['stickers_per_household'] - (used.count ?? 0),
);
```

### Fetch Pending Sticker Requests
```dart
final requests = await supabase
    .from('sticker_requests')
    .select('''
      *,
      household_member:household_members(*),
      beneficial_user:beneficial_users(*)
    ''')
    .eq('household_id', householdId)
    .in_('status', ['pending', 'approved'])
    .order('requested_at', ascending: false);
```

### Fetch Scheduled Guests
```dart
final guests = await supabase
    .from('pre_registered_guests')
    .select()
    .eq('household_id', householdId)
    .gte('visit_end', DateTime.now().toIso8601String())
    .in_('status', ['scheduled', 'checked_in'])
    .order('visit_start', ascending: true);
```

### Fetch Construction Permits
```dart
final permits = await supabase
    .from('construction_permit_requests')
    .select('''
      *,
      payment_log:payment_logs(receipt_number, amount)
    ''')
    .eq('household_id', householdId)
    .order('created_at', ascending: false);
```

### Fetch Announcements
```dart
final announcements = await supabase
    .from('announcements')
    .select()
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .contains('target_audience', ['residents'])
    .lte('published_at', DateTime.now().toIso8601String())
    .order('published_at', ascending: false)
    .limit(20);
```

### Fetch Village Rules
```dart
final rules = await supabase
    .from('village_rules')
    .select()
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .order('rule_category', ascending: true);
```

---

## File Upload Endpoints

### Upload Beneficial User ID Photo
```dart
// lib/services/photo_upload_service.dart
Future<String> uploadBeneficialUserPhoto({
  required File photoFile,
  required String userId,
}) async {
  // 1. Compress image
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

  await supabase.storage
      .from('user-photos')
      .upload(path, compressedFile!);

  // 3. Get signed URL (24-hour expiration)
  final signedUrl = await supabase.storage
      .from('user-photos')
      .createSignedUrl(path, 86400);

  return signedUrl;
}
```

---

## Push Notification Handling

### Register FCM Token
```dart
// lib/services/notification_service.dart
Future<void> registerFCMToken() async {
  final token = await FirebaseMessaging.instance.getToken();

  await supabase.from('user_fcm_tokens').upsert({
    'user_id': supabase.auth.currentUser!.id,
    'fcm_token': token!,
    'platform': Platform.isIOS ? 'ios' : 'android',
    'updated_at': DateTime.now().toIso8601String(),
  });
}
```

### Handle Notification Tap
```dart
// lib/services/notification_service.dart
void handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  final type = data['type'] as String?;

  switch (type) {
    case 'sticker_approval':
      // Navigate to sticker details
      context.go('/stickers/${data['requestId']}');
      break;
    case 'guest_verification':
      // Navigate to guest management
      context.go('/guests');
      break;
    case 'announcement':
      // Navigate to announcements
      context.go('/announcements/${data['announcementId']}');
      break;
    default:
      // Navigate to home
      context.go('/');
  }
}
```

---

## Error Handling

### Standard Error Response
```dart
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? code;

  ApiResult.success(this.data)
      : success = true,
        error = null,
        code = null;

  ApiResult.failure(this.error, {this.code})
      : success = false,
        data = null;
}
```

### Common Error Codes
- `UNAUTHORIZED`: Insufficient permissions
- `VALIDATION_ERROR`: Input validation failed
- `ALLOCATION_EXCEEDED`: Sticker allocation limit reached
- `NOT_FOUND`: Resource not found
- `ALREADY_EXISTS`: Duplicate entry

---

## Authorization Matrix

| Operation | Household Head | Admin | Guard |
|-----------|----------------|-------|-------|
| Add Household Member | ✅ (own) | ✅ (all) | ❌ |
| Update Household Member | ✅ (own) | ✅ (all) | ❌ |
| Remove Household Member | ✅ (own) | ✅ (all) | ❌ |
| Add Beneficial User | ✅ (own) | ✅ (all) | ❌ |
| Request Sticker | ✅ (own) | ❌ | ❌ |
| Schedule Guest | ✅ (own) | ❌ | ❌ |
| Submit Permit Request | ✅ (own) | ❌ | ❌ |
| Send Message to Admin | ✅ | ❌ | ❌ |
| View Announcements | ✅ | ✅ | ✅ |
| View Village Rules | ✅ | ✅ | ✅ |

---

## Realtime Subscriptions

### Subscribe to Sticker Request Updates
```dart
// lib/providers/sticker_provider.dart
final stickerSubscription = supabase
    .from('sticker_requests')
    .stream(primaryKey: ['id'])
    .eq('household_id', householdId)
    .listen((data) {
      // Update state when sticker request status changes
      ref.read(stickerRequestsProvider.notifier).updateRequests(data);
    });
```

### Subscribe to Announcements
```dart
// lib/providers/announcement_provider.dart
final announcementSubscription = supabase
    .from('announcements')
    .stream(primaryKey: ['id'])
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .contains('target_audience', ['residents'])
    .listen((data) {
      ref.read(announcementsProvider.notifier).updateAnnouncements(data);
    });
```

---

**Last Updated**: 2025-10-10
**Related Docs**: [data-model.md](../data-model.md), [quickstart.md](../quickstart.md)
