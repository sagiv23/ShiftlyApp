import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/main.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/persistence_service.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/secure_storage_helper.dart';
import 'package:shiftly/utils/ui_utils.dart';

class AuthProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  bool _isGuest = false;
  final bool _isByosConnected = false;
  bool _isInitializing = true;
  final Completer<void> _initCompleter = Completer<void>();

  String? _userName;
  String? _userEmail;

  String? _token;
  String? _userCreatedAt;
  String? _userBirthDate;
  SettingsProvider? _settingsProvider;

  void updateSettingsProvider(SettingsProvider settings) {
    _settingsProvider = settings;
    if (_token != null) {
      _settingsProvider?.updateAuthToken(_token);
    }
  }

  bool get isLoggedIn => _isLoggedIn;

  bool get isGuest => _isGuest;

  bool get isByosConnected => false; // _isByosConnected

  bool get isInitializing => _isInitializing;

  Future<void> get initializationFuture => _initCompleter.future;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get byosEmail => null; // _byosEmail

  String? get token => _token;

  String? get userCreatedAt => _userCreatedAt;

  String? get userBirthDate => _userBirthDate;

  int? get userAge {
    if (_userBirthDate == null) return null;
    final birth = DateTime.tryParse(_userBirthDate!);
    if (birth == null) return null;
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  bool _hasStartedInitializing = false;

  AuthProvider(this._persistence) {
    // Delay initialization until SplashScreen is rendered at 0%
  }

  Future<void> restoreLocalSession() async {
    _isInitializing = true;
    try {
      final box = _persistence.settingsBox;
      _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
      _isGuest = box.get('isGuest', defaultValue: false);

      // Load secure PII
      final secureData = await SecureStorageHelper.getUserData();
      _userEmail = secureData['email'] ?? box.get('userEmail');
      _userName = secureData['name'] ?? box.get('userName');
      _userCreatedAt = secureData['createdAt'] ?? box.get('userCreatedAt');
      _userBirthDate = secureData['birthDate'] ?? box.get('userBirthDate');

      // Migrate legacy plaintext keys to secure storage
      if (box.containsKey('userEmail') || box.containsKey('userName')) {
        await SecureStorageHelper.saveUserData(
          email: _userEmail,
          name: _userName,
          createdAt: _userCreatedAt,
          birthDate: _userBirthDate,
        );
        await box.delete('userEmail');
        await box.delete('userName');
        await box.delete('userCreatedAt');
        await box.delete('userBirthDate');
      }

      _token = await SecureStorageHelper.getToken();

      if (_token != null && _token!.isNotEmpty) {
        _isLoggedIn = true;
        _isGuest = false;
        await box.put('isLoggedIn', true);
        await box.put('isGuest', false);
        _settingsProvider?.updateAuthToken(_token);
      } else {
        _isLoggedIn = false;
        await box.put('isLoggedIn', false);
        _isGuest = box.get('isGuest', defaultValue: false);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to restore local session: ${e.runtimeType}');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _isLoggedIn = false;
    _isGuest = true;
    _userName = null;
    _userEmail = null;
    _token = null;
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.put('isGuest', true);
    await SecureStorageHelper.deleteToken();
    notifyListeners();
  }

  Future<bool> _handleUserNotFoundOrUnauthorized() async {
    debugPrint('User no longer exists in database or unauthorized.');
    final locale = _settingsProvider?.locale ?? const Locale('he', 'IL');
    final l = lookupAppLocalizations(locale);
    final msg = l.auth_user_deleted_local_data_preserved;

    if (!_isByosConnected) {
      await logout(navigate: true, clearData: false, notificationMessage: msg);
    } else {
      _isLoggedIn = false;
      _token = null;
      await SecureStorageHelper.deleteToken();
      await _persistence.settingsBox.put('isLoggedIn', false);
      notifyListeners();
      navigatorKey.currentState?.pushAndRemoveUntil(
        AppPageRoute.fadeScale(
          const AuthScreen(),
          duration: const Duration(milliseconds: 200),
        ),
        (route) => false,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        // ignore: use_build_context_synchronously
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          // ignore: use_build_context_synchronously
          UIUtils.showSnackBar(ctx, msg);
        }
      });
    }
    return false;
  }

  Future<bool> syncProfileAndDrive() async {
    try {
      if (_isLoggedIn) {
        if (_token == null || _token!.isEmpty) {
          debugPrint('No auth token available, logging out.');
          if (!_isByosConnected) {
            await logout(navigate: false);
          } else {
            _isLoggedIn = false;
            _token = null;
            await SecureStorageHelper.deleteToken();
            await _persistence.settingsBox.put('isLoggedIn', false);
            notifyListeners();
          }
          return false;
        }

        try {
          final profile = await _apiService.getProfile(_token!);
          if (profile.isEmpty ||
              (profile['email'] == null &&
                  profile['id'] == null &&
                  profile['name'] == null)) {
            debugPrint('User does not exist in database.');
            return await _handleUserNotFoundOrUnauthorized();
          }

          _userName = profile['name'] ?? _userName;
          _userEmail = profile['email'] ?? _userEmail;
          final createdAt = profile['created_at'] ?? profile['createdAt'];
          if (createdAt != null) {
            _userCreatedAt = createdAt.toString();
          }
          final birthVal = profile['birth_date'] ?? profile['birthDate'];
          if (birthVal != null) {
            _userBirthDate = birthVal.toString();
          }
          await _settingsProvider?.updateSettingsFromProfile(profile);
          await _saveToPersistence();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to sync profile on load: ${e.runtimeType}');
          }
          if (e.toString().contains('unauthorized')) {
            if (kDebugMode) {
              debugPrint('User check failed with unauthorized.');
            }
            return await _handleUserNotFoundOrUnauthorized();
          }
        }
      }

      if (_isLoggedIn && (_userCreatedAt == null || _userCreatedAt!.isEmpty)) {
        _userCreatedAt = DateTime.now().toIso8601String();
        await _persistence.settingsBox.put('userCreatedAt', _userCreatedAt!);
      }

      return _isLoggedIn;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error in syncProfileAndDrive: ${e.runtimeType}');
      }
      if (e.toString().contains('unauthorized')) {
        return await _handleUserNotFoundOrUnauthorized();
      }
      return _isLoggedIn;
    } finally {
      _isInitializing = false;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_hasStartedInitializing) {
      return initializationFuture;
    }
    _hasStartedInitializing = true;
    await restoreLocalSession();
    await syncProfileAndDrive();
  }

  Future<Map<String, dynamic>> authenticateOnly(
    String email,
    String password,
  ) async {
    return await _apiService.login(email, password);
  }

  Future<void> applyLoginSession(Map<String, dynamic> data) async {
    _isLoggedIn = true;
    _isGuest = false;
    _userEmail = data['user']['email'];
    _userName = data['user']['name'];
    _token = data['token'];
    _settingsProvider?.updateAuthToken(_token);
    if (data['user'] != null && data['user'] is Map) {
      await _settingsProvider?.updateSettingsFromProfile(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    }
    _userCreatedAt =
        data['user']['created_at'] ??
        data['user']['createdAt'] ??
        data['created_at'] ??
        data['createdAt'] ??
        _persistence.settingsBox.get('userCreatedAt');
    if (_userCreatedAt == null || _userCreatedAt!.isEmpty) {
      _userCreatedAt = DateTime.now().toIso8601String();
    }
    _userBirthDate =
        data['user']['birth_date'] ??
        data['user']['birthDate'] ??
        _persistence.settingsBox.get('userBirthDate');
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await authenticateOnly(email, password);
    await applyLoginSession(data);
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    DateTime? birthDate,
  }) async {
    final data = await _apiService.register(
      name,
      email,
      password,
      birthDate: birthDate,
    );
    _isLoggedIn = true;
    _isGuest = false;
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _token = data['token'];
    _settingsProvider?.updateAuthToken(_token);
    if (data['user'] != null && data['user'] is Map) {
      await _settingsProvider?.updateSettingsFromProfile(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    }
    await _settingsProvider?.syncSettingsToServer(_token);

    _userCreatedAt =
        data['user']['created_at'] ??
        data['user']['createdAt'] ??
        DateTime.now().toIso8601String();
    _userBirthDate =
        birthDate?.toIso8601String() ??
        data['user']['birth_date'] ??
        data['user']['birthDate'];
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> _saveToPersistence() async {
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', true);
    await box.put('isGuest', false);

    // Save PII in encrypted secure storage, delete from settingsBox
    await SecureStorageHelper.saveUserData(
      email: _userEmail,
      name: _userName,
      createdAt: _userCreatedAt,
      birthDate: _userBirthDate,
    );
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('userCreatedAt');
    await box.delete('userBirthDate');

    if (_token != null && _token!.isNotEmpty) {
      await SecureStorageHelper.saveToken(_token!);
    }
  }

  Future<void> updateProfile(
    String name,
    String email, {
    String? oldPassword,
    String? newPassword,
    DateTime? birthDate,
  }) async {
    if (_token == null) return;

    if (newPassword != null && newPassword.isNotEmpty) {
      if (oldPassword == null || oldPassword.isEmpty) {
        throw Exception('profile_password_required');
      }
      try {
        await _apiService.login(_userEmail!, oldPassword);
      } catch (e) {
        throw Exception('profile_password_error');
      }
    }

    final data = await _apiService.updateProfile(
      _token!,
      name,
      email,
      oldPassword: oldPassword,
      newPassword: newPassword,
      birthDate: birthDate,
    );

    _userName = data['name'] ?? data['user']?['name'];
    _userEmail = data['email'] ?? data['user']?['email'];
    final createdAtVal =
        data['created_at'] ??
        data['createdAt'] ??
        data['user']?['created_at'] ??
        data['user']?['createdAt'];
    if (createdAtVal != null) {
      _userCreatedAt = createdAtVal;
    }

    final birthVal =
        birthDate?.toIso8601String() ??
        data['birth_date'] ??
        data['birthDate'] ??
        data['user']?['birth_date'] ??
        data['user']?['birthDate'];
    if (birthVal != null) {
      _userBirthDate = birthVal;
    }

    await _settingsProvider?.updateSettingsFromProfile(data);

    await SecureStorageHelper.saveUserData(
      email: _userEmail,
      name: _userName,
      createdAt: _userCreatedAt,
      birthDate: _userBirthDate,
    );
    final box = _persistence.settingsBox;
    await box.delete('userName');
    await box.delete('userEmail');
    await box.delete('userCreatedAt');
    await box.delete('userBirthDate');

    notifyListeners();
  }

  Future<void> logout({
    bool navigate = true,
    bool clearData = true,
    String? notificationMessage,
  }) async {
    _isLoggedIn = false;
    _isGuest = false;
    _userName = null;
    _userEmail = null;
    _token = null;
    _userCreatedAt = null;
    _userBirthDate = null;
    if (clearData && !_isByosConnected) {
      await _persistence.clearUserData();
    }
    await _settingsProvider?.resetUserSettings();
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.put('isGuest', false);
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('userCreatedAt');
    await box.delete('userBirthDate');
    await SecureStorageHelper.deleteUserData();
    await SecureStorageHelper.deleteToken();
    notifyListeners();

    if (navigate) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        AppPageRoute.fadeScale(
          const AuthScreen(),
          duration: const Duration(milliseconds: 200),
        ),
        (route) => false,
      );
      if (notificationMessage != null && notificationMessage.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // ignore: use_build_context_synchronously
          final navContext = navigatorKey.currentContext;
          if (navContext != null) {
            // ignore: use_build_context_synchronously
            UIUtils.showSnackBar(navContext, notificationMessage);
          }
        });
      }
    }
  }

  Future<void> deleteAccount() async {
    if (_token != null) {
      await _apiService.deleteAccount(_token!);
    }
    await logout();
  }
}
