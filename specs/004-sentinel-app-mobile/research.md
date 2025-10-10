# Research Findings: Sentinel App Mobile - Technical Implementation

**Date**: 2025-10-10
**Feature**: Sentinel App - Gate Guard Access Control Mobile Application
**Purpose**: Resolve technical unknowns and establish implementation patterns

---

## 1. RFID Hardware Integration for Flutter

### Decision
**Recommended Approach: Embedded NFC via `nfc_manager` package for standard NFC/RFID tags (13.56 MHz), with Platform Channels for specialized external RFID readers**

### Rationale
- Most modern smartphones have built-in NFC capabilities (13.56 MHz frequency), eliminating need for external hardware in many cases
- The `nfc_manager` package is the most actively maintained and community-recommended solution as of 2025
- External readers via Bluetooth/USB should only be used when dealing with UHF RFID or specialized frequency requirements
- Embedded NFC provides better user experience and lower hardware costs

### Implementation Pattern
```
1. For Standard NFC Tags (13.56 MHz):
   - Use nfc_manager package for tag reading/writing
   - Implement session-based scanning with automatic pooling
   - Validate tag data against backend before granting access

2. For External RFID Readers (UHF/Custom):
   - Create Platform Channels (MethodChannel for operations, EventChannel for streams)
   - Implement native code (Kotlin/Swift) interfacing with manufacturer SDK
   - Bridge data to Flutter via JSON serialization
```

### Key Packages/Tools
- **Primary: `nfc_manager` (latest stable version)**
  - Cross-platform (iOS & Android)
  - Active maintenance and community support
  - Simple API for NDEF message reading/writing

- **Alternative: `flutter_nfc_kit`**
  - Supports Android, iOS, and Web (via WebUSB)
  - Two operation modes: polling and event streaming
  - More comprehensive tag format support (NFC-A/B/F/V, ISO-DEP, MIFARE, Felica)

- **For External Readers:**
  - `flutter_blue_plus` for BLE communication
  - `flutter_bluetooth_serial` for classic Bluetooth (Android only)
  - Platform Channels for manufacturer-specific SDKs (e.g., Zebra RFID SDK)

### Alternatives Considered
- **flutter_nfc_kit**: Rejected as primary due to less community adoption, though offers more advanced features
- **Custom native implementation only**: Rejected due to higher development overhead
- **External readers as primary solution**: Rejected due to cost and complexity; reserved for specialized requirements

### Security/Performance Considerations

**Security Best Practices:**
- Always validate NFC tag data - never trust tag contents without backend verification
- Implement tag authenticity checks to prevent spoofing/cloning attacks
- Don't store sensitive data solely on tags - use tags as identifiers only
- Request user permission before writing to tags
- Implement timeout mechanisms for scanning sessions (3-5 seconds)
- Use encrypted communication between app and backend for tag verification

**RFID Security Landscape (2025):**
- RFID cards without encryption are vulnerable to skimming attacks
- Static, unencrypted data can be read by portable RFID readers
- Modern smartphones can read poorly secured 13.56 MHz RFID cards
- Implement challenge-response authentication where possible

**Performance Notes:**
- iOS NFC reader is more sensitive on front side of device
- Most smartphones cannot read low-frequency RFID (125 kHz)
- NFC scanning should have 3-5 second timeout for better UX
- Background tag reading requires specific iOS configuration

**Recommended Approach: Embedded NFC vs External Reader**
- **Use Embedded NFC when:**
  - Working with standard access cards (13.56 MHz)
  - Cost optimization is important
  - User experience is priority
  - Target devices are modern smartphones (iPhone 7+, Android with NFC)

- **Use External Reader when:**
  - Dealing with UHF RFID (long-range reading required)
  - Working with legacy 125 kHz cards
  - Need simultaneous multi-tag reading
  - Require industrial-grade reliability in harsh environments

---

## 2. Background Service Architecture for Offline Sync

### Decision
**Recommended Approach: Hybrid architecture using WorkManager for periodic sync + flutter_background_service for critical real-time tasks, with queue-based offline-first pattern**

### Rationale
- WorkManager provides reliable, battery-efficient periodic execution that survives app termination and device reboots
- Android 14 and iOS 17 have stricter background execution rules requiring platform-native scheduling
- Queue-based architecture decouples local operations from network sync, ensuring data integrity
- Exponential backoff prevents battery drain from repeated failed sync attempts

