import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/routes/app_router.dart';
import 'package:dokomandu/app/theme/dark_theme.dart';
import 'package:dokomandu/app/theme/light_theme.dart';
import 'package:dokomandu/app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DokomanduApp extends ConsumerStatefulWidget {
  const DokomanduApp({super.key});

  @override
  ConsumerState<DokomanduApp> createState() => _DokomanduAppState();
}

class _DokomanduAppState extends ConsumerState<DokomanduApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppLightTheme.build(),
      darkTheme: AppDarkTheme.build(),
      themeMode: themeSettings.themeMode,
      routerConfig: router,
    );
  }
}
