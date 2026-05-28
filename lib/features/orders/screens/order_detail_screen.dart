import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/core/widgets/app_loader.dart';
import 'package:dokomandu/features/orders/models/order_tracking_model.dart';
import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/features/orders/widgets/order_timeline.dart';
import 'package:dokomandu/features/reviews/viewmodels/review_viewmodel.dart';
import 'package:dokomandu/features/tracking/models/tracking_view_state.dart';
import 'package:dokomandu/features/tracking/viewmodels/tracking_viewmodel.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as osm;

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingViewModelProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Order #$orderId')),
      body: tracking.when(
        loading: () => const AppLoader(message: 'Loading tracking...'),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref
              .read(trackingViewModelProvider(orderId).notifier)
              .refresh(orderId),
        ),
        data: (viewState) {
          final trackingData = viewState.snapshot;
          final order = trackingData.order;
          final theme = Theme.of(context);
          final review = ref.watch(orderReviewProvider(order.id));

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              _OrderSummaryCard(order: order),
              const SizedBox(height: AppSpacing.md),
              _TrackingCard(order: order, tracking: trackingData),
              const SizedBox(height: AppSpacing.sm),
              _TrackingControls(
                order: order,
                viewState: viewState,
                onToggleAuto: (value) => ref
                    .read(trackingViewModelProvider(orderId).notifier)
                    .toggleAutoAdvance(value),
                onNextStatus: () => ref
                    .read(trackingViewModelProvider(orderId).notifier)
                    .nextStatus(orderId),
                onStartScheduledDemo: () => ref
                    .read(trackingViewModelProvider(orderId).notifier)
                    .startScheduledDemo(orderId),
                onCancelOrder: () => ref
                    .read(trackingViewModelProvider(orderId).notifier)
                    .cancelOrder(orderId),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support: +977-9800000000 (Demo)'),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Help & Support'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _RiderTrackingMap(
                riderLatitude: trackingData.riderLatitude,
                riderLongitude: trackingData.riderLongitude,
                pickupLatitude: trackingData.pickupLatitude,
                pickupLongitude: trackingData.pickupLongitude,
                destinationLatitude: trackingData.destinationLatitude,
                destinationLongitude: trackingData.destinationLongitude,
                canTrackLive: trackingData.canTrackLive,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Order Status Timeline', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: OrderTimeline(currentStatus: order.status),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Items', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              ...order.items.map(
                (item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: AppRadius.brMd,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'x${item.quantity}',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.foodName,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          'Rs ${item.price.toStringAsFixed(0)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _row('Subtotal', order.subtotal),
                      _row('Delivery Fee', order.deliveryFee),
                      _row('Tax', order.tax),
                      _row(
                        'COD Status',
                        0,
                        suffix: order.codPaid ? 'Paid' : 'Pending',
                      ),
                      const Divider(height: AppSpacing.lg),
                      _row('Total', order.total, isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Rating & Review', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              if (order.status != OrderStatus.delivered)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Rating unlocks once your order is delivered.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                )
              else if (review == null)
                FilledButton.icon(
                  onPressed: () => context.push(
                    RoutePaths.reviewOrder.replaceFirst(':id', order.id),
                  ),
                  icon: const Icon(Icons.reviews_outlined),
                  label: const Text('Rate This Order'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thanks for your review!',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Overall: ${review.overallRating}/5 • Food: ${review.foodQualityRating}/5 • Delivery: ${review.deliveryRating}/5',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (review.comment != null &&
                            review.comment!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              review.comment!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(
    String label,
    double value, {
    bool isTotal = false,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            suffix ?? 'Rs ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.status.label,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Placed on ${DateFormat('MMM d, yyyy • hh:mm a').format(order.createdAt)}',
            style: theme.textTheme.bodySmall,
          ),
          if (order.isScheduled && order.scheduledFor != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Scheduled for ${DateFormat('MMM d, yyyy • hh:mm a').format(order.scheduledFor!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.kitchenName ?? 'Assigned Kitchen',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Payment: ${order.paymentMethod}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.order, required this.tracking});

  final OrderModel order;
  final OrderTrackingModel tracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tracking.riderName,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        tracking.riderVehicle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rider contact: ${tracking.riderPhone}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: tracking.progress),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tracking.canTrackLive
                        ? 'Rider is on the way'
                        : 'Tracking starts once rider moves for delivery',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  order.status == OrderStatus.delivered
                      ? 'Delivered'
                      : 'ETA ${tracking.etaMinutes} min',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingControls extends StatelessWidget {
  const _TrackingControls({
    required this.order,
    required this.viewState,
    required this.onToggleAuto,
    required this.onNextStatus,
    required this.onStartScheduledDemo,
    required this.onCancelOrder,
  });

  final OrderModel order;
  final TrackingViewState viewState;
  final ValueChanged<bool> onToggleAuto;
  final VoidCallback onNextStatus;
  final VoidCallback onStartScheduledDemo;
  final VoidCallback onCancelOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Demo Tracking Controls',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch.adaptive(
                  value: viewState.autoAdvance,
                  onChanged: onToggleAuto,
                ),
              ],
            ),
            Text(
              'Auto Tracking ${viewState.autoAdvance ? 'On' : 'Off'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed:
                        (order.status == OrderStatus.delivered ||
                            order.status == OrderStatus.cancelled ||
                            (order.isScheduled && !order.trackingStarted))
                        ? null
                        : onNextStatus,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Next Status'),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canCancel(order.status) ? onCancelOrder : null,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
                ),
              ],
            ),
            if (order.isScheduled && !order.trackingStarted) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This is a scheduled order. Start the demo to enable status progression.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FilledButton.icon(
                onPressed: onStartScheduledDemo,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Start Scheduled Order Demo'),
              ),
            ],
            if (viewState.error != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                viewState.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RiderTrackingMap extends StatelessWidget {
  const _RiderTrackingMap({
    required this.riderLatitude,
    required this.riderLongitude,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.canTrackLive,
  });

  final double riderLatitude;
  final double riderLongitude;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final bool canTrackLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: AppRadius.brLg,
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: osm.LatLng(riderLatitude, riderLongitude),
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dokomandu',
                  maxZoom: 19,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      color: theme.colorScheme.primary.withValues(alpha: 0.45),
                      strokeWidth: 4,
                      points: [
                        osm.LatLng(pickupLatitude, pickupLongitude),
                        osm.LatLng(destinationLatitude, destinationLongitude),
                      ],
                    ),
                    Polyline(
                      color: theme.colorScheme.primary,
                      strokeWidth: 5,
                      points: [
                        osm.LatLng(riderLatitude, riderLongitude),
                        osm.LatLng(destinationLatitude, destinationLongitude),
                      ],
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: osm.LatLng(pickupLatitude, pickupLongitude),
                      width: 38,
                      height: 38,
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    Marker(
                      point: osm.LatLng(
                        destinationLatitude,
                        destinationLongitude,
                      ),
                      width: 38,
                      height: 38,
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    Marker(
                      point: osm.LatLng(riderLatitude, riderLongitude),
                      width: 42,
                      height: 42,
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        color: Colors.blue,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!canTrackLive)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text('Waiting for rider movement...'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
