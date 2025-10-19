# Implementation Tasks: Sentinel App - Gate Guard Access Control Mobile Application

**Feature Branch**: `004-sentinel-app-mobile`
**Total Tasks**: 78
**Estimated Duration**: 6-8 weeks
**Last Updated**: 2025-10-19

**Based on**: [spec.md](./spec.md), [plan.md](./plan.md), [data-model.md](./data-model.md), [research.md](./research.md), [contracts/openapi.yaml](./contracts/openapi.yaml)

---

## Task Execution Strategy

### Independent Test Criteria per User Story

1. **US1 (RFID Resident Entry)**: Scan RFID → verify status → grant/deny entry in <5s
2. **US2 (Guest Management)**: Search guest → verify identity → log entry in <30s
3. **US3 (Delivery Tracking)**: Log delivery → start timer → track duration
4. **US4 (Construction Access)**: Verify permit → check worker → log entry
5. **US5 (Incident Reporting)**: Create incident → send dispatch → receive acknowledgment
6. **US6 (Rules & Announcements)**: View rules → read announcements → get notifications

### Parallel Execution Examples

```bash
# Phase 3 - User Story 1 (RFID Verification)
flutter run lib/tasks/T005_models_rfid_sticker.dart &     # [P]
flutter run lib/tasks/T006_models_guard.dart &            # [P]
flutter run lib/tasks/T007_services_nfc.dart &            # [P]
flutter run lib/tasks/T008_services_supabase.dart &       # [P]
wait  # All complete, proceed to integration
```

---

## Phase 1: Setup & Infrastructure (T001-T004)

### T001: Initialize Flutter Project Structure
**File**: `apps/sentinel/`
**Priority**: High
**Estimated**: 2 hours

```bash
# Create Flutter project structure
flutter create apps/sentinel --org com.villagetech
cd apps/sentinel

# Configure pubspec.yaml with required dependencies
# Update main.dart with basic app structure
# Set up Android and iOS configurations
```

### T002: Configure Dependencies & Environment
**File**: `apps/sentinel/pubspec.yaml`, `.env.local`
**Priority**: High
**Estimated**: 1 hour

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_riverpod: ^2.4.0
  go_router: ^12.1.0
  flutter_nfc_kit: ^4.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  connectable_plus: ^5.0.0
  local_auth: ^2.1.0
  firebase_messaging: ^14.7.0
  image_picker: ^1.0.0
```

### T003: Setup Supabase Database Schema
**File**: `supabase/migrations/030_create_guards.sql` (and others)
**Priority**: High
**Estimated**: 3 hours

```sql
-- Migration 030: Create guards table
CREATE TABLE guards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('head_guard', 'guard_officer', 'guard_trainee')),
  phone TEXT,
  employee_id TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Additional migrations for all entities (031-039)
