import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/features/notifications/models/app_notification_model.dart';

class NotificationsService {
  const NotificationsService(this._apiService);

  final BaseApiService _apiService;

  Future<List<AppNotificationModel>> fetchNotifications() {
    if (AppConfig.useStaticContent) {
      return _fetchNotificationsStatic();
    }

    return _apiService.get<List<AppNotificationModel>>(
      ApiEndpoints.notifications,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map(
              (e) => AppNotificationModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<List<AppNotificationModel>> _fetchNotificationsStatic() async {
    await DummyData.delay();
    return DummyData.notifications();
  }
}
