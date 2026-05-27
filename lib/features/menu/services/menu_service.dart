import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';

class MenuService {
  const MenuService(this._apiService);

  final BaseApiService _apiService;

  Future<List<FoodItemModel>> fetchKitchenMenu(String kitchenId) {
    if (AppConfig.useStaticContent) {
      return _fetchKitchenMenuStatic(kitchenId);
    }

    final endpoint = ApiEndpoints.kitchenMenu.replaceFirst('{id}', kitchenId);

    return _apiService.get<List<FoodItemModel>>(
      endpoint,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<FoodItemModel>> _fetchKitchenMenuStatic(String kitchenId) async {
    await DummyData.delay();
    return DummyData.menuForKitchen(kitchenId);
  }
}