```

### T004: Configure Authentication & Security
**File**: `apps/sentinel/lib/services/auth_service.dart`, `lib/providers/auth_provider.dart`
**Priority**: High
**Estimated**: 4 hours

```dart
// Implement multi-layer authentication
// Setup biometric authentication
// Configure JWT token management
// Implement session timeout and auto-logout
// Setup role-based access control
```

---

## Phase 2: Foundational Infrastructure (T005-T012)

*These tasks must complete before any user story implementation*

### T005: Core Data Models - Guard & RFID
**File**: `apps/sentinel/lib/models/guard.dart`, `lib/models/rfid_sticker.dart`
**Priority**: Critical
**Estimated**: 3 hours
**[Story]**: Foundation for all user stories
**[P]**: Can be done in parallel with T006

```dart
// Implement Guard model with authentication properties
// Implement RfidSticker model with validation
// Add JSON serialization/deserialization
// Add validation methods
// Add database mapping (Drift)
```

### T006: Core Data Models - Entry Log & Session
**File**: `apps/sentinel/lib/models/entry_log.dart`, `lib/models/guard_session.dart`
**Priority**: Critical
**Estimated**: 3 hours
**[Story]**: Foundation for all user stories
**[P]**: Can be done in parallel with T005

```dart
// Implement EntryLog model for comprehensive audit trail
// Implement GuardSession model for authentication management
// Add timestamp and duration calculations
// Add sync status tracking
// Add database mapping (Drift)
```

### T007: NFC Service Integration
**File**: `apps/sentinel/lib/services/nfc_service.dart`
**Priority**: Critical
**Estimated**: 4 hours
**[Story]**: Foundation for US1, US4
**[P]**: Can be done in parallel with T005, T006

```dart
// Implement flutter_nfc_kit integration
// Add RFID scanning functionality
// Implement error handling for scan failures
// Add timeout and retry mechanisms
// Add scan result validation
```

### T008: Supabase Service Layer
**File**: `apps/sentinel/lib/services/supabase_service.dart`
**Priority**: Critical
**Estimated**: 4 hours
**[Story]**: Foundation for all user stories
**[P]**: Can be done in parallel with T005, T006, T007

```dart
// Implement Supabase client configuration
// Add authentication methods
// Add CRUD operations for all entities
// Implement RLS policy handling
// Add error handling and retry logic
```

### T009: Offline Cache Service
**File**: `apps/sentinel/lib/services/offline_cache_service.dart`
**Priority**: Critical
**Estimated**: 5 hours
**[Story]**: Foundation for all user stories
**[P]**: Can be done in parallel with T007, T008

```dart
// Implement Hive local database
// Add cache invalidation strategies
// Implement optimistic UI updates
// Add data synchronization logic
// Add conflict resolution framework
```

### T010: Sync Service & Queue Management
**File**: `apps/sentinel/lib/services/sync_service.dart`, `lib/models/sync_queue.dart`
**Priority**: Critical
**Estimated**: 4 hours
**[Story]**: Foundation for all user stories
**[P]**: Can be done in parallel with T009

```dart
// Implement sync queue management
// Add priority-based operation processing
// Implement retry mechanisms with exponential backoff
// Add conflict detection and resolution
// Add batch processing capabilities
```

### T011: Navigation & Routing Setup
**File**: `apps/sentinel/lib/app.dart`, `lib/utils/router.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: Foundation for all user stories

```dart
// Implement GoRouter configuration
// Add route definitions for all screens
// Implement authentication guards
// Add nested routing for complex flows
// Add error handling for navigation
```

### T012: Base UI Components & Theming
**File**: `apps/sentinel/lib/shared/theme/app_theme.dart`, `lib/widgets/shared/`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: Foundation for all user stories

```dart
// Implement app theme with design tokens
// Create shared UI components (buttons, forms, cards)
// Add responsive layout utilities
// Implement loading states and error handling
// Add accessibility features
```

---

## Phase 3: User Story 1 - RFID Resident Entry (T013-T022)

**Goal**: Gate guard scans RFID stickers, validates status, and grants/denies resident entry
**Priority**: P1 (Critical)
**Independent Test**: Scan RFID → validate status → grant/deny entry in <5 seconds

### T013: [Story US1] RFID Scanning Screen
**File**: `apps/sentinel/lib/screens/rfid_scanning/rfid_scan_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Implement RFID scanning interface
// Add scan progress indicators
// Display scan results and resident information
// Add manual verification fallback
// Implement error handling for scan failures
```

### T014: [Story US1] RFID Provider - State Management
**File**: `apps/sentinel/lib/providers/rfid_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Implement Riverpod provider for RFID state
// Add scan result handling
// Implement offline-first caching
// Add real-time status updates
// Add error state management
```

### T015: [Story US1] Entry Logging Service
**File**: `apps/sentinel/lib/services/entry_service.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Implement entry log creation
// Add RFID sticker validation
// Implement resident information lookup
// Add entry/duration tracking
// Add sync queue integration
```

### T016: [Story US1] Resident Information Display
**File**: `apps/sentinel/lib/widgets/forms/resident_info_card.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US1 - RFID Resident Entry
**[P]**: Can be done in parallel with T013, T014, T015

```dart
// Create resident information display widget
// Add vehicle and sticker details
// Implement entry history view
// Add photo display capabilities
// Implement responsive design
```

### T017: [Story US1] Entry Decision UI
**File**: `apps/sentinel/lib/widgets/forms/entry_decision_dialog.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US1 - RFID Resident Entry
**[P]**: Can be done in parallel with T013, T014, T015

