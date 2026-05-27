import 'package:dio/dio.dart';
import 'package:dokomandu/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  static const _skipAuthHeader = 'x-skip-auth';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.headers.remove(_skipAuthHeader) == true;
    if (!skipAuth) {
      final token = await _secureStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  static Options skipAuthOptions({Map<String, dynamic>? headers}) {
    return Options(headers: {...?headers, _skipAuthHeader: true});
  }
}
