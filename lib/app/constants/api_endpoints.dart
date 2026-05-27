class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/delete-account';

  static const String me = '/users/me';
  static const String updateProfile = '/users/profile';

  static const String addresses = '/addresses';
  static const String nearbyKitchens = '/kitchens/nearby';
  static const String kitchens = '/kitchens';
  static const String kitchenDetail = '/kitchens/{id}';
  static const String kitchenMenu = '/kitchens/{id}/menu';

  static const String homeFeed = '/home/feed';
  static const String categories = '/categories';
  static const String popularFoods = '/foods/popular';
  static const String searchFoods = '/foods/search';

  static const String placeOrder = '/orders';
  static const String activeOrders = '/orders/active';
  static const String orderHistory = '/orders/history';
  static const String orderDetail = '/orders/{id}';
  static const String cancelOrder = '/orders/{id}/cancel';
  static const String reorder = '/orders/{id}/reorder';

  static const String notifications = '/notifications';
}
