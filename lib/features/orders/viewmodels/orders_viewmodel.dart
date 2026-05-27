import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersState {
  const OrdersState({required this.activeOrders, required this.historyOrders});

  final List<OrderModel> activeOrders;
  final List<OrderModel> historyOrders;
}

class OrdersViewModel extends AsyncNotifier<OrdersState> {
  OrdersService get _service => ref.read(ordersServiceProvider);

  @override
  Future<OrdersState> build() async {
    final active = await _service.fetchActiveOrders();
    final history = await _service.fetchOrderHistory();
    return OrdersState(activeOrders: active, historyOrders: history);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> cancelOrder(String orderId) async {
    await _service.cancelOrder(orderId);
    await refresh();
  }

  Future<void> reorder(String orderId) async {
    await _service.reorder(orderId);
  }
}

final ordersServiceProvider = Provider<OrdersService>(
  (ref) => OrdersService(ref.watch(baseApiServiceProvider)),
);

final ordersViewModelProvider =
    AsyncNotifierProvider<OrdersViewModel, OrdersState>(OrdersViewModel.new);

final orderDetailProvider = FutureProvider.family<OrderModel, String>(
  (ref, id) => ref.watch(ordersServiceProvider).fetchOrderDetail(id),
);
