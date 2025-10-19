# Quick Start Guide: Sentinel App - Gate Guard Access Control

**Version**: 1.0.0
**Date**: 2025-10-19
**Target Audience**: Developers implementing the Sentinel mobile application

---

## Overview

The Sentinel app is a Flutter-based mobile application for gate guards to manage access control in residential communities. This guide provides everything needed to set up, configure, and run the application locally.

### Key Features

- **RFID Verification**: Scan and validate vehicle RFID stickers
- **Guest Management**: Pre-register and verify guest entries
- **Delivery Tracking**: Log and monitor delivery operations
- **Construction Access**: Verify construction permits and worker authorization
- **Incident Reporting**: Document security incidents and rule violations
- **Offline Capability**: Full offline operation with automatic sync
- **Real-time Updates**: Live synchronization with backend services

---

## Prerequisites

### Development Environment

```bash
# Required Software
- Flutter SDK 3.24+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (Android development)
- Xcode (iOS development - macOS only)
- Git

# Optional but Recommended
- Android device or emulator for testing
- iOS device or simulator for testing
- Postman or similar API testing tool
```

### Platform Setup

#### Flutter Installation
```bash
# Install Flutter (if not already installed)
# Visit: https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor
```

#### Android Development
```bash
# Install Android Studio
# Configure Android SDK
# Enable developer options on test device
# Install USB drivers (if using physical device)
```

#### iOS Development (macOS only)
```bash
# Install Xcode from App Store
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods
```

---

## Project Setup

### 1. Clone Repository

```bash
# Clone the repository
git clone https://github.com/your-org/village-tech-v4.git
cd village-tech-v4

# Switch to the Sentinel app branch
git checkout 004-sentinel-app-mobile
```

### 2. Dependencies Installation

```bash
# Navigate to Sentinel app directory
cd apps/sentinel

# Install Flutter dependencies
flutter pub get

# Install iOS dependencies (macOS only)
cd ios && pod install && cd ..
```

### 3. Environment Configuration

Create environment configuration files:

```bash
# Create environment files
touch .env.local
touch .env.development
touch .env.production
```

#### Environment Variables (.env.local)
```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# App Configuration
FLUTTER_ENV=development
APP_NAME=Sentinel Dev
APP_VERSION=1.0.0

# API Configuration
API_BASE_URL=https://dev-api.villagetech.com/v1
API_TIMEOUT=30000

# Logging
LOG_LEVEL=debug
ENABLE_CRASHLYTICS=false

# Feature Flags
ENABLE_BIOMETRIC_AUTH=true
ENABLE_OFFLINE_MODE=true
ENABLE_PUSH_NOTIFICATIONS=true
```

### 4. Configuration Files

Update app configuration files:

#### `lib/utils/constants.dart`
```dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isDevelopment =>
    String.fromEnvironment('FLUTTER_ENV') == 'development';

  static bool get isProduction =>
    String.fromEnvironment('FLUTTER_ENV') == 'production';
}
```

#### `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Add required permissions -->
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

#### `ios/Runner/Info.plist`
```xml
<!-- Add iOS permissions -->
<key>NSNFCUsageDescription</key>
<string>This app uses NFC to scan RFID stickers for vehicle verification</string>
<key>NSCameraUsageDescription</key>
<string>This app uses camera to take photos for incident reports</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location for gate security verification</string>
```

---

## Running the Application

### 1. Development Server

```bash
# Start Flutter development server
flutter run

# Or run on specific device
flutter run -d chrome          # Web development
flutter run -d android         # Android device/emulator
flutter run -d ios             # iOS device/simulator (macOS only)
```

### 2. Hot Reload & Hot Restart

```bash
# Hot reload (preserves app state)
# Press 'r' in terminal or use IDE hot reload

# Hot restart (resets app state)
# Press 'R' in terminal or use IDE hot restart
```

### 3. Build for Testing

```bash
# Debug build
flutter build apk --debug      # Android debug
flutter build ios --debug      # iOS debug (macOS only)

# Profile build (for performance testing)
flutter build apk --profile    # Android profile
flutter build ios --profile    # iOS profile (macOS only)
```

---

## Authentication Setup

### 1. Supabase Configuration

Configure Supabase authentication:

```sql
-- Create guard_users table
CREATE TABLE guard_users (
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

-- Enable RLS
ALTER TABLE guard_users ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Guards can view tenant data" ON guard_users
  FOR ALL USING (tenant_id = auth.jwt() ->> 'tenant_id'::uuid);
```

### 2. Test Users

Create test guard accounts:

```sql
-- Create test guard users
INSERT INTO guard_users (email, full_name, role, tenant_id, employee_id) VALUES
  ('head.guard@villagetech.com', 'John Smith', 'head_guard', 'tenant-uuid-1', 'G001'),
  ('guard.officer@villagetech.com', 'Jane Doe', 'guard_officer', 'tenant-uuid-1', 'G002'),
  ('guard.trainee@villagetech.com', 'Mike Johnson', 'guard_trainee', 'tenant-uuid-1', 'G003');
```

### 3. Test Authentication

```dart
// Test login credentials
final testCredentials = {
  'email': 'head.guard@villagetech.com',
  'password': 'TempPassword123!',
  'tenant_code': 'DEMO-VILLAGE',
};
```

