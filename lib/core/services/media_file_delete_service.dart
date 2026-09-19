import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pulse/core/utils/app_logger.dart';

/// Result of attempting to delete a media file from disk.
enum MediaDeleteOutcome {
  /// File is gone (deleted now or already missing).
  deleted,

  /// User dismissed the system delete confirmation (Android R+).
  cancelled,

  /// Delete failed (permission, I/O, or MediaStore lookup).
  failed,
}

/// Deletes local audio files, using Android MediaStore when needed.
class MediaFileDeleteService {
  MediaFileDeleteService({
    MethodChannel? deviceChannel,
    Future<bool> Function(String path)? ioDelete,
    bool? isAndroid,
  }) : _deviceChannel =
           deviceChannel ?? const MethodChannel('dev.pulse.app/device'),
       _ioDelete = ioDelete ?? _defaultIoDelete,
       _isAndroid = isAndroid ?? Platform.isAndroid;

  static const _tag = 'MediaFileDelete';

  final MethodChannel _deviceChannel;
  final Future<bool> Function(String path) _ioDelete;
  final bool _isAndroid;

  Future<MediaDeleteOutcome> deleteFile(String filePath) async {
    if (filePath.trim().isEmpty) return MediaDeleteOutcome.failed;

    if (!_isAndroid) {
      final removed = await _ioDelete(filePath);
      return removed ? MediaDeleteOutcome.deleted : MediaDeleteOutcome.failed;
    }

    try {
      final raw = await _deviceChannel.invokeMethod<dynamic>(
        'deleteMediaFile',
        {'path': filePath},
      );
      if (raw is! Map) {
        AppLogger.w(_tag, 'Unexpected deleteMediaFile payload: $raw');
        return MediaDeleteOutcome.failed;
      }

      final result = Map<String, dynamic>.from(raw);
      if (result['deleted'] == true) {
        return MediaDeleteOutcome.deleted;
      }
      if (result['cancelled'] == true) {
        return MediaDeleteOutcome.cancelled;
      }
      AppLogger.w(_tag, 'deleteMediaFile failed: $result');
      return MediaDeleteOutcome.failed;
    } on PlatformException catch (e, st) {
      AppLogger.e(_tag, 'deleteMediaFile platform error', e, st);
      return MediaDeleteOutcome.failed;
    } on MissingPluginException catch (e, st) {
      AppLogger.e(_tag, 'deleteMediaFile plugin missing', e, st);
      // Fall back to dart:io for tests / incomplete embedding.
      final removed = await _ioDelete(filePath);
      return removed ? MediaDeleteOutcome.deleted : MediaDeleteOutcome.failed;
    }
  }

  static Future<bool> _defaultIoDelete(String path) async {
    final file = File(path);
    if (!file.existsSync()) return true;
    try {
      await file.delete();
      return !file.existsSync();
    } on Exception {
      return false;
    }
  }
}
