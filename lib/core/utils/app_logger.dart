import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DEBUG] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ERROR] $message ${error ?? ''}');
    }
  }
}
