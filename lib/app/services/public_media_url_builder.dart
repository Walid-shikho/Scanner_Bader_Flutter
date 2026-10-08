import '../../core/config/app_config.dart';

/// Centralized public media URL construction for API-0455.
class PublicMediaUrlBuilder {
  const PublicMediaUrlBuilder();

  Uri media(String filePublicId) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/public/media/${Uri.encodeComponent(filePublicId)}');
  }
}