### Implementation Pattern
```
Offline-First Architecture Layers:

1. Local Persistence Layer (Hive/Drift)
   - Immediate write to local database
   - Generate unique client IDs for all records
   - Timestamp all operations

2. Sync Queue Layer (SQLite table)
   - Record sync events: {id, operation, entity, timestamp, retryCount, status}
   - Support operation types: CREATE, UPDATE, DELETE
   - Implement queue compaction (e.g., delete UPDATE if followed by DELETE)

3. Background Sync Service (WorkManager)
   - Periodic tasks: Minimum 15-minute intervals
   - Constraints: NetworkType.CONNECTED, requiresBatteryNotLow
   - Process queue in batches
   - Implement exponential backoff: baseDelay * (2^retryCount) with jitter

4. State Management Layer (BLoC/Riverpod)
   - Optimistic UI updates
   - Handle rollback on sync failure
   - Real-time sync status notifications
```

### Key Packages/Tools
- **Primary Packages:**
  - `workmanager: ^0.5.2` - Periodic background tasks
  - `flutter_background_service: ^5.0.0` - Continuous foreground services (use sparingly)
  - `connectivity_plus: ^5.0.0` - Network status monitoring
  - `hive: ^2.2.3` or `drift: ^2.14.0` - Local persistence
  - `flutter_bloc: ^8.1.3` or `riverpod: ^2.4.9` - State management

- **Specialized Packages:**
  - `flutter_network_watcher` - Advanced retry with exponential backoff and jitter
  - `offline_sync_kit` - Automatic reconnection with conflict resolution

### Alternatives Considered
- **flutter_background_service only**: Rejected due to battery concerns; Android 14+ restricts background services
- **Manual timer-based sync**: Rejected due to unreliability and battery drain
- **Real-time sync only (no queue)**: Rejected due to data loss risk in poor connectivity
- **Firebase Realtime Database sync**: Rejected due to offline-first requirement and vendor lock-in

### Security/Performance Considerations

**Battery Optimization:**
- WorkManager respects Doze mode and App Standby automatically
- Minimum 15-minute periodic interval prevents excessive wake-ups
- Constraints ensure tasks run during optimal conditions (charging, Wi-Fi)
- Foreground services require persistent notification and should only be used for critical tasks

**Handling Platform Restrictions:**
- **Android 14:** Force-quit apps won't receive background tasks until manually reopened
- **iOS 17:** Apps swiped from app switcher must be reopened for background tasks
- **Solution:** Educate users about battery optimization exemptions for critical apps

**Sync Queue Best Practices:**
- Implement dead letter queue for permanently failed items (after max retries)
- Use priority-based processing for time-sensitive operations
- Enable queue persistence across app sessions
- Implement jitter (10% randomization) in retry delays to prevent thundering herd

**Conflict Resolution Strategies:**
1. **Last-Write-Wins (LWW)** - Simplest, based on timestamps
2. **Merge Strategy** - Combine changes with business logic rules
3. **User-Driven Resolution** - Present conflicts to user for manual resolution
4. **CRDTs** - Conflict-free Replicated Data Types for deterministic convergence (advanced)

**Exponential Backoff Implementation:**
```dart
final baseDelay = Duration(seconds: 2);
final maxDelay = Duration(seconds: 60);
final jitterPercent = 0.1;

final delay = min(baseDelay * pow(2, retryCount), maxDelay);
final jitter = delay * (Random().nextDouble() * jitterPercent);
final finalDelay = delay + jitter;
```

---

## 3. Offline Data Encryption Strategy

### Decision
**Recommended Approach: Drift with SQLCipher encryption for structured data + flutter_secure_storage for encryption keys, using AES-256 encryption**

### Rationale
- Drift provides SQL capabilities with compile-time type safety and robust migration support
- SQLCipher offers 256-bit AES encryption with zero configuration overhead
- flutter_secure_storage leverages hardware-backed keystores (Android KeyStore, iOS Keychain)
- Separation of data encryption from key storage follows security best practices
- This combination is production-proven and actively maintained in 2025

### Implementation Pattern
```
Layered Encryption Architecture:

1. Key Management Layer
   - Generate encryption key on first launch using Dart's crypto libraries
   - Store key in flutter_secure_storage (uses Keychain/KeyStore)
   - Optional: Implement key rotation strategy

2. Database Encryption Layer
   - Use Drift with drift_sqflite and sqlcipher_flutter_libs
   - Pass encryption key from secure storage on database open
   - All data encrypted at rest automatically

3. Sensitive Field Encryption (Optional)
   - Double-encrypt PII fields using AES-256
   - Store encrypted blobs in database
   - Decrypt only when needed for display

4. Secure Deletion
   - Implement secure key deletion on logout
   - Overwrite sensitive data before deletion
   - Clear in-memory caches
```

### Key Packages/Tools
- **Primary Stack:**
  - `drift: ^2.14.0` - Type-safe SQL database with migration support
  - `drift_sqflite: ^2.0.0` - SQLite backend for Drift
  - `sqlcipher_flutter_libs: ^0.6.1` - SQLCipher encryption for SQLite
  - `flutter_secure_storage: ^9.0.0` - Secure key storage

