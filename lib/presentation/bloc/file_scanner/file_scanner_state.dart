import 'package:equatable/equatable.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';

/// Status of file scanning
enum FileScannerStatus { initial, loading, scanning, completed, error }

/// State for FileScannerBloc
class FileScannerState extends Equatable {
  const FileScannerState({
    this.status = FileScannerStatus.initial,
    this.folders = const [],
    this.libraryFiles = const [],
    this.scanProgress,
    this.errorMessage,
  });

  final FileScannerStatus status;
  final List<ScannedFolder> folders;
  final List<AudioFile> libraryFiles;
  final ScanProgress? scanProgress;
  final String? errorMessage;

  /// Whether a scan is in progress
  bool get isScanning => status == FileScannerStatus.scanning;

  /// Whether loading from database
  bool get isLoading => status == FileScannerStatus.loading;

  /// Total number of files found across all folders
  int get totalFilesFound =>
      folders.fold(0, (sum, folder) => sum + folder.fileCount);

  /// Number of selected folders
  int get selectedFolderCount => folders.where((f) => f.isSelected).length;

  /// Selected folders
  List<ScannedFolder> get selectedFolders =>
      folders.where((f) => f.isSelected).toList();

  /// Total files in selected folders
  int get selectedFilesCount =>
      selectedFolders.fold(0, (sum, folder) => sum + folder.fileCount);

  /// Library rows preferred; folder scan/import files fill gaps by path.
  /// This prevents newly imported files from disappearing while libraryFiles
  /// is still non-empty from a previous load.
  List<AudioFile> get allFiles {
    final byPath = <String, AudioFile>{};
    for (final file in libraryFiles) {
      byPath[AudioPathUtils.canonicalize(file.path)] = file;
    }
    for (final file in folders.expand((folder) => folder.files)) {
      byPath.putIfAbsent(AudioPathUtils.canonicalize(file.path), () => file);
    }
    return byPath.values.toList(growable: false);
  }

  FileScannerState copyWith({
    FileScannerStatus? status,
    List<ScannedFolder>? folders,
    List<AudioFile>? libraryFiles,
    ScanProgress? scanProgress,
    String? errorMessage,
  }) => FileScannerState(
    status: status ?? this.status,
    folders: folders ?? this.folders,
    libraryFiles: libraryFiles ?? this.libraryFiles,
    scanProgress: scanProgress ?? this.scanProgress,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    folders,
    libraryFiles,
    scanProgress,
    errorMessage,
  ];
}
