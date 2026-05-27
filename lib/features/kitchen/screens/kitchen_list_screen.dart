import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/kitchen/viewmodels/kitchen_viewmodel.dart';
import 'package:dokomandu/features/kitchen/widgets/kitchen_card.dart';
import 'package:dokomandu/features/kitchen/widgets/kitchen_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KitchenListScreen extends ConsumerStatefulWidget {
  const KitchenListScreen({super.key});

  @override
  ConsumerState<KitchenListScreen> createState() => _KitchenListScreenState();
}

class _KitchenListScreenState extends ConsumerState<KitchenListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _selectedFilterIndex = 0;

  static const _filters = ['Nearest', 'Top Rated', 'Fast Delivery', 'Open'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(kitchenViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(kitchenViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Kitchens')),
      body: state.when(
        loading: () => const KitchenListShimmer(),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(kitchenViewModelProvider.notifier).refresh(),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return const AppEmptyState(
              title: 'No kitchens available right now',
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(kitchenViewModelProvider.notifier).refresh(),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.items.length}+ kitchens available',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find the best kitchens near you with faster delivery and top ratings.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search kitchens or cuisine',
                  leading: const Icon(Icons.search_rounded),
                  trailing: const [Icon(Icons.tune_rounded)],
                  onChanged: (value) =>
                      ref.read(kitchenViewModelProvider.notifier).search(value),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final selected = _selectedFilterIndex == index;
                      return ChoiceChip(
                        label: Text(_filters[index]),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedFilterIndex = index);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...data.items.map(
                  (kitchen) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: KitchenCard(
                      kitchen: kitchen,
                      onTap: () => context.push('/kitchens/${kitchen.id}'),
                    ),
                  ),
                ),
                if (data.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