```dart
// Implement entry approval/denial interface
// Add reason selection for denials
// Add notes and documentation fields
// Implement confirmation dialogs
// Add accessibility features
```

### T018: [Story US1] Manual Verification Flow
**File**: `apps/sentinel/lib/screens/rfid_scanning/manual_verification_screen.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Implement manual resident verification
// Add search by name/phone/address
// Implement ID verification workflow
// Add photo capture for verification
// Implement approval workflow
```

### T019: [Story US1] RFID Performance Monitoring
**File**: `apps/sentinel/lib/services/performance_monitor.dart`
**Priority**: Low
**Estimated**: 2 hours
**[Story]**: US1 - RFID Resident Entry
**[P]**: Can be done in parallel with T016, T017

```dart
// Implement scan time tracking
// Add success rate monitoring
// Implement performance analytics
// Add alert system for degraded performance
// Add reporting dashboard
```

### T020: [Story US1] RFID Error Handling
**File**: `apps/sentinel/lib/services/rfid_error_handler.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US1 - RFID Resident Entry
**[P]**: Can be done in parallel with T016, T017

```dart
// Implement comprehensive error handling
// Add troubleshooting guidance
// Implement fallback procedures
// Add error logging and reporting
// Add user-friendly error messages
```

### T021: [Story US1] Integration Tests - RFID Flow
**File**: `apps/sentinel/test/integration/rfid_flow_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Test complete RFID scanning flow
// Test entry logging and validation
// Test offline capabilities
// Test error scenarios
// Test performance requirements (<5s)
```

### T022: [Story US1] User Acceptance Testing
**File**: `apps/sentinel/test/widget/rfid_uat_test.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US1 - RFID Resident Entry

```dart
// Test user acceptance scenarios
// Test scan success/failure flows
// Test resident information display
// Test entry decision workflow
// Test manual verification fallback
```

**🏁 CHECKPOINT: User Story 1 Complete - Guard can scan RFID and process resident entries**

---

## Phase 4: User Story 2 - Guest Management (T023-T032)

**Goal**: Guard checks pre-registered guests, verifies identity, and logs guest entries
**Priority**: P1 (Critical)
**Independent Test**: Search guest → verify identity → log entry in <30 seconds

### T023: [Story US2] Guest Model & Data Structure
**File**: `apps/sentinel/lib/models/guest.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T024, T025

```dart
// Implement Guest model with validation
// Add scheduled visit tracking
// Implement check-in/check-out status
// Add household association
// Add database mapping (Drift)
```

### T024: [Story US2] Guest Registration Screen
**File**: `apps/sentinel/lib/screens/guests/guest_registration_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T023, T025

```dart
// Implement guest registration interface
// Add form validation and error handling
// Implement household selection
// Add scheduled date/time selection
// Add photo capture for guest verification
```

### T025: [Story US2] Guest List & Search
**File**: `apps/sentinel/lib/screens/guests/guest_list_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T023, T024

```dart
// Implement today's guest list display
// Add search by name/household
// Implement filtering by status
// Add real-time updates
// Implement offline search capabilities
```

### T026: [Story US2] Guest Provider - State Management
**File**: `apps/sentinel/lib/providers/guest_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management

```dart
// Implement Riverpod provider for guest state
// Add search and filtering logic
// Implement real-time guest updates
// Add offline caching and sync
// Add error state management
```

### T027: [Story US2] Guest Check-in/Check-out Flow
**File**: `apps/sentinel/lib/screens/guests/guest_checkin_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management

```dart
// Implement guest verification interface
// Add check-in/check-out functionality
// Implement photo verification
// Add notes and special instructions
// Add household contact integration
```

### T028: [Story US2] Household Contact Integration
**File**: `apps/sentinel/lib/services/household_contact_service.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T029, T030

```dart
// Implement household head contact system
// Add phone call integration
// Implement approval recording
// Add SMS notification capabilities
// Add contact history tracking
```

