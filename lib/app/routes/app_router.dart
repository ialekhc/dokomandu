import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/features/auth/screens/login_screen.dart';
import 'package:dokomandu/features/auth/screens/otp_verification_screen.dart';
import 'package:dokomandu/features/auth/screens/splash_screen.dart';
import 'package:dokomandu/features/cart/screens/cart_screen.dart';
import 'package:dokomandu/features/checkout/screens/checkout_screen.dart';
import 'package:dokomandu/features/checkout/screens/order_success_screen.dart';
import 'package:dokomandu/features/home/screens/home_screen.dart';
import 'package:dokomandu/features/kitchen/screens/kitchen_detail_screen.dart';
import 'package:dokomandu/features/kitchen/screens/kitchen_list_screen.dart';
import 'package:dokomandu/features/location/screens/location_picker_screen.dart';
import 'package:dokomandu/features/notifications/screens/notifications_screen.dart';
import 'package:dokomandu/features/orders/screens/order_detail_screen.dart';
import 'package:dokomandu/features/orders/screens/orders_screen.dart';
import 'package:dokomandu/features/profile/screens/edit_profile_screen.dart';
import 'package:dokomandu/features/profile/screens/profile_screen.dart';
import 'package:dokomandu/shared/providers/session_provider.dart';
import 'package:dokomandu/shared/widgets/app_shell_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final current = state.matchedLocation;
      final isSplash = current == RoutePaths.splash;
      final isAuthRoute =
          current == RoutePaths.login || current == RoutePaths.otp;

      if (AppConfig.bypassAuth) {
        if (isSplash || isAuthRoute) {
          return RoutePaths.home;
        }
        return null;
      }

      if (sessionState.status == SessionStatus.unknown) {
        return isSplash ? null : RoutePaths.splash;
      }

      if (sessionState.status == SessionStatus.unauthenticated) {
        return isAuthRoute ? null : RoutePaths.login;
      }

      if (sessionState.status == SessionStatus.authenticated &&
          (isSplash || isAuthRoute)) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: RoutePaths.locationPicker,
        builder: (context, state) => const LocationPickerScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RoutePaths.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.kitchenList,
        builder: (context, state) => const KitchenListScreen(),
      ),
      GoRoute(
        path: RoutePaths.kitchenDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return KitchenDetailScreen(kitchenId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RoutePaths.orderSuccess,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderSuccessScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
