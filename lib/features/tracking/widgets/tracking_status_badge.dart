import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/shared/models/order_model.dart';
import 'package:flutter/material.dart';

class TrackingStatusBadge extends StatelessWidget {
  const TrackingStatusBadge({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      OrderStatus.delivered => theme.colorScheme.tertiaryContainer,
      OrderStatus.cancelled => theme.colorScheme.errorContainer,
      _ => theme.colorScheme.primaryContainer,
    };
    final textColor = switch (status) {
      OrderStatus.delivered => theme.colorScheme.onTertiaryContainer,
      OrderStatus.cancelled => theme.colorScheme.onErrorContainer,
      _ => theme.colorScheme.onPrimaryContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.brXl),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
