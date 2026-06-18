import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/app_update.dart';

typedef UpdateDownloadProgress = void Function(int received, int? total);

/// Downloads a selected release asset and opens it with the system installer.
class UpdateDownloadService {
  const UpdateDownloadService({HttpClient? httpClient})
    : _httpClient = httpClient;

  static const MethodChannel _deviceChannel = MethodChannel(
    'dev.pulse.app/device',
  );

  final HttpClient? _httpClient;

  Future<File> download(
    AppUpdate update, {
    UpdateDownloadProgress? onProgress,
  }) async {
    final file = await _installerFileFor(update);
    if (file.existsSync() && file.lengthSync() > 0) {
      onProgress?.call(file.lengthSync(), file.lengthSync());
      return file;
    }

    final client = _httpClient ?? HttpClient();
    try {
      final request = await client
          .getUrl(update.downloadUrl)
          .timeout(const Duration(seconds: 10));
      request.followRedirects = true;

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Download failed with HTTP ${response.statusCode}',
          uri: update.downloadUrl,
        );
      }

      final total = response.contentLength > 0 ? response.contentLength : null;
      final partialFile = File('${file.path}.download');
      if (partialFile.existsSync()) await partialFile.delete();

      final sink = partialFile.openWrite();
      var received = 0;

      try {
        try {
          await for (final chunk in response) {
            received += chunk.length;
            sink.add(chunk);
            onProgress?.call(received, total);
          }
        } finally {
          await sink.close();
        }
      } on Exception {
        if (partialFile.existsSync()) await partialFile.delete();
        rethrow;
      }

      if (total != null && received != total) {
        if (partialFile.existsSync()) await partialFile.delete();
        throw HttpException(
          'Download incomplete: received $received of $total bytes',
          uri: update.downloadUrl,
        );
      }

      if (file.existsSync()) await file.delete();
      await partialFile.rename(file.path);
      await cleanDownloadedInstallers(keep: file);
      return file;
    } finally {
      if (_httpClient == null) client.close(force: true);
    }
  }

  Future<void> openInstaller(File file) async {
    if (Platform.isAndroid && !await _canRequestPackageInstalls()) {
      await _openUnknownAppsSettings();
      throw const UpdateInstallPermissionException();
    }

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw FileSystemException(result.message, file.path);
    }
  }

  Future<void> cleanDownloadedInstallers({
    File? keep,
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    try {
      final directory = await getTemporaryDirectory();
      final keepPath = keep == null ? null : p.normalize(keep.path);
      await for (final entity in directory.list()) {
        if (entity is! File) continue;
        final normalizedPath = p.normalize(entity.path);
        if (normalizedPath == keepPath) continue;
        if (!_isPulseInstallerName(p.basename(entity.path))) continue;
        await entity.delete();
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.w('UpdateDownloadService', 'Installer cleanup failed: $error');
      AppLogger.d('UpdateDownloadService', stackTrace.toString());
    }
  }

  bool _isPulseInstallerName(String fileName) {
    final lowerName = fileName.toLowerCase();
    return lowerName.startsWith('pulse-') &&
        (lowerName.endsWith('.apk') ||
            lowerName.endsWith('.aab') ||
            lowerName.endsWith('.zip') ||
            lowerName.endsWith('.tar.gz'));
  }

  String _safeFilePart(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  Future<File> _installerFileFor(AppUpdate update) async {
    final directory = await getTemporaryDirectory();
    final safeVersion = _safeFilePart(update.version);
    final safeAssetName = _safeFilePart(update.assetName);
    final fileName = 'pulse-$safeVersion-$safeAssetName';
    return File(p.join(directory.path, fileName));
  }

  Future<bool> _canRequestPackageInstalls() async {
    try {
      return await _deviceChannel.invokeMethod<bool>(
            'canRequestPackageInstalls',
          ) ??
          true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  Future<void> _openUnknownAppsSettings() async {
    try {
      await _deviceChannel.invokeMethod<void>('openUnknownAppsSettings');
    } on MissingPluginException {
      // Ignore: the external APK URL fallback still lets users install manually.
    } on PlatformException {
      // Ignore: the external APK URL fallback still lets users install manually.
    }
  }
}

class UpdateInstallPermissionException implements Exception {
  const UpdateInstallPermissionException();
}
