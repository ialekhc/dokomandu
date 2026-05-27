import 'package:dokomandu/shared/models/order_model.dart';

class OrderTimelineStep {
  const OrderTimelineStep({
    required this.status,
    required this.label,
    required this.isCompleted,
  });

  final OrderStatus status;
  final String label;
  final bool isCompleted;
}
