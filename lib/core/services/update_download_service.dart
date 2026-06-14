import 'dart:async';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pulse/domain/entities/app_update.dart';

typedef UpdateDownloadProgress = void Function(int received, int? total);

/// Downloads a selected release asset and opens it with the system installer.
class UpdateDownloadService {
  const UpdateDownloadService({HttpClient? httpClient})
    : _httpClient = httpClient;

  final HttpClient? _httpClient;

  Future<File> download(
    AppUpdate update, {
    UpdateDownloadProgress? onProgress,
  }) async {
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

      final directory = await getTemporaryDirectory();
      final fileName = update.assetName.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );
      final file = File(p.join(directory.path, fileName));
      final sink = file.openWrite();
      var received = 0;
      final total = response.contentLength > 0 ? response.contentLength : null;

      try {
        await for (final chunk in response) {
          received += chunk.length;
          sink.add(chunk);
          onProgress?.call(received, total);
        }
      } finally {
        await sink.close();
      }

      return file;
    } finally {
      if (_httpClient == null) client.close(force: true);
    }
  }

  Future<void> openInstaller(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw FileSystemException(result.message, file.path);
    }
  }
}
