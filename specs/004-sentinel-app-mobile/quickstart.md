# Developer Quickstart: Sentinel App Mobile

**Feature**: Sentinel App - Gate Guard Access Control
**Platform**: Flutter 3.24+ (iOS 14+ | Android 8.0+)
**Date**: 2025-10-10

---

## 🎯 Overview

The Sentinel App is a Flutter mobile application for gate guards to manage entry of residents, guests, deliveries, and construction workers. It features RFID verification, offline-first architecture, and real-time sync with Supabase backend.

**Key Capabilities**:
- ✅ RFID sticker scanning for resident vehicles (FR-001 to FR-005)
- ✅ Pre-registered guest validation (FR-006 to FR-011)
- ✅ Delivery logging with timers (FR-012 to FR-018)
- ✅ Construction permit verification (FR-019 to FR-025)
- ✅ Incident reporting (FR-026 to FR-029)
- ✅ Village rules & announcements (FR-030 to FR-033)

---

## 📋 Prerequisites

### Required Tools
- **Flutter SDK**: 3.24.0 or higher
- **Dart**: 3.0 or higher
- **Android Studio** or **Xcode** (for platform builds)
- **VS Code** or **Android Studio** (recommended IDE)
- **Git**: For version control

### Backend Setup
- **Supabase Project**: Access to Village Tech v4 Supabase instance
- **Environment Variables**: `.env` file with Supabase credentials

### Hardware (for RFID testing)
- iOS device with NFC capability (iPhone 7+) OR
- Android device with NFC capability (Android 8.0+)
- RFID test stickers (13.56 MHz NFC tags)

---

## 🚀 Quick Start (5 minutes)

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/village-tech-v4.git
cd village-tech-v4
git checkout 004-sentinel-app-mobile
```

### 2. Navigate to Sentinel App
```bash
cd apps/sentinel
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Environment
Create `.env` file in `apps/sentinel/`:
```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Environment
ENVIRONMENT=development

# Feature Flags
ENABLE_RFID=true
ENABLE_OFFLINE_MODE=true
```

### 5. Run the App
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For Web (limited features)
flutter run -d chrome
```

---

## 🏗️ Project Structure

```
apps/sentinel/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   │
│   ├── core/                        # Core infrastructure
│   │   ├── auth/
│   │   │   ├── auth_provider.dart   # Supabase auth integration
│   │   │   └── guard_session.dart   # Guard session management
│   │   ├── storage/
│   │   │   ├── local_db.dart        # Drift database setup
│   │   │   └── encryption.dart      # SQLCipher encryption
│   │   ├── sync/
│   │   │   ├── sync_service.dart    # Background sync orchestrator
│   │   │   └── sync_queue.dart      # Offline queue management
│   │   ├── rfid/
│   │   │   └── nfc_manager.dart     # NFC/RFID integration
│   │   └── navigation/
│   │       └── app_router.dart      # GoRouter configuration
│   │
│   ├── features/                    # Feature modules (Clean Architecture)
│   │   ├── rfid_verification/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── rfid_scan_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   └── sticker_result_card.dart
│   │   │   │   └── providers/
│   │   │   │       └── rfid_provider.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── rfid_sticker.dart
│   │   │   │   ├── usecases/
│   │   │   │   │   └── validate_rfid_usecase.dart
│   │   │   │   └── repositories/
│   │   │   │       └── rfid_repository.dart (interface)
│   │   │   └── data/
│   │   │       ├── repositories/
│   │   │       │   └── rfid_repository_impl.dart
│   │   │       ├── datasources/
│   │   │       │   ├── rfid_remote_datasource.dart
│   │   │       │   └── rfid_local_datasource.dart
│   │   │       └── models/
│   │   │           └── rfid_sticker_model.dart
│   │   │
│   │   ├── guest_management/        # Similar structure
│   │   ├── delivery_tracking/       # Similar structure
│   │   ├── construction_permits/    # Similar structure
│   │   ├── incident_reporting/      # Similar structure
│   │   └── village_info/            # Similar structure
│   │
│   └── shared/
│       ├── widgets/                 # Reusable UI components
│       │   ├── custom_button.dart
│       │   ├── loading_indicator.dart
│       │   └── error_display.dart
│       ├── theme/
│       │   ├── app_theme.dart       # Material 3 theme
│       │   ├── app_colors.dart      # Design tokens
│       │   └── app_text_styles.dart
│       └── utils/
│           ├── validators.dart
│           ├── formatters.dart
│           └── constants.dart
│
├── test/                            # Tests
│   ├── unit/
│   ├── widget/
│   ├── integration/
│   └── mocks/
│
├── android/                         # Android platform code
├── ios/                             # iOS platform code
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Linting rules
```

---

## 📦 Key Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Supabase Backend
  supabase_flutter: ^2.5.0          # Supabase client

  # State Management
  flutter_riverpod: ^2.4.9          # State management

  # Navigation
  go_router: ^14.0.0                # Declarative routing

  # Local Storage & Encryption
  drift: ^2.14.0                    # Type-safe SQLite
  drift_sqflite: ^2.0.0             # SQLite backend
  sqlcipher_flutter_libs: ^0.6.1   # Database encryption
  flutter_secure_storage: ^9.0.0    # Secure key storage

  # RFID/NFC
  nfc_manager: ^3.3.0               # NFC tag reading

  # Background Services
  workmanager: ^0.5.2               # Periodic sync tasks
  connectivity_plus: ^5.0.0         # Network monitoring

  # Push Notifications
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.2.3

  # Utilities
  envied: ^0.5.0                    # Environment variables
  logger: ^2.0.0                    # Logging
  intl: ^0.19.0                     # Internationalization
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0        # Strict linting rules
  mockito: ^5.4.0                   # Mocking for tests
  build_runner: ^2.4.0              # Code generation
  drift_dev: ^2.14.0                # Drift code gen
  envied_generator: ^0.5.0          # .env code gen
```

