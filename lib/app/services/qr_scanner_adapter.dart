import 'dart:async';

import 'package:get/get.dart';

class QrScanCapture {
  const QrScanCapture({required this.signedQrToken});

  final String signedQrToken;

  @override
  String toString() => 'QrScanCapture(signedQrToken: <redacted>)';
}

abstract interface class QrScannerAdapter {
  Future<QrScanCapture?> scan();
  Future<void> cancel();
}

enum OfflineQrScenario {
  validDynamic,
  validStatic,
  expired,
  replayed,
  invalid,
  noEligibleOffers,
}

extension OfflineQrScenarioWire on OfflineQrScenario {
  String get token => 'offline-demo:${name}';
  String get translationKey => switch (this) {
        OfflineQrScenario.validDynamic => 'offline_qr_valid_dynamic',
        OfflineQrScenario.validStatic => 'offline_qr_valid_static',
        OfflineQrScenario.expired => 'offline_qr_expired',
        OfflineQrScenario.replayed => 'offline_qr_replayed',
        OfflineQrScenario.invalid => 'offline_qr_invalid',
        OfflineQrScenario.noEligibleOffers => 'offline_qr_no_offers',
      };
}

/// Explicit Offline Demo adapter. It never touches a camera or network and
/// makes the selected deterministic scenario visible to the user.
class OfflineQrScannerAdapter extends GetxService implements QrScannerAdapter {
  final selectedScenario = OfflineQrScenario.validDynamic.obs;
  int _generation = 0;

  void selectScenario(OfflineQrScenario scenario) {
    selectedScenario.value = scenario;
  }

  @override
  Future<QrScanCapture?> scan() async {
    final generation = ++_generation;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (generation != _generation) return null;
    return QrScanCapture(signedQrToken: selectedScenario.value.token);
  }

  @override
  Future<void> cancel() async {
    _generation += 1;
  }
}

/// Legacy deterministic scanner retained for old widget tests only.
class MockQrScannerAdapter extends GetxService implements QrScannerAdapter {
  static const _scanDelay = Duration(milliseconds: 120);
  int _scanGeneration = 0;

  @override
  Future<QrScanCapture?> scan() async {
    final generation = ++_scanGeneration;
    await Future<void>.delayed(_scanDelay);
    if (generation != _scanGeneration) return null;
    return const QrScanCapture(
      signedQrToken: 'offline-demo:validDynamic',
    );
  }

  @override
  Future<void> cancel() async {
    _scanGeneration += 1;
  }
}

class UnavailableQrScannerAdapter extends GetxService implements QrScannerAdapter {
  @override
  Future<QrScanCapture?> scan() => Future<QrScanCapture?>.error(
        StateError('BLOCKED_BY_EXTERNAL_QR_CAMERA_PROVIDER'),
      );

  @override
  Future<void> cancel() async {}
}
