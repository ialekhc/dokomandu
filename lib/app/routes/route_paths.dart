class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String locationPicker = '/location';
  static const String addressManagement = '/addresses/manage';

  static const String home = '/home';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  static const String kitchenList = '/kitchens';
  static const String kitchenDetail = '/kitchens/:id';

  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success/:id';

  static const String notifications = '/notifications';
  static const String orderDetail = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';
  static const String reviewOrder = '/orders/:id/review';
  static const String editProfile = '/profile/edit';
}
