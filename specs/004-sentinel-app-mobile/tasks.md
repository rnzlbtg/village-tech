# Tasks: Sentinel App - Gate Guard Access Control Mobile Application

**Input**: Design documents from `/specs/004-sentinel-app-mobile/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tech Stack**: Flutter 3.24+/Dart 3, supabase_flutter, riverpod, go_router, drift+sqlcipher, nfc_manager, workmanager, firebase_messaging

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and basic structure

- [ ] T001 Create Flutter project structure at `apps/sentinel/` with feature-based architecture
- [ ] T002 Initialize pubspec.yaml with core dependencies (flutter_riverpod, go_router, drift, supabase_flutter, nfc_manager, workmanager, firebase_messaging)
- [ ] T003 [P] Configure very_good_analysis linting rules in analysis_options.yaml
- [ ] T004 [P] Setup .env file structure with envied package for environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)
- [ ] T005 [P] Create shared theme system in `lib/shared/theme/` (app_theme.dart, app_colors.dart, app_text_styles.dart) using Material 3

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

### Authentication & Supabase Setup

- [ ] T006 Setup Supabase client initialization in `lib/core/auth/supabase_client.dart` with environment variables
- [ ] T007 Implement guard authentication provider in `lib/core/auth/auth_provider.dart` using Riverpod
- [ ] T008 Create guard session management in `lib/core/auth/guard_session.dart` with tenant_id isolation
- [ ] T009 Configure RLS policy validation and JWT token handling

### Local Database & Encryption

- [ ] T010 Setup Drift database schema in `lib/core/storage/database.dart` for offline-first architecture
- [ ] T011 Implement SQLCipher encryption setup in `lib/core/storage/encryption.dart` with AES-256
- [ ] T012 Configure flutter_secure_storage for encryption key management in `lib/core/storage/key_storage.dart`
- [ ] T013 Create Drift tables for entry_logs, rfid_stickers, pre_registered_guests, guest_logs (mirroring Supabase schema)
- [ ] T014 Create Drift table for sync_queue (local-only) with operation tracking
- [ ] T015 Implement database migration strategy and version management

### NFC/RFID Infrastructure

- [ ] T016 Setup NFC manager service in `lib/core/rfid/nfc_manager_service.dart` using nfc_manager package
- [ ] T017 Implement iOS NFC configuration in `ios/Runner/Info.plist` with NFCReaderUsageDescription
- [ ] T018 [P] Implement Android NFC permissions in `android/app/src/main/AndroidManifest.xml`
- [ ] T019 Create RFID tag data extraction utility in `lib/core/rfid/tag_parser.dart` for 13.56 MHz tags
- [ ] T020 Implement NFC session timeout (3-5 seconds) and error handling

### Background Sync & Offline Infrastructure

- [ ] T021 Configure WorkManager for periodic sync in `lib/core/sync/workmanager_config.dart` (15-minute intervals)
- [ ] T022 Implement sync queue manager in `lib/core/sync/sync_queue_manager.dart` with exponential backoff
- [ ] T023 Create sync service in `lib/core/sync/sync_service.dart` with batch processing
- [ ] T024 Implement network connectivity monitoring using connectivity_plus in `lib/core/sync/network_monitor.dart`
- [ ] T025 Create conflict resolution strategies (Last-Write-Wins, Merge) in `lib/core/sync/conflict_resolver.dart`
- [ ] T026 Implement background task callback dispatcher with proper initialization

### Push Notifications (FCM)

- [ ] T027 Initialize Firebase Core and Firebase Messaging in `lib/core/notifications/fcm_setup.dart`
- [ ] T028 Configure iOS APNs settings and permissions in `ios/Runner/AppDelegate.swift`
- [ ] T029 [P] Configure Android notification channels for Android 8+ in `android/app/src/main/kotlin/MainActivity.kt`
- [ ] T030 Implement FCM token management and backend registration in `lib/core/notifications/token_manager.dart`
- [ ] T031 Create background message handler for silent push notifications
- [ ] T032 Setup flutter_local_notifications for foreground notification display

### Navigation & Routing

- [ ] T033 Configure GoRouter in `lib/core/navigation/app_router.dart` with route definitions for all features
- [ ] T034 Implement route guards for authentication state
- [ ] T035 Create navigation service provider using Riverpod

### Shared UI Components

- [ ] T036 [P] Create reusable widgets: custom_button.dart, loading_indicator.dart, error_display.dart in `lib/shared/widgets/`
- [ ] T037 [P] Create form validators in `lib/shared/utils/validators.dart`
- [ ] T038 [P] Create date/time formatters in `lib/shared/utils/formatters.dart`
- [ ] T039 [P] Create constants file in `lib/shared/utils/constants.dart` with API endpoints, timeout values

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Manage Resident Entry with RFID Verification (Priority: P1) 🎯 MVP

**Goal**: Gate guard can scan RFID stickers, validate resident vehicles, and grant/deny entry based on verification results

**Independent Test**: Scan an RFID sticker → System validates status → Display resident info → Grant entry for valid sticker, deny for expired/invalid

### Domain Layer (US1)

- [ ] T040 [P] [US1] Create RfidSticker entity in `lib/features/rfid_verification/domain/entities/rfid_sticker.dart` with all fields from data-model.md
- [ ] T041 [P] [US1] Create EntryLog entity in `lib/features/rfid_verification/domain/entities/entry_log.dart`
- [ ] T042 [P] [US1] Create RfidRepository interface in `lib/features/rfid_verification/domain/repositories/rfid_repository.dart`
- [ ] T043 [US1] Create ValidateRfidUseCase in `lib/features/rfid_verification/domain/usecases/validate_rfid_usecase.dart`
- [ ] T044 [US1] Create LogRfidEntryUseCase in `lib/features/rfid_verification/domain/usecases/log_rfid_entry_usecase.dart`

### Data Layer (US1)

- [ ] T045 [P] [US1] Create RfidStickerModel in `lib/features/rfid_verification/data/models/rfid_sticker_model.dart` with JSON serialization
- [ ] T046 [P] [US1] Create EntryLogModel in `lib/features/rfid_verification/data/models/entry_log_model.dart`
- [ ] T047 [US1] Implement RfidRemoteDataSource in `lib/features/rfid_verification/data/datasources/rfid_remote_datasource.dart` calling Supabase Edge Functions
- [ ] T048 [US1] Implement RfidLocalDataSource in `lib/features/rfid_verification/data/datasources/rfid_local_datasource.dart` using Drift
- [ ] T049 [US1] Implement RfidRepositoryImpl in `lib/features/rfid_verification/data/repositories/rfid_repository_impl.dart` with offline-first logic

### Presentation Layer (US1)

- [ ] T050 [US1] Create RfidState model in `lib/features/rfid_verification/presentation/providers/rfid_state.dart` (idle, scanning, validating, success, error)
- [ ] T051 [US1] Implement RfidProvider using Riverpod in `lib/features/rfid_verification/presentation/providers/rfid_provider.dart`
- [ ] T052 [US1] Create RfidScanScreen in `lib/features/rfid_verification/presentation/screens/rfid_scan_screen.dart` with scan button
- [ ] T053 [P] [US1] Create StickerResultCard widget in `lib/features/rfid_verification/presentation/widgets/sticker_result_card.dart` displaying resident info
- [ ] T054 [P] [US1] Create VerificationStatusWidget in `lib/features/rfid_verification/presentation/widgets/verification_status_widget.dart` (granted/denied UI)
- [ ] T055 [US1] Implement NFC session handling in RfidScanScreen with 3-5 second timeout
- [ ] T056 [US1] Add error handling for NFC not available, tag read failure, network errors
- [ ] T057 [US1] Implement optimistic UI updates and offline queueing for entry logs

**Checkpoint**: User Story 1 should be fully functional - guards can scan RFID, validate stickers, and log entries offline

---

## Phase 4: User Story 2 - Manage Guest Entry with Pre-Registration Check (Priority: P1) 🎯 MVP

**Goal**: Gate guard can check pre-registered guests, verify identity, call household for unregistered guests, and log guest entries

**Independent Test**: Search pre-registered guest → Find on list → Verify identity → Log entry; OR Search unregistered guest → Call household → Approve/deny → Log

### Domain Layer (US2)

- [ ] T058 [P] [US2] Create PreRegisteredGuest entity in `lib/features/guest_management/domain/entities/pre_registered_guest.dart`
- [ ] T059 [P] [US2] Create GuestLog entity in `lib/features/guest_management/domain/entities/guest_log.dart`
- [ ] T060 [P] [US2] Create Household entity in `lib/features/guest_management/domain/entities/household.dart`
- [ ] T061 [P] [US2] Create GuestRepository interface in `lib/features/guest_management/domain/repositories/guest_repository.dart`
- [ ] T062 [US2] Create SearchPreRegisteredGuestsUseCase in `lib/features/guest_management/domain/usecases/search_preregistered_guests_usecase.dart`
- [ ] T063 [US2] Create VerifyGuestEntryUseCase in `lib/features/guest_management/domain/usecases/verify_guest_entry_usecase.dart`
- [ ] T064 [US2] Create CallHouseholdUseCase in `lib/features/guest_management/domain/usecases/call_household_usecase.dart`

### Data Layer (US2)

- [ ] T065 [P] [US2] Create PreRegisteredGuestModel in `lib/features/guest_management/data/models/pre_registered_guest_model.dart`
- [ ] T066 [P] [US2] Create GuestLogModel in `lib/features/guest_management/data/models/guest_log_model.dart`
- [ ] T067 [US2] Implement GuestRemoteDataSource in `lib/features/guest_management/data/datasources/guest_remote_datasource.dart`
- [ ] T068 [US2] Implement GuestLocalDataSource in `lib/features/guest_management/data/datasources/guest_local_datasource.dart`
- [ ] T069 [US2] Implement GuestRepositoryImpl in `lib/features/guest_management/data/repositories/guest_repository_impl.dart` with offline caching

### Presentation Layer (US2)

- [ ] T070 [US2] Create GuestState model in `lib/features/guest_management/presentation/providers/guest_state.dart`
- [ ] T071 [US2] Implement GuestProvider using Riverpod in `lib/features/guest_management/presentation/providers/guest_provider.dart`
- [ ] T072 [US2] Create GuestSearchScreen in `lib/features/guest_management/presentation/screens/guest_search_screen.dart` with search bar
- [ ] T073 [US2] Create GuestVerificationScreen in `lib/features/guest_management/presentation/screens/guest_verification_screen.dart`
- [ ] T074 [P] [US2] Create PreRegisteredGuestCard widget in `lib/features/guest_management/presentation/widgets/preregistered_guest_card.dart`
- [ ] T075 [P] [US2] Create HouseholdCallDialog widget in `lib/features/guest_management/presentation/widgets/household_call_dialog.dart`
- [ ] T076 [P] [US2] Create GuestEntryForm widget in `lib/features/guest_management/presentation/widgets/guest_entry_form.dart`
- [ ] T077 [US2] Implement search filtering by name and household with debouncing
- [ ] T078 [US2] Add phone dialer integration for household calls using url_launcher
- [ ] T079 [US2] Implement guest entry logging with multiple verification methods (pre_registered, household_call, manual)

**Checkpoint**: User Story 2 should be fully functional - guards can search guests, verify with household, and log entries

---

## Phase 5: User Story 3 - Manage Delivery Entry and Tracking (Priority: P2)

**Goal**: Gate guard can log delivery arrivals, verify recipient address, start delivery timer, and track delivery duration

**Independent Test**: Log delivery with details → Verify address exists → Start timer → Alert on timeout → Log exit

### Domain Layer (US3)

- [ ] T080 [P] [US3] Create DeliveryLog entity in `lib/features/delivery_tracking/domain/entities/delivery_log.dart`
- [ ] T081 [P] [US3] Create DeliveryRepository interface in `lib/features/delivery_tracking/domain/repositories/delivery_repository.dart`
- [ ] T082 [US3] Create LogDeliveryEntryUseCase in `lib/features/delivery_tracking/domain/usecases/log_delivery_entry_usecase.dart`
- [ ] T083 [US3] Create VerifyDeliveryAddressUseCase in `lib/features/delivery_tracking/domain/usecases/verify_delivery_address_usecase.dart`
- [ ] T084 [US3] Create LogDeliveryExitUseCase in `lib/features/delivery_tracking/domain/usecases/log_delivery_exit_usecase.dart`
- [ ] T085 [US3] Create GetActiveDeliveriesUseCase in `lib/features/delivery_tracking/domain/usecases/get_active_deliveries_usecase.dart`

### Data Layer (US3)

- [ ] T086 [P] [US3] Create DeliveryLogModel in `lib/features/delivery_tracking/data/models/delivery_log_model.dart`
- [ ] T087 [US3] Implement DeliveryRemoteDataSource in `lib/features/delivery_tracking/data/datasources/delivery_remote_datasource.dart`
- [ ] T088 [US3] Implement DeliveryLocalDataSource in `lib/features/delivery_tracking/data/datasources/delivery_local_datasource.dart`
- [ ] T089 [US3] Implement DeliveryRepositoryImpl in `lib/features/delivery_tracking/data/repositories/delivery_repository_impl.dart`

### Presentation Layer (US3)

- [ ] T090 [US3] Create DeliveryState model in `lib/features/delivery_tracking/presentation/providers/delivery_state.dart`
- [ ] T091 [US3] Implement DeliveryProvider using Riverpod in `lib/features/delivery_tracking/presentation/providers/delivery_provider.dart`
- [ ] T092 [US3] Create DeliveryEntryScreen in `lib/features/delivery_tracking/presentation/screens/delivery_entry_screen.dart`
- [ ] T093 [US3] Create ActiveDeliveriesScreen in `lib/features/delivery_tracking/presentation/screens/active_deliveries_screen.dart`
- [ ] T094 [P] [US3] Create DeliveryEntryForm widget in `lib/features/delivery_tracking/presentation/widgets/delivery_entry_form.dart`
- [ ] T095 [P] [US3] Create DeliveryTimerCard widget in `lib/features/delivery_tracking/presentation/widgets/delivery_timer_card.dart`
- [ ] T096 [P] [US3] Create AddressVerificationWidget in `lib/features/delivery_tracking/presentation/widgets/address_verification_widget.dart`
- [ ] T097 [US3] Implement delivery timer with real-time countdown and duration alerts
- [ ] T098 [US3] Add special instructions input for perishable deliveries
- [ ] T099 [US3] Implement delivery exit logging with automatic duration calculation

**Checkpoint**: User Story 3 should be fully functional - guards can log deliveries, track timers, and manage delivery flow

---

## Phase 6: User Story 4 - Manage Construction Worker Entry with Permit Verification (Priority: P2)

**Goal**: Gate guard can verify construction permits, check worker authorization, and track worker entry/exit

**Independent Test**: Enter permit reference → Display authorized workers → Verify worker → Log entry/exit → Track on-site workers

### Domain Layer (US4)

- [ ] T100 [P] [US4] Create ConstructionPermit entity in `lib/features/construction_permits/domain/entities/construction_permit.dart`
- [ ] T101 [P] [US4] Create ConstructionWorkerLog entity in `lib/features/construction_permits/domain/entities/construction_worker_log.dart`
- [ ] T102 [P] [US4] Create PermitRepository interface in `lib/features/construction_permits/domain/repositories/permit_repository.dart`
- [ ] T103 [US4] Create ValidatePermitUseCase in `lib/features/construction_permits/domain/usecases/validate_permit_usecase.dart`
- [ ] T104 [US4] Create LogWorkerEntryUseCase in `lib/features/construction_permits/domain/usecases/log_worker_entry_usecase.dart`
- [ ] T105 [US4] Create LogWorkerExitUseCase in `lib/features/construction_permits/domain/usecases/log_worker_exit_usecase.dart`
- [ ] T106 [US4] Create GetWorkersOnSiteUseCase in `lib/features/construction_permits/domain/usecases/get_workers_onsite_usecase.dart`

### Data Layer (US4)

- [ ] T107 [P] [US4] Create ConstructionPermitModel in `lib/features/construction_permits/data/models/construction_permit_model.dart`
- [ ] T108 [P] [US4] Create ConstructionWorkerLogModel in `lib/features/construction_permits/data/models/construction_worker_log_model.dart`
- [ ] T109 [US4] Implement PermitRemoteDataSource in `lib/features/construction_permits/data/datasources/permit_remote_datasource.dart`
- [ ] T110 [US4] Implement PermitLocalDataSource in `lib/features/construction_permits/data/datasources/permit_local_datasource.dart`
- [ ] T111 [US4] Implement PermitRepositoryImpl in `lib/features/construction_permits/data/repositories/permit_repository_impl.dart`

### Presentation Layer (US4)

- [ ] T112 [US4] Create PermitState model in `lib/features/construction_permits/presentation/providers/permit_state.dart`
- [ ] T113 [US4] Implement PermitProvider using Riverpod in `lib/features/construction_permits/presentation/providers/permit_provider.dart`
- [ ] T114 [US4] Create PermitVerificationScreen in `lib/features/construction_permits/presentation/screens/permit_verification_screen.dart`
- [ ] T115 [US4] Create WorkersOnSiteScreen in `lib/features/construction_permits/presentation/screens/workers_onsite_screen.dart`
- [ ] T116 [P] [US4] Create PermitDetailsCard widget in `lib/features/construction_permits/presentation/widgets/permit_details_card.dart`
- [ ] T117 [P] [US4] Create AuthorizedWorkersList widget in `lib/features/construction_permits/presentation/widgets/authorized_workers_list.dart`
- [ ] T118 [P] [US4] Create WorkerEntryForm widget in `lib/features/construction_permits/presentation/widgets/worker_entry_form.dart`
- [ ] T119 [US4] Implement permit reference search and validation
- [ ] T120 [US4] Add worker authorization check against permit's authorized_workers JSONB array
- [ ] T121 [US4] Implement on-site tracking with entry/exit timestamps
- [ ] T122 [US4] Add permit expiry alerts and status display

**Checkpoint**: User Story 4 should be fully functional - guards can verify permits, track workers, and manage construction access

---

## Phase 7: User Story 5 - Incident Reporting and Communication (Priority: P3)

**Goal**: Gate guard can report incidents, upload photos, communicate with dispatch, and track incident resolution

**Independent Test**: Create incident report → Upload photo → Send to dispatch → Receive response → Mark resolved

### Domain Layer (US5)

- [ ] T123 [P] [US5] Create IncidentReport entity in `lib/features/incident_reporting/domain/entities/incident_report.dart`
- [ ] T124 [P] [US5] Create IncidentRepository interface in `lib/features/incident_reporting/domain/repositories/incident_repository.dart`
- [ ] T125 [US5] Create ReportIncidentUseCase in `lib/features/incident_reporting/domain/usecases/report_incident_usecase.dart`
- [ ] T126 [US5] Create UploadIncidentPhotoUseCase in `lib/features/incident_reporting/domain/usecases/upload_incident_photo_usecase.dart`
- [ ] T127 [US5] Create GetIncidentListUseCase in `lib/features/incident_reporting/domain/usecases/get_incident_list_usecase.dart`
- [ ] T128 [US5] Create ResolveIncidentUseCase in `lib/features/incident_reporting/domain/usecases/resolve_incident_usecase.dart`

### Data Layer (US5)

- [ ] T129 [P] [US5] Create IncidentReportModel in `lib/features/incident_reporting/data/models/incident_report_model.dart`
- [ ] T130 [US5] Implement IncidentRemoteDataSource in `lib/features/incident_reporting/data/datasources/incident_remote_datasource.dart`
- [ ] T131 [US5] Implement IncidentLocalDataSource in `lib/features/incident_reporting/data/datasources/incident_local_datasource.dart`
- [ ] T132 [US5] Implement IncidentRepositoryImpl in `lib/features/incident_reporting/data/repositories/incident_repository_impl.dart`
- [ ] T133 [US5] Implement Supabase Storage integration for photo uploads in `lib/core/storage/supabase_storage.dart`

### Presentation Layer (US5)

- [ ] T134 [US5] Create IncidentState model in `lib/features/incident_reporting/presentation/providers/incident_state.dart`
- [ ] T135 [US5] Implement IncidentProvider using Riverpod in `lib/features/incident_reporting/presentation/providers/incident_provider.dart`
- [ ] T136 [US5] Create IncidentReportScreen in `lib/features/incident_reporting/presentation/screens/incident_report_screen.dart`
- [ ] T137 [US5] Create IncidentListScreen in `lib/features/incident_reporting/presentation/screens/incident_list_screen.dart`
- [ ] T138 [P] [US5] Create IncidentReportForm widget in `lib/features/incident_reporting/presentation/widgets/incident_report_form.dart`
- [ ] T139 [P] [US5] Create PhotoUploadWidget in `lib/features/incident_reporting/presentation/widgets/photo_upload_widget.dart` using image_picker
- [ ] T140 [P] [US5] Create IncidentCard widget in `lib/features/incident_reporting/presentation/widgets/incident_card.dart`
- [ ] T141 [US5] Implement incident type and severity selection
- [ ] T142 [US5] Add photo capture/selection from gallery and upload to Supabase Storage
- [ ] T143 [US5] Implement dispatch notification via FCM when incident reported
- [ ] T144 [US5] Add incident resolution workflow with status updates

**Checkpoint**: User Story 5 should be fully functional - guards can report incidents, upload photos, and track resolution

---

## Phase 8: User Story 6 - View Village Rules and Announcements (Priority: P3)

**Goal**: Gate guard can view village rules, check curfew times, and read announcements from admin

**Independent Test**: Open app → View rules section → Check curfew times → Read announcements → Receive urgent push notification

### Domain Layer (US6)

- [ ] T145 [P] [US6] Create VillageRule entity in `lib/features/village_info/domain/entities/village_rule.dart`
- [ ] T146 [P] [US6] Create Announcement entity in `lib/features/village_info/domain/entities/announcement.dart`
- [ ] T147 [P] [US6] Create VillageInfoRepository interface in `lib/features/village_info/domain/repositories/village_info_repository.dart`
- [ ] T148 [US6] Create GetVillageRulesUseCase in `lib/features/village_info/domain/usecases/get_village_rules_usecase.dart`
- [ ] T149 [US6] Create GetAnnouncementsUseCase in `lib/features/village_info/domain/usecases/get_announcements_usecase.dart`
- [ ] T150 [US6] Create MarkAnnouncementReadUseCase in `lib/features/village_info/domain/usecases/mark_announcement_read_usecase.dart`

### Data Layer (US6)

- [ ] T151 [P] [US6] Create VillageRuleModel in `lib/features/village_info/data/models/village_rule_model.dart`
- [ ] T152 [P] [US6] Create AnnouncementModel in `lib/features/village_info/data/models/announcement_model.dart`
- [ ] T153 [US6] Implement VillageInfoRemoteDataSource in `lib/features/village_info/data/datasources/village_info_remote_datasource.dart`
- [ ] T154 [US6] Implement VillageInfoLocalDataSource in `lib/features/village_info/data/datasources/village_info_local_datasource.dart`
- [ ] T155 [US6] Implement VillageInfoRepositoryImpl in `lib/features/village_info/data/repositories/village_info_repository_impl.dart`

### Presentation Layer (US6)

- [ ] T156 [US6] Create VillageInfoState model in `lib/features/village_info/presentation/providers/village_info_state.dart`
- [ ] T157 [US6] Implement VillageInfoProvider using Riverpod in `lib/features/village_info/presentation/providers/village_info_provider.dart`
- [ ] T158 [US6] Create VillageRulesScreen in `lib/features/village_info/presentation/screens/village_rules_screen.dart`
- [ ] T159 [US6] Create AnnouncementsScreen in `lib/features/village_info/presentation/screens/announcements_screen.dart`
- [ ] T160 [P] [US6] Create RuleCategoryList widget in `lib/features/village_info/presentation/widgets/rule_category_list.dart`
- [ ] T161 [P] [US6] Create RuleCard widget in `lib/features/village_info/presentation/widgets/rule_card.dart`
- [ ] T162 [P] [US6] Create AnnouncementCard widget in `lib/features/village_info/presentation/widgets/announcement_card.dart`
- [ ] T163 [US6] Implement rule categorization and filtering (curfew, parking, noise, security, general)
- [ ] T164 [US6] Add curfew time highlighting and enforcement instructions display
- [ ] T165 [US6] Implement announcement priority display (normal, high, urgent) with color coding
- [ ] T166 [US6] Integrate FCM notifications for urgent announcements with notification tap handler

**Checkpoint**: User Story 6 should be fully functional - guards can view rules, read announcements, and receive urgent notifications

---

## Phase 9: Home Screen & Main Navigation

**Purpose**: Unified dashboard and navigation structure tying all user stories together

- [ ] T167 Create HomeScreen in `lib/features/home/presentation/screens/home_screen.dart` with dashboard tiles
- [ ] T168 [P] Create FeatureTile widget in `lib/features/home/presentation/widgets/feature_tile.dart` for each user story
- [ ] T169 [P] Create QuickActionButton widget in `lib/features/home/presentation/widgets/quick_action_button.dart` for RFID scan and incident report
- [ ] T170 Implement bottom navigation bar with Home, Active Tasks (deliveries/workers), Incidents, More tabs
- [ ] T171 Add sync status indicator showing online/offline mode and pending sync count
- [ ] T172 Create profile/settings screen with logout, sync preferences, and app version info

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final release preparation

### Error Handling & Logging

- [ ] T173 [P] Implement global error handler in `lib/core/error/error_handler.dart` with user-friendly messages
- [ ] T174 [P] Setup Logger service in `lib/core/logging/logger_service.dart` with different log levels
- [ ] T175 [P] Add Crashlytics integration for production error tracking

### Performance Optimization

- [ ] T176 Implement image caching for incident photos using cached_network_image
- [ ] T177 Optimize Drift queries with proper indexes matching data-model.md specifications
- [ ] T178 Add pagination for long lists (entry logs, incidents, announcements)
- [ ] T179 Implement lazy loading for inactive features to reduce initial app bundle size

### Security Hardening

- [ ] T180 Implement root/jailbreak detection using flutter_jailbreak_detection
- [ ] T181 Add certificate pinning for Supabase API calls in production
- [ ] T182 Implement biometric authentication for app unlock using local_auth
- [ ] T183 Add secure key deletion on logout to protect encrypted database
- [ ] T184 Implement session timeout with automatic logout after inactivity

### Platform-Specific Configuration

- [ ] T185 [P] Configure iOS background modes for FCM and NFC in Xcode
- [ ] T186 [P] Configure Android battery optimization exemptions and foreground service notification
- [ ] T187 [P] Setup iOS App Store metadata and screenshots
- [ ] T188 [P] Setup Android Play Store metadata and screenshots

### Testing & Quality Assurance

- [ ] T189 Add comprehensive unit tests for all use cases in `test/unit/` (OPTIONAL - only if spec requests)
- [ ] T190 Add widget tests for critical UI components in `test/widget/` (OPTIONAL)
- [ ] T191 Add integration tests for complete user flows in `integration_test/` (OPTIONAL)
- [ ] T192 Run quickstart.md validation on real devices (iOS & Android)
- [ ] T193 Test offline-first scenarios: scan RFID offline → go online → verify sync
- [ ] T194 Test NFC on multiple device models (iPhone 7+, various Android devices)

### Documentation & Deployment

- [ ] T195 [P] Update README.md with project overview, setup instructions, and team contacts
- [ ] T196 [P] Create CHANGELOG.md documenting all features and versions
- [ ] T197 Configure CI/CD pipeline for automated builds and tests
- [ ] T198 Prepare production environment variables and Supabase project configuration
- [ ] T199 Build release APK/IPA and submit to internal testing track
- [ ] T200 Conduct security audit of encryption, authentication, and data handling

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - User stories can proceed in parallel (if staffed)
  - Or sequentially in priority order (US1 → US2 → US3 → US4 → US5 → US6)
- **Home Screen (Phase 9)**: Depends on at least US1 and US2 (MVP stories)
- **Polish (Phase 10)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Independent from US1 but both needed for MVP
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Independent from US1/US2
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Independent from all other stories
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Independent from all other stories
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - Independent from all other stories

### Within Each User Story

- Domain entities before repositories and use cases
- Data models before data sources
- Data sources before repository implementations
- Repository implementations before use cases
- Providers before screens
- Widgets can be built in parallel with screens (marked with [P])

### Parallel Opportunities

- **Setup Phase**: T003, T004, T005 can run in parallel
- **Foundational Phase**:
  - T009 (RLS) in parallel with T010-T015 (Database)
  - T017, T018 (Platform configs) in parallel
  - T029 (Android notif) in parallel with T028 (iOS)
  - T036, T037, T038, T039 (Shared utils) all in parallel
- **User Story Phases**: All user stories can be developed in parallel by different developers after Phase 2
- **Within Each Story**: All tasks marked [P] can be worked on simultaneously
- **Polish Phase**: T173, T174, T175 (Error handling) in parallel; T185-T188 (Platform configs) in parallel; T195, T196 (Docs) in parallel

---

## Parallel Example: User Story 1 Domain Layer

```bash
# Launch all entity models for User Story 1 together:
Task T040: Create RfidSticker entity
Task T041: Create EntryLog entity
# Both can be worked on simultaneously by different developers

