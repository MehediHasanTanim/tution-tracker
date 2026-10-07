import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A PIN stored as a salted, slow hash, never as the PIN itself.
///
/// Encoded as `v1:<length>:<iterations>:<salt>:<hash>` (base64). The length is
/// kept so the lock screen can unlock as soon as enough digits are typed.
class PinHash {
  const PinHash({
    required this.length,
    required this.iterations,
    required this.salt,
    required this.hash,
  });

  /// Iterations used for new hashes. Slow on purpose.
  static const defaultIterations = 60000;

  final int length;
  final int iterations;
  final List<int> salt;
  final List<int> hash;

  static final _random = Random.secure();

  String encode() =>
      'v1:$length:$iterations:${base64.encode(salt)}:${base64.encode(hash)}';

  static PinHash? tryDecode(String? text) {
    if (text == null) return null;
    final parts = text.split(':');
    if (parts.length != 5 || parts[0] != 'v1') return null;
    try {
      return PinHash(
        length: int.parse(parts[1]),
        iterations: int.parse(parts[2]),
        salt: base64.decode(parts[3]),
        hash: base64.decode(parts[4]),
      );
    } on Object {
      return null;
    }
  }

  static Future<List<int>> _derive(
    String pin,
    List<int> salt,
    int iterations,
  ) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }

  static Future<PinHash> create(
    String pin, {
    int iterations = defaultIterations,
  }) async {
    final salt = Uint8List.fromList(
      List.generate(16, (_) => _random.nextInt(256)),
    );
    return PinHash(
      length: pin.length,
      iterations: iterations,
      salt: salt,
      hash: await _derive(pin, salt, iterations),
    );
  }

  /// Compares in constant time, so timing reveals nothing about the PIN.
  Future<bool> matches(String pin) async {
    final candidate = await _derive(pin, salt, iterations);
    if (candidate.length != hash.length) return false;
    var diff = 0;
    for (var i = 0; i < hash.length; i++) {
      diff |= candidate[i] ^ hash[i];
    }
    return diff == 0;
  }
}
