import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path_lib;
import 'package:pulse/core/services/media_file_delete_service.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/audio_file_model.dart';
import 'package:pulse/data/models/settings_model.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of FileScannerRepository
/// 使用檔案系統掃描音樂檔案（跨平台）
class FileScannerRepositoryImpl implements FileScannerRepository {
  FileScannerRepositoryImpl(
    this._dataSource, {
    MediaFileDeleteService? mediaFileDeleteService,
  }) : _mediaFileDeleteService =
           mediaFileDeleteService ?? MediaFileDeleteService();

  final LocalStorageDataSource _dataSource;
  final MediaFileDeleteService _mediaFileDeleteService;
  final _uuid = const Uuid();
  List<ScannedFolder> _lastScannedFolders = const [];
  @override
  Stream<ScanProgress> scanForMusicFiles() async* {
    final directories = await getCommonMusicDirectories();
    var filesFound = 0;
    var foldersScanned = 0;
    final folderMap = <String, List<AudioFile>>{};

    _lastScannedFolders = const [];

    if (directories.isEmpty) {
      yield ScanProgress.noMusicFolders;
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
            final folderPath = AudioPathUtils.dirname(entity.path);
            final audioFile = await extractMetadata(entity.path);
            if (audioFile != null) {
              folderMap.putIfAbsent(folderPath, () => []).add(audioFile);
            }
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

    _lastScannedFolders =
        folderMap.entries
            .map(
              (e) => ScannedFolder(
                path: e.key,
                name: path_lib.basename(e.key),
                files: e.value,
              ),
            )
            .toList();

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
      paths.addAll([
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Audiobooks',
      ]);
    }

    return paths.where((p) => Directory(p).existsSync()).toList();
  }

