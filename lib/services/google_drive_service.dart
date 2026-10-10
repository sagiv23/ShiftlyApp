import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const String _backupFileName = 'shiftly_backup.json';

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
    defaultValue: '',
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
      ),
    );
  }

  /// Attempts to restore a previous session without user interaction.
  Future<void> init() async {
    try {
      debugPrint('GoogleDrive: Initializing and attempting silent sign-in...');
      await _googleSignIn.silentSignIn();
    } catch (e) {
      debugPrint('GoogleDrive: Silent sign-in failed: $e');
    }
  }

  /// Returns a placeholder or email on success, or null on failure.
  Future<String?> signIn() async {
    try {
      final credentials = await _googleSignIn.signIn();
      if (credentials != null) {
        // In this package, credentials might not always have email
        // depending on scopes and platform.
        return 'Google Drive User';
      }
      return null;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  Future<http.Client?> _getAuthenticatedClient() async {
    // In version 2.0.3, authenticatedClient is a getter
    return await _googleSignIn.authenticatedClient;
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
