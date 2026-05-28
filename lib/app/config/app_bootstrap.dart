import 'package:dokomandu/core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    AppLogger.debug('Static demo bootstrap initialized.');
  }
}
