import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({required this.currentStatus, super.key});

  final OrderStatus currentStatus;

  static const _statusFlow = [
    OrderStatus.placed,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.onTheWay,
    OrderStatus.nearby,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _statusFlow.indexOf(currentStatus);

    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'This order was cancelled.',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _statusFlow.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final completed = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return _TimelineStep(
          label: status.label,
          completed: completed,
          isCurrent: isCurrent,
          isLast: index == _statusFlow.length - 1,
        );
      }).toList(),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.completed,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool completed;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.outlineVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? activeColor : Colors.transparent,
                  border: Border.all(
                    color: completed ? activeColor : inactiveColor,
                    width: 2,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  color: completed ? activeColor : inactiveColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: completed
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Current status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
