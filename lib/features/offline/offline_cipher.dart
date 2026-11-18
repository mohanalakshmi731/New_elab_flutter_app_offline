import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authenticated encryption; the key stays in platform secure storage.
class OfflineCipher {
  OfflineCipher(List<int> key) : _key = SecretKeyData(key);
  final SecretKeyData _key;
  final _algorithm = DartAesGcm.with256bits();
  static Future<OfflineCipher>? _opening;
  static Future<OfflineCipher> open() async {
    try {
      return await (_opening ??= _load());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  static Future<OfflineCipher> _load() async {
    const storage = FlutterSecureStorage();
    const name = 'elab.offline.aes256.v1';
    var key = await storage.read(key: name);
    if (key == null) {
      key = base64Encode(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      await storage.write(key: name, value: key);
    }
    return OfflineCipher(base64Decode(key));
  }

  Uint8List seal(List<int> bytes) {
    final nonce = _algorithm.newNonce();
    return Uint8List.fromList(
      _algorithm
          .encryptSync(bytes, secretKeyData: _key, nonce: nonce)
          .concatenation(),
    );
  }

  Uint8List unseal(List<int> bytes) => Uint8List.fromList(
    _algorithm.decryptSync(
      SecretBox.fromConcatenation(bytes, nonceLength: 12, macLength: 16),
      secretKeyData: _key,
    ),
  );
  String encode(Object? value) =>
      'enc1:${base64Encode(seal(utf8.encode(jsonEncode(value))))}';
  dynamic decode(String value) => jsonDecode(
    value.startsWith('enc1:')
        ? utf8.decode(unseal(base64Decode(value.substring(5))))
        : value,
  );
  static const _header = [69, 76, 65, 66, 49]; // ELAB1
  bool isProtected(List<int> bytes) =>
      bytes.length >= 5 &&
      List.generate(5, (i) => bytes[i] == _header[i]).every((v) => v);
  Future<void> write(File file, List<int> bytes) async {
    final temporary = File('${file.path}.writing');
    await temporary.writeAsBytes([..._header, ...seal(bytes)], flush: true);
    await temporary.rename(file.path);
  }

  Future<Uint8List> read(File file) async {
    final bytes = await file.readAsBytes();
    if (!isProtected(bytes))
      throw const FormatException(
        'Prepared file encryption header is invalid.',
      );
    return unseal(bytes.sublist(5));
  }
}
