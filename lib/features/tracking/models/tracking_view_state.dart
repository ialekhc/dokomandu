import 'package:dokomandu/features/orders/models/order_tracking_model.dart';

class TrackingViewState {
  const TrackingViewState({
    required this.snapshot,
    this.autoAdvance = true,
    this.isBusy = false,
    this.error,
  });

  final OrderTrackingModel snapshot;
  final bool autoAdvance;
  final bool isBusy;
  final String? error;

  TrackingViewState copyWith({
    OrderTrackingModel? snapshot,
    bool? autoAdvance,
    bool? isBusy,
    String? error,
  }) {
    return TrackingViewState(
      snapshot: snapshot ?? this.snapshot,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}
