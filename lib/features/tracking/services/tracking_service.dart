import 'package:dokomandu/features/orders/models/order_tracking_model.dart';
import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/features/orders/viewmodels/orders_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingService {
  const TrackingService(this._ordersService);

  final OrdersService _ordersService;

  Future<OrderTrackingModel> fetch(String orderId) =>
      _ordersService.fetchOrderTracking(orderId);

  Future<void> advance(String orderId) =>
      _ordersService.advanceOrderStatus(orderId);

  Future<void> cancel(String orderId) => _ordersService.cancelOrder(orderId);

  Future<void> startScheduledDemo(String orderId) =>
      _ordersService.startScheduledOrderDemo(orderId);
}

final trackingServiceProvider = Provider<TrackingService>(
  (ref) => TrackingService(ref.watch(ordersServiceProvider)),
);
