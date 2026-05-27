import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/notifications/viewmodels/notifications_viewmodel.dart';
import 'package:dokomandu/features/notifications/widgets/notifications_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: state.when(
        loading: () => const NotificationsShimmer(),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.read(notificationsViewModelProvider.notifier).refresh(),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const AppEmptyState(
              title: 'No notifications yet',
              subtitle: 'Order updates and offers will appear here.',
            );
          }

          final unreadCount = notifications.where((n) => !n.isRead).length;
          final theme = Theme.of(context);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsViewModelProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              itemCount: notifications.length + 1,
              separatorBuilder: (_, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            unreadCount == 0
                                ? 'You are all caught up.'
                                : '$unreadCount unread notifications',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          'Tap to read',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = notifications[index - 1];

                return Card(
                  color: item.isRead
                      ? null
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.28,
                        ),
                  child: InkWell(
                    borderRadius: AppRadius.brLg,
                    onTap: () => ref
                        .read(notificationsViewModelProvider.notifier)
                        .markAsRead(item.id),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.primary,
                              borderRadius: AppRadius.brMd,
                            ),
                            child: Icon(
                              item.isRead
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_active_rounded,
                              color: item.isRead
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: item.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.body,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  DateFormat(
                                    'MMM d, hh:mm a',
                                  ).format(item.createdAt),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
