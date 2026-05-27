import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettings {
  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.useDynamicTheming = false,
  });

  final ThemeMode themeMode;
  final bool useDynamicTheming;

  ThemeSettings copyWith({ThemeMode? themeMode, bool? useDynamicTheming}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      useDynamicTheming: useDynamicTheming ?? this.useDynamicTheming,
    );
  }
}

class ThemeController extends StateNotifier<ThemeSettings> {
  ThemeController(this._ref) : super(const ThemeSettings()) {
    _hydrate();
  }

  final Ref _ref;

  static const _themeModeKey = 'theme_mode';
  static const _dynamicThemeKey = 'use_dynamic_theme';

  Future<void> _hydrate() async {
    final cache = _ref.read(localCacheServiceProvider);
    final storedMode = await cache.getString(_themeModeKey);
    final storedDynamic = await cache.getBool(_dynamicThemeKey) ?? false;

    state = state.copyWith(
      themeMode: _parseThemeMode(storedMode),
      useDynamicTheming: storedDynamic,
    );
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _ref
        .read(localCacheServiceProvider)
        .setString(_themeModeKey, _serializeThemeMode(mode));
  }

  Future<void> setDynamicTheming(bool enabled) async {
    state = state.copyWith(useDynamicTheming: enabled);
    await _ref
        .read(localCacheServiceProvider)
        .setBool(_dynamicThemeKey, enabled);
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeSettings>(
  ThemeController.new,
);
