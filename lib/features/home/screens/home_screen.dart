import 'dart:async';

import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/features/home/viewmodels/home_viewmodel.dart';
import 'package:dokomandu/features/home/widgets/category_chips.dart';
import 'package:dokomandu/features/home/widgets/home_shimmer.dart';
import 'package:dokomandu/features/home/widgets/offer_banner_carousel.dart';
import 'package:dokomandu/features/home/widgets/popular_food_list.dart';
import 'package:dokomandu/features/kitchen/widgets/kitchen_card.dart';
import 'package:dokomandu/features/menu/screens/food_detail_sheet.dart';
import 'package:dokomandu/features/menu/widgets/food_card.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/widgets/brand_logo.dart';
import 'package:dokomandu/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void _showCartAddedSnackBar(BuildContext context, String foodName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$foodName added to cart'),
      action: SnackBarAction(
        label: 'View Cart',
        onPressed: () => context.go(RoutePaths.cart),
      ),
    ),
  );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(homeViewModelProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final cart = ref.watch(cartViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: AppSpacing.md,
        title: const Row(
          children: [
            BrandLogo(size: 34),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dokomandu', maxLines: 1),
                  SizedBox(height: 1),
                  Text(
                    'Food & essentials in minutes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton.filledTonal(
              onPressed: () => context.push(RoutePaths.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: state.when(
        loading: () => const HomeShimmer(),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(homeViewModelProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
          child: _HomeBody(
            data: data,
            cart: cart,
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.data,
    required this.cart,
    required this.searchController,
    required this.onSearchChanged,
  });

  final HomeViewState data;
  final CartState cart;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSearchQuery = searchController.text.trim().isNotEmpty;
    final showSearchEmpty =
        hasSearchQuery && !data.isSearching && data.searchResults.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        _AddressBanner(onTap: () => context.push(RoutePaths.locationPicker)),
        const SizedBox(height: AppSpacing.md),
        SearchBar(
          controller: searchController,
          hintText: 'Search foods, kitchens, and categories',
          leading: const Icon(Icons.search_rounded),
          trailing: data.isSearching
              ? const [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ]
              : const [Icon(Icons.tune_rounded)],
          onChanged: onSearchChanged,
        ),
        if (cart.items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _HomeCartPreview(
            totalItems: cart.totalItems,
            subtotal: cart.subtotal,
            onTap: () => context.go(RoutePaths.cart),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (hasSearchQuery)
          _SearchResultsSection(
            isEmpty: showSearchEmpty,
            results: data.searchResults,
          )
        else
          _HomeFeedSection(data: data),
      ],
    );
  }
}

class _SearchResultsSection extends ConsumerWidget {
  const _SearchResultsSection({required this.isEmpty, required this.results});

  final bool isEmpty;
  final List<FoodItemModel> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Search Results',
          subtitle: 'Tap an item to customize and add to cart',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isEmpty)
          const AppEmptyState(
            title: 'No food found for your search',
            subtitle: 'Try another keyword or shorter name.',
            icon: Icons.search_off_rounded,
          )
        else
          ...results.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FoodCard(
                item: item,
                onTap: () => showFoodDetailSheet(context, ref, item),
                onQuickAdd: () async {
                  await ref
                      .read(cartViewModelProvider.notifier)
                      .addItem(food: item);
                  if (!context.mounted) return;
                  _showCartAddedSnackBar(context, item.name);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeFeedSection extends ConsumerWidget {
  const _HomeFeedSection({required this.data});

  final HomeViewState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Access',
          subtitle: 'Open and test all core app screens quickly',
        ),
        const SizedBox(height: AppSpacing.sm),
        _HomeQuickActions(),
        const SizedBox(height: AppSpacing.lg),
        OfferBannerCarousel(banners: data.feed.offers),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "WHAT'S ON YOUR MIND?",
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Explore what you are craving today',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryChips(categories: data.feed.categories),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(
          title: 'Popular Foods',
          subtitle: 'Best rated dishes near your location',
        ),
        const SizedBox(height: AppSpacing.sm),
        PopularFoodList(
          items: data.feed.popularFoods,
          onTap: (item) => showFoodDetailSheet(context, ref, item),
          onQuickAdd: (item) async {
            await ref.read(cartViewModelProvider.notifier).addItem(food: item);
            if (!context.mounted) return;
            _showCartAddedSnackBar(context, item.name);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Nearby Kitchens',
          subtitle: 'Fast delivery from top sellers',
          actionLabel: 'View all',
          onActionTap: () => context.push(RoutePaths.kitchenList),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...data.feed.nearbyKitchens.map(
          (kitchen) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: KitchenCard(
              kitchen: kitchen,
              onTap: () => context.push('/kitchens/${kitchen.id}'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
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
                  'Delivery updates and tracking are enabled for your upcoming orders.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressBanner extends StatelessWidget {
  const _AddressBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.62),
        borderRadius: AppRadius.brLg,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.location_on_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text('Delivering to Home', style: theme.textTheme.titleSmall),
        subtitle: Text(
          'Tap to change your delivery location',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _HomeCartPreview extends StatelessWidget {
  const _HomeCartPreview({
    required this.totalItems,
    required this.subtotal,
    required this.onTap,
  });

  final int totalItems;
  final double subtotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.56),
        borderRadius: AppRadius.brLg,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Badge.count(
          count: totalItems,
          isLabelVisible: totalItems > 0,
          child: Icon(
            Icons.shopping_cart_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          '$totalItems item${totalItems > 1 ? 's' : ''} added in cart',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          'Rs ${subtotal.toStringAsFixed(0)} • Tap to review cart',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _HomeQuickActions extends StatelessWidget {
  const _HomeQuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _QuickActionButton(
          label: 'Kitchens',
          icon: Icons.storefront_outlined,
          onTap: () => context.push(RoutePaths.kitchenList),
        ),
        _QuickActionButton(
          label: 'Cart',
          icon: Icons.shopping_cart_outlined,
          onTap: () => context.go(RoutePaths.cart),
        ),
        _QuickActionButton(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          onTap: () => context.go(RoutePaths.orders),
        ),
        _QuickActionButton(
          label: 'Profile',
          icon: Icons.person_outline,
          onTap: () => context.go(RoutePaths.profile),
        ),
        _QuickActionButton(
          label: 'Location',
          icon: Icons.location_on_outlined,
          onTap: () => context.push(RoutePaths.locationPicker),
        ),
        _QuickActionButton(
          label: 'Alerts',
          icon: Icons.notifications_outlined,
          onTap: () => context.push(RoutePaths.notifications),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: Container(
          constraints: const BoxConstraints(minWidth: 104),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brMd,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
