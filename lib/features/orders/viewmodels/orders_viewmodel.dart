import 'package:dokomandu/features/orders/services/order_local_store.dart';
import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/features/tracking/viewmodels/tracking_viewmodel.dart';
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
    try {
      await _service.cancelOrder(orderId);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> reorder(String orderId) async {
    try {
      await _service.reorder(orderId);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> startScheduledOrderDemo(String orderId) async {
    try {
      await _service.startScheduledOrderDemo(orderId);
      ref.invalidate(trackingViewModelProvider(orderId));
      await refresh();
    } catch (_) {
      await refresh();
    }
  }
}

final orderLocalStoreProvider = Provider<OrderLocalStore>(
  (ref) => OrderLocalStore(ref.watch(localCacheServiceProvider)),
);

final ordersServiceProvider = Provider<OrdersService>(
  (ref) => OrdersService(
    ref.watch(baseApiServiceProvider),
    ref.watch(orderLocalStoreProvider),
  ),
);

final ordersViewModelProvider =
    AsyncNotifierProvider<OrdersViewModel, OrdersState>(OrdersViewModel.new);

final orderDetailProvider = FutureProvider.family<OrderModel, String>(
  (ref, id) => ref.watch(ordersServiceProvider).fetchOrderDetail(id),
);
