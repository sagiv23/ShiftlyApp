import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftly/utils/web_cookie.dart';

class SecureStorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _legacyTokenKey = 'token';

  static const String _userEmailKey = 'user_email_secure';
  static const String _userNameKey = 'user_name_secure';
  static const String _userCreatedAtKey = 'user_created_at_secure';
  static const String _userBirthDateKey = 'user_birth_date_secure';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(
      dbName: 'ShiftlySecureStorage',
      publicKey: 'ShiftlyKey',
    ),
  );

  /// Saves the auth token strictly using FlutterSecureStorage.
  /// No unencrypted SharedPreferences fallback is allowed.
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureStorage write token failed: ${e.runtimeType}');
      }
    }

    if (kIsWeb) {
      try {
        WebCookie.set(_tokenKey, token);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('WebCookie write failed: ${e.runtimeType}');
        }
      }
    }
  }

  /// Reads the auth token checking SecureStorage.
  static Future<String?> getToken() async {
    String? token;

    try {
      token = await _secureStorage.read(key: _tokenKey);
      token ??= await _secureStorage.read(key: _legacyTokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureStorage read token failed: ${e.runtimeType}');
      }
    }

    if (token != null && token.isNotEmpty) return token;

    // One-time legacy plaintext cleanup and migration check
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy =
          prefs.getString(_tokenKey) ?? prefs.getString(_legacyTokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        await saveToken(legacy);
        await prefs.remove(_tokenKey);
        await prefs.remove(_legacyTokenKey);
        return legacy;
      }
    } catch (_) {}

    if (kIsWeb) {
      try {
        token = WebCookie.get(_tokenKey) ?? WebCookie.get(_legacyTokenKey);
      } catch (_) {}
    }

    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Clears the auth token securely from storage.
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _legacyTokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureStorage delete failed: ${e.runtimeType}');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_legacyTokenKey);
    } catch (_) {}

    if (kIsWeb) {
      try {
        WebCookie.delete(_tokenKey);
        WebCookie.delete(_legacyTokenKey);
      } catch (_) {}
    }
  }

  /// Securely saves sensitive user PII in encrypted storage.
  static Future<void> saveUserData({
    String? email,
    String? name,
    String? createdAt,
    String? birthDate,
  }) async {
    try {
      if (email != null) {
        await _secureStorage.write(key: _userEmailKey, value: email);
      }
      if (name != null) {
        await _secureStorage.write(key: _userNameKey, value: name);
      }
      if (createdAt != null) {
        await _secureStorage.write(key: _userCreatedAtKey, value: createdAt);
      }
      if (birthDate != null) {
        await _secureStorage.write(key: _userBirthDateKey, value: birthDate);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureStorage saveUserData failed: ${e.runtimeType}');
      }
    }
  }

  /// Securely retrieves sensitive user PII from encrypted storage.
  static Future<Map<String, String?>> getUserData() async {
    try {
      final email = await _secureStorage.read(key: _userEmailKey);
      final name = await _secureStorage.read(key: _userNameKey);
      final createdAt = await _secureStorage.read(key: _userCreatedAtKey);
      final birthDate = await _secureStorage.read(key: _userBirthDateKey);
      return {
        'email': email,
        'name': name,
        'createdAt': createdAt,
        'birthDate': birthDate,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureStorage getUserData failed: ${e.runtimeType}');
      }
      return {};
    }
  }

  /// Securely deletes stored user PII.
  static Future<void> deleteUserData() async {
    try {
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _userCreatedAtKey);
      await _secureStorage.delete(key: _userBirthDateKey);
    } catch (_) {}
  }
}
