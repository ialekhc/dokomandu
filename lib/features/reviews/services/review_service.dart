import 'dart:convert';

import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/core/storage/local_cache_service.dart';
import 'package:dokomandu/features/reviews/models/order_review_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewService {
  const ReviewService(this._cache);

  final LocalCacheService _cache;

  Future<Map<String, OrderReviewModel>> readAll() async {
    final raw = await _cache.getString(AppConfig.cacheOrderReviews);
    if (raw == null || raw.isEmpty) return const {};

    final decoded = jsonDecode(raw) as List<dynamic>;
    final map = <String, OrderReviewModel>{};
    for (final item in decoded.whereType<Map>()) {
      final review = OrderReviewModel.fromJson(
        item.map((key, value) => MapEntry(key.toString(), value)),
      );
      map[review.orderId] = review;
    }
    return map;
  }

  Future<void> saveAll(Map<String, OrderReviewModel> data) async {
    final payload = data.values.map((e) => e.toJson()).toList();
    await _cache.setString(AppConfig.cacheOrderReviews, jsonEncode(payload));
  }
}

final reviewServiceProvider = Provider<ReviewService>(
  (ref) => ReviewService(ref.watch(localCacheServiceProvider)),
);