  @override
  Future<List<AudioFile>> scanFolder(String folderPath) async {
    final files = <AudioFile>[];
    final dir = Directory(AudioPathUtils.canonicalize(folderPath));

    if (!dir.existsSync()) return files;

    try {
      // Recursive so "select folder" matches auto-scan and nested albums.
      await for (final entity in dir.list(recursive: true)) {
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
  Future<List<ScannedFolder>> getScannedFolders() async => _lastScannedFolders;

  @override
  Future<void> saveSelectedFolders(List<String> folderPaths) async {
    final canonicalPaths = folderPaths
        .map(AudioPathUtils.canonicalize)
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final current = await _dataSource.getSettings();
    final updated = SettingsModel(
      darkMode: current.darkMode,
      locale: current.locale,
      defaultVolume: current.defaultVolume,
      defaultPlaybackSpeed: current.defaultPlaybackSpeed,
      autoResume: current.autoResume,
      resumePlaybackOnTrackTap: current.resumePlaybackOnTrackTap,
      skipForwardSeconds: current.skipForwardSeconds,
      skipBackwardSeconds: current.skipBackwardSeconds,
      monitoredFolders: canonicalPaths,
      sleepTimerFadeOutEnabled: current.sleepTimerFadeOutEnabled,
      sleepTimerFadeOutSeconds: current.sleepTimerFadeOutSeconds,
      navigateToPlayerOnResume: current.navigateToPlayerOnResume,
      autoUpdateEnabled: current.autoUpdateEnabled,
    );
    await _dataSource.saveSettings(updated);
  }

  @override
  Future<List<String>> getSavedFolderPreferences() async {
    final settings = await _dataSource.getSettings();
    return settings.monitoredFolders
        .map(AudioPathUtils.canonicalize)
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
  }

  @override
  bool isSupportedAudioFile(String filePath) {
    final extension =
        path_lib.extension(AudioPathUtils.canonicalize(filePath)).toLowerCase();
    return FileScannerRepository.supportedExtensions.contains(extension);
  }

  @override
  Future<AudioFile?> extractMetadata(String filePath) async {
    final canonicalPath = AudioPathUtils.canonicalize(filePath);
    final file = File(canonicalPath);
    if (!file.existsSync()) return null;

    try {
      final stat = file.statSync();
      final fileName = AudioPathUtils.basenameWithoutExtension(canonicalPath);

      return AudioFile(
        id: _uuid.v4(),
        path: canonicalPath,
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
    // Upsert by canonical path so rescan/import never create duplicate rows.
    // Existing IDs are preserved inside LocalStorageDataSource/AppDatabase.
    final seenPaths = <String>{};
    final models = <AudioFileModel>[];
    for (final file in files) {
      final path = AudioPathUtils.canonicalize(file.path);
      if (!seenPaths.add(path)) continue;
      models.add(AudioFileModel.fromEntity(file.copyWith(path: path)));
    }
    if (models.isEmpty) return;
    await _dataSource.saveAudioFiles(models);
  }

  @override
  Future<List<AudioFile>> getLibraryFiles() async {
    final models = await _dataSource.getAllAudioFiles();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteFromLibrary(String fileId) async {
    final path = await _pathForAudioFileId(fileId);
    await _dataSource.deleteAudioFile(fileId);
    if (path != null) {
      await _cleanupRelatedPersistence(path);
    }
  }

  @override
  Future<void> deleteMultipleFromLibrary(List<String> fileIds) async {
    final paths = <String>[];
    for (final id in fileIds) {
      final path = await _pathForAudioFileId(id);
      if (path != null) paths.add(path);
    }
    await _dataSource.deleteAudioFiles(fileIds);
    for (final path in paths) {
      await _cleanupRelatedPersistence(path);
    }
  }

  @override
  Future<MediaDeleteOutcome> deleteFileFromDisk(
    String fileId,
    String filePath,
  ) async {
    final canonicalPath = AudioPathUtils.canonicalize(filePath);
    final outcome = await _mediaFileDeleteService.deleteFile(canonicalPath);
    if (outcome != MediaDeleteOutcome.deleted) {
      return outcome;
    }

    await _dataSource.deleteAudioFile(fileId);
    await _cleanupRelatedPersistence(canonicalPath);
    return MediaDeleteOutcome.deleted;
  }

  Future<String?> _pathForAudioFileId(String fileId) async {
    final file = await _dataSource.getAudioFileById(fileId);
    if (file == null) return null;
    return AudioPathUtils.canonicalize(file.path);
  }

  Future<void> _cleanupRelatedPersistence(String canonicalPath) async {
    await _dataSource.clearFilePosition(canonicalPath);
    final lastState = await _dataSource.getLastPlaybackState();
    if (lastState != null &&
        AudioPathUtils.canonicalize(lastState.audioFilePath) == canonicalPath) {
      await _dataSource.clearPlaybackState();
    }
  }

  @override
  Future<void> clearLibrary() async {
    final paths = await _dataSource.getAllAudioFilePaths();
    if (paths.isNotEmpty) {
      await _dataSource.clearFilePositions(paths);
    }
    await _dataSource.clearPlaybackState();
    await _dataSource.clearAllAudioFiles();
  }

  @override
  Future<int> cleanupOrphanedEntries() async {
    var removedCount = 0;

    // 1. Clean up audio_files table - remove entries where file no longer exists
    final audioPaths = await _dataSource.getAllAudioFilePaths();
    final missingAudioPaths = <String>[];

    for (final path in audioPaths) {
      if (!File(path).existsSync()) {
        missingAudioPaths.add(path);
      }
    }

    if (missingAudioPaths.isNotEmpty) {
      removedCount += await _dataSource.deleteAudioFilesByPaths(
        missingAudioPaths,
      );
    }

    // 2. Clean up file_positions table - remove entries where file no longer exists
    final positionPaths = await _dataSource.getAllFilePositionPaths();
    final missingPositionPaths = <String>[];

    for (final path in positionPaths) {
      if (!File(path).existsSync()) {
        missingPositionPaths.add(path);
      }
    }

    if (missingPositionPaths.isNotEmpty) {
      await _dataSource.clearFilePositions(missingPositionPaths);
      removedCount += missingPositionPaths.length;
    }

    removedCount += await _dataSource.repairDuplicateAudioFilesByPath();

    return removedCount;
  }
}
