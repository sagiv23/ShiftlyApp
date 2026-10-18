import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleDriveService {
  static const String _backupFileName = 'shiftly_backup.json';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    webOptions: WebOptions(
      dbName: 'ShiftlySecureStorage',
      publicKey: 'ShiftlyKey',
    ),
  );
  static const String _googleTokenKey = 'google_drive_access_token';

  // Google Client IDs for Google Sign-In
  static const String _windowsClientId = String.fromEnvironment(
    'WINDOWS_CLIENT_ID',
    defaultValue:
        '471238980617-6844beciupc5kt0tafejlr7umsfmn95s.apps.googleusercontent.com',
  );

  // OAuth Client Secret must NOT be hardcoded in client code.
  // Supply at compile time via --dart-define=WINDOWS_CLIENT_SECRET=xxx if needed.
  static const String _windowsClientSecret = String.fromEnvironment(
    'WINDOWS_CLIENT_SECRET',
    defaultValue: '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',
  );
  static const String _mobileWebClientId = String.fromEnvironment(
    'MOBILE_WEB_CLIENT_ID',
    defaultValue:
        '471238980617-3hc67sm28ckcp7p4a1ukm7u3ln8pp1k5.apps.googleusercontent.com',
  );

  // Singleton instance
  static final GoogleDriveService _instance = GoogleDriveService._internal();

  factory GoogleDriveService() => _instance;

  late final GoogleSignIn _googleSignIn;

  GoogleDriveService._internal() {
    _googleSignIn = GoogleSignIn(
      params: GoogleSignInParams(
        clientId: kIsWeb || !Platform.isWindows
            ? _mobileWebClientId
            : _windowsClientId,
        clientSecret: kIsWeb || !Platform.isWindows
            ? null
            : _windowsClientSecret,
        scopes: [drive.DriveApi.driveAppdataScope],
        redirectPort: 8082,
        saveAccessToken: (tokenJson) async {
          try {
            await _secureStorage.write(key: _googleTokenKey, value: tokenJson);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_googleTokenKey, tokenJson);
          } catch (e) {
            debugPrint('GoogleDrive: Failed to save access token: $e');
          }
        },
        retrieveAccessToken: () async {
          try {
            String? token = await _secureStorage.read(key: _googleTokenKey);
            if (token != null && token.isNotEmpty) return token;
            final prefs = await SharedPreferences.getInstance();
            return prefs.getString(_googleTokenKey);
          } catch (e) {
            debugPrint('GoogleDrive: Failed to retrieve access token: $e');
            return null;
          }
        },
      ),
    );
  }

  /// Attempts to restore a previous session without user interaction.
  Future<void> init() async {
    try {
      debugPrint(
        'GoogleDrive: Initializing and attempting lightweight sign-in...',
      );
      await _googleSignIn.lightweightSignIn();
    } catch (e) {
      debugPrint('GoogleDrive: Lightweight sign-in failed: $e');
    }
  }

  /// Returns user's email on success, or null on failure.
  Future<String?> signIn() async {
    try {
      GoogleSignInCredentials? credentials = await _googleSignIn
          .lightweightSignIn();
      credentials ??= await _googleSignIn.signIn();
      if (credentials != null) {
        final httpClient = await _getAuthenticatedClient();
        if (httpClient != null) {
          try {
            final driveApi = drive.DriveApi(httpClient);
            final about = await driveApi.about.get(
              $fields: 'user(emailAddress,displayName)',
            );
            final email = about.user?.emailAddress;
            if (email != null && email.isNotEmpty) {
              return email;
            }
          } catch (e) {
            debugPrint('GoogleDrive: Failed to fetch user profile email: $e');
          }
        }
        return 'Google Drive User';
      }
      return null;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _secureStorage.delete(key: _googleTokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_googleTokenKey);
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  Future<http.Client?> _getAuthenticatedClient() async {
    var client = await _googleSignIn.authenticatedClient;
    if (client == null) {
      debugPrint(
        'GoogleDrive: Authenticated client is null, attempting lightweightSignIn...',
      );
      await init();
      client = await _googleSignIn.authenticatedClient;
    }
    return client;
  }

  Future<void> uploadBackup(Map<String, dynamic> data) async {
    final httpClient = await _getAuthenticatedClient();
    if (httpClient == null) {
      debugPrint('GoogleDrive: Cannot upload, authenticated client is null.');
      throw Exception('Not authenticated with Google');
    }

    final driveApi = drive.DriveApi(httpClient);
    final jsonContent = jsonEncode(data);
    final bytes = utf8.encode(jsonContent);
    final media = drive.Media(Stream.value(bytes), bytes.length);

    debugPrint('GoogleDrive: Uploading backup... size: ${bytes.length} bytes');

    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName'",
      spaces: 'appDataFolder',
    );

    if (fileList.files?.isNotEmpty ?? false) {
      final fileId = fileList.files!.first.id!;
      debugPrint('GoogleDrive: Updating existing file $fileId');
      // Set metadata to ensure it stays in appDataFolder
      final metadata = drive.File()..name = _backupFileName;
      await driveApi.files.update(metadata, fileId, uploadMedia: media);
    } else {
      debugPrint('GoogleDrive: Creating new backup file');
      final driveFile = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder']
        ..mimeType = 'application/json';
      await driveApi.files.create(driveFile, uploadMedia: media);
    }
    debugPrint('GoogleDrive: Upload successful.');
  }

  Future<Map<String, dynamic>?> downloadBackup() async {
    final httpClient = await _getAuthenticatedClient();
    if (httpClient == null) {
      debugPrint(
        'GoogleDrive: Failed to get authenticated client for download.',
      );
      return null;
    }

    final driveApi = drive.DriveApi(httpClient);
    debugPrint('GoogleDrive: Searching for backup file...');

    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName'",
      spaces: 'appDataFolder',
    );

    if (fileList.files?.isEmpty ?? true) {
      debugPrint('GoogleDrive: No backup file found in appDataFolder.');
      return null;
    }

    final fileId = fileList.files!.first.id!;
    debugPrint('GoogleDrive: Downloading file $fileId');

    final response =
        await driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final List<int> dataStore = [];
    await for (final data in response.stream) {
      dataStore.addAll(data);
    }

    final decodedString = utf8.decode(dataStore);
    debugPrint('GoogleDrive: Downloaded ${dataStore.length} bytes');

    try {
      return jsonDecode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('GoogleDrive: Failed to decode JSON: $e');
      return null;
    }
  }

  Future<DateTime?> getBackupModifiedTime() async {
    final httpClient = await _getAuthenticatedClient();
    if (httpClient == null) {
      debugPrint(
        'GoogleDrive: Cannot get modified time, authenticated client is null.',
      );
      return null;
    }

    try {
      final driveApi = drive.DriveApi(httpClient);
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName'",
        spaces: 'appDataFolder',
        $fields: 'files(id, modifiedTime)',
      );

      if (fileList.files?.isNotEmpty ?? false) {
        final modifiedTime = fileList.files!.first.modifiedTime;
        debugPrint('GoogleDrive: Backup file modifiedTime: $modifiedTime');
        return modifiedTime;
      }
    } catch (e) {
      debugPrint('GoogleDrive: Error getting backup modifiedTime: $e');
    }
    return null;
  }

  Future<bool> deleteBackup() async {
    final httpClient = await _getAuthenticatedClient();
    if (httpClient == null) {
      debugPrint('GoogleDrive: Cannot delete, authenticated client is null.');
      return false;
    }

    final driveApi = drive.DriveApi(httpClient);
    final fileList = await driveApi.files.list(
      q: "name = '$_backupFileName'",
      spaces: 'appDataFolder',
    );

    if (fileList.files?.isNotEmpty ?? false) {
      for (var file in fileList.files!) {
        if (file.id != null) {
          await driveApi.files.delete(file.id!);
        }
      }
      debugPrint('GoogleDrive: Backup file deleted.');
      return true;
    }
    return false;
  }
}
