import 'package:get/get.dart';

/// Optional location sample used only when the host application already has
/// location permission. The Scanner contract makes latitude/longitude optional.
class ScannerLocationSample {
  const ScannerLocationSample({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Abstraction over optional location acquisition for QR verification.
///
/// Returning null means permission is absent/denied/unavailable and must not
/// block verification because location is optional in API-0196.
abstract interface class ScannerLocationProvider {
  Future<ScannerLocationSample?> currentLocationIfGranted();
}

/// Deterministic provider for UI development. It defaults to no location and
/// can be configured by tests to prove the optional-location request path.
class MockScannerLocationProvider extends GetxService
    implements ScannerLocationProvider {
  MockScannerLocationProvider({
    this.permissionGranted = false,
    this.sample = const ScannerLocationSample(
      latitude: 33.5138,
      longitude: 36.2765,
    ),
  });

  final bool permissionGranted;
  final ScannerLocationSample sample;

  @override
  Future<ScannerLocationSample?> currentLocationIfGranted() async {
    return permissionGranted ? sample : null;
  }
}

/// Production-safe optional location provider. Location is optional in API-0196,
/// so absence must not fabricate coordinates or block verification.
class NoLocationScannerLocationProvider extends GetxService
    implements ScannerLocationProvider {
  @override
  Future<ScannerLocationSample?> currentLocationIfGranted() async => null;
}
