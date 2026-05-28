import 'package:dokomandu/core/utils/app_logger.dart';
import 'package:dokomandu/core/storage/secure_storage_service.dart';

class FirebaseMessagingService {
  FirebaseMessagingService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> initialize() async {
    AppLogger.debug(
      'Firebase messaging is disabled in static demo mode. No setup performed.',
    );
    final existing = await _secureStorage.readFcmToken();
    if (existing == null) {
      await _secureStorage.saveFcmToken('demo-fcm-disabled');
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(dynamic _) async {
  // Intentionally no-op for static demo.
}