### T029: [Story US2] Guest Verification Widgets
**File**: `apps/sentinel/lib/widgets/forms/guest_verification_form.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T028, T030

```dart
// Create guest verification form components
// Add identity verification fields
// Implement photo capture widget
// Add approval workflow components
// Implement responsive design
```

### T030: [Story US2] Unregistered Guest Workflow
**File**: `apps/sentinel/lib/screens/guests/unregistered_guest_screen.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management
**[P]**: Can be done in parallel with T028, T029

```dart
// Implement unregistered guest handling
// Add household contact workflow
// Implement approval/denial interface
// Add guest registration on-the-fly
// Add documentation and note-taking
```

### T031: [Story US2] Integration Tests - Guest Flow
**File**: `apps/sentinel/test/integration/guest_flow_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US2 - Guest Management

```dart
// Test complete guest management flow
// Test guest registration and check-in
// Test household contact integration
// Test offline capabilities
// Test performance requirements (<30s)
```

### T032: [Story US2] User Acceptance Testing
**File**: `apps/sentinel/test/widget/guest_uat_test.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US2 - Guest Management

```dart
// Test user acceptance scenarios
// Test pre-registered guest check-in
// Test unregistered guest handling
// Test household contact workflow
// Test guest history and reporting
```

**🏁 CHECKPOINT: User Story 2 Complete - Guard can manage guest entries and household verification**

---

## Phase 5: User Story 3 - Delivery Tracking (T033-T040)

**Goal**: Guard logs deliveries, tracks duration, and handles special instructions
**Priority**: P2 (Important)
**Independent Test**: Log delivery → start timer → track duration

### T033: [Story US3] Delivery Model & Timer System
**File**: `apps/sentinel/lib/models/delivery.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T034, T035

```dart
// Implement Delivery model with validation
// Add timer management system
// Implement perishable delivery tracking
// Add household association
// Add database mapping (Drift)
```

### T034: [Story US3] Delivery Logging Screen
**File**: `apps/sentinel/lib/screens/deliveries/delivery_log_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T033, T035

```dart
// Implement delivery logging interface
// Add delivery company selection
// Implement recipient address verification
// Add package type categorization
// Add special instructions handling
```

### T035: [Story US3] Delivery Timer & Alert System
**File**: `apps/sentinel/lib/services/delivery_timer_service.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T033, T034

```dart
// Implement delivery timer functionality
// Add duration-based alerts
// Implement perishable delivery priority
// Add guard notification system
// Add timer persistence across app sessions
```

### T036: [Story US3] Delivery Provider - State Management
**File**: `apps/sentinel/lib/providers/delivery_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US3 - Delivery Tracking

```dart
// Implement Riverpod provider for delivery state
// Add active delivery tracking
// Implement real-time timer updates
// Add offline delivery logging
// Add alert state management
```

### T037: [Story US3] Active Deliveries Dashboard
**File**: `apps/sentinel/lib/screens/deliveries/active_deliveries_screen.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T038, T039

```dart
// Implement active deliveries overview
// Add timer display and countdown
// Implement delivery status updates
// Add guard notification center
// Add delivery completion workflow
```

### T038: [Story US3] Delivery Verification Widgets
**File**: `apps/sentinel/lib/widgets/forms/delivery_verification_form.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T037, T039

```dart
// Create delivery verification form components
// Add recipient contact display
// Implement special instructions widget
// Add delivery completion confirmation
// Implement responsive design
```

### T039: [Story US3] Delivery History & Reporting
**File**: `apps/sentinel/lib/screens/deliveries/delivery_history_screen.dart`
**Priority**: Low
**Estimated**: 2 hours
**[Story]**: US3 - Delivery Tracking
**[P]**: Can be done in parallel with T037, T038

```dart
// Implement delivery history interface
// Add search and filtering capabilities
// Implement delivery analytics
// Add export functionality
// Add performance metrics
```

