import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/kitchen/viewmodels/kitchen_viewmodel.dart';
import 'package:dokomandu/features/kitchen/widgets/kitchen_shimmer.dart';
import 'package:dokomandu/features/menu/screens/food_detail_sheet.dart';
import 'package:dokomandu/features/menu/viewmodels/menu_viewmodel.dart';
import 'package:dokomandu/features/menu/widgets/food_card.dart';
import 'package:dokomandu/shared/widgets/network_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KitchenDetailScreen extends ConsumerWidget {
  const KitchenDetailScreen({required this.kitchenId, super.key});

  final String kitchenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitchen = ref.watch(kitchenDetailProvider(kitchenId));
    final menu = ref.watch(menuViewModelProvider(kitchenId));
    final cart = ref.watch(cartViewModelProvider);

    return Scaffold(
      body: kitchen.when(
        loading: () => const KitchenDetailShimmer(),
        error: (error, stack) => AppErrorState(message: error.toString()),
        data: (kitchenData) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(menuViewModelProvider(kitchenId).notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                120,
              ),
              children: [
                Stack(
                  children: [
                    NetworkImageView(
                      imageUrl: kitchenData.imageUrl,
                      height: 220,
                      borderRadius: 22,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.brXl,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.62),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.sm,
                      top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
                      child: IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kitchenData.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              _HeroMeta(
                                icon: Icons.star_rounded,
                                text: kitchenData.rating.toStringAsFixed(1),
                              ),
                              _HeroMeta(
                                icon: Icons.location_on_outlined,
                                text:
                                    '${kitchenData.distanceKm.toStringAsFixed(1)} km',
                              ),
                              _HeroMeta(
                                icon: Icons.schedule_outlined,
                                text:
                                    kitchenData.estimatedDeliveryMinutes != null
                                    ? '${kitchenData.estimatedDeliveryMinutes} min'
                                    : '30 min',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: kitchenData.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Menu', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Choose your favorites and customize with variants or add-ons.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                menu.when(
                  loading: () => const MenuSectionShimmer(),
                  error: (error, stack) => AppErrorState(
                    message: error.toString(),
                    onRetry: () => ref
                        .read(menuViewModelProvider(kitchenId).notifier)
                        .refresh(),
                  ),
                  data: (foods) {
                    if (foods.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: AppEmptyState(
                          title: 'Menu is updating',
                          subtitle: 'Please check back in a bit.',
                          icon: Icons.restaurant_menu_outlined,
                        ),
                      );
                    }

                    return Column(
                      children: foods
                          .map(
                            (food) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: FoodCard(
                                item: food,
                                onTap: () =>
                                    showFoodDetailSheet(context, ref, food),
                                onQuickAdd: () async {
                                  await ref
                                      .read(cartViewModelProvider.notifier)
                                      .addItem(food: food);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${food.name} added to cart',
                                      ),
                                      action: SnackBarAction(
                                        label: 'View Cart',
                                        onPressed: () =>
                                            context.go(RoutePaths.cart),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: FilledButton.icon(
                onPressed: () => context.push(RoutePaths.cart),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  'View Cart (${cart.totalItems}) • Rs ${cart.subtotal.toStringAsFixed(0)}',
                ),
              ),
            ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: AppRadius.brXl,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
