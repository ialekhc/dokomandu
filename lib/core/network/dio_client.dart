import 'package:dio/dio.dart';
import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/core/network/interceptors/auth_interceptor.dart';
import 'package:dokomandu/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:dokomandu/core/network/interceptors/retry_interceptor.dart';
import 'package:dokomandu/core/storage/secure_storage_service.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  DioClient({required SecureStorageService secureStorage})
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          contentType: Headers.jsonContentType,
        ),
      ) {
    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      RefreshTokenInterceptor(secureStorage: secureStorage),
      RetryInterceptor(_dio),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
    ]);
  }

  final Dio _dio;

  Dio get client => _dio;
}