- **Alternative Options:**
  - **Hive Encrypted Boxes:**
    - `hive: ^2.2.3`
    - Built-in AES-256 encryption via `HiveAesCipher`
    - Simpler API but less suitable for complex queries

  - **Plain sqflite with sqflite_sqlcipher:**
    - `sqflite_sqlcipher: ^3.1.0`
    - Drop-in replacement for sqflite
    - Good for existing sqflite projects

### Alternatives Considered
- **Hive encrypted boxes**: Suitable for simple key-value storage, but Drift chosen for complex queries and type safety
- **Manual AES encryption per field**: Too much overhead and error-prone
- **Server-side encryption only**: Rejected due to offline-first requirement
- **Device encryption only**: Insufficient for sensitive access control logs

### Security/Performance Considerations

**Key Management (Critical):**
- NEVER hardcode encryption keys in source code
- Generate cryptographically secure random keys (32 bytes for AES-256)
- Store keys exclusively in flutter_secure_storage
- Consider implementing key rotation for long-lived apps
- Implement secure key deletion on logout/uninstall

**Drift with SQLCipher Pattern:**
```dart
final encryptionKey = await secureStorage.read(key: 'dbKey');
final executor = NativeDatabase.createInBackground(
  File(dbPath),
  setup: (db) => db.execute('PRAGMA key = "$encryptionKey"'),
);
```

**Security Vulnerabilities & Mitigations:**
- **Runtime Attacks:** Encrypted data can still be accessed on rooted/jailbroken devices. Mitigation: Implement root/jailbreak detection, use obfuscation
- **Padding Oracle Attacks:** Current flutter_secure_storage has theoretical vulnerability. Mitigation: Keep packages updated, monitor security advisories
- **Key Storage Limitations:** Hardware keystores not immune to runtime attacks. Mitigation: Implement app-level authentication (biometrics, PIN)

**Performance Considerations:**
- SQLCipher adds ~5-15% performance overhead for read/write operations
- Hive encryption overhead is minimal (<5%)
- Decrypt only what's needed - avoid loading entire encrypted datasets
- Use indexed queries to minimize decryption operations
- Consider caching decrypted data in-memory for frequently accessed records (with proper lifecycle management)

**Biometric Authentication Integration:**
```dart
final authenticated = await localAuth.authenticate(
  localizedReason: 'Authenticate to access secure data'
);
if (authenticated) {
  final key = await secureStorage.read(key: 'encryptionKey');
}
```

---

## 4. FCM Integration for Real-time Notifications

### Decision
**Recommended Approach: Firebase Cloud Messaging with firebase_messaging package, implementing both notification messages for user alerts and data messages for silent sync triggers**

### Rationale
- FCM is the industry standard for cross-platform push notifications as of 2025
- Native integration with iOS APNs and Android FCM ensures reliable delivery
- Supports both foreground notifications and background data sync triggers
- firebase_messaging package is officially maintained and follows latest platform guidelines
- Silent push enables efficient offline sync without user interruption

### Implementation Pattern
```
FCM Architecture:

1. Initialization & Permission Flow
   iOS/macOS/Web:
   - Request permission via requestPermission()
   - Handle authorization/denied states
   - Note: Permission cannot be re-requested if denied (Apple policy)

   Android:
   - Permissions granted automatically (no user prompt)
   - Configure notification channels for Android 8+

2. Message Types
   a) Notification Messages (User-visible)
      - Display notifications when app is background/terminated
      - Blocked when app is foreground (handled manually)
      - Use flutter_local_notifications for foreground display

   b) Data-Only Messages (Silent sync)
      - Set priority: "high" (Android) or content-available: 1 (iOS)
      - Trigger background sync on receive
      - Do not display notification

3. Background Message Handling
   - Define top-level function for background handler
   - Register with FirebaseMessaging.onBackgroundMessage()
   - Must complete quickly (<30s Android, <30s iOS)
   - Use for triggering sync, not performing it

4. Token Management
   - Retrieve FCM token on app start
   - Store token in backend for targeted messaging
   - Listen to token refresh events
   - Update backend when token changes
```

### Key Packages/Tools
- **Primary Packages (2025 versions):**
  - `firebase_core: ^3.6.0` - Firebase initialization
  - `firebase_messaging: ^15.1.3` - FCM functionality
  - `flutter_local_notifications: ^17.2.3` - Foreground notification display

- **Supporting Packages:**
  - `permission_handler: ^11.0.0` - Manage notification permissions
  - `flutter_app_badger: ^1.5.0` - Badge count management

