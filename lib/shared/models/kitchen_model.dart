class KitchenModel {
  const KitchenModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.distanceKm,
    required this.deliveryFee,
    required this.tags,
    required this.isOpen,
    this.estimatedDeliveryMinutes,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final double distanceKm;
  final double deliveryFee;
  final List<String> tags;
  final bool isOpen;
  final int? estimatedDeliveryMinutes;

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      isOpen: json['isOpen'] as bool? ?? true,
      estimatedDeliveryMinutes: (json['estimatedDeliveryMinutes'] as num?)
          ?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'distanceKm': distanceKm,
      'deliveryFee': deliveryFee,
      'tags': tags,
      'isOpen': isOpen,
      'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
    };
  }
}