# After entities complete, work on use cases:
Task T043: Create ValidateRfidUseCase
Task T044: Create LogRfidEntryUseCase
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (RFID Verification)
4. Complete Phase 4: User Story 2 (Guest Management)
5. Complete Phase 9: Home Screen (minimal dashboard)
6. **STOP and VALIDATE**: Test US1 and US2 independently on real devices with NFC
7. Deploy to internal testing for guard feedback

**MVP Deliverable**: Guards can verify residents via RFID and manage guest entries - covers primary gate operations

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (Checkpoint)
2. Add User Story 1 → Test RFID verification independently → Deploy (MVP Core 1)
3. Add User Story 2 → Test guest management independently → Deploy (MVP Core 2)
4. Add User Story 3 → Test delivery tracking independently → Deploy (Enhanced v1.1)
5. Add User Story 4 → Test construction permits independently → Deploy (Enhanced v1.2)
6. Add User Story 5 → Test incident reporting independently → Deploy (Full Feature v1.3)
7. Add User Story 6 → Test village info independently → Deploy (Complete v1.4)
8. Complete Polish Phase → Production release (v1.5)

**Each story adds value without breaking previous stories**

### Parallel Team Strategy

With 3-4 developers:

1. **Team completes Setup + Foundational together** (1-2 weeks)
2. **Once Foundational is done (Checkpoint), split:**
   - **Developer A**: User Story 1 (RFID Verification) - P1
   - **Developer B**: User Story 2 (Guest Management) - P1
   - **Developer C**: User Story 3 (Delivery Tracking) - P2
   - **Developer D**: User Story 4 (Construction Permits) - P2
