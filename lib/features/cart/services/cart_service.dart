import 'package:dokomandu/core/storage/hive_storage_service.dart';
import 'package:dokomandu/features/cart/models/cart_item_model.dart';

class CartService {
  const CartService(this._hiveStorageService);

  final HiveStorageService _hiveStorageService;

  Future<List<CartItemModel>> loadCachedCartItems() async {
    final items = await _hiveStorageService.readCartItems();
    return items.map(CartItemModel.fromJson).toList();
  }

  Future<void> persistCartItems(List<CartItemModel> items) {
    return _hiveStorageService.saveCartItems(
      items.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> clearCart() => _hiveStorageService.clearCart();

  double calculateDeliveryFee(double subtotal) {
    if (subtotal >= 700) {
      return 0;
    }
    if (subtotal >= 300) {
      return 40;
    }
    return 60;
  }

  double calculateTax(double taxableAmount) => taxableAmount * 0.13;
}
