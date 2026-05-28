import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';

class CheckoutService {
  const CheckoutService(this._apiService);

  final BaseApiService _apiService;

  Future<String> placeOrder(Map<String, dynamic> payload) {
    if (AppConfig.useStaticContent) {
      return _placeOrderStatic();
    }

    return _apiService.post<String>(
      ApiEndpoints.placeOrder,
      data: payload,
      parser: (data) {
        final map = data as Map<String, dynamic>? ?? const {};
        return map['orderId']?.toString() ?? map['id']?.toString() ?? '';
      },
    );
  }

  Future<String> _placeOrderStatic() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ORD-$stamp';
  }
}
