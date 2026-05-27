import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/features/home/models/home_feed_model.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';

class HomeService {
  const HomeService(this._apiService);

  final BaseApiService _apiService;

  Future<HomeFeedModel> fetchHomeFeed({
    required double lat,
    required double lng,
  }) {
    if (AppConfig.useStaticContent) {
      return _fetchHomeFeedStatic();
    }

    return _apiService.get<HomeFeedModel>(
      ApiEndpoints.homeFeed,
      queryParameters: {'lat': lat, 'lng': lng},
      parser: (data) => HomeFeedModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<FoodItemModel>> searchFoods(String query) {
    if (AppConfig.useStaticContent) {
      return _searchFoodsStatic(query);
    }

    return _apiService.get<List<FoodItemModel>>(
      ApiEndpoints.searchFoods,
      queryParameters: {'q': query},
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<HomeFeedModel> _fetchHomeFeedStatic() async {
    await DummyData.delay();
    return DummyData.homeFeed();
  }

  Future<List<FoodItemModel>> _searchFoodsStatic(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return DummyData.searchFoods(query);
  }
}
