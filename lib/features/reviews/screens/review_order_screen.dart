import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/orders/viewmodels/orders_viewmodel.dart';
import 'package:dokomandu/features/reviews/models/order_review_model.dart';
import 'package:dokomandu/features/reviews/viewmodels/review_viewmodel.dart';
import 'package:dokomandu/features/reviews/widgets/rating_input_row.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewOrderScreen extends ConsumerStatefulWidget {
  const ReviewOrderScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  final _commentController = TextEditingController();
  int _overall = 0;
  int _foodQuality = 0;
  int _delivery = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overall < 1 || _foodQuality < 1 || _delivery < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all ratings.')),
      );
      return;
    }

    final review = OrderReviewModel(
      orderId: widget.orderId,
      overallRating: _overall,
      foodQualityRating: _foodQuality,
      deliveryRating: _delivery,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      submittedAt: DateTime.now(),
    );

    final ok = await ref
        .read(reviewViewModelProvider.notifier)
        .submitReview(review);

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already submitted a review.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Thanks for your review!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(orderReviewProvider(widget.orderId));
    final order = ref.watch(orderDetailProvider(widget.orderId));

    return order.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Rate Order')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Rate Order')),
        body: Center(child: Text(error.toString())),
      ),
      data: (orderData) {
        if (orderData.status != OrderStatus.delivered) {
          return Scaffold(
            appBar: AppBar(title: const Text('Rate Order')),
            body: const Center(
              child: Text('Review is available only after delivery.'),
            ),
          );
        }

        if (existing != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Rate Order')),
            body: const Center(
              child: Text('Review already submitted for this order.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Rate Order')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              RatingInputRow(
                title: 'Overall Order',
                value: _overall,
                onChanged: (value) => setState(() => _overall = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              RatingInputRow(
                title: 'Food Quality',
                value: _foodQuality,
                onChanged: (value) => setState(() => _foodQuality = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              RatingInputRow(
                title: 'Delivery Experience',
                value: _delivery,
                onChanged: (value) => setState(() => _delivery = value),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Optional Feedback',
                  hintText: 'Tell us what went well or what can improve.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _submit,
                child: const Text('Submit Review'),
              ),
            ],
          ),
        );
      },
    );
  }
}
