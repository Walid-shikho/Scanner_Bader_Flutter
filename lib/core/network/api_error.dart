import 'api_headers.dart';

class ApiLocalizedText {
  const ApiLocalizedText({
    required this.ar,
    this.en,
    this.de,
  });

  factory ApiLocalizedText.fromJson(Map<String, dynamic> json) {
    return ApiLocalizedText(
      ar: json['ar'] as String? ?? '',
      en: json['en'] as String?,
      de: json['de'] as String?,
    );
  }

  final String ar;
  final String? en;
  final String? de;
}

class ApiErrorItem {
  const ApiErrorItem({
    required this.code,
    required this.message,
    this.field,
  });

  factory ApiErrorItem.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'];
    return ApiErrorItem(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      field: json['field'] as String?,
      message: rawMessage is Map
          ? ApiLocalizedText.fromJson(Map<String, dynamic>.from(rawMessage))
          : const ApiLocalizedText(ar: ''),
    );
  }

  final String code;
  final String? field;
  final ApiLocalizedText message;
}

class NormalizedApiError implements Exception {
  NormalizedApiError({
    required this.statusCode,
    required this.message,
    required this.errors,
    required Map<String, String> headers,
    this.requestId,
  })  : headers = Map<String, String>.unmodifiable(headers),
        responseHeaders = ApiResponseHeaders(headers);

  factory NormalizedApiError.fromResponse({
    required int statusCode,
    required Map<String, String> headers,
    required Object? decodedBody,
  }) {
    final body = decodedBody is Map
        ? Map<String, dynamic>.from(decodedBody)
        : const <String, dynamic>{};
    final rawMessage = body['message'];
    final rawErrors = body['errors'];
    final rawMeta = body['meta'];
    final bodyRequestId = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)['request_id'] as String?
        : null;
    final parsedHeaders = ApiResponseHeaders(headers);

    return NormalizedApiError(
      statusCode: statusCode,
      requestId: parsedHeaders.requestId ?? bodyRequestId,
      headers: headers,
      message: rawMessage is Map
          ? ApiLocalizedText.fromJson(Map<String, dynamic>.from(rawMessage))
          : const ApiLocalizedText(ar: ''),
      errors: rawErrors is List
          ? rawErrors
              .whereType<Map>()
              .map(
                (item) => ApiErrorItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <ApiErrorItem>[],
    );
  }

  final int statusCode;
  final String? requestId;
  final ApiLocalizedText message;
  final List<ApiErrorItem> errors;
  final Map<String, String> headers;
  final ApiResponseHeaders responseHeaders;

  String? get retryAfter => responseHeaders.retryAfter;
  ApiRateLimitMetadata get rateLimit => responseHeaders.rateLimit;

  @override
  String toString() {
    final codes = errors.map((error) => error.code).join(',');
    return 'NormalizedApiError(statusCode: $statusCode, requestId: $requestId, codes: [$codes])';
  }
}
