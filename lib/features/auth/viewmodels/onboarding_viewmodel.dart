import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OnboardingStatus { unknown, required, completed }

class OnboardingNotifier extends StateNotifier<OnboardingStatus> {
  OnboardingNotifier(this._ref) : super(OnboardingStatus.unknown) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    final done =
        await _ref
            .read(localCacheServiceProvider)
            .getBool(AppConfig.cacheOnboardingDone) ??
        false;
    state = done ? OnboardingStatus.completed : OnboardingStatus.required;
  }

  Future<void> completeOnboarding() async {
    await _ref
        .read(localCacheServiceProvider)
        .setBool(AppConfig.cacheOnboardingDone, true);
    state = OnboardingStatus.completed;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingStatus>(
      (ref) => OnboardingNotifier(ref),
    );
