import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path_lib;
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/audio_file_model.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of FileScannerRepository
/// 使用檔案系統掃描音樂檔案（跨平台）
class FileScannerRepositoryImpl implements FileScannerRepository {
  FileScannerRepositoryImpl(this._dataSource);

  final LocalStorageDataSource _dataSource;
  final _uuid = const Uuid();
  @override
  Stream<ScanProgress> scanForMusicFiles() async* {
    final directories = await getCommonMusicDirectories();
    var filesFound = 0;
    var foldersScanned = 0;

    if (directories.isEmpty) {
      yield const ScanProgress(
        filesFound: 0,
        foldersScanned: 0,
        currentFolder: '找不到音樂資料夾，請使用手動匯入',
        isComplete: true,
      );
      return;
    }

    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;

      yield ScanProgress(
        filesFound: filesFound,
        foldersScanned: foldersScanned,
        currentFolder: dirPath,
      );

      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && isSupportedAudioFile(entity.path)) {
            filesFound++;
            if (filesFound % 50 == 0) {
              yield ScanProgress(
                filesFound: filesFound,
                foldersScanned: foldersScanned,
                currentFolder: path_lib.dirname(entity.path),
              );
            }
          }
        }
      } on Exception {
        // Skip inaccessible directories
      }
      foldersScanned++;
    }

    yield ScanProgress(
      filesFound: filesFound,
      foldersScanned: foldersScanned,
      currentFolder: '',
      isComplete: true,
    );
  }

  @override
  Future<List<String>> getCommonMusicDirectories() async {
    final paths = <String>[];

    if (Platform.isAndroid) {
      // Android 常見音樂路徑
      paths.addAll([
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Audiobooks',
      ]);
    } else if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'] ?? '';
      paths.addAll([
        path_lib.join(home, 'Music'),
        path_lib.join(home, 'Downloads'),
        r'D:\Music',
        r'E:\Music',
      ]);
    } else if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '';
      paths.addAll([
        path_lib.join(home, 'Music'),
        path_lib.join(home, 'Downloads'),
      ]);
    }

    return paths.where((p) => Directory(p).existsSync()).toList();
  }

  @override
  Future<List<AudioFile>> scanFolder(String folderPath) async {
    final files = <AudioFile>[];
    final dir = Directory(folderPath);

    if (!dir.existsSync()) return files;

    try {
      await for (final entity in dir.list()) {
        if (entity is File && isSupportedAudioFile(entity.path)) {
          final audioFile = await extractMetadata(entity.path);
          if (audioFile != null) files.add(audioFile);
        }
      }
    } on Exception {
      // Skip errors
    }

    return files;
  }

  @override
  Future<List<ScannedFolder>> getScannedFolders() async {
    final directories = await getCommonMusicDirectories();
    final folderMap = <String, List<AudioFile>>{};

    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) continue;

      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && isSupportedAudioFile(entity.path)) {
            final folderPath = path_lib.dirname(entity.path);
            final audioFile = await extractMetadata(entity.path);
            if (audioFile != null) {
              folderMap.putIfAbsent(folderPath, () => []).add(audioFile);
            }
          }
        }
      } on Exception {
        // Skip inaccessible directories
      }
    }

    return folderMap.entries
        .map(
          (e) => ScannedFolder(
            path: e.key,
            name: path_lib.basename(e.key),
            files: e.value,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveSelectedFolders(List<String> folderPaths) async {
    // Placeholder
  }

  @override
  Future<List<String>> getSavedFolderPreferences() async => [];

  @override
  bool isSupportedAudioFile(String filePath) {
    final extension = path_lib.extension(filePath).toLowerCase();
    return FileScannerRepository.supportedExtensions.contains(extension);
  }

  @override
  Future<AudioFile?> extractMetadata(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    try {
      final stat = file.statSync();
      final fileName = path_lib.basenameWithoutExtension(filePath);

      return AudioFile(
        id: _uuid.v4(),
        path: filePath,
        title: fileName,
        duration: Duration.zero,
        fileSizeBytes: stat.size,
        addedAt: DateTime.now(),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> saveToLibrary(List<AudioFile> files) async {
    final models = files.map(AudioFileModel.fromEntity).toList();
    await _dataSource.saveAudioFiles(models);
  }

  @override
  Future<List<AudioFile>> getLibraryFiles() async {
    final models = await _dataSource.getAllAudioFiles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteFromLibrary(String fileId) async {
    await _dataSource.deleteAudioFile(fileId);
  }

  @override
  Future<void> deleteMultipleFromLibrary(List<String> fileIds) async {
    await _dataSource.deleteAudioFiles(fileIds);
  }

  @override
  Future<bool> deleteFileFromDisk(String fileId, String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await _dataSource.deleteAudioFile(fileId);
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<void> clearLibrary() async {
    await _dataSource.clearAllAudioFiles();
  }
}
