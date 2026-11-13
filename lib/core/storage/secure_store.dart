import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key/value storage — replaces `encrypt-storage` + sessionStorage.
///
/// Uses Keychain (iOS/macOS), EncryptedSharedPreferences/Keystore (Android)
/// and DPAPI-protected storage (Windows).
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      debugPrint('SecureStore.readJson($key) failed: $e');
      // Corrupted entry: drop it, like the web code did.
      await delete(key);
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    try {
      await _storage.write(key: key, value: jsonEncode(value));
    } catch (e) {
      debugPrint('SecureStore.writeJson($key) failed: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStore.write($key) failed: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }
}
