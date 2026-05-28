import 'package:dokomandu/features/reviews/models/order_review_model.dart';
import 'package:dokomandu/features/reviews/services/review_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewViewModel extends AsyncNotifier<Map<String, OrderReviewModel>> {
  ReviewService get _service => ref.read(reviewServiceProvider);

  @override
  Future<Map<String, OrderReviewModel>> build() {
    return _service.readAll();
  }

  OrderReviewModel? reviewFor(String orderId) {
    return state.valueOrNull?[orderId];
  }

  bool hasReview(String orderId) => reviewFor(orderId) != null;

  Future<bool> submitReview(OrderReviewModel review) async {
    final current = state.valueOrNull ?? <String, OrderReviewModel>{};
    if (current.containsKey(review.orderId)) {
      return false;
    }

    final next = {...current, review.orderId: review};
    await _service.saveAll(next);
    state = AsyncData(next);
    return true;
  }
}

final reviewViewModelProvider =
    AsyncNotifierProvider<ReviewViewModel, Map<String, OrderReviewModel>>(
      ReviewViewModel.new,
    );

final orderReviewProvider = Provider.family<OrderReviewModel?, String>((
  ref,
  orderId,
) {
  final reviews = ref.watch(reviewViewModelProvider).valueOrNull;
  return reviews?[orderId];
});
