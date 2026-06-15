import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/update_check_service.dart';

void main() {
  group('UpdateCheckService version comparison', () {
    test('detects newer semantic versions', () {
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.16', '0.1.15'),
        isTrue,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('v0.2.0', '0.1.99'),
        isTrue,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('1.0.0', '0.9.9'),
        isTrue,
      );
    });

    test('does not update for equal or older versions', () {
      expect(
        UpdateCheckService.isNewerVersionForTesting('v0.1.15', '0.1.15'),
        isFalse,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.15+99', '0.1.15'),
        isFalse,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.14', '0.1.15'),
        isFalse,
      );
    });
  });

  group('UpdateCheckService release parsing', () {
    test('selects universal APK first on Android', () {
      final update = UpdateCheckService.buildUpdateFromReleaseForTesting(
        _releaseJson(
          assets: [
            _asset('pulse-android-arm64-v8a.apk'),
            _asset('pulse-android-universal.apk'),
          ],
        ),
        '0.1.17',
        isAndroid: true,
        isWindows: false,
        isLinux: false,
        isMacOS: false,
      );

      expect(update, isNotNull);
      expect(update!.version, equals('0.1.18'));
      expect(update.assetName, equals('pulse-android-universal.apk'));
      expect(update.canDownloadDirectly, isTrue);
    });

    test('selects ABI-specific APK first when Android ABI is known', () {
      final update = UpdateCheckService.buildUpdateFromReleaseForTesting(
        _releaseJson(
          assets: [
            _asset('pulse-android-universal.apk'),
            _asset('pulse-android-arm64-v8a.apk'),
            _asset('pulse-android-armeabi-v7a.apk'),
            _asset('pulse-android-x86_64.apk'),
          ],
        ),
        '0.1.17',
        isAndroid: true,
        isWindows: false,
        isLinux: false,
        isMacOS: false,
        supportedAbis: const ['arm64-v8a', 'armeabi-v7a'],
      );

      expect(update, isNotNull);
      expect(update!.assetName, equals('pulse-android-arm64-v8a.apk'));
      expect(
        update.availableAssets.map((asset) => asset.name),
        containsAll([
          'pulse-android-universal.apk',
          'pulse-android-arm64-v8a.apk',
          'pulse-android-armeabi-v7a.apk',
          'pulse-android-x86_64.apk',
        ]),
      );
    });

    test('uses release page on Android when APK assets are missing', () {
      final update = UpdateCheckService.buildUpdateFromReleaseForTesting(
        _releaseJson(assets: []),
        '0.1.17',
        isAndroid: true,
        isWindows: false,
        isLinux: false,
        isMacOS: false,
      );

      expect(update, isNotNull);
      expect(update!.assetName, equals('GitHub Releases'));
      expect(update.canDownloadDirectly, isFalse);
      expect(
        update.downloadUrl.toString(),
        equals('https://github.com/911218sky/pulse/releases/tag/v0.1.18'),
      );
    });

    test('uses release page when no direct desktop asset matches', () {
      final update = UpdateCheckService.buildUpdateFromReleaseForTesting(
        _releaseJson(assets: []),
        '0.1.17',
        isAndroid: false,
        isWindows: true,
        isLinux: false,
        isMacOS: false,
      );

      expect(update, isNotNull);
      expect(update!.assetName, equals('GitHub Releases'));
      expect(update.canDownloadDirectly, isFalse);
      expect(
        update.downloadUrl.toString(),
        equals('https://github.com/911218sky/pulse/releases/tag/v0.1.18'),
      );
    });

    test('returns null when latest release is not newer', () {
      final update = UpdateCheckService.buildUpdateFromReleaseForTesting(
        _releaseJson(),
        '0.1.18',
        isAndroid: true,
        isWindows: false,
        isLinux: false,
        isMacOS: false,
      );

      expect(update, isNull);
    });

    test('throws when release payload is malformed', () {
      expect(
        () => UpdateCheckService.buildUpdateFromReleaseForTesting(
          {
            'html_url':
                'https://github.com/911218sky/pulse/releases/tag/v0.1.18',
          },
          '0.1.17',
          isAndroid: true,
          isWindows: false,
          isLinux: false,
          isMacOS: false,
        ),
        throwsFormatException,
      );

      expect(
        () => UpdateCheckService.buildUpdateFromReleaseForTesting(
          {'tag_name': 'v0.1.18'},
          '0.1.17',
          isAndroid: true,
          isWindows: false,
          isLinux: false,
          isMacOS: false,
        ),
        throwsFormatException,
      );
    });
  });
}

Map<String, dynamic> _releaseJson({List<Map<String, dynamic>>? assets}) => {
  'tag_name': 'v0.1.18',
  'html_url': 'https://github.com/911218sky/pulse/releases/tag/v0.1.18',
  'assets': assets ?? [_asset('pulse-android-universal.apk')],
};

Map<String, dynamic> _asset(String name) => {
  'name': name,
  'browser_download_url':
      'https://github.com/911218sky/pulse/releases/download/v0.1.18/$name',
};
