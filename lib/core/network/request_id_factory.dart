import 'dart:math';

abstract interface class RequestIdFactory {
  String create();
}

/// Generates a UUID-shaped opaque correlation ID with cryptographically secure
/// randomness. The server remains authoritative and may replace invalid IDs.
class SecureRequestIdFactory implements RequestIdFactory {
  SecureRequestIdFactory() : _random = Random.secure();

  final Random _random;

  @override
  String create() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x70;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
