import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/app_update.dart';

/// Checks GitHub Releases for a newer public Pulse APK release.
class UpdateCheckService {
  const UpdateCheckService({HttpClient? httpClient}) : _httpClient = httpClient;

  static final Uri _latestReleaseUri = Uri.https(
    'api.github.com',
    '/repos/911218sky/pulse/releases/latest',
  );
  static const MethodChannel _deviceChannel = MethodChannel(
    'dev.pulse.app/device',
  );
  final HttpClient? _httpClient;

  Future<AppUpdate?> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final client = _httpClient ?? HttpClient();

    try {
      AppLogger.i(
        'UpdateCheckService',
        'Checking updates: current=$currentVersion',
      );
      final request = await client
          .getUrl(_latestReleaseUri)
          .timeout(const Duration(seconds: 5));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'Pulse/${packageInfo.version}');

      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode != HttpStatus.ok) {
        AppLogger.w(
          'UpdateCheckService',
          'GitHub latest API returned ${response.statusCode}',
        );
        throw HttpException(
          'GitHub latest API returned ${response.statusCode}',
          uri: _latestReleaseUri,
        );
      }

      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final supportedAbis = await _supportedAbis();
      final update = buildUpdateFromRelease(
        json,
        currentVersion,
        isAndroid: Platform.isAndroid,
        isWindows: Platform.isWindows,
        isLinux: Platform.isLinux,
        isMacOS: Platform.isMacOS,
        supportedAbis: supportedAbis,
      );
      if (update == null) return null;
      AppLogger.i(
        'UpdateCheckService',
        'Selected asset=${update.assetName} direct=${update.canDownloadDirectly}',
      );

      return update;
    } finally {
      if (_httpClient == null) client.close(force: true);
    }
  }

  static AppUpdate? buildUpdateFromRelease(
    Map<String, dynamic> json,
    String currentVersion, {
    required bool isAndroid,
    required bool isWindows,
    required bool isLinux,
    required bool isMacOS,
    List<String> supportedAbis = const [],
  }) {
    final tagName = json['tag_name'] as String?;
    if (tagName == null || tagName.trim().isEmpty) {
      AppLogger.w('UpdateCheckService', 'Missing tag_name in latest release');
      throw const FormatException('Missing tag_name in latest release');
    }

    final latestVersion = _normalizeVersion(tagName);
    if (!_isNewerVersion(latestVersion, currentVersion)) {
      AppLogger.i(
        'UpdateCheckService',
        'No update available: latest=$latestVersion current=$currentVersion',
      );
      return null;
    }

    final releaseUrlRaw = json['html_url'] as String?;
    final releaseUrl =
        releaseUrlRaw == null || releaseUrlRaw.trim().isEmpty
            ? null
            : Uri.tryParse(releaseUrlRaw);
    if (releaseUrl == null ||
        !releaseUrl.hasScheme ||
        !releaseUrl.hasAuthority) {
      AppLogger.w('UpdateCheckService', 'Missing html_url in latest release');
      throw const FormatException('Missing html_url in latest release');
    }

    final preferredNames = _preferredAssetNames(
      isAndroid: isAndroid,
      isWindows: isWindows,
      isLinux: isLinux,
      isMacOS: isMacOS,
      supportedAbis: supportedAbis,
    );
    final releaseAssets = _releaseAssetsFromJson(json);
    final selectedAsset = _findReleaseAsset(
      releaseAssets,
      tagName,
      preferredNames,
    );
    final availableAssets = _availableAssetsForPlatform(
      releaseAssets,
      selectedAsset,
      isAndroid: isAndroid,
      isWindows: isWindows,
      isLinux: isLinux,
      isMacOS: isMacOS,
    );

    return AppUpdate(
      currentVersion: currentVersion,
      version: latestVersion,
      releaseUrl: releaseUrl,
      selectedAsset: selectedAsset,
      availableAssets: availableAssets,
    );
  }

  static List<UpdateAsset> _releaseAssetsFromJson(Map<String, dynamic> json) {
    final releaseAssets = <UpdateAsset>[];
    final assets = json['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name'] as String? ?? '';
        final url = asset['browser_download_url'] as String? ?? '';
        final parsedUrl = Uri.tryParse(url);
        if (parsedUrl == null) continue;
        releaseAssets.add(
          UpdateAsset(
            name: name,
            downloadUrl: parsedUrl,
            canDownloadDirectly: true,
          ),
        );
      }
    }
    return releaseAssets;
  }

  static List<UpdateAsset> _availableAssetsForPlatform(
    List<UpdateAsset> releaseAssets,
    UpdateAsset selectedAsset, {
    required bool isAndroid,
    required bool isWindows,
    required bool isLinux,
    required bool isMacOS,
  }) {
    final preferredNames =
        _preferredAssetNames(
          isAndroid: isAndroid,
          isWindows: isWindows,
          isLinux: isLinux,
          isMacOS: isMacOS,
        ).toSet();
    final assets =
        releaseAssets
            .where((asset) => preferredNames.contains(asset.name.toLowerCase()))
            .map(
              (asset) => asset.copyWith(
                isRecommended: asset.name == selectedAsset.name,
              ),
            )
            .toList();

    if (assets.isEmpty || !selectedAsset.canDownloadDirectly) {
      return [selectedAsset.copyWith(isRecommended: true)];
    }
    return assets;
  }

  static UpdateAsset _findReleaseAsset(
    List<UpdateAsset> releaseAssets,
    String tagName,
    List<String> preferredNames,
  ) {
    for (final preferredName in preferredNames) {
      for (final asset in releaseAssets) {
        if (asset.name.toLowerCase() == preferredName) {
          return asset.copyWith(isRecommended: true);
        }
      }
    }

    return UpdateAsset(
      name: 'GitHub Releases',
      downloadUrl: Uri.https(
        'github.com',
        '/911218sky/pulse/releases/tag/$tagName',
      ),
      canDownloadDirectly: false,
      isRecommended: true,
    );
  }

  static List<String> _preferredAssetNames({
    required bool isAndroid,
    required bool isWindows,
    required bool isLinux,
    required bool isMacOS,
    List<String> supportedAbis = const [],
  }) {
    if (isWindows) return const ['pulse-windows-x64.zip'];
    if (isLinux) return const ['pulse-linux-x64.tar.gz'];
    if (isMacOS) return const ['pulse-macos-universal.zip'];
    if (!isAndroid) return const [];

    final names = <String>[];
    for (final abi in supportedAbis.map((abi) => abi.toLowerCase())) {
      switch (abi) {
        case 'arm64-v8a':
          names.add('pulse-android-arm64-v8a.apk');
          break;
        case 'armeabi-v7a':
          names.add('pulse-android-armeabi-v7a.apk');
          break;
        case 'x86_64':
          names.add('pulse-android-x86_64.apk');
          break;
      }
    }

    names.addAll(const [
      'pulse-android-universal.apk',
      'pulse-android-arm64-v8a.apk',
      'pulse-android-armeabi-v7a.apk',
      'pulse-android-x86_64.apk',
    ]);

    return names.toSet().toList(growable: false);
  }

  Future<List<String>> _supportedAbis() async {
    if (!Platform.isAndroid) return const [];
    try {
      final abis = await _deviceChannel.invokeListMethod<String>(
        'supportedAbis',
      );
      return abis ?? const [];
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  static String _normalizeVersion(String version) =>
      version.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;

  static bool isNewerVersionForTesting(String latest, String current) =>
      _isNewerVersion(latest, current);

  static AppUpdate? buildUpdateFromReleaseForTesting(
    Map<String, dynamic> json,
    String currentVersion, {
    required bool isAndroid,
    required bool isWindows,
    required bool isLinux,
    required bool isMacOS,
    List<String> supportedAbis = const [],
  }) => buildUpdateFromRelease(
    json,
    currentVersion,
    isAndroid: isAndroid,
    isWindows: isWindows,
    isLinux: isLinux,
    isMacOS: isMacOS,
    supportedAbis: supportedAbis,
  );

  static bool _isNewerVersion(String latest, String current) {
    final latestParts = _parseVersion(latest);
    final currentParts = _parseVersion(current);
    final length =
        latestParts.length > currentParts.length
            ? latestParts.length
            : currentParts.length;

    for (var i = 0; i < length; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }

    return false;
  }

  static List<int> _parseVersion(String version) =>
      _normalizeVersion(version)
          .split('.')
          .map((part) => int.tryParse(part.replaceAll(RegExp(r'\D.*$'), '')))
          .whereType<int>()
          .toList();
}
