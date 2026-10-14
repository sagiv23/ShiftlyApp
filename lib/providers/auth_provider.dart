import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shiftly/main.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/services/persistence_service.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/secure_storage_helper.dart';

class AuthProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  final GoogleDriveService _driveService = GoogleDriveService();

  bool _isLoggedIn = false;
  bool _isByosConnected = false;
  bool _isInitializing = true;
  final Completer<void> _initCompleter = Completer<void>();

  String? _userName;
  String? _userEmail;
  String? _byosEmail;
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

  bool get isByosConnected => _isByosConnected;

  bool get isInitializing => _isInitializing;

  Future<void> get initializationFuture => _initCompleter.future;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get byosEmail => _byosEmail;

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
      _isByosConnected = box.get('isByosConnected', defaultValue: false);
      _userName = box.get('userName');
      _userEmail = box.get('userEmail');
      _byosEmail = box.get('byosEmail');
      _userCreatedAt = box.get('userCreatedAt');
      _userBirthDate = box.get('userBirthDate');
      _token = await SecureStorageHelper.getToken();

      if (_token != null && _token!.isNotEmpty) {
        _isLoggedIn = true;
        await box.put('isLoggedIn', true);
        _settingsProvider?.updateAuthToken(_token);
      } else {
        _isLoggedIn = false;
        await box.put('isLoggedIn', false);
      }
    } catch (e) {
      debugPrint('Failed to restore local session: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> syncProfileAndDrive() async {
    try {
      if (_isLoggedIn) {
        if (_token == null || _token!.isEmpty) {
          debugPrint('No auth token available, logging out.');
          await logout(navigate: false);
          return false;
        }

        try {
          final profile = await _apiService.getProfile(_token!);
          if (profile.isEmpty ||
              (profile['email'] == null &&
                  profile['id'] == null &&
                  profile['name'] == null)) {
            debugPrint('User does not exist in database.');
            await logout(navigate: false);
            return false;
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
          debugPrint('Failed to sync profile on load: $e');
          if (e.toString().contains('unauthorized')) {
            debugPrint('User check failed with unauthorized. Logging out.');
            await logout(navigate: false);
            return false;
          } else {
            debugPrint(
              'Network or server error during profile sync. Continuing with local cached user session.',
            );
          }
        }
      }

      if (_isLoggedIn && (_userCreatedAt == null || _userCreatedAt!.isEmpty)) {
        _userCreatedAt = DateTime.now().toIso8601String();
        await _persistence.settingsBox.put('userCreatedAt', _userCreatedAt!);
      }

      if (_isByosConnected) {
        try {
          await _driveService.init();
        } catch (e) {
          debugPrint('Drive init failed: $e');
        }
      }

      return _isLoggedIn;
    } catch (e) {
      debugPrint('Unexpected error in syncProfileAndDrive: $e');
      if (e.toString().contains('unauthorized')) {
        await logout(navigate: false);
        return false;
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

  Future<void> connectBYOS() async {
    try {
      final email = await _driveService.signIn();
      if (email != null) {
        _isByosConnected = true;
        _byosEmail = email;

        final box = _persistence.settingsBox;
        await box.put('isByosConnected', true);
        await box.put('byosEmail', _byosEmail ?? '');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('BYOS connection failed: $e');
      rethrow;
    }
  }

  Future<void> disconnectBYOS() async {
    try {
      await _driveService.signOut();
    } catch (e) {
      debugPrint('Drive signOut failed: $e');
    }
    _isByosConnected = false;
    _byosEmail = null;

    final box = _persistence.settingsBox;
    await box.put('isByosConnected', false);
    await box.delete('byosEmail');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);
    _isLoggedIn = true;
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
    await box.put('userEmail', _userEmail ?? '');
    await box.put('userName', _userName ?? '');
    if (_userCreatedAt != null) {
      await box.put('userCreatedAt', _userCreatedAt!);
    }
    if (_userBirthDate != null) {
      await box.put('userBirthDate', _userBirthDate!);
    }
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

    final box = _persistence.settingsBox;
    await box.put('userName', _userName ?? '');
    await box.put('userEmail', _userEmail ?? '');
    if (_userCreatedAt != null) {
      await box.put('userCreatedAt', _userCreatedAt!);
    }
    if (_userBirthDate != null) {
      await box.put('userBirthDate', _userBirthDate!);
    }

    notifyListeners();
  }

  Future<void> logout({bool navigate = true}) async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _token = null;
    _userCreatedAt = null;
    _userBirthDate = null;
    await _persistence.clearUserData();
    await _settingsProvider?.resetUserSettings();
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('userCreatedAt');
    await box.delete('userBirthDate');
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
    }
  }

  Future<void> deleteAccount() async {
    if (_token != null) {
      await _apiService.deleteAccount(_token!);
    }
    await logout();
  }
}
