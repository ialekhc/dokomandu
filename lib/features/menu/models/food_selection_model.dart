import 'package:dokomandu/shared/models/food_item_model.dart';

class FoodSelectionModel {
  const FoodSelectionModel({
    this.variant,
    this.addons = const [],
    this.quantity = 1,
  });

  final FoodVariant? variant;
  final List<FoodAddon> addons;
  final int quantity;
}
