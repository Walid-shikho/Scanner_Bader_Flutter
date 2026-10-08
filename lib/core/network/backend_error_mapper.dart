import 'api_error.dart';

enum BackendErrorAction {
  showMessage,
  relogin,
  permissionDenied,
  blockingSuspended,
  notFound,
  conflict,
  validation,
  unsupportedMedia,
  locked,
  securityBootstrap,
  rateLimited,
  retryableServiceFailure,
}

class BackendErrorDisposition {
  const BackendErrorDisposition({
    required this.action,
    required this.translationKey,
    this.fieldErrors = const <String, List<String>>{},
    this.retryAfter,
  });

  final BackendErrorAction action;
  final String translationKey;
  final Map<String, List<String>> fieldErrors;
  final Duration? retryAfter;
}

/// Central mapping for the final Partner/Scanner error contract.
/// Raw exception text is intentionally never exposed as user-facing copy.
abstract final class BackendErrorMapper {
  static BackendErrorDisposition map(
    NormalizedApiError error, {
    Duration? retryAfter,
  }) {
    final code = error.errors.isEmpty ? '' : error.errors.first.code;
    if (code == 'ACCOUNT_MODERATION_SUSPENDED') {
      return const BackendErrorDisposition(
        action: BackendErrorAction.blockingSuspended,
        translationKey: 'account_suspended',
      );
    }
    if (code == 'CONTENT_MODERATION_BLOCKED') {
      return const BackendErrorDisposition(
        action: BackendErrorAction.conflict,
        translationKey: 'content_moderation_blocked',
      );
    }
    switch (error.statusCode) {
      case 400:
        return const BackendErrorDisposition(action: BackendErrorAction.showMessage, translationKey: 'invalid_request');
      case 401:
        return const BackendErrorDisposition(action: BackendErrorAction.relogin, translationKey: 'session_expired_relogin');
      case 403:
        return const BackendErrorDisposition(action: BackendErrorAction.permissionDenied, translationKey: 'permission_denied');
      case 404:
        return const BackendErrorDisposition(action: BackendErrorAction.notFound, translationKey: 'resource_not_found');
      case 409:
        return const BackendErrorDisposition(action: BackendErrorAction.conflict, translationKey: 'state_conflict');
      case 415:
        return const BackendErrorDisposition(action: BackendErrorAction.unsupportedMedia, translationKey: 'unsupported_media_type');
      case 422:
        return BackendErrorDisposition(
          action: BackendErrorAction.validation,
          translationKey: 'validation_failed',
          fieldErrors: _fieldErrors(error),
        );
      case 423:
        return const BackendErrorDisposition(action: BackendErrorAction.locked, translationKey: 'account_locked');
      case 428:
        return const BackendErrorDisposition(action: BackendErrorAction.securityBootstrap, translationKey: 'security_verification_required');
      case 429:
        return BackendErrorDisposition(action: BackendErrorAction.rateLimited, translationKey: 'rate_limited', retryAfter: retryAfter);
      case 500:
      case 503:
        return const BackendErrorDisposition(action: BackendErrorAction.retryableServiceFailure, translationKey: 'service_unavailable');
      default:
        return const BackendErrorDisposition(action: BackendErrorAction.showMessage, translationKey: 'error');
    }
  }

  static Map<String, List<String>> _fieldErrors(NormalizedApiError error) {
    final result = <String, List<String>>{};
    for (final detail in error.errors) {
      final field = detail.field;
      if (field == null || field.isEmpty) continue;
      result.putIfAbsent(field, () => <String>[]).add(detail.message.en ?? detail.message.ar);
    }
    return result;
  }
}
