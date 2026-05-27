import 'package:dokomandu/app/config/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  Future<Box<dynamic>> _cartBox() async {
    if (Hive.isBoxOpen(AppConfig.hiveBoxCart)) {
      return Hive.box<dynamic>(AppConfig.hiveBoxCart);
    }
    return Hive.openBox<dynamic>(AppConfig.hiveBoxCart);
  }

  Future<void> saveCartItems(List<Map<String, dynamic>> cartItems) async {
    final box = await _cartBox();
    await box.put('items', cartItems);
  }

  Future<List<Map<String, dynamic>>> readCartItems() async {
    final box = await _cartBox();
    final raw = box.get('items', defaultValue: <dynamic>[]);
    final list = raw is List ? raw : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
  }

  Future<void> clearCart() async {
    final box = await _cartBox();
    await box.delete('items');
  }
}
