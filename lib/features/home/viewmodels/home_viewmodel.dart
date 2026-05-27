import 'package:dokomandu/features/home/models/home_feed_model.dart';
import 'package:dokomandu/features/home/services/home_service.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewState {
  const HomeViewState({
    required this.feed,
    this.searchResults = const [],
    this.isSearching = false,
  });

  final HomeFeedModel feed;
  final List<FoodItemModel> searchResults;
  final bool isSearching;

  HomeViewState copyWith({
    HomeFeedModel? feed,
    List<FoodItemModel>? searchResults,
    bool? isSearching,
  }) {
    return HomeViewState(
      feed: feed ?? this.feed,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeViewState> {
  HomeService get _service => ref.read(homeServiceProvider);

  @override
  Future<HomeViewState> build() async {
    return _loadFeed();
  }

  Future<HomeViewState> _loadFeed() async {
    final location = ref.read(locationViewModelProvider).valueOrNull;

    final lat = location?.selectedPoint?.latitude ?? 27.7172;
    final lng = location?.selectedPoint?.longitude ?? 85.3240;

    final feed = await _service.fetchHomeFeed(lat: lat, lng: lng);
    return HomeViewState(feed: feed);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFeed);
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (query.trim().isEmpty) {
      state = AsyncData(
        current.copyWith(searchResults: const [], isSearching: false),
      );
      return;
    }

    state = AsyncData(current.copyWith(isSearching: true));
    final items = await _service.searchFoods(query);
    final updated = state.valueOrNull;
    if (updated == null) return;
    state = AsyncData(
      updated.copyWith(searchResults: items, isSearching: false),
    );
  }
}

final homeServiceProvider = Provider<HomeService>(
  (ref) => HomeService(ref.watch(baseApiServiceProvider)),
);

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeViewState>(HomeViewModel.new);
