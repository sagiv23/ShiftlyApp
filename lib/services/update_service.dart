import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Model representing details about a GitHub Release update.
class AppUpdateInfo {
  final String tagName;
  final String versionName;
  final String currentVersion;
  final String changelog;
  final bool changelogIsRtl;
  final String? downloadUrl;
  final String releaseUrl;
  final DateTime? publishedAt;
  final bool isNewer;

  const AppUpdateInfo({
    required this.tagName,
    required this.versionName,
    required this.currentVersion,
    required this.changelog,
    required this.changelogIsRtl,
    this.downloadUrl,
    required this.releaseUrl,
    this.publishedAt,
    required this.isNewer,
  });
}

class UpdateService {
  static const String repoOwner = 'sagiv23';
  static const String repoName = 'ShiftlyApp';
  static const String latestReleaseApiUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  /// Checks GitHub Releases API for a newer version than the currently installed app.
  static Future<AppUpdateInfo?> checkForUpdates({AppLocalizations? l}) async {
    if (kIsWeb) return null;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version.isNotEmpty
          ? packageInfo.version
          : '1.0.0';

      final response = await http
          .get(
            Uri.parse(latestReleaseApiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'Shiftly-App',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint(
          'Update check failed with status code: ${response.statusCode}',
        );
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      final String tagName = json['tag_name'] ?? '';
      final String versionName =
          tagName.startsWith('v') || tagName.startsWith('V')
          ? tagName.substring(1)
          : tagName;

      final String fallbackChangelog =
          l?.update_service_no_changelog ?? 'אין פירוט שינויים זמין.';
      final String rawChangelog = json['body'] is String
          ? json['body'] as String
          : '';
      final String changelog = _releaseNotesToPlainText(
        rawChangelog.isEmpty ? fallbackChangelog : rawChangelog,
      );
      final String releaseUrl =
          json['html_url'] ??
          'https://github.com/$repoOwner/$repoName/releases';

      DateTime? publishedAt;
      if (json['published_at'] != null) {
        publishedAt = DateTime.tryParse(json['published_at']);
      }

      final String? downloadUrl = _downloadUrlForCurrentPlatform(
        json['assets'],
      );

      final bool isNewer = _isVersionNewer(versionName, currentVersion);

      return AppUpdateInfo(
        tagName: tagName,
        versionName: versionName,
        currentVersion: currentVersion,
        changelog: changelog,
        changelogIsRtl: RegExp(
          r'<div\s+[^>]*dir\s*=\s*["\x27]rtl["\x27]',
          caseSensitive: false,
        ).hasMatch(rawChangelog),
        downloadUrl: downloadUrl,
        releaseUrl: releaseUrl,
        publishedAt: publishedAt,
        isNewer: isNewer,
      );
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  static String? _downloadUrlForCurrentPlatform(dynamic assets) {
    if (kIsWeb || assets is! List) return null;

    final (extensions, platformName) = switch (defaultTargetPlatform) {
      TargetPlatform.android => (['.apk'], null),
      TargetPlatform.windows => (['.exe', '.zip'], 'windows'),
      TargetPlatform.macOS => (['.dmg', '.zip'], 'macos'),
      TargetPlatform.iOS => (['.ipa'], null),
      _ => (<String>[], null),
    };
    if (extensions.isEmpty) return null;

    for (final ext in extensions) {
      for (final asset in assets) {
        if (asset is! Map) continue;
        final String name = (asset['name'] ?? '').toString().toLowerCase();
        if (!name.endsWith(ext)) continue;
        if (platformName != null && !name.contains(platformName)) continue;

        final String url = (asset['browser_download_url'] ?? '').toString();
        if (url.isNotEmpty) return url;
      }
    }
    return null;
  }

  static String _releaseNotesToPlainText(String notes) {
    final String plainText = notes
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ')
        .replaceAll(RegExp(r'</(div|p|h[1-6]|li)>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[*-]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'`([^`]*)`'), r'$1');

    return plainText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  /// Compares semver version strings (e.g. "1.0.1" vs "1.0.0").
  static bool _isVersionNewer(String latest, String current) {
    try {
      final List<int> latestParts = _parseVersion(latest);
      final List<int> currentParts = _parseVersion(current);

      final int maxLength = latestParts.length > currentParts.length
          ? latestParts.length
          : currentParts.length;

      for (int i = 0; i < maxLength; i++) {
        final int l = i < latestParts.length ? latestParts[i] : 0;
        final int c = i < currentParts.length ? currentParts[i] : 0;

        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static List<int> _parseVersion(String v) {
    // Strip trailing +build numbers if any, e.g. "1.0.1+2" -> "1.0.1"
    final String cleanVersion = v.split('+').first.trim();
    return cleanVersion
        .split('.')
        .map(
          (part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        )
        .toList();
  }

  /// Downloads the APK file from [downloadUrl] and launches the Android installer via OpenFilex.
  static Future<void> downloadAndInstallApk({
    required String downloadUrl,
    required Function(double progress) onProgress,
    required Function(String filePath) onCompleted,
    required Function(String errorMessage) onError,
    AppLocalizations? l,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'Shiftly-App';

      final http.StreamedResponse response = await client.send(request);

      if (response.statusCode != 200) {
        final String errStr =
            l?.update_service_download_failed(response.statusCode) ??
            'הורדת הקובץ נכשלה (קוד שגיאה: ${response.statusCode})';
        onError(errStr);
        return;
      }

      final int totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      final Directory tempDir = await getTemporaryDirectory();
      final File apkFile = File('${tempDir.path}/shiftly_update.apk');

      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      final IOSink sink = apkFile.openWrite();

      await for (final List<int> chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes > 0) {
          final double progress = downloadedBytes / totalBytes;
          onProgress(progress);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      onCompleted(apkFile.path);

      // Prompt Android OS package installer
      final OpenResult openResult = await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );

      if (openResult.type != ResultType.done) {
        debugPrint(
          'OpenFilex result type: ${openResult.type}, message: ${openResult.message}',
        );
        if (openResult.type == ResultType.noAppToOpen) {
          final String noInstallerStr =
              l?.update_service_no_installer ??
              'לא נמצאה אפליקציה להתקנת קובצי APK במכשיר. נסה לפתוח בדפדפן.';
          onError(noInstallerStr);
        } else {
          final String cannotLaunchStr =
              l?.update_service_cannot_launch_installer(openResult.message) ??
              'לא ניתן להפעיל את מתקין האפליקציות (${openResult.message})';
          onError(cannotLaunchStr);
        }
      }
    } catch (e) {
      debugPrint('Error downloading and installing APK: $e');
      final String downloadErrStr =
          l?.update_service_download_error(e) ?? 'שגיאה במהלך הורדת העדכון: $e';
      onError(downloadErrStr);
    }
  }

  /// Opens the release webpage in external browser.
  static Future<bool> openReleaseInBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching release URL: $e');
      return false;
    }
  }
}
