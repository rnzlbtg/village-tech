# Implementation Plan: Residence App - Household Management Mobile Application

**Branch**: `003-residence-app-mobile` | **Date**: 2025-10-10 | **Spec**: [spec.md](spec.md)

## Summary

Mobile application for household heads to manage household members, beneficial users (non-residents with access privileges), vehicle gate pass sticker requests, guest scheduling, construction permit applications, and communication with admin officers. The app must support offline caching for household data, photo uploads for beneficial user verification, and push notifications for sticker approvals and announcements.

## Technical Context

**Language/Version**: Flutter 3.24+ / Dart 3
**Primary Dependencies**: supabase_flutter, riverpod, go_router, hive (offline cache), flutter_image_compress, firebase_messaging
**Storage**: Supabase PostgreSQL with RLS (household-scoped access), Supabase Storage (photo uploads), Hive (offline cache)
**Testing**: Flutter Test, Integration Test, Mockito
**Target Platform**: Mobile (iOS 13+, Android 7.0+)
**Project Type**: Mobile application (Flutter + Supabase)
**Performance Goals**: <1 min to add household member, <2 min to schedule guest, <5 sec sticker allocation check
**Constraints**: Household-scoped data access (RLS), photo upload with compression, offline caching for household data, push notifications for approvals
**Scale/Scope**: Per-household app, 10-20 household members, 5-10 beneficial users, 20-50 active guests, ~12-15 screens

## Constitution Check

### Specification-Driven Workflow (NON-NEGOTIABLE)
- ✅ PASS: Feature spec exists with 6 user stories
- ✅ PASS: Functional requirements FR-001 through FR-030
- ✅ PASS: Success criteria SC-001 through SC-008

### Architecture
- ✅ PASS: Flutter frontend + Supabase backend
- ⚠️ RESEARCH NEEDED: Photo upload strategy for beneficial user ID verification
- ⚠️ RESEARCH NEEDED: Offline caching for household data
- ⚠️ RESEARCH NEEDED: Photo security and access control

### Security
- ✅ PASS: Household-scoped RLS policies
- ⚠️ RESEARCH NEEDED: Push notification implementation

**Gate Status**: ✅ CONDITIONALLY APPROVED - Proceed to research

---

## Research Summary

**Photo Upload Strategy**: Supabase Storage with client-side compression via flutter_image_compress, signed URLs with 24-hour expiration

**Offline Caching**: Hive for lightweight key-value caching of household members, sticker allocations, and guest schedules

**Photo Security**: Supabase Storage RLS policies with tenant-scoped isolation, signed URLs prevent unauthorized access

**Push Notifications**: Firebase Cloud Messaging (FCM) via firebase_messaging package, database triggers send notifications on sticker approvals

---

## Project Structure

```
apps/residence/                             # Flutter mobile app
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── household_member.dart
│   │   ├── beneficial_user.dart
│   │   ├── sticker_request.dart
│   │   ├── guest.dart
│   │   └── construction_permit.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── household_provider.dart
│   │   ├── sticker_provider.dart
│   │   ├── guest_provider.dart
│   │   └── notification_provider.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── offline_cache_service.dart
│   │   ├── photo_upload_service.dart
│   │   └── notification_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── household_members/
│   │   ├── beneficial_users/
│   │   ├── stickers/
│   │   ├── guests/
│   │   ├── permits/
│   │   └── announcements/
│   ├── widgets/
│   │   ├── shared/
│   │   └── forms/
│   └── utils/
│       ├── constants.dart
│       └── validators.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/
└── ios/

supabase/
├── migrations/
│   ├── 020_create_household_members.sql
│   ├── 021_create_beneficial_users.sql
│   ├── 022_create_sticker_requests.sql
│   ├── 023_create_pre_registered_guests.sql
│   └── 024_create_construction_permit_requests.sql
└── storage/
    └── user-photos/
```

**Structure Decision**: Flutter mobile app following clean architecture with Riverpod state management, offline-first data layer with Hive caching, and Supabase for backend.

---

## Key Entities (Data Model Summary)

1. **household_members** - Family members living in residence
2. **beneficial_users** - Non-residents with access privileges
3. **sticker_requests** - Vehicle sticker applications
4. **rfid_stickers** - Physical stickers assigned to vehicles
5. **pre_registered_guests** - Scheduled guest visits
6. **guest_logs** - Entry/exit records (read-only, created by Sentinel)
7. **construction_permit_requests** - Permit applications
8. **messages** - Communication with admin
9. **announcements** - Broadcast messages from admin
10. **user_fcm_tokens** - Push notification tokens
11. **village_rules** - Community rules (read-only)

---

## Constitution Re-check (Post-Design)

**Status**: ✅ FULLY APPROVED

- ✅ Photo upload strategy defined (Supabase Storage + compression)
- ✅ Offline caching defined (Hive)
- ✅ Photo security defined (Storage RLS + signed URLs)
- ✅ Push notifications defined (FCM + database triggers)
- ✅ All design artifacts complete

**Next Step**: Generate tasks.md via `/speckit.tasks`

---

**Artifacts Generated**:
- ✅ plan.md (this file)
- ✅ [research.md](./research.md) - Photo upload, offline caching, photo security, push notifications
- ✅ [data-model.md](./data-model.md) - 11 entities with RLS policies and state transitions
- ✅ [contracts/README.md](./contracts/README.md) - Supabase RPC contracts and direct queries
- ✅ [quickstart.md](./quickstart.md) - Developer setup guide with Flutter workflows

**Status**: ✅ Phase 0 and Phase 1 complete - Ready for `/speckit.tasks`
