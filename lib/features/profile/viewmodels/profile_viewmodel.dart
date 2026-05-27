import 'package:dokomandu/features/auth/services/auth_service.dart';
import 'package:dokomandu/features/profile/services/profile_service.dart';
import 'package:dokomandu/shared/models/user_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:dokomandu/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileViewModel extends AsyncNotifier<UserModel?> {
  ProfileService get _profileService => ref.read(profileServiceProvider);
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  Future<UserModel?> build() async {
    final sessionUser = ref.read(sessionProvider).user;
    if (sessionUser != null) {
      return sessionUser;
    }

    try {
      return await _profileService.fetchProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> updateProfile(UserModel user) async {
    final updated = await _profileService.updateProfile(user);
    await ref.read(sessionProvider.notifier).updateUser(updated);
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore API failure and clear local session anyway.
    }
    await ref.read(sessionProvider.notifier).logout();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    await ref.read(sessionProvider.notifier).logout();
  }
}

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(baseApiServiceProvider)),
);

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, UserModel?>(ProfileViewModel.new);
