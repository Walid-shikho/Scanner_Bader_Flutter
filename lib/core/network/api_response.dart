import 'api_headers.dart';

class ApiResponse<T> {
  ApiResponse({
    required this.data,
    required this.statusCode,
    required Map<String, String> headers,
    String? requestId,
  })  : headers = Map<String, String>.unmodifiable(headers),
        responseHeaders = ApiResponseHeaders(headers),
        requestId = requestId ?? ApiResponseHeaders(headers).requestId;

  final T data;
  final int statusCode;
  final Map<String, String> headers;
  final ApiResponseHeaders responseHeaders;
  final String? requestId;

  String? get etag => responseHeaders.etag;
  String? get retryAfter => responseHeaders.retryAfter;
  ApiRateLimitMetadata get rateLimit => responseHeaders.rateLimit;

  ApiResponse<R> map<R>(R Function(T value) transform) {
    return ApiResponse<R>(
      data: transform(data),
      statusCode: statusCode,
      headers: headers,
      requestId: requestId,
    );
  }
}