---

## 🔑 Key Workflows

### 1. RFID Verification Flow

```dart
// lib/features/rfid_verification/presentation/screens/rfid_scan_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';

class RfidScanScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfidState = ref.watch(rfidProvider);

    return Scaffold(
      appBar: AppBar(title: Text('RFID Verification')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startNfcScan(ref),
          child: Text('Scan RFID Sticker'),
        ),
      ),
    );
  }

  Future<void> _startNfcScan(WidgetRef ref) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      // Handle NFC not available
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Extract sticker code from NFC tag
      final stickerCode = extractStickerCode(tag);

      // Validate via provider
      await ref.read(rfidProvider.notifier).validateSticker(stickerCode);

      NfcManager.instance.stopSession();
    });
  }
}
```

### 2. Offline Sync Flow

```dart
// lib/core/sync/sync_service.dart

import 'package:workmanager/workmanager.dart';

class SyncService {
  static const syncTaskName = 'sentinel_sync';

  static void initialize() {
    Workmanager().initialize(callbackDispatcher);

    // Register periodic sync (every 15 minutes)
    Workmanager().registerPeriodicTask(
      'periodic_sync',
      syncTaskName,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> callbackDispatcher() async {
    Workmanager().executeTask((task, inputData) async {
      // Process sync queue
      final syncQueue = SyncQueue();
      await syncQueue.processPendingItems();
      return true;
    });
  }
}
```

### 3. Database Encryption Setup

```dart
// lib/core/storage/local_db.dart

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() async {
    final secureStorage = FlutterSecureStorage();

    // Get or generate encryption key
    String? encryptionKey = await secureStorage.read(key: 'db_key');
    if (encryptionKey == null) {
      encryptionKey = generateSecureKey();
      await secureStorage.write(key: 'db_key', value: encryptionKey);
    }

    final dbPath = await getDatabasePath();

    return NativeDatabase.createInBackground(
      File(dbPath),
      setup: (db) {
        db.execute('PRAGMA key = "$encryptionKey"');
        db.execute('PRAGMA cipher_page_size = 4096');
      },
    );
  }
}
```

---

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit

