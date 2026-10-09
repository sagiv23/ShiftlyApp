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
  String? _userCreatedAt;
  String? _userBirthDate;

  bool get isLoggedIn => _isLoggedIn;

  bool get isByosConnected => _isByosConnected;

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
    _userCreatedAt = box.get('userCreatedAt');
    _userBirthDate = box.get('userBirthDate');
    _token = await _secureStorage.read(key: 'token');

    if (_isLoggedIn && _token != null) {
      try {
        final profile = await _apiService.getProfile(_token!);
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
        await _saveToPersistence();
      } catch (e) {
        debugPrint('Failed to sync profile on load: $e');
      }
    }

    if (_isLoggedIn && (_userCreatedAt == null || _userCreatedAt!.isEmpty)) {
      _userCreatedAt = DateTime.now().toIso8601String();
      await box.put('userCreatedAt', _userCreatedAt!);
    }

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
    if (_token != null) {
      await _secureStorage.write(key: 'token', value: _token!);
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

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _token = null;
    _userCreatedAt = null;
    _userBirthDate = null;
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('userCreatedAt');
    await box.delete('userBirthDate');
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
