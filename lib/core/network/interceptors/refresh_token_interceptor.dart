import 'package:dio/dio.dart';
import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/storage/secure_storage_service.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage,
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
        ),
      );

  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  bool _isRefreshing = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isRefreshEndpoint = path.contains(ApiEndpoints.refreshToken);

    if (!isUnauthorized || isRefreshEndpoint || _isRefreshing) {
      handler.next(err);
      return;
    }

    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _secureStorage.clearSession();
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data =
          refreshResponse.data?['data'] as Map<String, dynamic>? ?? const {};
      final newAccessToken = data['accessToken']?.toString();
      final newRefreshToken = data['refreshToken']?.toString();

      if (newAccessToken == null || newRefreshToken == null) {
        await _secureStorage.clearSession();
        handler.next(err);
        return;
      }

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $newAccessToken';

      final response = await _refreshDio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException {
      await _secureStorage.clearSession();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