### Alternatives Considered
- **OneSignal**: Rejected due to preference for first-party Firebase integration
- **AWS SNS**: Rejected due to additional complexity and cost
- **Custom WebSocket solution**: Rejected due to battery drain and implementation complexity
- **Pusher/PubNub**: Rejected due to cost and vendor lock-in

### Security/Performance Considerations

**iOS Permission Implementation:**
```dart
final settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

// CRITICAL: Once denied, cannot re-request - direct user to Settings
if (settings.authorizationStatus == AuthorizationStatus.denied) {
  // Guide user to Settings
}
```

**Background Handler Implementation:**
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Trigger sync or process data
  // Do NOT perform long-running operations here
  // Queue sync task instead

  if (message.data.containsKey('sync_trigger')) {
    await SyncQueue.instance.triggerSync();
  }
}
```

**Silent Push for Data Sync:**
```json
{
  "to": "DEVICE_FCM_TOKEN",
  "priority": "high",
  "content_available": true,
  "data": {
    "sync_trigger": "true",
    "sync_type": "incremental",
    "timestamp": "2025-10-10T10:30:00Z"
  }
}
```

**Data-Only Message Priority (Critical):**
- **Android:** Set `"priority": "high"` in payload, otherwise message ignored when app is background/terminated
- **iOS:** Set `"content_available": true` or `"content-available": 1`
- Low priority data messages will be dropped by OS when app is not active

**Message State Handling:**

| App State | Notification Message | Data Message |
|-----------|---------------------|--------------|
| Foreground | onMessage (must handle manually) | onMessage |
| Background | System tray (automatic) | onBackgroundMessage |
| Terminated | System tray (automatic) | onBackgroundMessage |

**Token Management Best Practices:**
```dart
// Get initial token
final token = await FirebaseMessaging.instance.getToken();
await sendTokenToBackend(token);

// Listen for token refresh
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  sendTokenToBackend(newToken);
});

// Delete token on logout
await FirebaseMessaging.instance.deleteToken();
```

**Security Considerations:**
1. FCM tokens should be transmitted securely (HTTPS)
2. Implement token validation on backend
3. Never include sensitive data in notification payload
4. Use notification as trigger, fetch actual data securely
5. Implement rate limiting on backend to prevent spam

**Performance & Battery Optimization:**
- Background handlers must complete within 30 seconds
- Use data messages to trigger WorkManager tasks, not perform sync directly
- Batch notifications when appropriate to reduce wake-ups
- Test on real iOS devices (simulators don't support push notifications)

---

## Summary & Recommendations

### Recommended Technology Stack

**Core Flutter Packages:**
- **NFC/RFID:** `nfc_manager` (primary), Platform Channels for external readers
- **Offline Sync:** `workmanager` + `connectivity_plus`
- **Local Storage:** `drift` + `sqlcipher_flutter_libs`
- **Encryption:** `flutter_secure_storage` for key management
- **Push Notifications:** `firebase_messaging` + `flutter_local_notifications`
- **State Management:** `riverpod` (as specified in Technical Context)

### Implementation Priority

**Phase 1 - Foundation:**
1. Set up Drift database with SQLCipher encryption
2. Implement flutter_secure_storage for key management
3. Create basic offline-first architecture with sync queue

**Phase 2 - Hardware Integration:**
4. Integrate NFC reading via nfc_manager
5. Implement RFID data validation and security checks
6. Set up FCM for push notifications

**Phase 3 - Background Services:**
7. Configure WorkManager for periodic sync
8. Implement exponential backoff retry logic
9. Add conflict resolution strategies

**Phase 4 - Optimization:**
10. Fine-tune battery optimization settings
11. Implement comprehensive error handling
12. Add monitoring and analytics

### Critical Success Factors

1. **Security First:** Never compromise on encryption and data validation
2. **Test on Real Devices:** Especially for NFC, background services, and FCM
3. **Handle Platform Differences:** iOS and Android have different constraints
4. **Plan for Offline:** Queue-based sync is essential for gate guard reliability
5. **Battery Awareness:** Background tasks must be efficient and respectful of battery life
6. **User Education:** Inform users about battery optimization exemptions if needed

### Known Limitations & Mitigations

| Limitation | Platform | Mitigation |
|-----------|----------|------------|
| NFC requires manual app open after swipe away | iOS | User education, persistent notification |
| Background tasks stop after force-quit | Android 14 | Require battery optimization exemption |
| 15-minute minimum periodic sync | Android | Use FCM silent push for urgent sync |
| Low-frequency RFID not supported | Both | Use external reader via Bluetooth |
| FCM permission cannot be re-requested | iOS | Guide users to Settings, use provisional auth |

---

**Research Completed**: 2025-10-10
**Next Phase**: Phase 1 - Design & Contracts (data-model.md, contracts/, quickstart.md)
