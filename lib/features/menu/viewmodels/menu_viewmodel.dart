import 'package:dokomandu/features/menu/services/menu_service.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuViewModel extends FamilyAsyncNotifier<List<FoodItemModel>, String> {
  MenuService get _service => ref.read(menuServiceProvider);

  @override
  Future<List<FoodItemModel>> build(String kitchenId) {
    return _service.fetchKitchenMenu(kitchenId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final menuServiceProvider = Provider<MenuService>(
  (ref) => MenuService(ref.watch(baseApiServiceProvider)),
);

final menuViewModelProvider =
    AsyncNotifierProviderFamily<MenuViewModel, List<FoodItemModel>, String>(
      MenuViewModel.new,
    );
