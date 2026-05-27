import 'package:dokomandu/features/cart/models/cart_item_model.dart';
import 'package:dokomandu/features/cart/services/cart_service.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.couponCode,
    this.discountAmount = 0,
  });

  final List<CartItemModel> items;
  final String? couponCode;
  final double discountAmount;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    List<CartItemModel>? items,
    String? couponCode,
    double? discountAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

class CartViewModel extends StateNotifier<CartState> {
  CartViewModel(this._service) : super(const CartState()) {
    _hydrate();
  }

  final CartService _service;

  double get deliveryFee => _service.calculateDeliveryFee(state.subtotal);
  double get tax => _service.calculateTax(
    (state.subtotal - state.discountAmount).clamp(0, double.infinity),
  );
  double get total => state.subtotal + deliveryFee + tax - state.discountAmount;

  Future<void> _hydrate() async {
    final items = await _service.loadCachedCartItems();
    state = state.copyWith(items: items);
  }

  String _buildItemId(
    FoodItemModel food,
    FoodVariant? variant,
    List<FoodAddon> addons,
  ) {
    final addonKey = addons.map((e) => e.id).toList()..sort();
    return '${food.id}::${variant?.id ?? 'default'}::${addonKey.join(',')}';
  }

  Future<void> addItem({
    required FoodItemModel food,
    FoodVariant? variant,
    List<FoodAddon> addons = const [],
    int quantity = 1,
  }) async {
    final itemId = _buildItemId(food, variant, addons);
    final current = [...state.items];
    final index = current.indexWhere((e) => e.id == itemId);

    if (index >= 0) {
      final existing = current[index];
      current[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      current.add(
        CartItemModel(
          id: itemId,
          food: food,
          quantity: quantity,
          selectedVariant: variant,
          selectedAddons: addons,
        ),
      );
    }

    state = state.copyWith(items: current);
    await _service.persistCartItems(current);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final updated = state.items
        .map(
          (item) =>
              item.id == itemId ? item.copyWith(quantity: quantity) : item,
        )
        .toList();

    state = state.copyWith(items: updated);
    await _service.persistCartItems(updated);
  }

  Future<void> removeItem(String itemId) async {
    final updated = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updated);
    await _service.persistCartItems(updated);
  }

  Future<void> clearCart() async {
    state = const CartState();
    await _service.clearCart();
  }

  void applyCouponPlaceholder(String couponCode) {
    state = state.copyWith(couponCode: couponCode, discountAmount: 0);
  }
}

final cartServiceProvider = Provider<CartService>(
  (ref) => CartService(ref.watch(hiveStorageServiceProvider)),
);

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>(
  (ref) => CartViewModel(ref.watch(cartServiceProvider)),
);
