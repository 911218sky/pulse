import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      final request = await client
          .getUrl(_latestReleaseUri)
          .timeout(const Duration(seconds: 5));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'Pulse/${packageInfo.version}');

      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final tagName = json['tag_name'] as String?;
      if (tagName == null || tagName.trim().isEmpty) return null;

      final latestVersion = _normalizeVersion(tagName);
      if (!_isNewerVersion(latestVersion, currentVersion)) return null;

      final releaseUrl = Uri.tryParse(json['html_url'] as String? ?? '');
      if (releaseUrl == null) return null;

      final supportedAbis = await _supportedAbis();
      final selectedAsset = _findReleaseAsset(
        json,
        tagName,
        _preferredAssetNames(supportedAbis),
      );

      return AppUpdate(
        currentVersion: currentVersion,
        version: latestVersion,
        releaseUrl: releaseUrl,
        downloadUrl: selectedAsset.url,
        assetName: selectedAsset.name,
        canDownloadDirectly: selectedAsset.canDownloadDirectly,
      );
    } finally {
      if (_httpClient == null) client.close(force: true);
    }
  }

  static _ReleaseAsset _findReleaseAsset(
    Map<String, dynamic> json,
    String tagName,
    List<String> preferredNames,
  ) {
    final releaseAssets = <_ReleaseAsset>[];
    final assets = json['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name'] as String? ?? '';
        final url = asset['browser_download_url'] as String? ?? '';
        final parsedUrl = Uri.tryParse(url);
        if (parsedUrl == null) continue;
        releaseAssets.add(
          _ReleaseAsset(name: name, url: parsedUrl, canDownloadDirectly: true),
        );
      }
    }

    for (final preferredName in preferredNames) {
      for (final asset in releaseAssets) {
        if (asset.name.toLowerCase() == preferredName) return asset;
      }
    }

    if (Platform.isAndroid) {
      for (final asset in releaseAssets) {
        if (asset.name.toLowerCase() == 'pulse-android-universal.apk') {
          return asset;
        }
      }

      const fallbackName = 'pulse-android-universal.apk';
      return _ReleaseAsset(
        name: fallbackName,
        url: Uri.https(
          'github.com',
          '/911218sky/pulse/releases/download/$tagName/$fallbackName',
        ),
        canDownloadDirectly: true,
      );
    }

    return _ReleaseAsset(
      name: 'GitHub Releases',
      url: Uri.https('github.com', '/911218sky/pulse/releases/tag/$tagName'),
      canDownloadDirectly: false,
    );
  }

  static Future<List<String>> _supportedAbis() async {
    if (!Platform.isAndroid) return const [];

    try {
      final abis = await _deviceChannel.invokeListMethod<String>(
        'supportedAbis',
      );
      return abis ?? const [];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  static List<String> _preferredAssetNames(List<String> supportedAbis) {
    if (Platform.isWindows) return const ['pulse-windows-x64.zip'];
    if (Platform.isLinux) return const ['pulse-linux-x64.tar.gz'];
    if (Platform.isMacOS) return const ['pulse-macos-universal.zip'];
    if (!Platform.isAndroid) return const [];

    final names = <String>[];
    final abis = supportedAbis.map((abi) => abi.toLowerCase()).toSet();

    if (abis.contains('arm64-v8a')) {
      names.add('pulse-android-arm64-v8a.apk');
    }
    if (abis.contains('armeabi-v7a')) {
      names.add('pulse-android-armeabi-v7a.apk');
    }
    if (abis.contains('x86_64')) {
      names.add('pulse-android-x86_64.apk');
    }
    names.add('pulse-android-universal.apk');

    return names;
  }

  static String _normalizeVersion(String version) =>
      version.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;

  static bool isNewerVersionForTesting(String latest, String current) =>
      _isNewerVersion(latest, current);

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

class _ReleaseAsset {
  const _ReleaseAsset({
    required this.name,
    required this.url,
    required this.canDownloadDirectly,
  });

  final String name;
  final Uri url;
  final bool canDownloadDirectly;
}