### T040: [Story US3] Integration Tests - Delivery Flow
**File**: `apps/sentinel/test/integration/delivery_flow_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US3 - Delivery Tracking

```dart
// Test complete delivery tracking flow
// Test timer functionality and alerts
// Test perishable delivery handling
// Test offline capabilities
// Test delivery completion workflow
```

**🏁 CHECKPOINT: User Story 3 Complete - Guard can log and track deliveries with timer management**

---

## Phase 6: User Story 4 - Construction Access (T041-T048)

**Goal**: Guard verifies construction permits, checks worker authorization, and tracks on-site workers
**Priority**: P2 (Important)
**Independent Test**: Verify permit → check worker → log entry

### T041: [Story US4] Construction Permit Model
**File**: `apps/sentinel/lib/models/construction_permit.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T042, T043

```dart
// Implement ConstructionPermit model with validation
// Add authorized worker list management
// Implement project duration tracking
// Add household association
// Add database mapping (Drift)
```

### T042: [Story US4] Permit Verification Screen
**File**: `apps/sentinel/lib/screens/construction/permit_verification_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T041, T043

```dart
// Implement permit verification interface
// Add permit reference lookup
// Implement worker authorization check
// Add permit status validation
// Add project information display
```

### T043: [Story US4] On-site Workers Tracking
**File**: `apps/sentinel/lib/screens/construction/onsite_workers_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T041, T042

```dart
// Implement on-site workers dashboard
// Add worker check-in/check-out tracking
// Implement real-time worker count
// Add permit expiry alerts
// Add worker search and filtering
```

### T044: [Story US4] Construction Provider - State Management
**File**: `apps/sentinel/lib/providers/construction_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US4 - Construction Access

```dart
// Implement Riverpod provider for construction state
// Add permit verification logic
// Implement worker tracking system
// Add real-time updates
// Add offline capability
```

### T045: [Story US4] Worker Entry/Exit Logging
**File**: `apps/sentinel/lib/screens/construction/worker_entry_screen.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T046, T047

```dart
// Implement worker entry/exit interface
// Add worker identity verification
// Implement time tracking for workers
// Add permit validation
// Add photo capture for verification
```

### T046: [Story US4] Permit Management Widgets
**File**: `apps/sentinel/lib/widgets/forms/permit_verification_form.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T045, T047

```dart
// Create permit verification form components
// Add worker authorization display
// Implement permit status indicators
// Add project information widgets
// Implement responsive design
```

### T047: [Story US4] Construction Analytics
**File**: `apps/sentinel/lib/screens/construction/construction_analytics_screen.dart`
**Priority**: Low
**Estimated**: 2 hours
**[Story]**: US4 - Construction Access
**[P]**: Can be done in parallel with T045, T046

```dart
// Implement construction analytics interface
// Add worker time tracking reports
// Implement permit utilization metrics
// Add project duration tracking
// Add export functionality
```

### T048: [Story US4] Integration Tests - Construction Flow
**File**: `apps/sentinel/test/integration/construction_flow_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US4 - Construction Access

```dart
// Test complete construction access flow
// Test permit verification and validation
// Test worker authorization checking
// Test on-site worker tracking
// Test permit expiry handling
```

**🏁 CHECKPOINT: User Story 4 Complete - Guard can verify permits and track construction workers**

---

## Phase 7: User Story 5 - Incident Reporting (T049-T056)

**Goal**: Guard reports incidents, communicates with dispatch, and tracks resolution
**Priority**: P3 (Nice-to-have)
**Independent Test**: Create incident → send dispatch → receive acknowledgment

### T049: [Story US5] Incident Report Model
**File**: `apps/sentinel/lib/models/incident_report.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T050, T051

```dart
// Implement IncidentReport model with validation
// Add incident categorization system
// Implement severity level management
// Add photo evidence support
// Add database mapping (Drift)
```

### T050: [Story US5] Incident Reporting Screen
**File**: `apps/sentinel/lib/screens/incidents/incident_report_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T049, T051

```dart
// Implement incident reporting interface
// Add incident type selection
// Implement severity level assignment
// Add photo capture and evidence upload
// Add location and description fields
```

