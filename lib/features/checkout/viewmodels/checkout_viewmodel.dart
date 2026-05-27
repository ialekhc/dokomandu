import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/checkout/models/checkout_summary_model.dart';
import 'package:dokomandu/features/checkout/services/checkout_service.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutState {
  const CheckoutState({
    this.selectedAddress,
    this.paymentMethod = 'COD',
    this.isPlacingOrder = false,
    this.error,
    this.orderId,
  });

  final AddressModel? selectedAddress;
  final String paymentMethod;
  final bool isPlacingOrder;
  final String? error;
  final String? orderId;

  CheckoutState copyWith({
    AddressModel? selectedAddress,
    String? paymentMethod,
    bool? isPlacingOrder,
    String? error,
    String? orderId,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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
    state = state.copyWith(paymentMethod: method);
  }

  Future<bool> placeOrder() async {
    final address = state.selectedAddress;
    if (address == null) {
      state = state.copyWith(error: 'Please select a delivery address.');
      return false;
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
      await cartNotifier.clearCart();
      state = state.copyWith(isPlacingOrder: false, orderId: orderId);
      return true;
    } catch (e) {
      state = state.copyWith(isPlacingOrder: false, error: e.toString());
      return false;
    }
  }
}

final checkoutServiceProvider = Provider<CheckoutService>(
  (ref) => CheckoutService(ref.watch(baseApiServiceProvider)),
);

final checkoutViewModelProvider =
    StateNotifierProvider<CheckoutViewModel, CheckoutState>(
      (ref) => CheckoutViewModel(ref, ref.watch(checkoutServiceProvider)),
    );