# Run with coverage
flutter test --coverage
flutter pub run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
```

### Widget Tests Example
```dart
// test/widget/rfid_scan_screen_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RFID scan screen displays scan button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: RfidScanScreen()),
      ),
    );

    expect(find.text('Scan RFID Sticker'), findsOneWidget);
  });
}
```

### Integration Tests
```bash
# Run integration tests on device
flutter test integration_test/app_test.dart
```

---

## 🔐 Security Best Practices

### 1. Environment Variables
- NEVER commit `.env` to git
- Use `envied` package for compile-time environment injection
- Rotate Supabase keys regularly

### 2. Secure Storage
- All encryption keys stored in `flutter_secure_storage`
- Database encrypted with SQLCipher (AES-256)
- Implement biometric authentication for sensitive operations

### 3. RFID Security
- Always validate sticker codes against backend
- Never trust tag data alone
- Implement tag authenticity checks
- Log all verification attempts

### 4. Network Security
- Use HTTPS for all API calls (Supabase enforces this)
- Implement certificate pinning for production
- Validate JWT tokens on every request

---

## 🚨 Troubleshooting

### NFC Not Working
**Issue**: NFC scanning fails on device
**Solutions**:
1. Check device has NFC hardware: `NfcManager.instance.isAvailable()`
2. Ensure NFC is enabled in device settings
3. For iOS: Verify NFC capability in Xcode entitlements
4. For Android: Add NFC permission in AndroidManifest.xml

### Background Sync Not Triggering
**Issue**: Offline logs not syncing
**Solutions**:
1. Check battery optimization exemptions for app
2. Verify WorkManager is initialized in `main.dart`
3. Test with shorter intervals in development (min 15 min in production)
4. Check network constraints are met

### Database Encryption Error
**Issue**: "SQLCipher error" on database open
**Solutions**:
1. Verify encryption key exists in secure storage
2. Check SQLCipher libraries are properly linked (see platform-specific setup)
3. Ensure PRAGMA key is set before any queries

### Build Errors
**Issue**: Build fails with dependency conflicts
**Solutions**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📱 Platform-Specific Setup

### iOS Setup (Xcode)
1. Enable NFC capability:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target → Signing & Capabilities
   - Add "Near Field Communication Tag Reading"

2. Update Info.plist:
```xml
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC to scan RFID stickers for vehicle verification</string>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
  <string>A0000002471001</string>
</array>
```

3. Background modes:
   - Add "Background fetch" and "Remote notifications" capabilities

### Android Setup
1. Update AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<uses-feature android:name="android.hardware.nfc" android:required="false" />
```

2. Notification channels (for Android 8+):
   - Configure in `main.dart` on app start

---

## 🚢 Deployment

### Build for Production

#### iOS
```bash
# Build IPA
flutter build ipa --release

# Open in Xcode for App Store upload
open build/ios/archive/Runner.xcarchive
```

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### CI/CD (GitHub Actions Example)
```yaml
# .github/workflows/sentinel-app.yml
name: Sentinel App CI/CD

on:
  push:
    paths:
      - 'apps/sentinel/**'
      - 'packages/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: cd apps/sentinel && flutter pub get
      - run: cd apps/sentinel && flutter test
      - run: cd apps/sentinel && flutter build apk --release
```

---

## 📚 Additional Resources

### Documentation
- [Feature Specification](./spec.md)
- [Data Model](./data-model.md)
- [API Contracts](./contracts/README.md)
- [Research Findings](./research.md)

### External Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [nfc_manager Package](https://pub.dev/packages/nfc_manager)
- [Drift Documentation](https://drift.simonbinder.eu/)

### Team Contacts
- **Backend Lead**: backend-team@villagetech.com
- **Mobile Lead**: mobile-team@villagetech.com
- **Security Team**: security@villagetech.com

---

## 🎯 Next Steps

1. ✅ Complete Phase 0 research (DONE)
2. ✅ Complete Phase 1 design artifacts (DONE)
3. ⏳ Phase 2: Generate tasks.md via `/speckit.tasks` command
4. ⏳ Phase 3: Implement RFID verification feature (Priority P1)
5. ⏳ Phase 4: Implement guest management (Priority P1)
6. ⏳ Phase 5: Implement delivery tracking (Priority P2)

---

**Last Updated**: 2025-10-10
**Version**: 1.0.0
**Maintained By**: Village Tech v4 Mobile Team
