import 'dart:async';

import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/features/orders/viewmodels/orders_viewmodel.dart';
import 'package:dokomandu/features/tracking/models/tracking_view_state.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingViewModel extends FamilyAsyncNotifier<TrackingViewState, String> {
  OrdersService get _service => ref.read(ordersServiceProvider);
  Timer? _timer;

  @override
  Future<TrackingViewState> build(String orderId) async {
    ref.onDispose(() => _timer?.cancel());
    final snapshot = await _service.fetchOrderTracking(orderId);
    _startTimer(orderId);
    return TrackingViewState(snapshot: snapshot, autoAdvance: true);
  }

  void _startTimer(String orderId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final current = state.valueOrNull;
      if (current == null || !current.autoAdvance) return;

      final order = current.snapshot.order;
      if (order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled) {
        return;
      }

      if (order.isScheduled && !order.trackingStarted) {
        return;
      }

      await refresh(orderId);
    });
  }

  Future<void> refresh(String orderId) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(isBusy: true, error: null));
    }

    try {
      final snapshot = await _service.fetchOrderTracking(orderId);
      final auto = state.valueOrNull?.autoAdvance ?? true;
      state = AsyncData(
        TrackingViewState(snapshot: snapshot, autoAdvance: auto, isBusy: false),
      );
      ref.invalidate(ordersViewModelProvider);
    } catch (e, st) {
      if (current == null) {
        state = AsyncError(e, st);
      } else {
        state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
      }
    }
  }

  Future<void> nextStatus(String orderId) async {
    try {
      await _service.advanceOrderStatus(orderId);
      await refresh(orderId);
    } catch (e) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(error: e.toString()));
      }
    }
  }

  Future<void> startScheduledDemo(String orderId) async {
    try {
      await _service.startScheduledOrderDemo(orderId);
      await refresh(orderId);
    } catch (e) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(error: e.toString()));
      }
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _service.cancelOrder(orderId);
      await refresh(orderId);
    } catch (e) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(error: e.toString()));
      }
    }
  }

  void toggleAutoAdvance(bool value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(autoAdvance: value, error: null));
  }
}

final trackingViewModelProvider =
    AsyncNotifierProviderFamily<TrackingViewModel, TrackingViewState, String>(
      TrackingViewModel.new,
    );
