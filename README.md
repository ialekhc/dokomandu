# Dokomandu Customer App (Static Demo)

Dokomandu is a **client-demo-ready Flutter food delivery app** built with:
- Flutter + Dart
- MVVM (feature-first)
- Riverpod
- GoRouter
- Material 3 (Light/Dark theme)
- Static local data only

This project is intentionally backend-independent right now and is structured for future API integration.

## Demo Scope

Implemented as static/local demo:
- Splash and onboarding
- Phone + password authentication (register/login/forgot password demo)
- Session persistence (local secure storage)
- Home feed, categories, kitchens, menu, food details
- Variant and add-on selection
- Cart management and persistence
- Checkout with address selection
- Delivery type:
  - Order Now
  - Schedule Order (date + slot validation)
- Cash on Delivery only
- Place order and success flow
- Order tracking timeline (manual + fake auto progression)
- Scheduled order start demo action
- Active orders and order history separation
- Rating and review after delivery (single submission per order)
- Profile and address management
- Theme mode selection (System/Light/Dark)
- Notifications (static list)

## Not Included (By Design)

- Firebase / FCM
- Real backend API calls
- Real OTP verification
- Real Google Maps API integration
- Real payment gateway
- Real rider GPS tracking

## Map Integration

The app uses **OpenStreetMap** via `flutter_map` for demo map visuals and tap-based location selection.

## Theme

- Material 3
- Brand primary: `#193CB8`
- Font: **Nunito Sans**
- Light and dark theme support with persisted theme mode

## Demo Auth

Default seeded demo account:
- Phone: `9800000000`
- Password: `123456`

Registration rules:
- Full name required
- Valid phone required
- Password min length 6
- Confirm password must match
- Terms acceptance required
- Duplicate phone is blocked in local state

## Project Structure

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
    address/
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
    reviews/
    tracking/
  shared/
    models/
    providers/
    widgets/
  main.dart
```

## Configuration Flags

`lib/app/config/app_config.dart`

- `BYPASS_AUTH` (default: `false`)
- `USE_STATIC_CONTENT` (default: `true`)
- `API_BASE_URL` (kept for future API integration)

Example:

```bash
flutter run --dart-define=BYPASS_AUTH=true --dart-define=USE_STATIC_CONTENT=true
```

## Run

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk
```

If you hit Android NDK corruption (missing `source.properties`), delete the broken NDK folder and re-download from Android SDK Manager.

## Quality

```bash
flutter analyze
flutter test
```

Note: In restricted sandbox environments, Flutter SDK cache updates may be blocked and can prevent running these commands.

## Architecture Doc

See: [docs/architecture.md](docs/architecture.md)