### T051: [Story US5] Incident Communication System
**File**: `apps/sentinel/lib/services/incident_communication_service.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T049, T050

```dart
// Implement dispatch communication system
// Add real-time messaging
// Implement incident status updates
// Add notification system
// Add communication history tracking
```

### T052: [Story US5] Incident Provider - State Management
**File**: `apps/sentinel/lib/providers/incident_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting

```dart
// Implement Riverpod provider for incident state
// Add incident creation and management
// Implement real-time status updates
// Add offline incident logging
// Add photo upload and management
```

### T053: [Story US5] Active Incidents Dashboard
**File**: `apps/sentinel/lib/screens/incidents/active_incidents_screen.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T054, T055

```dart
// Implement active incidents overview
// Add real-time status updates
// Implement incident communication interface
// Add resolution workflow
// Add incident priority management
```

### T054: [Story US5] Photo Evidence System
**File**: `apps/sentinel/lib/services/photo_evidence_service.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T053, T055

```dart
// Implement photo capture and upload
// Add image compression and optimization
// Implement secure storage for evidence
// Add photo metadata management
// Add bulk photo operations
```

### T055: [Story US5] Incident Resolution Workflow
**File**: `apps/sentinel/lib/screens/incidents/incident_resolution_screen.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US5 - Incident Reporting
**[P]**: Can be done in parallel with T053, T054

```dart
// Implement incident resolution interface
// Add resolution notes and documentation
// Implement status change workflow
// Add final report generation
// Add closure verification
```

### T056: [Story US5] Integration Tests - Incident Flow
**File**: `apps/sentinel/test/integration/incident_flow_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US5 - Incident Reporting

```dart
// Test complete incident reporting flow
// Test incident communication system
// Test photo evidence handling
// Test offline capabilities
// Test incident resolution workflow
```

**🏁 CHECKPOINT: User Story 5 Complete - Guard can report incidents and communicate with dispatch**

---

## Phase 8: User Story 6 - Rules & Announcements (T057-T064)

**Goal**: Guard views village rules, curfew times, and admin announcements
**Priority**: P3 (Nice-to-have)
**Independent Test**: View rules → read announcements → get notifications

### T057: [Story US6] Village Rules Model
**File**: `apps/sentinel/lib/models/village_rule.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US6 - Rules & Announcements
**[P]**: Can be done in parallel with T058, T059

```dart
// Implement VillageRule model with validation
// Add rule categorization system
// Implement enforcement level management
// Add rule status tracking
// Add database mapping (Drift)
```

### T058: [Story US6] Announcement Model
**File**: `apps/sentinel/lib/models/announcement.dart`
**Priority**: High
**Estimated**: 2 hours
**[Story]**: US6 - Rules & Announcements
**[P]**: Can be done in parallel with T057, T059

```dart
// Implement Announcement model with validation
// Add priority level management
// Implement acknowledgment tracking
// Add targeting system
// Add database mapping (Drift)
```

### T059: [Story US6] Rules Display Screen
**File**: `apps/sentinel/lib/screens/rules/village_rules_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US6 - Rules & Announcements
**[P]**: Can be done in parallel with T057, T058

```dart
// Implement village rules interface
// Add rule categorization and filtering
// Implement search functionality
// Add curfew time display
// Add rule status indicators
```

### T060: [Story US6] Announcements Screen
**File**: `apps/sentinel/lib/screens/announcements/announcements_screen.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US6 - Rules & Announcements

```dart
// Implement announcements interface
// Add priority-based sorting
// Implement acknowledgment system
// Add unread indicator tracking
// Add announcement search
```

### T061: [Story US6] Notification Service
**File**: `apps/sentinel/lib/services/notification_service.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US6 - Rules & Announcements

```dart
// Implement push notification system
// Add announcement notification handling
// Implement notification prioritization
// Add notification history
// Add notification preferences
```

### T062: [Story US6] Rules & Announcements Provider
**File**: `apps/sentinel/lib/providers/notification_provider.dart`
**Priority**: High
**Estimated**: 3 hours
**[Story]**: US6 - Rules & Announcements

