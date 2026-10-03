import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/services/persistence_service.dart';

class AuthProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  final GoogleDriveService _driveService = GoogleDriveService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isByosConnected = false;
  String? _userName;
  String? _userEmail;
  String? _byosEmail;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;

  bool get isByosConnected => _isByosConnected;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get byosEmail => _byosEmail;

  String? get token => _token;

  AuthProvider(this._persistence) {
    _loadAuthState();
  }

  void _loadAuthState() async {
    final box = _persistence.settingsBox;
    _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    _isByosConnected = box.get('isByosConnected', defaultValue: false);
    _userName = box.get('userName');
    _userEmail = box.get('userEmail');
    _byosEmail = box.get('byosEmail');
    _token = await _secureStorage.read(key: 'token');

    if (_isByosConnected) {
      try {
        await _driveService.init();
      } catch (e) {
        debugPrint('Drive init failed: $e');
      }
    }
    notifyListeners();
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
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final data = await _apiService.register(name, email, password);
    _isLoggedIn = true;
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _token = data['token'];
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> _saveToPersistence() async {
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', true);
    await box.put('userEmail', _userEmail ?? '');
    await box.put('userName', _userName ?? '');
    if (_token != null) {
      await _secureStorage.write(key: 'token', value: _token!);
    }
  }

  Future<void> updateProfile(
    String name,
    String email, {
    String? oldPassword,
    String? newPassword,
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
    );

    _userName = data['name'];
    _userEmail = data['email'];

    final box = _persistence.settingsBox;
    await box.put('userName', _userName ?? '');
    await box.put('userEmail', _userEmail ?? '');

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _token = null;
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.delete('userEmail');
    await box.delete('userName');
    await _secureStorage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_token != null) {
      await _apiService.deleteAccount(_token!);
    }
    await logout();
  }
}
