import 'package:dokomandu/core/storage/secure_storage_service.dart';
import 'package:dokomandu/core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.debug('Background message received: ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> initialize({void Function(RemoteMessage)? onMessageTap}) async {
    if (Firebase.apps.isEmpty) {
      AppLogger.error(
        'Skipping Firebase Messaging initialization because Firebase app is not configured.',
      );
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _secureStorage.saveFcmToken(token);
    }

    FirebaseMessaging.onMessage.listen((event) {
      AppLogger.debug('Foreground message: ${event.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      onMessageTap?.call(event);
    });

    messaging.onTokenRefresh.listen((token) async {
      await _secureStorage.saveFcmToken(token);
    });
  }
}
