# Dokomandu Architecture (Static Demo Edition)

## 1. Objective

Deliver a production-style Flutter customer app demo for food delivery that:
- is fully usable end-to-end with static/local data
- follows **MVVM + Riverpod**
- remains ready for future API integration

Out of scope for this phase:
- Clean Architecture
- real backend integration
- Firebase/FCM
- real OTP/payment/GPS tracking

## 2. Technical Foundation

- Flutter + Dart
- Material 3
- Riverpod (`StateNotifierProvider`, `AsyncNotifierProvider`)
- GoRouter
- Dio (kept API-ready, static mode enabled)
- Flutter Secure Storage (session)
- SharedPreferences + Hive (local persistence)
- OpenStreetMap (`flutter_map`) for map visualization

## 3. High-Level Layout

```text
lib/
  app/        -> bootstrap, routes, theme, runtime config
  core/       -> api/network/storage/utils/shared widgets
  features/   -> feature-first MVVM modules
  shared/     -> cross-feature models/providers/widgets
```

## 4. Feature-First MVVM Modules

Each feature uses:

```text
models/
services/
viewmodels/
screens/
widgets/
```

Primary modules:
- `auth`
- `home`
- `kitchen`
- `menu`
- `cart`
- `checkout`
- `orders`
- `tracking`
- `reviews`
- `profile`
- `address`
- `notifications`

## 5. Layer Responsibilities

## 5.1 View (screens/widgets)
- Render UI and forward user intents
- No direct data source mutation
- Read reactive state from Riverpod providers

## 5.2 ViewModel
- Own feature state and transitions
- Handle loading/success/error/empty states
- Call services and coordinate feature flow

## 5.3 Service
- Data operations (static now, API-ready path preserved)
- Encapsulate persistence and mapping
- No UI dependencies

## 5.4 Core
- Shared network client (`DioClient`)
- API wrapper (`BaseApiService`)
- Storage wrappers
- common error types/utilities/widgets

## 6. State Model

- `AuthProvider/AuthViewModel`
- `CartProvider/CartViewModel`
- `CheckoutProvider/CheckoutViewModel`
- `OrderProvider/OrderViewModel`
- `TrackingProvider/TrackingViewModel`
- `ReviewProvider/ReviewViewModel`
- `AddressProvider`
- `ThemeProvider`

Persistence coverage:
- session/token: secure storage
- cart: hive
- onboarding/theme/demo users/addresses/reviews/orders: local cache

## 7. Navigation Design (GoRouter)

Flow:
1. Splash
2. Onboarding
3. Login/Register/Forgot
4. Shell tabs (`Home`, `Cart`, `Orders`, `Profile`)
5. Feature detail routes (kitchen detail, checkout, order detail, review, etc.)

Redirect rules:
- onboarding gate first
- then authentication gate
- optional bypass available via config flag

## 8. Static Data Strategy

Static data is provided by local services and mock datasets for:
- users/session
- addresses
- kitchens/categories/offers/foods/variants/add-ons
- cart
- orders + scheduled orders
- tracking snapshots
- reviews
- notifications

This keeps the app fully demoable without backend dependencies.

## 9. Demo Auth Behavior

- Phone + password login
- Local registration with duplicate phone prevention
- Session persistence across restarts
- Logout clears stored session

No OTP/remote auth required in demo mode.

## 10. Checkout and Ordering

Checkout supports:
- Address selection
- Delivery type:
  - Order Now
  - Schedule Order (date + slot validation)
- COD only

Protections:
- no checkout without address
- no scheduled order without valid date/slot
- no order placement with empty cart
- unique local order IDs to prevent duplicates

## 11. Tracking and Order Lifecycle

Status flow:
- `ORDER_PLACED`
- `ORDER_ACCEPTED`
- `PREPARING_FOOD`
- `READY_FOR_PICKUP`
- `OUT_FOR_DELIVERY`
- `NEARBY`
- `DELIVERED`

Behaviors:
- fake automatic timeline progression
- manual `Next Status` action
- scheduled orders stay parked until `Start Scheduled Order Demo`
- cancel allowed only before out-for-delivery stage
- delivered/cancelled orders move to history

## 12. Review System

- unlocked only after delivery
- single submission per order
- captures overall/food/delivery ratings + optional comment
- review displayed in order detail

## 13. Theming System

- Material 3 light/dark themes
- Nunito Sans typography
- brand primary `#193CB8`
- system theme + manual switching
- design tokens centralized in `app/theme/`

## 14. API-Ready Path

Although demo uses static mode, service interfaces are already structured for:
- API endpoint integration
- request/response parsing
- centralized exception mapping
- interceptor-driven auth/refresh/retry

Switching to live APIs is mainly a service-layer change plus config flags.

