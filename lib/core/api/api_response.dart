class ApiResponse<T> {
  const ApiResponse({required this.success, this.message, this.data});

  final bool success;
  final String? message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic value) parser,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString(),
      data: json['data'] != null ? parser(json['data']) : null,
    );
  }
}
