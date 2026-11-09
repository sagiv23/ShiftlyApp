import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/services/update_service.dart';

void main() {
  group('UpdateService Unit Tests', () {
    test('AppUpdateInfo constructor holds expected values', () {
      const updateInfo = AppUpdateInfo(
        tagName: 'v1.1.0',
        versionName: '1.1.0',
        currentVersion: '1.0.0',
        changelog: 'New features added',
        changelogIsRtl: false,
        downloadUrl: 'https://example.com/app.apk',
        releaseUrl: 'https://github.com/sagiv23/ShiftlyApp/releases/tag/v1.1.0',
        expectedSha256: 'abc123hash',
        isNewer: true,
      );

      expect(updateInfo.tagName, 'v1.1.0');
      expect(updateInfo.versionName, '1.1.0');
      expect(updateInfo.currentVersion, '1.0.0');
      expect(updateInfo.downloadUrl, 'https://example.com/app.apk');
      expect(updateInfo.expectedSha256, 'abc123hash');
      expect(updateInfo.isNewer, isTrue);
    });
  });
}
