import 'package:dokomandu/features/notifications/models/app_notification_model.dart';
import 'package:dokomandu/features/notifications/services/notifications_service.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsViewModel extends AsyncNotifier<List<AppNotificationModel>> {
  NotificationsService get _service => ref.read(notificationsServiceProvider);

  @override
  Future<List<AppNotificationModel>> build() {
    return _service.fetchNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void markAsRead(String id) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();

    state = AsyncData(updated);
  }
}

final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsService(ref.watch(baseApiServiceProvider)),
);

final notificationsViewModelProvider =
    AsyncNotifierProvider<NotificationsViewModel, List<AppNotificationModel>>(
      NotificationsViewModel.new,
    );