```dart
// Implement Riverpod provider for notifications
// Add real-time announcement updates
// Implement acknowledgment tracking
// Add offline caching
// Add notification state management
```

### T063: [Story US6] Curfew Management System
**File**: `apps/sentinel/lib/screens/rules/curfew_screen.dart`
**Priority**: Medium
**Estimated**: 2 hours
**[Story]**: US6 - Rules & Announcements
**[P]**: Can be done in parallel with T064

```dart
// Implement curfew time display
// Add curfew enforcement instructions
// Implement curfew alert system
// Add curfew history tracking
// Add curfew violation reporting
```

### T064: [Story US6] Integration Tests - Rules & Announcements
**File**: `apps/sentinel/test/integration/rules_announcements_test.dart`
**Priority**: Medium
**Estimated**: 3 hours
**[Story]**: US6 - Rules & Announcements

```dart
// Test rules display and search
// Test announcement notification system
// Test acknowledgment workflow
// Test offline capabilities
// Test curfew management
```

**🏁 CHECKPOINT: User Story 6 Complete - Guard can access rules and receive announcements**

---

## Phase 9: Polish & Cross-Cutting Concerns (T065-T078)

### T065: Performance Optimization
**File**: `apps/sentinel/lib/services/performance_optimizer.dart`
**Priority**: Medium
**Estimated**: 4 hours

```dart
// Implement app performance monitoring
// Add memory usage optimization
// Implement battery usage management
// Add startup time optimization
// Add network request optimization
```

### T066: Security Hardening
**File**: `apps/sentinel/lib/services/security_service.dart`
**Priority**: High
**Estimated**: 4 hours

```dart
// Implement certificate pinning
// Add request signing
// Implement biometric authentication
// Add session security
// Add data encryption
```

### T067: Accessibility Enhancements
**File**: `apps/sentinel/lib/services/accessibility_service.dart`
**Priority**: Medium
**Estimated**: 3 hours

```dart
// Implement screen reader support
// Add high contrast mode
// Implement font size scaling
// Add voice navigation
// Add accessibility testing
```

### T068: Error Handling & Logging
**File**: `apps/sentinel/lib/services/logging_service.dart`
**Priority**: High
**Estimated**: 3 hours

```dart
// Implement comprehensive error handling
// Add structured logging
// Implement crash reporting
// Add error analytics
// Add user feedback system
```

### T069: Data Backup & Recovery
**File**: `apps/sentinel/lib/services/backup_service.dart`
**Priority**: Medium
**Estimated**: 3 hours

```dart
// Implement data backup system
// Add automatic backup scheduling
// Implement data recovery
// Add backup verification
// Add backup encryption
```

### T070: Testing Suite Enhancement
**File**: `apps/sentinel/test/`
**Priority**: High
**Estimated**: 5 hours

```dart
// Enhance unit test coverage
// Add widget testing
// Implement integration testing
// Add performance testing
// Add security testing
```

### T071: Documentation & User Guides
**File**: `apps/sentinel/docs/`
**Priority**: Medium
**Estimated**: 3 hours

```dart
// Create user documentation
// Add API documentation
// Implement in-app help system
// Add troubleshooting guides
// Create training materials
```

### T072: Biometric Authentication Enhancement
**File**: `apps/sentinel/lib/services/biometric_service.dart`
**Priority**: High
**Estimated**: 3 hours

```dart
// Enhance biometric authentication
// Add multi-factor authentication
// Implement biometric fallbacks
// Add authentication analytics
// Add security monitoring
```

### T073: Offline Mode Optimization
**File**: `apps/sentinel/lib/services/offline_optimizer.dart`
**Priority**: High
**Estimated**: 4 hours

```dart
// Optimize offline performance
// Enhance sync reliability
// Implement conflict resolution
// Add offline analytics
// Optimize data usage
```

### T074: Dashboard & Analytics
**File**: `apps/sentinel/lib/screens/dashboard/dashboard_screen.dart`
**Priority**: Medium
**Estimated**: 4 hours

```dart
// Implement comprehensive dashboard
// Add real-time analytics
// Implement performance metrics
// Add usage statistics
// Add reporting capabilities
```

