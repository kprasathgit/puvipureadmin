import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static final _storage = FlutterSecureStorage();

  /// Safe read with automatic recovery from BAD_DECRYPT
  static Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // clear corrupted value so app doesn’t crash
      await _storage.delete(key: key);
      return null;
    }
  }

  // ===== FCM =====
  static Future<void> saveToken(String token) async =>
      await _storage.write(key: 'fcm_token', value: token);

  static Future<String?> getToken() async =>
      _safeRead('fcm_token');

  static Future<void> clearToken() async =>
      await _storage.delete(key: 'fcm_token');

  // ===== Auth =====
  static Future<void> saveAuth(String adminId, String jwt) async {
    await _storage.write(key: 'admin_id', value: adminId);
    await _storage.write(key: 'auth_token', value: jwt);
  }

  static Future<String?> getAuthToken() async =>
      _safeRead('auth_token');

  static Future<String?> getAdminId() async =>
      _safeRead('admin_id');

  static Future<void> clearAuth() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'admin_id');
  }

  // ===== Admin PIN =====
  static Future<void> saveAdminPin(String pin) async =>
      await _storage.write(key: 'admin_pin', value: pin);

  static Future<String?> getAdminPin() async =>
      _safeRead('admin_pin');

  static Future<void> clearAdminPin() async =>
      await _storage.delete(key: 'admin_pin');
      
  // ===== Clear All =====
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