3. **After MVP (US1 + US2)**: Rotate developers to US5, US6, and Polish phase
4. **Stories complete and integrate independently**

---

## Suggested MVP Scope

**Minimum Viable Product for Gate Guard Operations**:

✅ **MUST HAVE (Phase 1-4, 9)**:
- Phase 1: Setup
- Phase 2: Foundational (all infrastructure)
- Phase 3: User Story 1 - RFID Verification (PRIMARY FUNCTION)
- Phase 4: User Story 2 - Guest Management (PRIMARY FUNCTION)
- Phase 9: Home Screen (basic navigation)

**Total MVP Tasks**: T001-T079 + T167-T172 = **87 tasks**

🎯 **NICE TO HAVE (Phase 5-6)**:
- Phase 5: User Story 3 - Delivery Tracking
- Phase 6: User Story 4 - Construction Permits

🔮 **FUTURE RELEASE (Phase 7-8, 10)**:
- Phase 7: User Story 5 - Incident Reporting
- Phase 8: User Story 6 - Village Rules & Announcements
- Phase 10: Polish & Cross-Cutting Concerns

**Rationale for MVP Scope**:
- US1 (RFID) and US2 (Guest) cover 80% of daily gate operations per spec.md priorities
- Both stories are P1 priority and marked as MVP in spec
- Delivers immediate value to gate guards
- Allows early feedback on offline-first architecture and NFC integration
- Reduces time-to-market for critical security functions

