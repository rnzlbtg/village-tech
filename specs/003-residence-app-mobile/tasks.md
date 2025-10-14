# Tasks: Residence App - Household Management Mobile Application

**Input**: Design documents from `/specs/003-residence-app-mobile/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tech Stack**: Flutter 3.24+/Dart 3, supabase_flutter, riverpod, go_router, hive, flutter_image_compress, firebase_messaging

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and basic structure

- [X] T001 Create Flutter project structure at apps/residence/ with standard directories (lib/, test/, android/, ios/)
- [X] T002 Initialize Flutter project with pubspec.yaml dependencies: supabase_flutter, riverpod, go_router, hive, flutter_image_compress, firebase_messaging
- [X] T003 [P] Configure Firebase for iOS (GoogleService-Info.plist in ios/Runner/)
- [X] T004 [P] Configure Firebase for Android (google-services.json in android/app/)
- [X] T005 [P] Configure linting and formatting with analysis_options.yaml
- [X] T006 [P] Create .env.example with SUPABASE_URL and SUPABASE_ANON_KEY placeholders

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T00 Create Supabase client singleton service in lib/services/supabase_service.dart with authentication state
- [X] T00 Implement authentication flow with email/password in lib/providers/auth_provider.dart using Riverpod
- [X] T00 Create offline cache service in lib/services/offline_cache_service.dart using Hive with three boxes (household_data, sticker_data, guest_data)
- [ ] T010 Initialize Firebase Cloud Messaging in lib/services/notification_service.dart with token registration and foreground/background handlers
- [ ] T011 Create photo upload service in lib/services/photo_upload_service.dart with flutter_image_compress and Supabase Storage integration
- [ ] T012 Setup go_router navigation with route definitions in lib/app.dart
- [ ] T013 [P] Create base ApiResult<T> class for error handling in lib/utils/api_result.dart
- [ ] T014 [P] Create form validators utility in lib/utils/validators.dart (email, phone, required fields)
- [ ] T015 [P] Create constants file in lib/utils/constants.dart with storage bucket names and cache keys
- [ ] T016 [P] Create shared loading widget in lib/widgets/shared/loading_widget.dart
- [ ] T017 [P] Create shared error widget in lib/widgets/shared/error_widget.dart
- [ ] T018 Create main entry point in lib/main.dart with Supabase initialization, Hive initialization, and FCM initialization

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Manage Household Members (Priority: P1) 🎯 MVP

**Goal**: Household head can add, update, remove household members and view household roster

**Independent Test**: Login as household head, add household member with name/contact, update member details, verify member appears in roster, remove member

### Implementation for User Story 1

- [ ] T019 [P] [US1] Create HouseholdMember model in lib/models/household_member.dart with fromJson/toJson serialization
- [ ] T020 [P] [US1] Create household service in lib/services/household_service.dart with addHouseholdMember, updateHouseholdMember, removeHouseholdMember, fetchHouseholdMembers methods
- [ ] T021 [US1] Create household provider in lib/providers/household_provider.dart using Riverpod StateNotifier with offline cache integration
- [ ] T022 [US1] Implement household members list screen in lib/screens/household_members/household_members_list_screen.dart with pull-to-refresh and offline indicator
- [ ] T023 [US1] Implement add household member form in lib/screens/household_members/add_household_member_screen.dart with name, relationship dropdown, contact, email, birth date fields
- [ ] T024 [US1] Implement edit household member form in lib/screens/household_members/edit_household_member_screen.dart reusing form widgets
- [ ] T025 [US1] Create household member card widget in lib/widgets/household_members/household_member_card.dart with edit/delete actions
- [ ] T026 [US1] Add validation for household member forms (required name, valid relationship)
- [ ] T027 [US1] Implement offline caching for household members list using Hive (cache on fetch, load from cache on startup)
- [ ] T028 [US1] Add remove household member confirmation dialog with cascade effect warning (stickers will be deactivated)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Request Vehicle Gate Pass Stickers (Priority: P1) 🎯 MVP

**Goal**: Household head can request stickers, receive approval notifications, and assign stickers to vehicles

**Independent Test**: Submit sticker request for household member vehicle, receive approval notification (simulate via database update), verify sticker is active for gate entry

### Implementation for User Story 2

- [ ] T029 [P] [US2] Create StickerRequest model in lib/models/sticker_request.dart with status enum (pending, approved, distributed, rejected)
- [ ] T030 [P] [US2] Create RfidSticker model in lib/models/rfid_sticker.dart with status enum (active, expired, lost, deactivated)
- [ ] T031 [P] [US2] Create StickerAllocation model in lib/models/sticker_allocation.dart with total, used, available fields
- [ ] T032 [US2] Create sticker service in lib/services/sticker_service.dart with requestSticker, checkAllocation, fetchPendingRequests, assignStickerToVehicle methods
- [ ] T033 [US2] Create sticker provider in lib/providers/sticker_provider.dart using Riverpod StateNotifier with Supabase realtime subscription for sticker_requests status changes
- [ ] T034 [US2] Implement sticker allocation dashboard screen in lib/screens/stickers/sticker_allocation_screen.dart showing total/used/available with circular progress indicator
- [ ] T035 [US2] Implement request sticker form in lib/screens/stickers/request_sticker_screen.dart with owner selection (household member or beneficial user), vehicle plate, make, color fields
- [ ] T036 [US2] Implement pending sticker requests list in lib/screens/stickers/pending_requests_screen.dart with status badges and approval timestamps
- [ ] T037 [US2] Implement sticker details screen in lib/screens/stickers/sticker_details_screen.dart showing request details, approval status, pickup instructions
- [ ] T038 [US2] Create sticker card widget in lib/widgets/stickers/sticker_card.dart with status badge and vehicle info
- [ ] T039 [US2] Add validation for sticker requests (check allocation before submission, prevent duplicate requests for same vehicle)
- [ ] T040 [US2] Implement offline caching for sticker allocation using Hive (cache allocation counts, display last cached timestamp)
- [ ] T041 [US2] Add push notification handler for sticker approval notifications (navigate to sticker details on tap)
- [ ] T042 [US2] Implement allocation limit exceeded error UI with clear messaging and suggestion to contact admin

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Manage Beneficial Users (Priority: P2)

**Goal**: Household head can add beneficial users (non-residents) with photo ID verification and manage their sticker assignments

**Independent Test**: Add beneficial user with contact details and photo ID, request sticker for their vehicle, verify sticker works at gate (simulate gate entry)

### Implementation for User Story 3

- [ ] T043 [P] [US3] Create BeneficialUser model in lib/models/beneficial_user.dart with status enum (active, inactive)
- [ ] T044 [US3] Create beneficial user service in lib/services/beneficial_user_service.dart with addBeneficialUser, updateBeneficialUser, removeBeneficialUser, uploadPhoto methods
- [ ] T045 [US3] Create beneficial user provider in lib/providers/beneficial_user_provider.dart using Riverpod StateNotifier
- [ ] T046 [US3] Implement beneficial users list screen in lib/screens/beneficial_users/beneficial_users_list_screen.dart with status filter (active/inactive)
- [ ] T047 [US3] Implement add beneficial user form in lib/screens/beneficial_users/add_beneficial_user_screen.dart with name, contact, email, relationship dropdown, photo capture/upload
- [ ] T048 [US3] Implement edit beneficial user form in lib/screens/beneficial_users/edit_beneficial_user_screen.dart with photo update capability
- [ ] T049 [US3] Create beneficial user card widget in lib/widgets/beneficial_users/beneficial_user_card.dart with photo thumbnail and edit/delete actions
- [ ] T050 [US3] Implement photo capture widget in lib/widgets/forms/photo_capture_widget.dart with camera and gallery options using image_picker
- [ ] T051 [US3] Integrate flutter_image_compress in photo upload service (compress to max 1MB, 1920x1080 resolution, quality 85)
- [ ] T052 [US3] Implement photo upload progress indicator with retry on failure
- [ ] T053 [US3] Add validation for beneficial user forms (required name, contact, relationship, photo upload optional but recommended)
- [ ] T054 [US3] Implement remove beneficial user with cascade confirmation (associated stickers will be deactivated)
- [ ] T055 [US3] Display beneficial user stickers in their detail view with sticker status and vehicle info

**Checkpoint**: All P1-P2 user stories should now be independently functional

---

## Phase 6: User Story 4 - Schedule Guest Visits (Priority: P2)

**Goal**: Household head can schedule guest visits with date/duration, pre-register guests for streamlined gate entry

**Independent Test**: Schedule guest visit with name and visit details, verify guest appears in pre-registered list, simulate gate entry verification

### Implementation for User Story 4

- [ ] T056 [P] [US4] Create Guest model in lib/models/guest.dart with visitType enum (day_trip, multi_day) and status enum (scheduled, checked_in, checked_out, cancelled)
- [ ] T057 [US4] Create guest service in lib/services/guest_service.dart with scheduleGuest, updateGuestSchedule, cancelGuestVisit, fetchScheduledGuests methods
- [ ] T058 [US4] Create guest provider in lib/providers/guest_provider.dart using Riverpod StateNotifier with auto-refresh for active guests
- [ ] T059 [US4] Implement scheduled guests list screen in lib/screens/guests/scheduled_guests_screen.dart with upcoming/active/past tabs
- [ ] T060 [US4] Implement schedule guest form in lib/screens/guests/schedule_guest_screen.dart with guest name, contact, visit start/end datetime pickers, visit type radio buttons, purpose, vehicle plate
- [ ] T061 [US4] Implement edit guest schedule form in lib/screens/guests/edit_guest_screen.dart with date/time updates
- [ ] T062 [US4] Implement guest details screen in lib/screens/guests/guest_details_screen.dart showing check-in/check-out status and visit duration
- [ ] T063 [US4] Create guest card widget in lib/widgets/guests/guest_card.dart with visit countdown timer for upcoming visits
- [ ] T064 [US4] Add validation for guest scheduling (visit_start < visit_end, start time not in past, max 30 days duration for multi_day)
- [ ] T065 [US4] Implement offline caching for scheduled guests using Hive (cache upcoming guests, sync when online)
- [ ] T066 [US4] Add push notification handler for guest verification requests from gate guards (navigate to guest approval screen)
- [ ] T067 [US4] Implement guest approval/denial screen for unregistered guests arriving at gate (quick approve/deny with reason)

**Checkpoint**: All P1-P2 user stories should work together seamlessly

---

## Phase 7: User Story 5 - Submit Construction Permit Requests (Priority: P3)

**Goal**: Household head can submit construction permit requests, receive fee notifications, pay fees, and receive approval

**Independent Test**: Submit permit request with project details, receive fee notification (simulate), verify permit approval flow

### Implementation for User Story 5

- [ ] T068 [P] [US5] Create ConstructionPermitRequest model in lib/models/construction_permit_request.dart with status enum (pending, fee_pending, approved, rejected, completed)
- [ ] T069 [P] [US5] Create PaymentLog model in lib/models/payment_log.dart with payment status and receipt info
- [ ] T070 [US5] Create permit service in lib/services/permit_service.dart with submitConstructionPermit, cancelPermitRequest, fetchPermitRequests methods
- [ ] T071 [US5] Create permit provider in lib/providers/permit_provider.dart using Riverpod StateNotifier
- [ ] T072 [US5] Implement construction permits list screen in lib/screens/permits/permits_list_screen.dart with status filter (pending, approved, completed)
- [ ] T073 [US5] Implement submit permit request form in lib/screens/permits/submit_permit_screen.dart with project type dropdown, description textarea, contractor name/contact, start/end date pickers, estimated workers number input
- [ ] T074 [US5] Implement permit details screen in lib/screens/permits/permit_details_screen.dart showing fee computation, payment status, approval status, permit reference
- [ ] T075 [US5] Create permit card widget in lib/widgets/permits/permit_card.dart with status badge and project timeline
- [ ] T076 [US5] Add validation for permit requests (start_date < end_date, start date not in past, estimated_workers > 0, max 365 days duration)
- [ ] T077 [US5] Add push notification handler for fee computation and permit approval notifications
- [ ] T078 [US5] Implement payment instructions screen showing fee amount and payment methods (placeholder for future payment integration)

**Checkpoint**: All user stories P1-P3 should be independently functional

---

## Phase 8: User Story 6 - Communication with Admin (Priority: P3)

**Goal**: Household head can send messages to admin, view announcements, receive notifications about community events

**Independent Test**: Send message to admin, view announcements feed, receive high-priority announcement notification

### Implementation for User Story 6

- [ ] T079 [P] [US6] Create Message model in lib/models/message.dart with messageType enum (household_to_admin, admin_to_household)
- [ ] T080 [P] [US6] Create Announcement model in lib/models/announcement.dart with priority enum (normal, high, urgent)
- [ ] T081 [P] [US6] Create VillageRule model in lib/models/village_rule.dart with ruleCategory enum (general, parking, noise, construction, curfew)
- [ ] T082 [US6] Create messaging service in lib/services/messaging_service.dart with sendMessageToAdmin, fetchMessages methods
- [ ] T083 [US6] Create announcement service in lib/services/announcement_service.dart with fetchAnnouncements method and Supabase realtime subscription
- [ ] T084 [US6] Create village rules service in lib/services/village_rules_service.dart with fetchVillageRules method
- [ ] T085 [US6] Create messaging provider in lib/providers/messaging_provider.dart using Riverpod StateNotifier
- [ ] T086 [US6] Create announcement provider in lib/providers/announcement_provider.dart with realtime updates
- [ ] T087 [US6] Implement messages list screen in lib/screens/messages/messages_list_screen.dart with sent/received tabs and unread badge
- [ ] T088 [US6] Implement compose message screen in lib/screens/messages/compose_message_screen.dart with subject, content fields
- [ ] T089 [US6] Implement announcements feed screen in lib/screens/announcements/announcements_screen.dart with priority badges and attachments
- [ ] T090 [US6] Implement announcement details screen in lib/screens/announcements/announcement_details_screen.dart with full content and attachment downloads
- [ ] T091 [US6] Implement village rules screen in lib/screens/village_rules/village_rules_screen.dart with category tabs and curfew time display
- [ ] T092 [US6] Create announcement card widget in lib/widgets/announcements/announcement_card.dart with priority badge and timestamp
- [ ] T093 [US6] Create message card widget in lib/widgets/messages/message_card.dart with read/unread indicator
- [ ] T094 [US6] Add push notification handler for high-priority announcements (navigate to announcement details on tap)
- [ ] T095 [US6] Add validation for message composition (required content, max 1000 characters)

**Checkpoint**: All user stories should now be independently functional and integrated

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T096 [P] Implement home dashboard screen in lib/screens/home/home_screen.dart with quick access cards to all features (household, stickers, beneficial users, guests, permits, announcements)
- [ ] T097 [P] Implement settings screen in lib/screens/settings/settings_screen.dart with profile view, notification preferences, logout
- [ ] T098 [P] Create app navigation drawer in lib/widgets/shared/app_drawer.dart with menu items for all main screens
- [ ] T099 Add empty state widgets for all list screens (household members, beneficial users, guests, stickers, permits, messages, announcements)
- [ ] T100 Add pull-to-refresh capability to all list screens with offline sync indicator
- [ ] T101 Implement search functionality for household members and beneficial users lists
- [ ] T102 Implement date range filters for guests (upcoming, today, this week, this month)
- [ ] T103 Add export/download capability for guest logs and sticker history (CSV format)
- [ ] T104 Implement app onboarding flow for first-time users (3-5 screens explaining key features)
- [ ] T105 Add error retry mechanisms for failed network requests with exponential backoff
- [ ] T106 Implement offline queue for mutations (add member, request sticker, schedule guest) with background sync when online
- [ ] T107 Add analytics tracking for key user actions (sticker requests, guest scheduling, permit submissions) using Firebase Analytics
- [ ] T108 Implement app theme with light/dark mode support using ThemeData
- [ ] T109 Add accessibility improvements (semantic labels, screen reader support, font scaling)
- [ ] T110 Optimize image caching for beneficial user photos using cached_network_image package
- [ ] T111 Add network connectivity monitoring with status banner (online/offline)
- [ ] T112 Implement app version check with update prompt for critical updates
- [ ] T113 Add user feedback mechanism (in-app feedback form in settings)
- [ ] T114 Create app documentation in apps/residence/README.md with setup instructions
- [ ] T115 Run quickstart.md validation (verify all workflows execute successfully)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (US1 → US2 → US3 → US4 → US5 → US6)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Integrates with US1 for owner selection (household members)
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Integrates with US2 for beneficial user sticker requests
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Independent, no dependencies on other stories
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Independent, no dependencies on other stories
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - Independent, no dependencies on other stories

### Within Each User Story

- Models before services (models define data structure)
- Services before providers (providers use services)
- Providers before screens (screens use providers for state)
- Core implementation before UI polish
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1 (Setup)**: T003-T006 can run in parallel (different configuration files)
- **Phase 2 (Foundational)**: T013-T017 can run in parallel (different utility files)
- **Phase 3 (US1)**: T019-T020 can run in parallel (model and service are independent initially)
- **Phase 4 (US2)**: T029-T031 can run in parallel (different model files)
- **Phase 5 (US3)**: T043 can run independently
- **Phase 6 (US4)**: T056 can run independently
- **Phase 7 (US5)**: T068-T069 can run in parallel
- **Phase 8 (US6)**: T079-T081 can run in parallel
- **Phase 9 (Polish)**: T096-T098 can run in parallel (different screens)
- **Once Foundational completes**: All user stories (US1-US6) can be worked on in parallel by different team members

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Manage Household Members)
4. Complete Phase 4: User Story 2 (Request Vehicle Stickers)
5. **STOP and VALIDATE**: Test US1 and US2 independently and together
6. Deploy/demo if ready

**MVP Scope**:
- Household member management (add, edit, remove)
- Vehicle sticker requests with allocation tracking
- Push notifications for sticker approvals
- Offline caching for household data and sticker allocation
- Basic home dashboard

**Tasks for MVP**: T001-T042, T096 (home dashboard)
**Total MVP Tasks**: 43 tasks

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo
3. Add User Story 2 → Test independently → Deploy/Demo (MVP!)
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Add User Story 5 → Test independently → Deploy/Demo
7. Add User Story 6 → Test independently → Deploy/Demo
8. Add Polish → Final release

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (Phase 1-2)
2. Once Foundational is done:
   - Developer A: User Story 1 (T019-T028)
   - Developer B: User Story 2 (T029-T042)
   - Developer C: User Story 3 (T043-T055)
3. Stories complete and integrate independently
4. Continue with US4-US6 in parallel
5. Converge for Polish phase

---

## Task Count Summary

**Phase 1 (Setup)**: 6 tasks
**Phase 2 (Foundational)**: 12 tasks
**Phase 3 (US1 - P1)**: 10 tasks
**Phase 4 (US2 - P1)**: 14 tasks
**Phase 5 (US3 - P2)**: 13 tasks
**Phase 6 (US4 - P2)**: 12 tasks
**Phase 7 (US5 - P3)**: 11 tasks
**Phase 8 (US6 - P3)**: 17 tasks
**Phase 9 (Polish)**: 20 tasks

**Total Tasks**: 115 tasks

### Tasks per User Story

- **US1 (Manage Household Members)**: 10 tasks
- **US2 (Request Vehicle Stickers)**: 14 tasks
- **US3 (Manage Beneficial Users)**: 13 tasks
- **US4 (Schedule Guest Visits)**: 12 tasks
- **US5 (Submit Construction Permits)**: 11 tasks
- **US6 (Communication with Admin)**: 17 tasks
- **Infrastructure (Phase 1-2)**: 18 tasks
- **Polish (Phase 9)**: 20 tasks

### Parallel Opportunities Identified

- **7 parallel groups** in Setup/Foundational (saves ~40% setup time)
- **6 user stories** can be developed in parallel after foundation (saves ~70% development time with 6 developers)
- **Model tasks** within each story can run in parallel (saves ~20% per story)

---

## Suggested MVP Scope

**Recommended MVP** (Phases 1-4):
- Infrastructure setup (Phase 1-2): 18 tasks
- Household member management (US1): 10 tasks
- Vehicle sticker requests (US2): 14 tasks
- Basic home dashboard (T096): 1 task
- **Total MVP: 43 tasks**

**MVP Deliverables**:
1. Household heads can manage household members
2. Household heads can request vehicle stickers with allocation tracking
3. Push notifications for sticker approvals
4. Offline caching for household data
5. Basic navigation and home dashboard

**Post-MVP** (Phases 5-9):
- Beneficial users (US3): 13 tasks
- Guest scheduling (US4): 12 tasks
- Construction permits (US5): 11 tasks
- Communication (US6): 17 tasks
- Polish: 19 tasks (excluding T096 already in MVP)
- **Total Post-MVP: 72 tasks**

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- **Tests are OPTIONAL** - not included in this task list as spec does not explicitly request TDD
- Offline-first approach: All list screens should load from cache first, then refresh from network
- Photo uploads use compression to reduce bandwidth (target <1MB per photo)
- Push notifications require FCM setup for both iOS and Android
- Supabase RLS policies enforce household-scoped access (household heads can only access their own data)
- All file paths assume apps/residence/ as root directory
