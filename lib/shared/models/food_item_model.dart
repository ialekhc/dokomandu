class FoodVariant {
  const FoodVariant({
    required this.id,
    required this.name,
    required this.priceDelta,
  });

  final String id;
  final String name;
  final double priceDelta;

  factory FoodVariant.fromJson(Map<String, dynamic> json) {
    return FoodVariant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      priceDelta: (json['priceDelta'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'priceDelta': priceDelta};
  }
}

class FoodAddon {
  const FoodAddon({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  factory FoodAddon.fromJson(Map<String, dynamic> json) {
    return FoodAddon(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }
}

class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.kitchenId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.isPopular,
    required this.variants,
    required this.addons,
    this.isVeg = false,
  });

  final String id;
  final String kitchenId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final bool isPopular;
  final bool isVeg;
  final List<FoodVariant> variants;
  final List<FoodAddon> addons;

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id']?.toString() ?? '',
      kitchenId: json['kitchenId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      isVeg: json['isVeg'] as bool? ?? false,
      variants: (json['variants'] as List<dynamic>? ?? const [])
          .map((e) => FoodVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      addons: (json['addons'] as List<dynamic>? ?? const [])
          .map((e) => FoodAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitchenId': kitchenId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'isPopular': isPopular,
      'isVeg': isVeg,
      'variants': variants.map((e) => e.toJson()).toList(),
      'addons': addons.map((e) => e.toJson()).toList(),
    };
  }
}