### T075: Multi-language Support
**File**: `apps/sentinel/lib/services/localization_service.dart`
**Priority**: Low
**Estimated**: 3 hours

```dart
// Implement internationalization
// Add language switching
// Implement translation management
// Add localized notifications
// Add cultural adaptation
```

### T076: App Deployment & Release
**File**: `apps/sentinel/`
**Priority**: High
**Estimated**: 4 hours

```bash
# Configure app signing
# Implement build automation
# Add deployment scripts
# Configure app store distribution
# Add version management
```

### T077: Final Integration Testing
**File**: `apps/sentinel/test/integration/`
**Priority**: High
**Estimated**: 4 hours

```dart
// Comprehensive integration testing
// End-to-end workflow testing
// Performance testing
// Security testing
// User acceptance testing
```

### T078: Production Monitoring & Analytics
**File**: `apps/sentinel/lib/services/monitoring_service.dart`
**Priority**: High
**Estimated**: 3 hours

```dart
// Implement production monitoring
// Add crash analytics
// Implement usage analytics
// Add performance monitoring
// Add security monitoring
```

**🏁 FINAL CHECKPOINT: All user stories complete and production-ready**

---

## Dependencies & Execution Order

### Prerequisites (Must Complete First)
1. **Phase 1** (T001-T004): Project setup and infrastructure
2. **Phase 2** (T005-T012): Foundational services and architecture

### User Story Execution Order
1. **User Story 1** (T013-T022): RFID Resident Entry - **MVP Priority**
2. **User Story 2** (T023-T032): Guest Management - **MVP Priority**
3. **User Story 3** (T033-T040): Delivery Tracking
4. **User Story 4** (T041-T048): Construction Access
5. **User Story 5** (T049-T056): Incident Reporting
6. **User Story 6** (T057-T064): Rules & Announcements

### Final Phase
7. **Phase 9** (T065-T078): Polish and cross-cutting concerns

### Story Dependencies
- **US1** (RFID): Independent - No dependencies on other stories
- **US2** (Guests): Independent - No dependencies on other stories
- **US3** (Deliveries): Independent - Can be implemented after US1/US2
- **US4** (Construction): Independent - Can be implemented after US1/US2
- **US5** (Incidents): Independent - Can be implemented anytime
- **US6** (Rules): Independent - Can be implemented anytime

### Parallel Development Opportunities
- **US1 and US2** can be developed in parallel after Phase 2
- **US3, US4, US5, US6** can be developed in any order
- **Within each story**: Multiple tasks marked with [P] can be parallelized

---

## Implementation Strategy

### MVP Scope (Suggested First Release)
**Duration**: 3-4 weeks
**Tasks**: T001-T032 (Phases 1-4)
**Features**:
- ✅ RFID scanning and resident entry verification
- ✅ Guest management and household verification
- ✅ Basic offline capability
- ✅ Authentication and security
- ✅ Core audit trail functionality

### Full Release Scope
**Duration**: 6-8 weeks
**Tasks**: T001-T078 (All phases)
**Features**:
- ✅ All 6 user stories complete
- ✅ Advanced offline synchronization
- ✅ Incident reporting and communication
- ✅ Analytics and reporting
- ✅ Production monitoring and optimization

### Risk Mitigation
1. **Technical Risks**: Regular testing and prototyping for RFID integration
2. **Performance Risks**: Continuous monitoring and optimization
3. **Security Risks**: Regular security audits and penetration testing
4. **User Adoption**: Regular user feedback and usability testing

### Success Metrics
- **RFID Verification**: <5 seconds per vehicle
- **Guest Processing**: <30 seconds per guest
- **Offline Reliability**: 99%+ sync success rate
- **User Satisfaction**: >90% positive feedback
- **System Uptime**: >99.5% availability

---

**Total Tasks**: 78
**Critical Path**: T001-T012 → T013-T022 → T023-T032 → T065-T078
**Estimated Duration**: 6-8 weeks
**Team Size**: 2-3 developers (1 Flutter dev, 1 backend dev, 1 QA)

**Ready for Implementation** ✅