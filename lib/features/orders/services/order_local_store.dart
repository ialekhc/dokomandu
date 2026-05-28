import 'dart:convert';

import 'package:dokomandu/core/storage/local_cache_service.dart';
import 'package:dokomandu/shared/models/order_model.dart';

class OrderLocalStore {
  const OrderLocalStore(this._cache);

  static const _placedOrdersKey = 'placed_orders';

  final LocalCacheService _cache;

  Future<List<OrderModel>> readPlacedOrders() async {
    final raw = await _cache.getString(_placedOrdersKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map(
          (e) => OrderModel.fromJson(
            e.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<void> savePlacedOrders(List<OrderModel> orders) async {
    final payload = orders.map((e) => e.toJson()).toList();
    await _cache.setString(_placedOrdersKey, jsonEncode(payload));
  }

  Future<void> upsertOrder(OrderModel order) async {
    final orders = await readPlacedOrders();
    final index = orders.indexWhere((existing) => existing.id == order.id);

    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.insert(0, order);
    }

    await savePlacedOrders(orders);
  }

  Future<OrderModel?> findById(String orderId) async {
    final orders = await readPlacedOrders();
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }
}
