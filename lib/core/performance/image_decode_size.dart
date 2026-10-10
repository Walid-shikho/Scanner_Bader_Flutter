import 'package:flutter/widgets.dart';

/// Utilities for keeping decoded image sizes close to the actual on-screen
/// footprint. This avoids retaining multi-megapixel bitmaps for tiny avatars,
/// thumbnails, and cards while preserving enough pixels for high-DPI screens.
abstract final class AppImageDecodeSize {
  static int width(
    BuildContext context,
    double logicalWidth, {
    int min = 48,
    int max = 1600,
  }) {
    final pixels =
        (logicalWidth * MediaQuery.devicePixelRatioOf(context)).ceil();
    return pixels.clamp(min, max).toInt();
  }

  static int height(
    BuildContext context,
    double logicalHeight, {
    int min = 48,
    int max = 1600,
  }) {
    final pixels =
        (logicalHeight * MediaQuery.devicePixelRatioOf(context)).ceil();
    return pixels.clamp(min, max).toInt();
  }
}
