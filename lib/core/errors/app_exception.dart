import 'dart:io';

import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;

  static AppException fromDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return const AppException('Request timed out. Please try again.');
    }

    if (exception.error is SocketException) {
      return const AppException('No internet connection.');
    }

    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;
    final serverMessage = responseData is Map<String, dynamic>
        ? responseData['message']?.toString()
        : null;

    if (statusCode == 401) {
      return AppException(
        serverMessage ?? 'Session expired. Please login again.',
        code: statusCode,
      );
    }

    if (statusCode != null) {
      return AppException(
        serverMessage ?? 'Server error occurred.',
        code: statusCode,
      );
    }

    return AppException(exception.message ?? 'Something went wrong.');
  }
}
