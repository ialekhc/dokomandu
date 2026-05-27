import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/network/interceptors/auth_interceptor.dart';
import 'package:dokomandu/features/auth/models/auth_tokens.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  const AuthService(this._apiService);

  final BaseApiService _apiService;

  Future<AuthTokens> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _apiService.post<AuthTokens>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<String> sendOtp(String phone) {
    return _apiService.post<String>(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) =>
          (data as Map<String, dynamic>)['message']?.toString() ?? 'OTP sent',
    );
  }

  Future<AuthTokens> verifyOtp({required String phone, required String otp}) {
    return _apiService.post<AuthTokens>(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
      options: AuthInterceptor.skipAuthOptions(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _apiService.post<bool>(ApiEndpoints.logout, parser: (_) => true);
  }

  Future<void> deleteAccount() async {
    await _apiService.delete<bool>(
      ApiEndpoints.deleteAccount,
      parser: (_) => true,
    );
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(baseApiServiceProvider)),
);
