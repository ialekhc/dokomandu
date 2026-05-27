# Dokomandu Customer App

Cloud Kitchen / Food Delivery customer mobile app built with Flutter using MVVM, Riverpod, Dio, and GoRouter.

## Overview
Dokomandu is a scalable mobile app codebase focused on:
- Location-based kitchen discovery
- Food browsing and cart management
- COD checkout flow
- Order tracking and history
- Push notification-ready architecture
- Profile and address management

## Tech Stack
- Flutter (latest stable)
- Dart (`^3.11.3` in `pubspec.yaml`)
- Architecture: MVVM (feature modular)
- State management: Riverpod (`AsyncNotifier` / `StateNotifier`)
- Networking: Dio + interceptors
- Navigation: GoRouter
- Secure storage: Flutter Secure Storage
- Local cache: SharedPreferences + Hive
- Notifications: Firebase Cloud Messaging
- Maps & location: Google Maps Flutter + Geolocator
- UI: Material 3, custom theme, Nunito Sans

## Design System
- Material 3 light and dark themes
- Brand primary color: `#193CB8`
- Typography: Nunito Sans via Google Fonts
- Reusable spacing/radius/component themes under `lib/app/theme/`

## Architecture
Feature-first MVVM modules:
- `models/`
- `services/`
- `viewmodels/`
- `screens/`
- `widgets/`

Top-level structure:

```text
lib/
  app/
    config/
    constants/
    routes/
    theme/
  core/
    api/
    errors/
    extensions/
    network/
    services/
    storage/
    utils/
    widgets/
  features/
    auth/
    cart/
    checkout/
    home/
    kitchen/
    location/
    menu/
    notifications/
    orders/
    profile/
  shared/
    models/
    providers/
    widgets/
  main.dart
```

## Implemented Modules
- Auth (email/password + OTP service methods)
- Location picker with Google Maps + service radius check
- Home feed (offers, categories, popular foods, nearby kitchens)
- Kitchen list/detail + menu browsing
- Food detail bottom sheet with variants/add-ons
- Cart with quantity, pricing, tax, and persistence
- Checkout with address selection and COD flow
- Orders (active/history/detail/timeline/cancel/reorder)
- Notifications list (read state)
- Profile/edit profile/theme mode selection/logout/delete account

## API Layer
- `BaseApiService` wrappers for `GET/POST/PATCH/DELETE`
- Generic API response model parsing
- Central Dio client with auth token injection
- Refresh token handling interceptor
- Retry interceptor
- Debug request/response logging (debug mode)

## Runtime Flags
Configuration lives in `lib/app/config/app_config.dart`.

| Flag | Default | Description |
|---|---|---|
| `API_BASE_URL` | `https://api.example.com/v1` | Backend base URL |
| `BYPASS_AUTH` | `true` | Skips auth routes and opens app directly |
| `USE_STATIC_CONTENT` | `true` | Uses dummy/static content in services |

## Getting Started
1. Install Flutter SDK and platform toolchains (Android Studio + Xcode).
2. From project root, run:

```bash
flutter pub get
```

3. Run app (default current mode: auth bypass + static data):

```bash
flutter run
```

## Useful Run Modes
Run against real backend data with auth enabled:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-api-base-url/v1 \
  --dart-define=BYPASS_AUTH=false \
  --dart-define=USE_STATIC_CONTENT=false
```

Run with real API but keep login bypass for UI testing:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-api-base-url/v1 \
  --dart-define=BYPASS_AUTH=true \
  --dart-define=USE_STATIC_CONTENT=false
```

## Firebase Setup (FCM)
Current bootstrap is crash-safe even if Firebase is missing, but notifications require proper setup.

1. Add `android/app/google-services.json`.
2. Add `ios/Runner/GoogleService-Info.plist`.
3. Configure APNs + Firebase Messaging for iOS.
4. Re-run pods:

```bash
cd ios && pod install && cd ..
```

## Google Maps & Location Setup
Before production use, configure platform keys and permissions.

Android:
- Add required location permissions in `android/app/src/main/AndroidManifest.xml`.
- Add Google Maps API key meta-data in the `application` tag.

iOS:
- Add location usage descriptions in `ios/Runner/Info.plist`.
- Provide Google Maps iOS key initialization if required by your setup.

## Platform Notes
- iOS deployment target is set to `15.0` in `ios/Podfile`.
- Android release currently uses debug signing in `android/app/build.gradle.kts`; replace with real signing config for production.

If Android build fails with NDK `source.properties` issue:
- Delete broken folder under `~/Library/Android/sdk/ndk/<version>`.
- Reinstall that NDK version using SDK Manager.

## Build Commands
Android APK:

```bash
flutter build apk
```

iOS (requires macOS + Xcode setup):

```bash
flutter build ios
```

## Quality Commands

```bash
flutter analyze
flutter test
```

## Assets
- App logo: `assets/images/logo.png`

## Current Development Defaults
- `BYPASS_AUTH=true`
- `USE_STATIC_CONTENT=true`

This allows immediate UI testing without backend dependency.
