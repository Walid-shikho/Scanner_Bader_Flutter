import 'dart:math';

import 'package:get/get.dart';

/// Generates UUIDv7 keys. The caller owns the key for the lifetime of one
/// logical user operation and MUST reuse it for transport retries.
abstract interface class IdempotencyKeyFactory {
  String create();
}

class DefaultIdempotencyKeyFactory extends GetxService
    implements IdempotencyKeyFactory {
  final Random _random = Random.secure();
  int _lastMs = -1;
  int _sequence = 0;

  @override
  String create() {
    final ms = DateTime.now().toUtc().millisecondsSinceEpoch;
    if (ms == _lastMs) {
      _sequence = (_sequence + 1) & 0x0fff;
    } else {
      _lastMs = ms;
      _sequence = _random.nextInt(0x1000);
    }

    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    var timestamp = ms;
    for (var i = 5; i >= 0; i--) {
      bytes[i] = timestamp & 0xff;
      timestamp >>= 8;
    }
    bytes[6] = 0x70 | ((_sequence >> 8) & 0x0f); // UUID version 7.
    bytes[7] = _sequence & 0xff;
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant.

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