**Estimated MVP Timeline**:
- Phase 1 (Setup): 2-3 days
- Phase 2 (Foundational): 1-2 weeks (most complex)
- Phase 3 (US1): 1 week
- Phase 4 (US2): 1 week
- Phase 9 (Home): 2-3 days
- **Total: 4-5 weeks** for 2-3 developers working in parallel after Foundational phase

---

## Notes

- [P] tasks = different files/features, no dependencies - can be parallelized across developers
- [Story] label maps task to specific user story for traceability and independent testing
- Each user story should be independently completable and testable (per spec.md acceptance scenarios)
- Commit after each task or logical group for proper version control
- Stop at each checkpoint to validate story independently on real devices
- **Tests are OPTIONAL**: Only included if explicitly requested in specification
- All file paths are relative to `apps/sentinel/` directory
- Follow Clean Architecture: Domain (entities, use cases, repositories) → Data (models, data sources, repository impls) → Presentation (providers, screens, widgets)
- Use Riverpod for state management across all features
- Implement offline-first pattern: Write to local Drift DB first, queue for sync, sync when online
- All network calls should have timeout and retry logic with exponential backoff
- Validate RFID stickers against backend - never trust tag data alone
- Test NFC functionality on REAL devices (simulators don't support NFC)
- Configure battery optimization exemptions for reliable background sync

---

**Total Task Count**: 200 tasks

**Task Count by User Story**:
- Setup (Phase 1): 5 tasks
- Foundational (Phase 2): 34 tasks
- User Story 1 (Phase 3): 18 tasks
- User Story 2 (Phase 4): 22 tasks
- User Story 3 (Phase 5): 20 tasks
- User Story 4 (Phase 6): 23 tasks
- User Story 5 (Phase 7): 22 tasks
- User Story 6 (Phase 8): 22 tasks
- Home Screen (Phase 9): 6 tasks
- Polish (Phase 10): 28 tasks

**Parallel Opportunities Identified**: 45+ tasks marked with [P] can run in parallel

**Critical Path**: Phase 1 (Setup) → Phase 2 (Foundational) → User Stories (can parallelize) → Polish

**MVP Tasks**: 87 tasks (43.5% of total) - Phases 1, 2, 3, 4, and 9

---

**Generated**: 2025-10-10
**Template Version**: tasks-template.md v1.0
**Feature**: 004-sentinel-app-mobile
**Platform**: Flutter 3.24+ Mobile App (iOS 14+ | Android 8.0+)
