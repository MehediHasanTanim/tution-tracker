import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:tution_tracker/features/backup/domain/backup_exception.dart';

/// Password protection for a backup file (design 10.2 step 5).
///
/// Layout: 8-byte magic, 16-byte salt, 12-byte nonce, then the AES-256-GCM
/// ciphertext with its 16-byte tag. The key comes from the password with
/// PBKDF2-HMAC-SHA256. A plain backup is a zip and starts with `PK`, so the
/// two are told apart by the first bytes.
abstract final class BackupCrypto {
  static final magic = Uint8List.fromList('TKENC001'.codeUnits);
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _headerLength = 8 + _saltLength + _nonceLength;

  /// Slow on purpose: it is what makes guessing a password expensive.
  static const iterations = 120000;

  static bool isEncrypted(List<int> bytes) {
    if (bytes.length < magic.length) return false;
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) return false;
    }
    return true;
  }

  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );
  static final _aes = AesGcm.with256bits();

  static Future<SecretKey> _key(String password, List<int> salt) =>
      _pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);

  static Future<Uint8List> encrypt(List<int> plain, String password) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(
      plain,
      secretKey: await _key(password, salt),
      nonce: nonce,
    );
    return Uint8List.fromList([
      ...magic,
      ...salt,
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// Throws [BackupException] with `wrongPassword` when the tag does not
  /// verify: a wrong password and a damaged file look the same here.
  static Future<Uint8List> decrypt(List<int> data, String password) async {
    if (data.length < _headerLength + 16 || !isEncrypted(data)) {
      throw const BackupException(BackupProblem.damaged, 'encrypted header');
    }
    final salt = data.sublist(8, 8 + _saltLength);
    final nonce = data.sublist(8 + _saltLength, _headerLength);
    final cipher = data.sublist(_headerLength, data.length - 16);
    final mac = Mac(data.sublist(data.length - 16));
    try {
      final plain = await _aes.decrypt(
        SecretBox(cipher, nonce: nonce, mac: mac),
        secretKey: await _key(password, salt),
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupProblem.wrongPassword);
    }
  }
}
