# Implementation Plan: Sentinel App - Gate Guard Access Control Mobile Application

**Branch**: `004-sentinel-app-mobile` | **Date**: 2025-10-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-sentinel-app-mobile/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Mobile Flutter application for gate guards to manage resident, guest, delivery, and construction worker entry with RFID verification, visitor logging, and incident reporting. Integrates with Supabase backend for real-time data validation and offline capability for basic operations.

## Technical Context

**Language/Version**: Flutter 3.24+ / Dart 3
**Primary Dependencies**: supabase_flutter, riverpod, go_router, hive (offline cache), flutter_nfc_kit (RFID), firebase_messaging
**Storage**: Supabase PostgreSQL with RLS (online), Hive (offline cache), Supabase Storage (incident photos)
**Testing**: Flutter Testing Framework (unit, widget, integration), Mockito
**Target Platform**: iOS 15+, Android 8+ (mobile)
**Project Type**: mobile - Flutter cross-platform application
**Performance Goals**: <5s RFID verification, <30s guest entry processing, support 50+ entries/hour
**Constraints**: <200MB app size, offline-capable for basic logging, secure auth with role-based access
**Scale/Scope**: Single community deployment, 10-50 gate guards, 1000+ entries/day

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security and Privacy Gates
✅ **PASS**: Uses Supabase Auth with JWT + role-based access control (guard_head, guard_officer)
✅ **PASS**: Row-Level Security (RLS) for tenant data isolation
✅ **PASS**: Secure defaults for authentication and data storage
✅ **PASS**: No logging of sensitive credentials or PII beyond necessary operational data

### Architecture Gates
✅ **PASS**: Modular layered architecture (UI → Application → Domain → Infrastructure)
✅ **PASS**: Clean architecture with Riverpod state management
✅ **PASS**: Clear boundaries between internal and external APIs
✅ **PASS**: Designed for scalability and testability

### Mobile (Flutter) Gates
✅ **PASS**: Flutter 3.24+ / Dart 3 with null safety
✅ **PASS**: Clean architecture with MVVM/BLoC pattern
✅ **PASS**: Cross-platform consistency (iOS 15+, Android 8+)
✅ **PASS**: Responsive layouts for various screen sizes
✅ **PASS**: State management with Riverpod
✅ **PASS**: Offline capability and graceful error handling
✅ **PASS**: Accessibility compliance (WCAG 2.1 AA minimum)
✅ **PASS**: Automated testing (unit, widget, integration)

### Performance Gates
✅ **PASS**: <5s RFID verification, <30s guest entry processing
✅ **PASS**: <200MB app size constraint
✅ **PASS**: Offline capability for basic operations
✅ **PASS**: Support for 50+ entries/hour without performance degradation

**RESULT**: ✅ ALL GATES PASSED - Proceed to Phase 0 Research

---
## Phase 1 Post-Design Constitution Check

### Additional Gates Passed
✅ **Data Model Security**: Comprehensive entity relationships with proper tenant isolation
✅ **API Design**: RESTful API with proper authentication and validation
✅ **Performance Requirements**: <5s RFID verification, offline capability confirmed
✅ **Scalability**: Multi-tenant architecture with proper indexing and partitioning
✅ **Audit Trail**: Complete entry logging with immutable audit requirements

**FINAL RESULT**: ✅ ALL CONSTITUTION GATES PASSED - Proceed to Phase 2 Implementation

## Project Structure

### Documentation (this feature)

```
specs/004-sentinel-app-mobile/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
apps/sentinel/                             # Flutter mobile app
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── guard.dart
│   │   ├── rfid_sticker.dart
│   │   ├── guest.dart
│   │   ├── entry_log.dart
│   │   ├── delivery.dart
│   │   ├── construction_permit.dart
│   │   ├── incident_report.dart
│   │   ├── village_rule.dart
│   │   └── announcement.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── rfid_provider.dart
│   │   ├── guest_provider.dart
│   │   ├── entry_provider.dart
│   │   ├── delivery_provider.dart
│   │   ├── construction_provider.dart
│   │   ├── incident_provider.dart
│   │   └── notification_provider.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── nfc_service.dart
│   │   ├── offline_cache_service.dart
│   │   ├── sync_service.dart
│   │   ├── biometric_service.dart
│   │   └── notification_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── rfid_scanning/
│   │   ├── guests/
│   │   ├── deliveries/
│   │   ├── construction/
│   │   ├── incidents/
│   │   ├── rules/
│   │   └── announcements/
│   ├── widgets/
│   │   ├── shared/
│   │   └── forms/
│   └── utils/
│       ├── constants.dart
│       ├── validators.dart
│       └── helpers.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/
└── ios/

supabase/
├── migrations/
│   ├── 030_create_guards.sql
│   ├── 031_create_rfid_stickers.sql
│   ├── 032_create_entry_logs.sql
│   ├── 033_create_guest_registrations.sql
│   ├── 034_create_delivery_logs.sql
│   ├── 035_create_construction_permits.sql
│   ├── 036_create_incident_reports.sql
│   ├── 037_create_village_rules.sql
│   ├── 038_create_announcements.sql
│   └── 039_create_sync_queue.sql
└── storage/
    └── incident-photos/
```

**Structure Decision**: Flutter mobile app following clean architecture with Riverpod state management, offline-first data layer with Hive caching, and Supabase for backend.

---

## Key Entities (Data Model Summary)

1. **guards** - Gate security personnel with authentication and roles
2. **rfid_stickers** - Vehicle RFID stickers for resident access
3. **entry_logs** - Complete audit trail of all gate entries/exits
4. **guest_registrations** - Pre-registered guest scheduling and management
5. **delivery_logs** - Delivery tracking with timer management
6. **construction_permits** - Construction project authorization and worker tracking
7. **incident_reports** - Security incidents and rule violation documentation
8. **village_rules** - Community guidelines and guard enforcement policies
9. **announcements** - Admin communications and guard notifications
10. **sync_queue** - Offline operations for background synchronization
11. **guard_sessions** - Authentication session management

---

## Constitution Re-check (Post-Design)

**Status**: ✅ FULLY APPROVED

- ✅ RFID verification strategy defined (flutter_nfc_kit + embedded NFC)
- ✅ Offline capability defined (Hive + sync queue + conflict resolution)
- ✅ Security framework defined (multi-layer authentication + RLS)
- ✅ Background sync defined (hybrid service + priority queues)
- ✅ All design artifacts complete

**Next Step**: Generate tasks.md via `/speckit.tasks`

---

**Artifacts Generated**:
- ✅ plan.md (this file)
- ✅ [research.md](./research.md) - RFID integration, offline architecture, background sync, security practices
- ✅ [data-model.md](./data-model.md) - 10 core entities with RLS policies and relationships
- ✅ [contracts/openapi.yaml](./contracts/openapi.yaml) - RESTful API specifications with authentication
- ✅ [quickstart.md](./quickstart.md) - Developer setup guide with Flutter workflows

**Status**: ✅ Phase 0 and Phase 1 complete - Ready for `/speckit.tasks`

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
