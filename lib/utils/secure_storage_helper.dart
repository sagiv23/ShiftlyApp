import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftly/utils/web_cookie.dart';

class SecureStorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _legacyTokenKey = 'token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    webOptions: WebOptions(
      dbName: 'ShiftlySecureStorage',
      publicKey: 'ShiftlyKey',
    ),
  );

  /// Saves the auth token securely using FlutterSecureStorage and fallbacks.
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('SecureStorage write failed: $e');
    }

    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
      } catch (e) {
        debugPrint('SharedPreferences write failed: $e');
      }

      try {
        WebCookie.set(_tokenKey, token);
      } catch (e) {
        debugPrint('WebCookie write failed: $e');
      }
    }
  }

  /// Reads the auth token checking SecureStorage first, then falling back to
  /// SharedPreferences and Web Cookie.
  static Future<String?> getToken() async {
    String? token;

    try {
      token = await _secureStorage.read(key: _tokenKey);
      token ??= await _secureStorage.read(key: _legacyTokenKey);
    } catch (e) {
      debugPrint('SecureStorage read failed (will try fallbacks): $e');
    }

    if (token != null && token.isNotEmpty) return token;

    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey) ?? prefs.getString(_legacyTokenKey);
    } catch (e) {
      debugPrint('SharedPreferences read failed: $e');
    }

    if (token != null && token.isNotEmpty) return token;

    if (kIsWeb) {
      try {
        token = WebCookie.get(_tokenKey) ?? WebCookie.get(_legacyTokenKey);
      } catch (e) {
        debugPrint('WebCookie read failed: $e');
      }
    }

    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Clears the auth token from all storage mechanisms.
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _legacyTokenKey);
    } catch (e) {
      debugPrint('SecureStorage delete failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_legacyTokenKey);
    } catch (e) {
      debugPrint('SharedPreferences remove failed: $e');
    }

    if (kIsWeb) {
      try {
        WebCookie.delete(_tokenKey);
        WebCookie.delete(_legacyTokenKey);
      } catch (e) {
        debugPrint('WebCookie delete failed: $e');
      }
    }
  }
}
