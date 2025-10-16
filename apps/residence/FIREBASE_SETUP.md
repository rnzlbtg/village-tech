# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Cloud Messaging (FCM)

## iOS Configuration (T003)

1. Download `GoogleService-Info.plist` from Firebase Console:
   - Go to Project Settings → General → Your apps → iOS app
   - Click "Download GoogleService-Info.plist"

2. Place the file at:
   ```
   apps/residence/ios/Runner/GoogleService-Info.plist
   ```

3. Open `ios/Runner.xcworkspace` in Xcode and add the file to the Runner target

## Android Configuration (T004)

1. Download `google-services.json` from Firebase Console:
   - Go to Project Settings → General → Your apps → Android app
   - Click "Download google-services.json"

2. Place the file at:
   ```
   apps/residence/android/app/google-services.json
   ```

3. Ensure `android/build.gradle` includes:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```

4. Ensure `android/app/build.gradle` includes at the bottom:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Verification

After configuration, verify FCM setup:
```bash
cd apps/residence
flutter run
```

Check that FCM token is generated and saved to `user_fcm_tokens` table in Supabase.
