class OrderReviewModel {
  const OrderReviewModel({
    required this.orderId,
    required this.overallRating,
    required this.foodQualityRating,
    required this.deliveryRating,
    this.comment,
    required this.submittedAt,
  });

  final String orderId;
  final int overallRating;
  final int foodQualityRating;
  final int deliveryRating;
  final String? comment;
  final DateTime submittedAt;

  factory OrderReviewModel.fromJson(Map<String, dynamic> json) {
    return OrderReviewModel(
      orderId: json['orderId']?.toString() ?? '',
      overallRating: (json['overallRating'] as num?)?.toInt() ?? 0,
      foodQualityRating: (json['foodQualityRating'] as num?)?.toInt() ?? 0,
      deliveryRating: (json['deliveryRating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      submittedAt:
          DateTime.tryParse(json['submittedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'overallRating': overallRating,
      'foodQualityRating': foodQualityRating,
      'deliveryRating': deliveryRating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
