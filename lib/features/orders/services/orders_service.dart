import 'dart:math' as math;

import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/errors/app_exception.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/features/cart/models/cart_item_model.dart';
import 'package:dokomandu/features/checkout/models/checkout_summary_model.dart';
import 'package:dokomandu/features/orders/models/order_tracking_model.dart';
import 'package:dokomandu/features/orders/services/order_local_store.dart';
import 'package:dokomandu/shared/models/order_model.dart';

class OrdersService {
  const OrdersService(this._apiService, this._localStore);

  final BaseApiService _apiService;
  final OrderLocalStore _localStore;

  static const _defaultLat = 27.7172;
  static const _defaultLng = 85.3240;

  Future<void> cachePlacedOrder({
    required String orderId,
    required CheckoutSummaryModel summary,
    required List<CartItemModel> cartItems,
  }) async {
    if (orderId.trim().isEmpty || cartItems.isEmpty) return;

    final primaryKitchen = cartItems.first.food.kitchenId;
    final pickup = _resolveKitchenCoordinates(primaryKitchen);

    final order = OrderModel(
      id: orderId,
      items: cartItems
          .map(
            (item) => OrderLineItem(
              foodName: item.food.name,
              quantity: item.quantity,
              price: item.lineTotal,
            ),
          )
          .toList(),
      subtotal: summary.subtotal,
      deliveryFee: summary.deliveryFee,
      tax: summary.tax,
      total: summary.total,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      deliveryAddress: summary.address.fullAddress,
      paymentMethod: summary.paymentMethod,
      kitchenName: 'Assigned Kitchen',
      kitchenLatitude: pickup.$1,
      kitchenLongitude: pickup.$2,
      deliveryLatitude: summary.address.latitude,
      deliveryLongitude: summary.address.longitude,
      isScheduled: summary.isScheduled,
      scheduledFor: summary.scheduledFor,
      trackingStarted: !summary.isScheduled,
    );

    await _localStore.upsertOrder(order);
  }

  Future<List<OrderModel>> fetchActiveOrders() async {
    final local = await _readLocalOrdersWithLifecycle();

    if (AppConfig.useStaticContent) {
      await DummyData.delay();
      final merged = _mergeOrders(
        primary: local,
        secondary: [...DummyData.activeOrders(), ...DummyData.historyOrders()],
      );
      return _activeOrdersOf(merged);
    }

    final remote = await _apiService.get<List<OrderModel>>(
      ApiEndpoints.activeOrders,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );

    final merged = _mergeOrders(primary: remote, secondary: local);
    return _activeOrdersOf(merged);
  }

  Future<List<OrderModel>> fetchOrderHistory() async {
    final local = await _readLocalOrdersWithLifecycle();

    if (AppConfig.useStaticContent) {
      await DummyData.delay();
      final merged = _mergeOrders(
        primary: local,
        secondary: [...DummyData.activeOrders(), ...DummyData.historyOrders()],
      );
      return _historyOrdersOf(merged);
    }

    final remote = await _apiService.get<List<OrderModel>>(
      ApiEndpoints.orderHistory,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );

    final merged = _mergeOrders(primary: remote, secondary: local);
    return _historyOrdersOf(merged);
  }

