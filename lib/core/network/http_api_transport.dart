import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_error.dart';
import 'api_response.dart';
import 'api_transport.dart';

/// Production HTTP transport.
///
/// This layer is deliberately unaware of feature/repository semantics. It
/// preserves response headers and never logs request/response bodies.
class HttpApiTransport implements ApiTransport {
  HttpApiTransport({
    required Uri origin,
    http.Client? client,
  })  : _origin = origin,
        _client = client ?? http.Client();

  final Uri _origin;
  final http.Client _client;

  Uri _uriFor(ApiRequest request) {
    var base = _origin.toString().replaceAll(RegExp(r'/+$'), '');
    if (base.endsWith('/api/v1')) {
      base = base.substring(0, base.length - '/api/v1'.length);
    }
    final path = request.path.startsWith('/') ? request.path : '/${request.path}';
    final uri = Uri.parse('$base$path');
    return uri.replace(
      queryParameters: request.queryParameters.isEmpty
          ? null
          : request.queryParameters.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
    );
  }

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    required T Function(Object? decodedData) decodeData,
  }) async {
    final uri = _uriFor(request);
    final encodedBody = request.body == null ? null : jsonEncode(request.body);

    late final http.Response response;
    final method = request.method.toUpperCase();
    if (method == 'GET') {
      response = await _client.get(uri, headers: request.headers);
    } else if (method == 'POST') {
      response = await _client.post(uri, headers: request.headers, body: encodedBody);
    } else if (method == 'PUT') {
      response = await _client.put(uri, headers: request.headers, body: encodedBody);
    } else if (method == 'PATCH') {
      response = await _client.patch(uri, headers: request.headers, body: encodedBody);
    } else if (method == 'DELETE') {
      response = await _client.delete(uri, headers: request.headers, body: encodedBody);
    } else {
      throw ArgumentError.value(request.method, 'method', 'Unsupported HTTP method');
    }

    final headers = Map<String, String>.from(response.headers);
    final decoded = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NormalizedApiError.fromResponse(
        statusCode: response.statusCode,
        headers: headers,
        decodedBody: decoded,
      );
    }

    return ApiResponse<T>(
      data: decodeData(decoded),
      statusCode: response.statusCode,
      headers: headers,
    );
  }

  void close() => _client.close();
}
