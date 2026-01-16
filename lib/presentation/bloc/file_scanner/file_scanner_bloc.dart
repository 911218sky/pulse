import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';

/// BLoC for managing file scanning
class FileScannerBloc extends Bloc<FileScannerEvent, FileScannerState> {
  FileScannerBloc({required FileScannerRepository fileScannerRepository})
    : _fileScannerRepository = fileScannerRepository,
      super(const FileScannerState()) {
    on<FileScannerStartScan>(_onStartScan);
    on<FileScannerCancelScan>(_onCancelScan);
    on<FileScannerProgressUpdated>(_onProgressUpdated);
    on<FileScannerToggleFolder>(_onToggleFolder);
    on<FileScannerSelectAll>(_onSelectAll);
    on<FileScannerDeselectAll>(_onDeselectAll);
    on<FileScannerSaveSelection>(_onSaveSelection);
    on<FileScannerLoadPreferences>(_onLoadPreferences);
    on<FileScannerRefresh>(_onRefresh);
    on<FileScannerImportFiles>(_onImportFiles);
    on<FileScannerLoadLibrary>(_onLoadLibrary);
    on<FileScannerDeleteFile>(_onDeleteFile);
    on<FileScannerDeleteFiles>(_onDeleteFiles);
    on<FileScannerClearLibrary>(_onClearLibrary);
    on<FileScannerCleanupOrphaned>(_onCleanupOrphaned);
  }

  final FileScannerRepository _fileScannerRepository;
  StreamSubscription<ScanProgress>? _scanSubscription;

