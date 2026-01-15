import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Represents a folder discovered during music scanning
class ScannedFolder extends Equatable {
  const ScannedFolder({
    required this.path,
    required this.name,
    required this.files,
    this.isSelected = false,
  });

  final String path;
  final String name;
  final List<AudioFile> files;
  final bool isSelected;

  /// Returns the number of audio files in this folder
  int get fileCount => files.length;

  /// Returns total size of all files in bytes
  int get totalSizeBytes => files.fold(0, (sum, f) => sum + f.fileSizeBytes);

  /// Returns total duration of all files
  Duration get totalDuration =>
      files.fold(Duration.zero, (sum, f) => sum + f.duration);

  /// Creates a copy with updated fields
  ScannedFolder copyWith({
    String? path,
    String? name,
    List<AudioFile>? files,
    bool? isSelected,
  }) => ScannedFolder(
    path: path ?? this.path,
    name: name ?? this.name,
    files: files ?? this.files,
    isSelected: isSelected ?? this.isSelected,
  );

  /// Toggles the selection state
  ScannedFolder toggleSelection() => copyWith(isSelected: !isSelected);

  @override
  List<Object?> get props => [path, name, files, isSelected];
}

/// Represents the progress of a folder scan operation
class ScanProgress extends Equatable {
  const ScanProgress({
    required this.filesFound,
    required this.foldersScanned,
    required this.currentFolder,
    this.isComplete = false,
  });

  final int filesFound;
  final int foldersScanned;
  final String currentFolder;
  final bool isComplete;

  /// Initial scan progress
  static const ScanProgress initial = ScanProgress(
    filesFound: 0,
    foldersScanned: 0,
    currentFolder: '',
  );

  /// Creates a copy with updated fields
  ScanProgress copyWith({
    int? filesFound,
    int? foldersScanned,
    String? currentFolder,
    bool? isComplete,
  }) => ScanProgress(
    filesFound: filesFound ?? this.filesFound,
    foldersScanned: foldersScanned ?? this.foldersScanned,
    currentFolder: currentFolder ?? this.currentFolder,
    isComplete: isComplete ?? this.isComplete,
  );

  @override
  List<Object?> get props => [
    filesFound,
    foldersScanned,
    currentFolder,
    isComplete,
  ];
}
