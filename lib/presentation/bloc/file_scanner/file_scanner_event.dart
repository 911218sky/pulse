import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';

/// Events for FileScannerBloc
sealed class FileScannerEvent extends Equatable {
  const FileScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning for music files
class FileScannerStartScan extends FileScannerEvent {
  const FileScannerStartScan();
}

/// Cancel ongoing scan
class FileScannerCancelScan extends FileScannerEvent {
  const FileScannerCancelScan();
}

/// Update scan progress (internal event)
class FileScannerProgressUpdated extends FileScannerEvent {
  const FileScannerProgressUpdated(this.progress);

  final ScanProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// Toggle folder selection
class FileScannerToggleFolder extends FileScannerEvent {
  const FileScannerToggleFolder(this.folderPath);

  final String folderPath;

  @override
  List<Object?> get props => [folderPath];
}

/// Select all folders
class FileScannerSelectAll extends FileScannerEvent {
  const FileScannerSelectAll();
}

/// Deselect all folders
class FileScannerDeselectAll extends FileScannerEvent {
  const FileScannerDeselectAll();
}

/// Save selected folders
class FileScannerSaveSelection extends FileScannerEvent {
  const FileScannerSaveSelection();
}

/// Load saved folder preferences
class FileScannerLoadPreferences extends FileScannerEvent {
  const FileScannerLoadPreferences();
}

/// Refresh scanned folders
class FileScannerRefresh extends FileScannerEvent {
  const FileScannerRefresh();
}

/// Import files and folders manually
class FileScannerImportFiles extends FileScannerEvent {
  const FileScannerImportFiles({
    this.files = const [],
    this.folders = const [],
  });

  final List<String> files;
  final List<String> folders;

  @override
  List<Object?> get props => [files, folders];
}

/// Load music library from database
class FileScannerLoadLibrary extends FileScannerEvent {
  const FileScannerLoadLibrary();
}

/// Delete a single file from library
class FileScannerDeleteFile extends FileScannerEvent {
  const FileScannerDeleteFile(
    this.fileId, {
    this.filePath,
    this.deleteFromDisk = false,
  });

  final String fileId;
  final String? filePath;
  final bool deleteFromDisk;

  @override
  List<Object?> get props => [fileId, filePath, deleteFromDisk];
}

/// Delete multiple files from library
class FileScannerDeleteFiles extends FileScannerEvent {
  const FileScannerDeleteFiles(this.fileIds);

  final List<String> fileIds;

  @override
  List<Object?> get props => [fileIds];
}

/// Clear entire music library
class FileScannerClearLibrary extends FileScannerEvent {
  const FileScannerClearLibrary();
}

/// Clean up orphaned database entries (files that no longer exist on disk)
class FileScannerCleanupOrphaned extends FileScannerEvent {
  const FileScannerCleanupOrphaned();
}
