import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/checkout/viewmodels/checkout_viewmodel.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  static const _slots = ['10:30', '13:00', '17:30', '20:00'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutViewModelProvider);
    final cartState = ref.watch(cartViewModelProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);
    final locationData = ref.watch(locationViewModelProvider).valueOrNull;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          190,
        ),
        children: [
          Text('Delivery Address', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          if (locationData == null || locationData.savedAddresses.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No saved addresses found. Add one to continue checkout.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push(RoutePaths.addressManagement),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Manage Addresses'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...locationData.savedAddresses.map(
              (address) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _AddressOptionCard(
                  address: address,
                  isSelected: checkoutState.selectedAddress?.id == address.id,
                  onTap: () => ref
                      .read(checkoutViewModelProvider.notifier)
                      .selectAddress(address),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Delivery Type', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _DeliveryTypeTile(
                  title: 'Order Now',
                  subtitle: 'Immediate kitchen processing',
                  icon: Icons.flash_on_outlined,
                  selected: checkoutState.deliveryType == 'NOW',
                  onTap: () => ref
                      .read(checkoutViewModelProvider.notifier)
                      .selectDeliveryType('NOW'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DeliveryTypeTile(
                  title: 'Schedule Order',
                  subtitle: 'Pick delivery date and slot',
                  icon: Icons.schedule_outlined,
                  selected: checkoutState.deliveryType == 'SCHEDULE',
                  onTap: () => ref
                      .read(checkoutViewModelProvider.notifier)
                      .selectDeliveryType('SCHEDULE'),
                ),
              ),
            ],
          ),
          if (checkoutState.deliveryType == 'SCHEDULE') ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 14)),
                  initialDate: checkoutState.scheduledDate ?? now,
                );
                if (picked == null) return;
                ref
                    .read(checkoutViewModelProvider.notifier)
                    .selectScheduledDate(picked);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                checkoutState.scheduledDate == null
                    ? 'Select Delivery Date'
                    : 'Delivery Date: ${checkoutState.scheduledDate!.day}/${checkoutState.scheduledDate!.month}/${checkoutState.scheduledDate!.year}',
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _slots
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(slot),
                      selected: checkoutState.scheduledSlot == slot,
                      onSelected: (_) => ref
                          .read(checkoutViewModelProvider.notifier)
                          .selectScheduledSlot(slot),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Payment Method', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                _PaymentOptionTile(
                  title: 'Cash on Delivery',
                  subtitle: 'Pay directly to delivery partner',
                  icon: Icons.payments_outlined,
                  selected: checkoutState.paymentMethod == 'COD',
                  onTap: () => ref
                      .read(checkoutViewModelProvider.notifier)
                      .selectPaymentMethod('COD'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: AppRadius.brMd,
                  ),
                  child: Text(
                    'Only Cash on Delivery is available right now.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _row('Items (${cartState.items.length})', cartState.subtotal),
                  if (checkoutState.deliveryType == 'SCHEDULE' &&
                      checkoutState.scheduledDate != null &&
                      checkoutState.scheduledSlot != null)
                    _row(
                      'Scheduled',
                      0,
                      suffix:
                          '${checkoutState.scheduledDate!.day}/${checkoutState.scheduledDate!.month} ${checkoutState.scheduledSlot}',
                    ),
                  _row('Delivery Fee', cartNotifier.deliveryFee),
                  _row('Tax', cartNotifier.tax),
                  const Divider(height: AppSpacing.lg),
                  _row('Total', cartNotifier.total, isTotal: true),
                ],
              ),
            ),
          ),
          if (checkoutState.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: AppRadius.brMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      checkoutState.error!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Payable Amount', style: theme.textTheme.labelMedium),
                  const Spacer(),
                  Text(
                    'Rs ${cartNotifier.total.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: checkoutState.isPlacingOrder
                      ? null
                      : () async {
                          final isSuccess = await ref
                              .read(checkoutViewModelProvider.notifier)
                              .placeOrder();
                          if (!context.mounted || !isSuccess) return;

                          final orderId =
                              ref.read(checkoutViewModelProvider).orderId ??
                              'N/A';
                          final isScheduled =
                              ref.read(checkoutViewModelProvider).deliveryType ==
                              'SCHEDULE';
                          final path = RoutePaths.orderSuccess
                              .replaceFirst(':id', orderId);
                          context.go('$path?scheduled=${isScheduled ? '1' : '0'}');
                        },
                  icon: checkoutState.isPlacingOrder
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_outline_rounded),
                  label: Text(
                    checkoutState.isPlacingOrder
                        ? 'Placing Order...'
                        : 'Place Order',
                  ),
                ),
              ),
            ],
          ),
        ),
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
          if (suffix != null)
            Text(
              suffix,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              ),
            )
          else
            Text(
              'Rs ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _DeliveryTypeTile extends StatelessWidget {
  const _DeliveryTypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
          : theme.colorScheme.surface,
      borderRadius: AppRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(title, style: theme.textTheme.titleSmall),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.36)
          : null,
      child: InkWell(
        borderRadius: AppRadius.brLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.label, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      address.fullAddress,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.colorScheme.surface,
      borderRadius: AppRadius.brMd,
      child: InkWell(
        borderRadius: AppRadius.brMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
