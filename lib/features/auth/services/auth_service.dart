import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/errors/app_exception.dart';
import 'package:dokomandu/core/network/interceptors/auth_interceptor.dart';
import 'package:dokomandu/features/auth/models/auth_tokens.dart';
import 'package:dokomandu/features/auth/models/demo_auth_user_model.dart';
import 'package:dokomandu/features/auth/services/auth_local_store.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  const AuthService(this._apiService, this._localStore);

  final BaseApiService _apiService;
  final AuthLocalStore _localStore;

  Future<AuthTokens> loginWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = _normalizePhone(phone);

    if (AppConfig.useStaticContent) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      final user = await _localStore.findByPhone(normalizedPhone);
      if (user == null || user.password != password) {
        throw const AppException('Invalid phone number or password.');
      }
      return _buildTokensFromDemoUser(user);
    }

    return _apiService.post<AuthTokens>(
      ApiEndpoints.login,
      data: {'phone': normalizedPhone, 'password': password},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AuthTokens> registerDemoUser({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = _normalizePhone(phone);

    if (AppConfig.useStaticContent) {
      await Future<void>.delayed(const Duration(milliseconds: 520));
      final existing = await _localStore.findByPhone(normalizedPhone);
      if (existing != null) {
        throw const AppException('Phone number is already registered.');
      }

      final user = DemoAuthUserModel(
        id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        phone: normalizedPhone,
        password: password,
      );
      await _localStore.upsertUser(user);
      return _buildTokensFromDemoUser(user);
    }

    return _apiService.post<AuthTokens>(
      '/auth/register',
      data: {
        'fullName': fullName,
        'phone': normalizedPhone,
        'password': password,
      },
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<String> forgotPasswordDemo({required String phone}) async {
    final normalizedPhone = _normalizePhone(phone);

    if (AppConfig.useStaticContent) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final existing = await _localStore.findByPhone(normalizedPhone);
      if (existing == null) {
        throw const AppException('No account found for this phone number.');
      }
      return 'Demo reset sent. Use your existing password for this prototype.';
    }

    return _apiService.post<String>(
      '/auth/forgot-password',
      data: {'phone': normalizedPhone},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) =>
          (data as Map<String, dynamic>)['message']?.toString() ??
          'Password reset link sent.',
    );
  }

  Future<String> sendOtp(String phone) {
    final normalizedPhone = _normalizePhone(phone);

    if (AppConfig.useStaticContent) {
      return Future<String>.value(
        'OTP flow is disabled in this static demo. Use phone + password login.',
      );
    }

    return _apiService.post<String>(
      ApiEndpoints.sendOtp,
      data: {'phone': normalizedPhone},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) =>
          (data as Map<String, dynamic>)['message']?.toString() ?? 'OTP sent',
    );
  }

  Future<AuthTokens> verifyOtp({required String phone, required String otp}) {
    final normalizedPhone = _normalizePhone(phone);

    if (AppConfig.useStaticContent) {
      throw const AppException(
        'OTP verification is disabled in this static demo.',
      );
    }

    return _apiService.post<AuthTokens>(
      ApiEndpoints.verifyOtp,
      data: {'phone': normalizedPhone, 'otp': otp},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    if (AppConfig.useStaticContent) {
      return;
    }
    await _apiService.post<bool>(ApiEndpoints.logout, parser: (_) => true);
  }

  Future<void> deleteAccount() async {
    if (AppConfig.useStaticContent) {
      return;
    }
    await _apiService.delete<bool>(
      ApiEndpoints.deleteAccount,
      parser: (_) => true,
    );
  }

  AuthTokens _buildTokensFromDemoUser(DemoAuthUserModel user) {
    return AuthTokens(
      accessToken: 'demo_access_${user.id}',
      refreshToken: 'demo_refresh_${user.id}',
      user: user.toUserModel(),
    );
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}

final authLocalStoreProvider = Provider<AuthLocalStore>(
  (ref) => AuthLocalStore(ref.watch(localCacheServiceProvider)),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(baseApiServiceProvider),
    ref.watch(authLocalStoreProvider),
  ),
);