  Future<void> _onStartScan(
    FileScannerStartScan event,
    Emitter<FileScannerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FileScannerStatus.scanning,
        scanProgress: ScanProgress.initial,
      ),
    );

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = _fileScannerRepository.scanForMusicFiles().listen(
        (progress) => add(FileScannerProgressUpdated(progress)),
        onError: (Object error) {
          emit(
            state.copyWith(
              status: FileScannerStatus.error,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCancelScan(
    FileScannerCancelScan event,
    Emitter<FileScannerState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    emit(state.copyWith(status: FileScannerStatus.initial));
  }

  Future<void> _onProgressUpdated(
    FileScannerProgressUpdated event,
    Emitter<FileScannerState> emit,
  ) async {
    emit(state.copyWith(scanProgress: event.progress));

    if (event.progress.isComplete) {
      // Scan complete, load the scanned folders
      try {
        final folders = await _fileScannerRepository.getScannedFolders();

        // Load saved preferences to restore selection state
        final savedPaths =
            await _fileScannerRepository.getSavedFolderPreferences();
        final foldersWithSelection =
            folders
                .map(
                  (folder) => folder.copyWith(
                    isSelected: savedPaths.contains(folder.path),
                  ),
                )
                .toList();

        emit(
          state.copyWith(
            status: FileScannerStatus.completed,
            folders: foldersWithSelection,
          ),
        );
      } on Exception catch (e) {
        emit(
          state.copyWith(
            status: FileScannerStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  void _onToggleFolder(
    FileScannerToggleFolder event,
    Emitter<FileScannerState> emit,
  ) {
    final updatedFolders =
        state.folders.map((folder) {
          if (folder.path == event.folderPath) {
            return folder.toggleSelection();
          }
          return folder;
        }).toList();

    emit(state.copyWith(folders: updatedFolders));
  }

  void _onSelectAll(
    FileScannerSelectAll event,
    Emitter<FileScannerState> emit,
  ) {
    final updatedFolders =
        state.folders
            .map((folder) => folder.copyWith(isSelected: true))
            .toList();

    emit(state.copyWith(folders: updatedFolders));
  }

  void _onDeselectAll(
    FileScannerDeselectAll event,
    Emitter<FileScannerState> emit,
  ) {
    final updatedFolders =
        state.folders
            .map((folder) => folder.copyWith(isSelected: false))
            .toList();

    emit(state.copyWith(folders: updatedFolders));
  }

  Future<void> _onSaveSelection(
    FileScannerSaveSelection event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      final selectedPaths = state.selectedFolders.map((f) => f.path).toList();
      await _fileScannerRepository.saveSelectedFolders(selectedPaths);

      // Save all files from selected folders to the library
      final allFiles = state.selectedFolders.expand((f) => f.files).toList();
      await _fileScannerRepository.saveToLibrary(allFiles);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadLibrary(
    FileScannerLoadLibrary event,
    Emitter<FileScannerState> emit,
  ) async {
    emit(state.copyWith(status: FileScannerStatus.loading));

    try {
      // Auto cleanup orphaned entries before loading
      await _fileScannerRepository.cleanupOrphanedEntries();

      final files = await _fileScannerRepository.getLibraryFiles();

      if (files.isEmpty) {
        emit(
          state.copyWith(
            status: FileScannerStatus.initial,
            libraryFiles: const [],
          ),
        );
        return;
      }

      // Group files by folder
      final folderMap = <String, List<AudioFile>>{};
      for (final file in files) {
        final folderPath = file.path.substring(
          0,
          file.path.lastIndexOf(RegExp(r'[/\\]')),
        );
        folderMap.putIfAbsent(folderPath, () => []).add(file);
      }

      final folders =
          folderMap.entries.map((e) {
            final folderName = e.key.split(RegExp(r'[/\\]')).last;
            return ScannedFolder(
              path: e.key,
              name: folderName,
              files: e.value,
              isSelected: true,
            );
          }).toList();

      emit(
        state.copyWith(
          status: FileScannerStatus.completed,
          folders: folders,
          libraryFiles: files,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteFile(
    FileScannerDeleteFile event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      if (event.deleteFromDisk && event.filePath != null) {
        await _fileScannerRepository.deleteFileFromDisk(
          event.fileId,
          event.filePath!,
        );
      } else {
        await _fileScannerRepository.deleteFromLibrary(event.fileId);
      }

      // Update state
      final updatedLibraryFiles =
          state.libraryFiles.where((f) => f.id != event.fileId).toList();

      final updatedFolders =
          state.folders
              .map((folder) {
                final updatedFiles =
                    folder.files.where((f) => f.id != event.fileId).toList();
                return folder.copyWith(files: updatedFiles);
              })
              .where((f) => f.files.isNotEmpty)
              .toList();

      emit(
        state.copyWith(
          folders: updatedFolders,
          libraryFiles: updatedLibraryFiles,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteFiles(
    FileScannerDeleteFiles event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      await _fileScannerRepository.deleteMultipleFromLibrary(event.fileIds);

      // Update state
      final idsToDelete = event.fileIds.toSet();
      final updatedLibraryFiles =
          state.libraryFiles.where((f) => !idsToDelete.contains(f.id)).toList();

      final updatedFolders =
          state.folders
              .map((folder) {
                final updatedFiles =
                    folder.files
                        .where((f) => !idsToDelete.contains(f.id))
                        .toList();
                return folder.copyWith(files: updatedFiles);
              })
              .where((f) => f.files.isNotEmpty)
              .toList();

      emit(
        state.copyWith(
          folders: updatedFolders,
          libraryFiles: updatedLibraryFiles,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadPreferences(
    FileScannerLoadPreferences event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      final savedPaths =
          await _fileScannerRepository.getSavedFolderPreferences();

      final updatedFolders =
          state.folders
              .map(
                (folder) => folder.copyWith(
                  isSelected: savedPaths.contains(folder.path),
                ),
              )
              .toList();

      emit(state.copyWith(folders: updatedFolders));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(
    FileScannerRefresh event,
    Emitter<FileScannerState> emit,
  ) async {
    add(const FileScannerStartScan());
  }

  Future<void> _onClearLibrary(
    FileScannerClearLibrary event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      await _fileScannerRepository.clearLibrary();

      emit(
        state.copyWith(
          folders: const [],
          libraryFiles: const [],
          status: FileScannerStatus.initial,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onImportFiles(
    FileScannerImportFiles event,
    Emitter<FileScannerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FileScannerStatus.scanning,
        scanProgress: ScanProgress.initial,
      ),
    );

    try {
      final importedFolders = <ScannedFolder>[];

      // Import individual files - group by parent folder
      if (event.files.isNotEmpty) {
        final filesByFolder = <String, List<String>>{};
        for (final filePath in event.files) {
          final parts = filePath.split(RegExp(r'[/\\]'));
          final folderPath =
              parts.length > 1
                  ? parts.sublist(0, parts.length - 1).join('/')
                  : '';
          filesByFolder.putIfAbsent(folderPath, () => []).add(filePath);
        }

        for (final entry in filesByFolder.entries) {
          // Process files in parallel batches for speed (batch of 10)
          final files = <AudioFile>[];
          const batchSize = 10;
          final filePaths = entry.value;

          for (var i = 0; i < filePaths.length; i += batchSize) {
            final batch = filePaths.skip(i).take(batchSize).toList();
            final results = await Future.wait(
              batch.map(_fileScannerRepository.extractMetadata),
            );
            files.addAll(results.whereType<AudioFile>());
          }

          if (files.isNotEmpty) {
            final folderName = entry.key.split(RegExp(r'[/\\]')).last;
            importedFolders.add(
              ScannedFolder(
                path: entry.key,
                name: folderName.isEmpty ? 'Imported Files' : folderName,
                files: files,
                isSelected: true,
              ),
            );
          }
        }
      }

      // Import folders in parallel for speed
      final folderResults = await Future.wait(
        event.folders.map((folderPath) async {
          final files = await _fileScannerRepository.scanFolder(folderPath);
          if (files.isNotEmpty) {
            final folderName = folderPath.split(RegExp(r'[/\\]')).last;
            return ScannedFolder(
              path: folderPath,
              name: folderName,
              files: files,
              isSelected: true,
            );
          }
          return null;
        }),
      );
      importedFolders.addAll(folderResults.whereType<ScannedFolder>());

      // Merge with existing folders
      final existingFolders = List<ScannedFolder>.from(state.folders);
      for (final imported in importedFolders) {
        final existingIndex = existingFolders.indexWhere(
          (f) => f.path == imported.path,
        );
        if (existingIndex >= 0) {
          // Merge files
          final existing = existingFolders[existingIndex];
          final mergedFiles = <AudioFile>[...existing.files];
          for (final file in imported.files) {
            if (!mergedFiles.any((f) => f.path == file.path)) {
              mergedFiles.add(file);
            }
          }
          existingFolders[existingIndex] = existing.copyWith(
            files: mergedFiles,
            isSelected: true,
          );
        } else {
          existingFolders.add(imported);
        }
      }

      emit(
        state.copyWith(
          status: FileScannerStatus.completed,
          folders: existingFolders,
          scanProgress: ScanProgress(
            filesFound: importedFolders.fold(0, (sum, f) => sum + f.fileCount),
            foldersScanned: importedFolders.length,
            currentFolder: '',
            isComplete: true,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCleanupOrphaned(
    FileScannerCleanupOrphaned event,
    Emitter<FileScannerState> emit,
  ) async {
    try {
      final removedCount =
          await _fileScannerRepository.cleanupOrphanedEntries();

      if (removedCount > 0) {
        // Reload library to reflect changes
        add(const FileScannerLoadLibrary());
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FileScannerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    return super.close();
  }
}
