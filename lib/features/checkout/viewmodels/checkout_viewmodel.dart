import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/checkout/models/checkout_summary_model.dart';
import 'package:dokomandu/features/checkout/services/checkout_service.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/features/orders/viewmodels/orders_viewmodel.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutState {
  const CheckoutState({
    this.selectedAddress,
    this.paymentMethod = 'COD',
    this.deliveryType = 'NOW',
    this.scheduledDate,
    this.scheduledSlot,
    this.isPlacingOrder = false,
    this.error,
    this.orderId,
  });

  final AddressModel? selectedAddress;
  final String paymentMethod;
  final String deliveryType;
  final DateTime? scheduledDate;
  final String? scheduledSlot;
  final bool isPlacingOrder;
  final String? error;
  final String? orderId;

  CheckoutState copyWith({
    AddressModel? selectedAddress,
    String? paymentMethod,
    String? deliveryType,
    DateTime? scheduledDate,
    String? scheduledSlot,
    bool? isPlacingOrder,
    String? error,
    String? orderId,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryType: deliveryType ?? this.deliveryType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledSlot: scheduledSlot ?? this.scheduledSlot,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: error,
      orderId: orderId,
    );
  }
}

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  CheckoutViewModel(this._ref, this._service) : super(const CheckoutState()) {
    _bootstrap();
  }

  final Ref _ref;
  final CheckoutService _service;

  void _bootstrap() {
    final locationState = _ref.read(locationViewModelProvider).valueOrNull;
    final selected =
        locationState?.savedAddresses.where((e) => e.isDefault).firstOrNull ??
        locationState?.savedAddresses.firstOrNull;

    if (selected != null) {
      state = state.copyWith(selectedAddress: selected);
    }
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address, error: null);
  }

  void selectPaymentMethod(String method) {
    if (method != 'COD') {
      state = state.copyWith(
        paymentMethod: 'COD',
        error: 'Only Cash on Delivery is available right now.',
      );
      return;
    }

    state = state.copyWith(paymentMethod: 'COD', error: null);
  }

  void selectDeliveryType(String type) {
    if (type != 'NOW' && type != 'SCHEDULE') return;
    state = state.copyWith(deliveryType: type, error: null);
  }

  void selectScheduledDate(DateTime date) {
    state = state.copyWith(scheduledDate: date, error: null);
  }

  void selectScheduledSlot(String slot) {
    state = state.copyWith(scheduledSlot: slot, error: null);
  }

  Future<bool> placeOrder() async {
    final address = state.selectedAddress;
    if (address == null) {
      state = state.copyWith(error: 'Please select a delivery address.');
      return false;
    }

    if (state.paymentMethod != 'COD') {
      state = state.copyWith(
        error: 'Online payment is coming soon. Please choose Cash on Delivery.',
      );
      return false;
    }

    DateTime? scheduleAt;
    if (state.deliveryType == 'SCHEDULE') {
      final selectedDate = state.scheduledDate;
      final selectedSlot = state.scheduledSlot;

      if (selectedDate == null ||
          selectedSlot == null ||
          selectedSlot.isEmpty) {
        state = state.copyWith(
          error: 'Please select schedule date and time slot.',
        );
        return false;
      }

      scheduleAt = _resolveScheduleDateTime(selectedDate, selectedSlot);
      if (scheduleAt == null || scheduleAt.isBefore(DateTime.now())) {
        state = state.copyWith(error: 'Scheduled time must be in the future.');
        return false;
      }

      if (!_isScheduleAvailable(scheduleAt)) {
        state = state.copyWith(
          error:
              'Selected slot is unavailable for demo kitchens. Try another slot.',
        );
        return false;
      }
    }

    final cart = _ref.read(cartViewModelProvider);
    final cartNotifier = _ref.read(cartViewModelProvider.notifier);

    if (cart.items.isEmpty) {
      state = state.copyWith(error: 'Cart is empty.');
      return false;
    }

    final summary = CheckoutSummaryModel(
      address: address,
      subtotal: cart.subtotal,
      deliveryFee: cartNotifier.deliveryFee,
      tax: cartNotifier.tax,
      total: cartNotifier.total,
      paymentMethod: state.paymentMethod,
      deliveryType: state.deliveryType,
      scheduledFor: scheduleAt,
    );

    state = state.copyWith(isPlacingOrder: true, error: null);

    try {
      final payload = {
        ...summary.toJson(),
        'items': cart.items
            .map(
              (item) => {
                'foodId': item.food.id,
                'quantity': item.quantity,
                'variantId': item.selectedVariant?.id,
                'addonIds': item.selectedAddons.map((e) => e.id).toList(),
              },
            )
            .toList(),
      };

      final orderId = await _service.placeOrder(payload);
      if (orderId.trim().isEmpty) {
        state = state.copyWith(
          isPlacingOrder: false,
          error: 'Could not create order. Please try again.',
        );
        return false;
      }

      await _ref
          .read(ordersServiceProvider)
          .cachePlacedOrder(
            orderId: orderId,
            summary: summary,
            cartItems: cart.items,
          );

      await cartNotifier.clearCart();
      _ref.invalidate(ordersViewModelProvider);

      state = state.copyWith(isPlacingOrder: false, orderId: orderId);
      return true;
    } catch (e) {
      state = state.copyWith(isPlacingOrder: false, error: e.toString());
      return false;
    }
  }

  DateTime? _resolveScheduleDateTime(DateTime date, String slot) {
    final parts = slot.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _isScheduleAvailable(DateTime scheduledAt) {
    // Static demo kitchen availability:
    // - Kitchens open between 10:00 and 21:30
    // - Sunday mornings (before 12:00) are unavailable
    if (scheduledAt.hour < 10 || scheduledAt.hour > 21) {
      return false;
    }
    if (scheduledAt.weekday == DateTime.sunday && scheduledAt.hour < 12) {
      return false;
    }
    return true;
  }
}

final checkoutServiceProvider = Provider<CheckoutService>(
  (ref) => CheckoutService(ref.watch(baseApiServiceProvider)),
);

final checkoutViewModelProvider =
    StateNotifierProvider<CheckoutViewModel, CheckoutState>(
      (ref) => CheckoutViewModel(ref, ref.watch(checkoutServiceProvider)),
    );
