import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/models/kitchen_model.dart';

class FoodCategory {
  const FoodCategory({required this.id, required this.name, this.imageUrl});

  final String id;
  final String name;
  final String? imageUrl;

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class OfferBanner {
  const OfferBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;

  factory OfferBanner.fromJson(Map<String, dynamic> json) {
    return OfferBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

class HomeFeedModel {
  const HomeFeedModel({
    required this.categories,
    required this.offers,
    required this.nearbyKitchens,
    required this.popularFoods,
  });

  final List<FoodCategory> categories;
  final List<OfferBanner> offers;
  final List<KitchenModel> nearbyKitchens;
  final List<FoodItemModel> popularFoods;

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? const [])
        .map((e) => FoodCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    final offers = (json['offers'] as List<dynamic>? ?? const [])
        .map((e) => OfferBanner.fromJson(e as Map<String, dynamic>))
        .toList();
    final nearbyKitchens =
        (json['nearbyKitchens'] as List<dynamic>? ?? const [])
            .map((e) => KitchenModel.fromJson(e as Map<String, dynamic>))
            .toList();
    final popularFoods = (json['popularFoods'] as List<dynamic>? ?? const [])
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return HomeFeedModel(
      categories: categories,
      offers: offers,
      nearbyKitchens: nearbyKitchens,
      popularFoods: popularFoods,
    );
  }
}
