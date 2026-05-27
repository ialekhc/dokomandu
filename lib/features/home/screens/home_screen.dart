import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/home/viewmodels/home_viewmodel.dart';
import 'package:dokomandu/features/home/widgets/category_chips.dart';
import 'package:dokomandu/features/home/widgets/home_shimmer.dart';
import 'package:dokomandu/features/home/widgets/offer_banner_carousel.dart';
import 'package:dokomandu/features/home/widgets/popular_food_list.dart';
import 'package:dokomandu/features/kitchen/widgets/kitchen_card.dart';
import 'package:dokomandu/features/menu/screens/food_detail_sheet.dart';
import 'package:dokomandu/shared/widgets/brand_logo.dart';
import 'package:dokomandu/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
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
        data: (data) {
          final hasSearchQuery = _searchController.text.trim().isNotEmpty;

          if (hasSearchQuery &&
              !data.isSearching &&
              data.searchResults.isEmpty) {
            return const AppEmptyState(title: 'No food found for your search');
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                120,
              ),
              children: [
                _AddressBanner(
                  onTap: () => context.push(RoutePaths.locationPicker),
                ),
                const SizedBox(height: AppSpacing.md),
                SearchBar(
                  controller: _searchController,
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
                  onChanged: (value) =>
                      ref.read(homeViewModelProvider.notifier).search(value),
                ),
                const SizedBox(height: AppSpacing.md),
                OfferBannerCarousel(banners: data.feed.offers),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Categories',
                  subtitle: 'Explore what you are craving today',
                  actionLabel: 'See all',
                  onActionTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                CategoryChips(categories: data.feed.categories),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Popular Foods',
                  subtitle: 'Best rated dishes near your location',
                ),
                const SizedBox(height: AppSpacing.sm),
                PopularFoodList(
                  items: data.feed.popularFoods,
                  onTap: (item) => showFoodDetailSheet(context, ref, item),
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
            ),
          );
        },
      ),
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