  Future<OrderModel> fetchOrderDetail(String orderId) async {
    final local = await _localStore.findById(orderId);
    if (local != null) {
      final progressed = _applyLifecycle(local);
      if (progressed.status != local.status) {
        await _localStore.upsertOrder(progressed);
      }
      return progressed;
    }

    if (AppConfig.useStaticContent) {
      await DummyData.delay();
      final merged = _mergeOrders(
        primary: const [],
        secondary: [...DummyData.activeOrders(), ...DummyData.historyOrders()],
      );
      for (final order in merged) {
        if (order.id == orderId) return _applyLifecycle(order);
      }
      throw const AppException('Order not found.');
    }

    return _apiService.get<OrderModel>(
      ApiEndpoints.orderDetail.replaceFirst('{id}', orderId),
      parser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<OrderTrackingModel> fetchOrderTracking(String orderId) async {
    if (!AppConfig.useStaticContent) {
      try {
        return await _apiService.get<OrderTrackingModel>(
          ApiEndpoints.orderTracking.replaceFirst('{id}', orderId),
          parser: (data) =>
              OrderTrackingModel.fromJson(data as Map<String, dynamic>),
        );
      } catch (_) {
        // Fallback to client-side snapshot below.
      }
    }

    final order = await fetchOrderDetail(orderId);
    return _buildTrackingSnapshot(order);
  }

  Future<void> cancelOrder(String orderId) async {
    final order = await _findAcrossSources(orderId);
    if (order == null) return;

    if (!canCancel(order.status)) {
      throw const AppException(
        'Order can only be cancelled before it is out for delivery.',
      );
    }

    if (!AppConfig.useStaticContent) {
      await _apiService.post<bool>(
        ApiEndpoints.cancelOrder.replaceFirst('{id}', orderId),
        parser: (_) => true,
      );
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }

    await _localStore.upsertOrder(
      order.copyWith(status: OrderStatus.cancelled),
    );
  }

  Future<void> reorder(String orderId) async {
    if (!AppConfig.useStaticContent) {
      await _apiService.post<bool>(
        ApiEndpoints.reorder.replaceFirst('{id}', orderId),
        parser: (_) => true,
      );
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }

    final sourceOrder = await _findAcrossSources(orderId);
    if (sourceOrder == null) return;

    final newId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    await _localStore.upsertOrder(
      sourceOrder.copyWith(
        id: newId,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
        trackingStarted: !sourceOrder.isScheduled,
        codPaid: false,
      ),
    );
  }

  Future<void> startScheduledOrderDemo(String orderId) async {
    final order = await _findAcrossSources(orderId);
    if (order == null) return;

    if (!order.isScheduled || order.trackingStarted) return;

    await _localStore.upsertOrder(
      order.copyWith(
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
        trackingStarted: true,
      ),
    );
  }

  Future<void> advanceOrderStatus(String orderId) async {
    final order = await _findAcrossSources(orderId);
    if (order == null) return;

    if (order.isScheduled && !order.trackingStarted) {
      throw const AppException(
        'Start scheduled order demo before advancing tracking status.',
      );
    }

    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.delivered) {
      return;
    }

    final nextRank = (_statusRank(order.status) + 1).clamp(0, 6);
    final nextStatus = _statusFromRank(nextRank);
    await _localStore.upsertOrder(
      order.copyWith(
        status: nextStatus,
        trackingStarted: true,
        codPaid: nextStatus == OrderStatus.delivered ? true : order.codPaid,
      ),
    );
  }

  Future<OrderModel?> _findAcrossSources(String orderId) async {
    final local = await _localStore.findById(orderId);
    if (local != null) return _applyLifecycle(local);

    final allDummy = [
      ...DummyData.activeOrders(),
      ...DummyData.historyOrders(),
    ];
    for (final order in allDummy) {
      if (order.id == orderId) return _applyLifecycle(order);
    }

    return null;
  }

  Future<List<OrderModel>> _readLocalOrdersWithLifecycle() async {
    final local = await _localStore.readPlacedOrders();
    if (local.isEmpty) return const [];

    final progressed = local.map(_applyLifecycle).toList();

    final hasChanges =
        progressed.length != local.length ||
        progressed.any((order) {
          OrderModel? original;
          for (final existing in local) {
            if (existing.id == order.id) {
              original = existing;
              break;
            }
          }
          return original == null || original.status != order.status;
        });

    if (hasChanges) {
      await _localStore.savePlacedOrders(progressed);
    }

    return progressed;
  }

  List<OrderModel> _mergeOrders({
    required List<OrderModel> primary,
    required List<OrderModel> secondary,
  }) {
    final map = <String, OrderModel>{};

    for (final order in primary) {
      map[order.id] = _applyLifecycle(order);
    }

    for (final order in secondary) {
      map.putIfAbsent(order.id, () => _applyLifecycle(order));
    }

    final values = map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return values;
  }

  List<OrderModel> _activeOrdersOf(List<OrderModel> orders) {
    return orders
        .where(
          (order) =>
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled,
        )
        .toList();
  }

  List<OrderModel> _historyOrdersOf(List<OrderModel> orders) {
    return orders
        .where(
          (order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled,
        )
        .toList();
  }

  OrderModel _applyLifecycle(OrderModel order) {
    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.delivered) {
      return order;
    }

    if (order.isScheduled && !order.trackingStarted) {
      return order.copyWith(status: OrderStatus.placed);
    }

    final elapsedMinutes = DateTime.now().difference(order.createdAt).inMinutes;

    final calculated = switch (elapsedMinutes) {
      < 2 => OrderStatus.placed,
      < 5 => OrderStatus.accepted,
      < 9 => OrderStatus.preparing,
      < 13 => OrderStatus.ready,
      < 18 => OrderStatus.onTheWay,
      < 22 => OrderStatus.nearby,
      _ => OrderStatus.delivered,
    };

    final rank = math.max(_statusRank(order.status), _statusRank(calculated));
    final status = _statusFromRank(rank);
    return order.copyWith(
      status: status,
      codPaid: status == OrderStatus.delivered ? true : order.codPaid,
    );
  }

  OrderTrackingModel _buildTrackingSnapshot(OrderModel sourceOrder) {
    final order = _applyLifecycle(sourceOrder);
    final pickup = _resolvePickup(order);
    final destination = _resolveDestination(order);

    if (order.isScheduled && !order.trackingStarted) {
      final waitMinutes = order.scheduledFor == null
          ? 0
          : order.scheduledFor!.difference(DateTime.now()).inMinutes;
      final riderIndex = order.id.hashCode.abs() % _riderNames.length;

      return OrderTrackingModel(
        order: order,
        riderName: _riderNames[riderIndex],
        riderPhone: _riderPhoneFor(order.id.hashCode.abs()),
        riderVehicle: 'Bike • Bag #${100 + riderIndex}',
        riderLatitude: pickup.$1,
        riderLongitude: pickup.$2,
        pickupLatitude: pickup.$1,
        pickupLongitude: pickup.$2,
        destinationLatitude: destination.$1,
        destinationLongitude: destination.$2,
        etaMinutes: waitMinutes > 0 ? waitMinutes : 0,
        distanceKm: _distanceInKm(
          pickup.$1,
          pickup.$2,
          destination.$1,
          destination.$2,
        ),
        progress: 0,
        lastUpdated: DateTime.now(),
        canTrackLive: false,
      );
    }

    final progress = _trackingProgress(order);

    final riderLatitude = _lerp(pickup.$1, destination.$1, progress);
    final riderLongitude = _lerp(pickup.$2, destination.$2, progress);

    final distanceKm = _distanceInKm(
      riderLatitude,
      riderLongitude,
      destination.$1,
      destination.$2,
    );

    final etaMinutes = order.status == OrderStatus.delivered
        ? 0
        : math.max(1, (distanceKm / 0.45).round());

    final riderIndex = order.id.hashCode.abs() % _riderNames.length;

    return OrderTrackingModel(
      order: order,
      riderName: _riderNames[riderIndex],
      riderPhone: _riderPhoneFor(order.id.hashCode.abs()),
      riderVehicle: 'Bike • Bag #${100 + riderIndex}',
      riderLatitude: riderLatitude,
      riderLongitude: riderLongitude,
      pickupLatitude: pickup.$1,
      pickupLongitude: pickup.$2,
      destinationLatitude: destination.$1,
      destinationLongitude: destination.$2,
      etaMinutes: etaMinutes,
      distanceKm: distanceKm,
      progress: progress,
      lastUpdated: DateTime.now(),
      canTrackLive: switch (order.status) {
        OrderStatus.ready || OrderStatus.onTheWay || OrderStatus.nearby => true,
        _ => false,
      },
    );
  }

  (double, double) _resolvePickup(OrderModel order) {
    if (order.kitchenLatitude != null && order.kitchenLongitude != null) {
      return (order.kitchenLatitude!, order.kitchenLongitude!);
    }

    final inferred = _resolveKitchenCoordinates(order.id);
    return inferred;
  }

  (double, double) _resolveDestination(OrderModel order) {
    if (order.deliveryLatitude != null && order.deliveryLongitude != null) {
      return (order.deliveryLatitude!, order.deliveryLongitude!);
    }

    final address = order.deliveryAddress.toLowerCase();

    if (address.contains('pulchowk')) return (27.6710, 85.3167);
    if (address.contains('baneshwor') || address.contains('baneswor')) {
      return (27.6915, 85.3438);
    }
    if (address.contains('jawalakhel')) return (27.6725, 85.3130);
    if (address.contains('sanepa')) return (27.6807, 85.3124);

    return (_defaultLat + 0.004, _defaultLng + 0.007);
  }

  (double, double) _resolveKitchenCoordinates(String seed) {
    final map = {
      'kitchen_1': (27.6717, 85.3169),
      'kitchen_2': (27.6878, 85.3358),
      'kitchen_3': (27.7061, 85.3148),
      'kitchen_4': (27.6992, 85.3335),
      'kitchen_5': (27.6684, 85.3203),
    };

    if (map.containsKey(seed)) return map[seed]!;

    final hash = seed.hashCode.abs();
    final latOffset = ((hash % 9) + 1) / 1000.0;
    final lngOffset = (((hash ~/ 7) % 9) + 1) / 1000.0;
    return (_defaultLat - latOffset, _defaultLng + lngOffset);
  }

  double _trackingProgress(OrderModel order) {
    if (order.status == OrderStatus.delivered) return 1;
    if (order.status == OrderStatus.cancelled) return 0;
    if (order.isScheduled && !order.trackingStarted) return 0;

    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;
    final routeProgress = ((elapsed - 12) / 10).clamp(0.0, 1.0);

    return switch (order.status) {
      OrderStatus.placed => 0,
      OrderStatus.accepted => 0,
      OrderStatus.preparing => 0.05,
      OrderStatus.ready => 0.1,
      OrderStatus.pickedUp => 0.35,
      OrderStatus.onTheWay => (0.55 + (routeProgress * 0.30)).clamp(0.55, 0.85),
      OrderStatus.nearby => 0.92,
      OrderStatus.delivered => 1,
      OrderStatus.cancelled => 0,
    };
  }

  int _statusRank(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => 0,
      OrderStatus.accepted => 1,
      OrderStatus.preparing => 2,
      OrderStatus.ready => 3,
      OrderStatus.pickedUp => 4,
      OrderStatus.onTheWay => 4,
      OrderStatus.nearby => 5,
      OrderStatus.delivered => 6,
      OrderStatus.cancelled => -1,
    };
  }

  OrderStatus _statusFromRank(int rank) {
    return switch (rank) {
      <= 0 => OrderStatus.placed,
      1 => OrderStatus.accepted,
      2 => OrderStatus.preparing,
      3 => OrderStatus.ready,
      4 => OrderStatus.onTheWay,
      5 => OrderStatus.nearby,
      _ => OrderStatus.delivered,
    };
  }

  double _lerp(double start, double end, double t) => start + (end - start) * t;

  double _distanceInKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLng / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * (math.pi / 180.0);

  String _riderPhoneFor(int hash) {
    final suffix = 10000000 + (hash % 89999999);
    return '+977-98$suffix';
  }
}

bool canCancel(OrderStatus status) {
  return status == OrderStatus.placed ||
      status == OrderStatus.accepted ||
      status == OrderStatus.preparing ||
      status == OrderStatus.ready;
}

const _riderNames = ['Aarav', 'Rabin', 'Suman', 'Kiran', 'Sagar'];