---

## Core Features Testing

### 1. RFID Verification

```dart
// Test RFID scanning
Future<void> testRfidScanning() async {
  try {
    final nfcManager = NfcManagerService();
    await nfcManager.startScanning();

    nfcManager.scanResults.listen((result) {
      if (result.success) {
        print('RFID Code: ${result.rfidCode}');
        // Verify sticker with backend
        verifyRfidSticker(result.rfidCode);
      }
    });
  } catch (e) {
    print('RFID scanning error: $e');
  }
}
```

### 2. Guest Management

```dart
// Test guest registration
Future<void> testGuestRegistration() async {
  final guest = Guest(
    guestName: 'John Visitor',
    phoneNumber: '+1234567890',
    householdId: 'household-uuid-1',
    scheduledDate: DateTime.now(),
    expectedArrival: const TimeOfDay(hour: 14, minute: 30),
    purpose: 'Social visit',
  );

  final result = await guestService.registerGuest(guest);
  print('Guest registered: ${result.success}');
}
```

### 3. Offline Operation

```dart
// Test offline capability
Future<void> testOfflineMode() async {
  // Simulate network disconnection
  await networkMonitor.simulateOffline();

  // Create entry log offline
  final entry = EntryLog(
    entryType: 'guest',
    personName: 'Test Visitor',
    verificationMethod: 'manual',
    destination: 'House 123',
  );

  final result = await entryService.createEntryLog(entry);
  print('Offline entry created: ${result.success}');

  // Verify it's queued for sync
  final pendingSync = await syncService.getPendingOperations();
  print('Pending sync operations: ${pendingSync.length}');
}
```

---

## Testing

### 1. Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### 2. Widget Tests

```bash
# Run widget tests
flutter test test/widgets/

# Run specific widget test
flutter test test/widgets/login_form_test.dart
```

### 3. Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run integration test on specific device
flutter test integration_test/app_test.dart -d android
```

### 4. Manual Testing Checklist

#### Authentication
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Biometric authentication
- [ ] Session timeout
- [ ] Token refresh

#### RFID Scanning
- [ ] Scan valid RFID sticker
- [ ] Scan expired/invalid sticker
- [ ] Handle NFC unavailability
- [ ] Multiple scan attempts
- [ ] Scan timeout handling

#### Guest Management
- [ ] Register new guest
- [ ] Search existing guests
- [ ] Check in guest
- [ ] Check out guest
- [ ] Cancel guest registration

#### Offline Operation
- [ ] Create entries offline
- [ ] Sync queued operations
- [ ] Handle sync conflicts
- [ ] Network reconnection
- [ ] Data consistency verification

---

## Troubleshooting

### Common Issues

#### 1. NFC Not Working
```bash
# Check NFC permissions
# Android: Settings > Apps > Sentinel > Permissions > NFC
# iOS: Settings > Privacy & Security > NFC

# Verify device NFC capability
flutter pub run flutter_nfc_kit:check_nfc_availability
```

#### 2. Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# iOS specific
cd ios && pod install && cd ..
```

#### 3. Supabase Connection Issues
```bash
# Verify environment variables
print('Supabase URL: ${Environment.supabaseUrl}');
print('Supabase Key: ${Environment.supabaseAnonKey}');

# Test connection
final response = await supabase.from('tenants').select().limit(1);
print('Connection test: ${response}');
```

#### 4. Sync Issues
```bash
# Check sync status
final syncStatus = await syncService.getSyncStatus();
print('Sync status: ${syncStatus}');

# Clear sync queue (development only)
await syncService.clearSyncQueue();
```

### Debug Mode

Enable debug logging:

```dart
// Enable debug logging
Logger.level = Level.debug;

// Monitor network requests
HttpClient.logRequests = true;

// Enable Flutter inspector
flutter run --debug
```

---

## Deployment

### 1. Android Build

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Sign APK (if needed)
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore keystore.jks build/app/outputs/flutter-apk/app-release.apk alias_name
```

### 2. iOS Build (macOS only)

```bash
# Build iOS app
flutter build ios --release

# Open in Xcode for final build and archive
open ios/Runner.xcworkspace
```

### 3. Web Build

```bash
# Build web app
flutter build web --release
```

---

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Flutter Docs](https://supabase.com/docs/guides/getting-started/flutter)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://gorouter.dev/)

### Packages Used
- `supabase_flutter` - Backend integration
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `drift` - Local database
- `flutter_nfc_kit` - RFID scanning
- `local_auth` - Biometric authentication
- `connectivity_plus` - Network monitoring
- `firebase_messaging` - Push notifications

### Support
- GitHub Issues: [Repository Issues](https://github.com/your-org/village-tech-v4/issues)
- Development Team: dev-team@villagetech.com
- Documentation: docs.villagetech.com

---

## Next Steps

1. **Complete Setup**: Follow this guide to set up your development environment
2. **Review Architecture**: Read the [data-model.md](data-model.md) for detailed entity relationships
3. **API Reference**: Review [contracts/openapi.yaml](contracts/openapi.yaml) for API specifications
4. **Start Development**: Begin implementing features following the clean architecture pattern
5. **Testing**: Write comprehensive tests for all features
6. **Code Review**: Submit pull requests for team review

Happy coding! 🚀