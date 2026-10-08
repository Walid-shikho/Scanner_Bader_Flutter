import 'api_response.dart';

class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.path,
    this.queryParameters = const <String, String>{},
    this.headers = const <String, String>{},
    this.body,
  });

  final String method;
  final String path;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final Object? body;

  @override
  String toString() => 'ApiRequest(method: $method, path: $path)';
}

abstract interface class ApiTransport {
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    required T Function(Object? decodedData) decodeData,
  });
}
