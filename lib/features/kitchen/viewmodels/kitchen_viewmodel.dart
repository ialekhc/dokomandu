import 'package:dokomandu/features/kitchen/services/kitchen_service.dart';
import 'package:dokomandu/shared/models/kitchen_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KitchenListState {
  const KitchenListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.search,
  });

  final List<KitchenModel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? search;

  KitchenListState copyWith({
    List<KitchenModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
  }) {
    return KitchenListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class KitchenViewModel extends AsyncNotifier<KitchenListState> {
  static const int _pageSize = 10;

  KitchenService get _service => ref.read(kitchenServiceProvider);

  @override
  Future<KitchenListState> build() async {
    final items = await _service.fetchKitchens(page: 1, limit: _pageSize);
    return KitchenListState(
      items: items,
      page: 1,
      hasMore: items.length >= _pageSize,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;
    final items = await _service.fetchKitchens(
      page: nextPage,
      limit: _pageSize,
      search: current.search,
    );

    final updated = state.valueOrNull;
    if (updated == null) return;

    state = AsyncData(
      updated.copyWith(
        isLoadingMore: false,
        page: nextPage,
        hasMore: items.length >= _pageSize,
        items: [...updated.items, ...items],
      ),
    );
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    final items = await _service.fetchKitchens(
      page: 1,
      limit: _pageSize,
      search: query,
    );
    state = AsyncData(
      KitchenListState(
        items: items,
        page: 1,
        hasMore: items.length >= _pageSize,
        search: query,
      ),
    );
  }
}

final kitchenServiceProvider = Provider<KitchenService>(
  (ref) => KitchenService(ref.watch(baseApiServiceProvider)),
);

final kitchenViewModelProvider =
    AsyncNotifierProvider<KitchenViewModel, KitchenListState>(
      KitchenViewModel.new,
    );

final kitchenDetailProvider = FutureProvider.family<KitchenModel, String>(
  (ref, kitchenId) =>
      ref.watch(kitchenServiceProvider).fetchKitchenDetail(kitchenId),
);
