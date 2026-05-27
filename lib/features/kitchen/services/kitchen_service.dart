import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/errors/app_exception.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/shared/models/kitchen_model.dart';

class KitchenService {
  const KitchenService(this._apiService);

  final BaseApiService _apiService;

  Future<List<KitchenModel>> fetchKitchens({
    required int page,
    required int limit,
    String? search,
  }) {
    if (AppConfig.useStaticContent) {
      return _fetchKitchensStatic(page: page, limit: limit, search: search);
    }

    return _apiService.get<List<KitchenModel>>(
      ApiEndpoints.kitchens,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => KitchenModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<KitchenModel> fetchKitchenDetail(String id) {
    if (AppConfig.useStaticContent) {
      return _fetchKitchenDetailStatic(id);
    }

    return _apiService.get<KitchenModel>(
      ApiEndpoints.kitchenDetail.replaceFirst('{id}', id),
      parser: (data) => KitchenModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<KitchenModel>> _fetchKitchensStatic({
    required int page,
    required int limit,
    String? search,
  }) async {
    await DummyData.delay();

    final keyword = search?.toLowerCase().trim() ?? '';
    final items = DummyData.kitchens().where((kitchen) {
      if (keyword.isEmpty) return true;
      return kitchen.name.toLowerCase().contains(keyword) ||
          kitchen.tags.any((tag) => tag.toLowerCase().contains(keyword));
    }).toList();

    final start = (page - 1) * limit;
    if (start >= items.length) return const [];
    final end = (start + limit).clamp(0, items.length).toInt();

    return items.sublist(start, end);
  }

  Future<KitchenModel> _fetchKitchenDetailStatic(String id) async {
    await DummyData.delay();
    final kitchen = DummyData.kitchenById(id);
    if (kitchen == null) {
      throw const AppException('Kitchen not found.');
    }
    return kitchen;
  }
}
