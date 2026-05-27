import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retries = (err.requestOptions.extra['retry_count'] as int?) ?? 0;

    if (retries >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra['retry_count'] = retries + 1;

    try {
      await Future<void>.delayed(Duration(milliseconds: 300 * (retries + 1)));
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
