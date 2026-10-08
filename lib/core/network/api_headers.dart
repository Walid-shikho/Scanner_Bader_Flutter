import '../config/app_config.dart';

abstract final class ApiHeaderNames {
  static const authorization = 'Authorization';
  static const accept = 'Accept';
  static const acceptLanguage = 'Accept-Language';
  static const contentType = 'Content-Type';
  static const requestId = 'X-Request-ID';
  static const appType = 'X-App-Type';
  static const appVersion = 'X-App-Version';
  static const platform = 'X-Platform';
  static const devicePublicId = 'X-Device-Public-ID';
  static const deviceSignature = 'X-Device-Signature';
  static const timezone = 'X-Timezone';
  static const idempotencyKey = 'X-Idempotency-Key';
  static const ifMatch = 'If-Match';
  static const etag = 'ETag';
  static const retryAfter = 'Retry-After';
  static const rateLimitLimit = 'X-RateLimit-Limit';
  static const rateLimitRemaining = 'X-RateLimit-Remaining';
  static const rateLimitReset = 'X-RateLimit-Reset';
}

class ApiRequestHeaderContext {
  const ApiRequestHeaderContext({
    required this.authorizationToken,
    required this.acceptLanguage,
    this.requestId,
    this.devicePublicId,
    this.idempotencyKey,
    this.ifMatch,
    this.contentType,
    this.endpointHeaders = const <String, String>{},
  });

  final String authorizationToken;
  final String acceptLanguage;
  final String? requestId;
  final String? devicePublicId;
  final String? idempotencyKey;
  final String? ifMatch;
  final String? contentType;
  final Map<String, String> endpointHeaders;

  Map<String, String> build() {
    final headers = <String, String>{
      ...endpointHeaders,
      ApiHeaderNames.authorization: 'Bearer $authorizationToken',
      ApiHeaderNames.accept: 'application/json',
      ApiHeaderNames.acceptLanguage: acceptLanguage,
      ApiHeaderNames.appType: AppConfig.appType,
      ApiHeaderNames.appVersion: AppConfig.appVersion,
      ApiHeaderNames.platform: AppConfig.platform,
      ApiHeaderNames.timezone: AppConfig.timezone,
    };

    if (requestId != null) {
      headers[ApiHeaderNames.requestId] = requestId!;
    }
    if (devicePublicId != null) {
      headers[ApiHeaderNames.devicePublicId] = devicePublicId!;
    }
    if (idempotencyKey != null) {
      headers[ApiHeaderNames.idempotencyKey] = idempotencyKey!;
    }
    if (ifMatch != null) {
      headers[ApiHeaderNames.ifMatch] = ifMatch!;
    }
    if (contentType != null) {
      headers[ApiHeaderNames.contentType] = contentType!;
    }

    return Map<String, String>.unmodifiable(headers);
  }
}

class ApiRateLimitMetadata {
  const ApiRateLimitMetadata({
    this.limit,
    this.remaining,
    this.reset,
  });

  final String? limit;
  final String? remaining;
  final String? reset;

  bool get isPresent => limit != null || remaining != null || reset != null;
}

class ApiResponseHeaders {
  ApiResponseHeaders(Map<String, String> headers)
      : values = Map<String, String>.unmodifiable(
          headers.map(
            (key, value) => MapEntry(key.toLowerCase(), value),
          ),
        );

  final Map<String, String> values;

  String? value(String name) => values[name.toLowerCase()];

  String? get requestId => value(ApiHeaderNames.requestId);
  String? get etag => value(ApiHeaderNames.etag);
  String? get retryAfter => value(ApiHeaderNames.retryAfter);

  ApiRateLimitMetadata get rateLimit => ApiRateLimitMetadata(
        limit: value(ApiHeaderNames.rateLimitLimit),
        remaining: value(ApiHeaderNames.rateLimitRemaining),
        reset: value(ApiHeaderNames.rateLimitReset),
      );
}
