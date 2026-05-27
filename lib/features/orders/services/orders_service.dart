import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/errors/app_exception.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/shared/models/order_model.dart';

class OrdersService {
  const OrdersService(this._apiService);

  final BaseApiService _apiService;

  Future<List<OrderModel>> fetchActiveOrders() {
    if (AppConfig.useStaticContent) {
      return _fetchActiveOrdersStatic();
    }

    return _apiService.get<List<OrderModel>>(
      ApiEndpoints.activeOrders,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<OrderModel>> fetchOrderHistory() {
    if (AppConfig.useStaticContent) {
      return _fetchOrderHistoryStatic();
    }

    return _apiService.get<List<OrderModel>>(
      ApiEndpoints.orderHistory,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<OrderModel> fetchOrderDetail(String orderId) {
    if (AppConfig.useStaticContent) {
      return _fetchOrderDetailStatic(orderId);
    }

    return _apiService.get<OrderModel>(
      ApiEndpoints.orderDetail.replaceFirst('{id}', orderId),
      parser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> cancelOrder(String orderId) {
    if (AppConfig.useStaticContent) {
      return Future<void>.delayed(const Duration(milliseconds: 350));
    }

    return _apiService.post<bool>(
      ApiEndpoints.cancelOrder.replaceFirst('{id}', orderId),
      parser: (_) => true,
    );
  }

  Future<void> reorder(String orderId) {
    if (AppConfig.useStaticContent) {
      return Future<void>.delayed(const Duration(milliseconds: 350));
    }

    return _apiService.post<bool>(
      ApiEndpoints.reorder.replaceFirst('{id}', orderId),
      parser: (_) => true,
    );
  }

  Future<List<OrderModel>> _fetchActiveOrdersStatic() async {
    await DummyData.delay();
    return DummyData.activeOrders();
  }

  Future<List<OrderModel>> _fetchOrderHistoryStatic() async {
    await DummyData.delay();
    return DummyData.historyOrders();
  }

  Future<OrderModel> _fetchOrderDetailStatic(String orderId) async {
    await DummyData.delay();
    final order = DummyData.orderById(orderId);
    if (order == null) {
      throw const AppException('Order not found.');
    }
    return order;
  }
}
