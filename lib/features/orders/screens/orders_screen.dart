import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/orders/services/orders_service.dart';
import 'package:dokomandu/features/orders/viewmodels/orders_viewmodel.dart';
import 'package:dokomandu/features/orders/widgets/orders_shimmer.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersViewModelProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: state.when(
          loading: () => const OrdersShimmer(),
          error: (error, stack) => AppErrorState(
            message: error.toString(),
            onRetry: () => ref.read(ordersViewModelProvider.notifier).refresh(),
          ),
          data: (data) {
            return TabBarView(
              children: [
                _OrderList(
                  emptyTitle: 'No active orders',
                  emptySubtitle:
                      'Your active delivery requests will appear here.',
                  orderItems: data.activeOrders,
                  onOrderTap: (id) => context.push(
                    RoutePaths.orderDetail.replaceFirst(':id', id),
                  ),
                  onCancelOrder: (id) => ref
                      .read(ordersViewModelProvider.notifier)
                      .cancelOrder(id),
                  onStartScheduledDemo: (id) => ref
                      .read(ordersViewModelProvider.notifier)
                      .startScheduledOrderDemo(id),
                ),
                _OrderList(
                  emptyTitle: 'No order history yet',
                  emptySubtitle:
                      'Delivered or cancelled orders will show up here.',
                  orderItems: data.historyOrders,
                  onOrderTap: (id) => context.push(
                    RoutePaths.orderDetail.replaceFirst(':id', id),
                  ),
                  onSecondaryAction: (id) =>
                      ref.read(ordersViewModelProvider.notifier).reorder(id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.orderItems,
    required this.onOrderTap,
    this.onSecondaryAction,
    this.onCancelOrder,
    this.onStartScheduledDemo,
  });

  final String emptyTitle;
  final String emptySubtitle;
  final List<OrderModel> orderItems;
  final ValueChanged<String> onOrderTap;
  final ValueChanged<String>? onSecondaryAction;
  final ValueChanged<String>? onCancelOrder;
  final ValueChanged<String>? onStartScheduledDemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (orderItems.isEmpty) {
      return AppEmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      itemCount: orderItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final order = orderItems[index];
        final statusStyle = _statusStyle(context, order.status);

        return Card(
          child: InkWell(
            borderRadius: AppRadius.brLg,
            onTap: () => onOrderTap(order.id),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusStyle.background,
                          borderRadius: AppRadius.brXl,
                        ),
                        child: Text(
                          order.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusStyle.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (order.isScheduled) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: AppRadius.brXl,
                          ),
                          child: Text(
                            'Scheduled',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, hh:mm a').format(order.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (order.isScheduled && order.scheduledFor != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.event_available_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'MMM d • hh:mm a',
                          ).format(order.scheduledFor!),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.fastfood_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${order.items.length} items',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text(
                        'Rs ${order.total.toStringAsFixed(0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (order.isScheduled &&
                          !order.trackingStarted &&
                          order.status != OrderStatus.cancelled &&
                          order.status != OrderStatus.delivered)
                        OutlinedButton.icon(
                          onPressed: onStartScheduledDemo == null
                              ? null
                              : () => onStartScheduledDemo!(order.id),
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: const Text('Start Demo'),
                        )
                      else if (onCancelOrder != null && canCancel(order.status))
                        OutlinedButton.icon(
                          onPressed: () => onCancelOrder!(order.id),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        )
                      else if (onSecondaryAction != null)
                        OutlinedButton.icon(
                          onPressed: () => onSecondaryAction!(order.id),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reorder'),
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      FilledButton(
                        onPressed: () => onOrderTap(order.id),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _StatusStyle _statusStyle(BuildContext context, OrderStatus status) {
    final scheme = Theme.of(context).colorScheme;

    switch (status) {
      case OrderStatus.delivered:
        return _StatusStyle(
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        );
      case OrderStatus.cancelled:
        return _StatusStyle(
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
      case OrderStatus.onTheWay:
      case OrderStatus.pickedUp:
      case OrderStatus.nearby:
        return _StatusStyle(
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
        );
      default:
        return _StatusStyle(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
