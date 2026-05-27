import 'package:dokomandu/core/errors/app_exception.dart';
import 'package:dokomandu/features/auth/services/auth_service.dart';
import 'package:dokomandu/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewState {
  const AuthViewState({this.isLoading = false, this.error, this.info});

  final bool isLoading;
  final String? error;
  final String? info;

  AuthViewState copyWith({bool? isLoading, String? error, String? info}) {
    return AuthViewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      info: info,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthViewState> {
  AuthViewModel(this._ref, this._authService) : super(const AuthViewState());

  final Ref _ref;
  final AuthService _authService;

  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, info: null);

    try {
      final auth = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );

      await _ref
          .read(sessionProvider.notifier)
          .setAuthenticated(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            user: auth.user,
          );

      state = state.copyWith(
        isLoading: false,
        info: 'Authenticated successfully.',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Email/password login failed.',
      );
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null, info: null);

    try {
      final message = await _authService.sendOtp(phone);
      state = state.copyWith(isLoading: false, info: message);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to send OTP right now.',
      );
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null, info: null);

    try {
      final auth = await _authService.verifyOtp(phone: phone, otp: otp);

      await _ref
          .read(sessionProvider.notifier)
          .setAuthenticated(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            user: auth.user,
          );

      state = state.copyWith(
        isLoading: false,
        info: 'Authenticated successfully.',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP verification failed.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthViewState>(
      (ref) => AuthViewModel(ref, ref.watch(authServiceProvider)),
    );
