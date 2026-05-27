import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/shared/models/user_model.dart';

class ProfileService {
  const ProfileService(this._apiService);

  final BaseApiService _apiService;

  Future<UserModel> fetchProfile() {
    if (AppConfig.useStaticContent) {
      return _fetchProfileStatic();
    }

    return _apiService.get<UserModel>(
      ApiEndpoints.me,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UserModel> updateProfile(UserModel user) {
    if (AppConfig.useStaticContent) {
      return _updateProfileStatic(user);
    }

    return _apiService.patch<UserModel>(
      ApiEndpoints.updateProfile,
      data: user.toJson(),
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UserModel> _fetchProfileStatic() async {
    await DummyData.delay();
    return DummyData.profile();
  }

  Future<UserModel> _updateProfileStatic(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return user;
  }
}
