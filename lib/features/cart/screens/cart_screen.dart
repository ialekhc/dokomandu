import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/cart/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartViewModelProvider);
    final notifier = ref.read(cartViewModelProvider.notifier);
    final theme = Theme.of(context);

    if (state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppEmptyState(
                title: 'Your cart is empty',
                subtitle: 'Add meals from nearby kitchens to place your order.',
                icon: Icons.shopping_cart_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.go(RoutePaths.home),
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text('Browse kitchens'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          TextButton.icon(
            onPressed: () => notifier.clearCart(),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          170,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delivery_dining_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Average delivery: 25-35 min',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  'Live tracking',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...state.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CartItemTile(
                item: item,
                onIncrement: () =>
                    notifier.updateQuantity(item.id, item.quantity + 1),
                onDecrement: () =>
                    notifier.updateQuantity(item.id, item.quantity - 1),
                onRemove: () => notifier.removeItem(item.id),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Coupon Code',
              hintText: 'Coming soon',
              prefixIcon: Icon(Icons.discount_outlined),
              suffixIcon: Icon(Icons.local_offer_outlined),
            ),
            onSubmitted: notifier.applyCouponPlaceholder,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _priceRow('Subtotal', state.subtotal),
                  _priceRow('Delivery Fee', notifier.deliveryFee),
                  _priceRow('VAT/Tax', notifier.tax),
                  if (state.discountAmount > 0)
                    _priceRow('Discount', -state.discountAmount),
                  const Divider(height: AppSpacing.lg),
                  _priceRow('Grand Total', notifier.total, isTotal: true),
                ],
              ),
            ),
          ),
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
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total Payable', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Rs ${notifier.total.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => context.push(RoutePaths.checkout),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
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
