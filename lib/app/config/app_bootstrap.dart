import 'package:dokomandu/core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBootstrap {
  const AppBootstrap._();

  static bool isFirebaseReady = false;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    try {
      await Firebase.initializeApp();
      isFirebaseReady = true;
    } catch (error) {
      isFirebaseReady = false;
      AppLogger.error(
        'Firebase is not configured yet. Continuing without crash.',
        error,
      );
    }
  }
}
