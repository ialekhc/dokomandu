import 'package:dokomandu/shared/models/food_item_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.food,
    required this.quantity,
    this.selectedVariant,
    this.selectedAddons = const [],
  });

  final String id;
  final FoodItemModel food;
  final int quantity;
  final FoodVariant? selectedVariant;
  final List<FoodAddon> selectedAddons;

  double get unitPrice {
    final variantDelta = selectedVariant?.priceDelta ?? 0;
    final addonsTotal = selectedAddons.fold<double>(
      0,
      (sum, addon) => sum + addon.price,
    );
    return food.price + variantDelta + addonsTotal;
  }

  double get lineTotal => unitPrice * quantity;

  CartItemModel copyWith({
    String? id,
    FoodItemModel? food,
    int? quantity,
    FoodVariant? selectedVariant,
    List<FoodAddon>? selectedAddons,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      food: FoodItemModel.fromJson(
        json['food'] as Map<String, dynamic>? ?? const {},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedVariant: json['selectedVariant'] != null
          ? FoodVariant.fromJson(
              json['selectedVariant'] as Map<String, dynamic>,
            )
          : null,
      selectedAddons: (json['selectedAddons'] as List<dynamic>? ?? const [])
          .map((e) => FoodAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'quantity': quantity,
      'selectedVariant': selectedVariant?.toJson(),
      'selectedAddons': selectedAddons.map((e) => e.toJson()).toList(),
    };
  }
}
