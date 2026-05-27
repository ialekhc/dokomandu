import 'package:dokomandu/app/app.dart';
import 'package:dokomandu/app/config/app_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();

  runApp(const ProviderScope(child: DokomanduApp()));
}
