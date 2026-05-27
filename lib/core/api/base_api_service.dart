import 'package:dio/dio.dart';
import 'package:dokomandu/core/api/api_response.dart';
import 'package:dokomandu/core/errors/app_exception.dart';

class BaseApiService {
  const BaseApiService(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      final parsed = ApiResponse<T>.fromJson(response.data ?? const {}, parser);
      return parsed.data as T;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final parsed = ApiResponse<T>.fromJson(response.data ?? const {}, parser);
      return parsed.data as T;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      final parsed = ApiResponse<T>.fromJson(response.data ?? const {}, parser);
      return parsed.data as T;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
      );
      final parsed = ApiResponse<T>.fromJson(response.data ?? const {}, parser);
      return parsed.data as T;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}
