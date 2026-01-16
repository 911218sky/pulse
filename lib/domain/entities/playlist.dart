import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Represents a playlist containing multiple audio files
class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.files,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an empty playlist with the given name
  factory Playlist.create({required String id, required String name}) {
    final now = DateTime.now();
    return Playlist(
      id: id,
      name: name,
      files: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  final String id;
  final String name;
  final List<AudioFile> files;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a copy with updated fields
  Playlist copyWith({
    String? id,
    String? name,
    List<AudioFile>? files,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    files: files ?? this.files,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  /// Adds a file to the playlist (prevents duplicates by path)
  Playlist addFile(AudioFile file) {
    // Check if file already exists by path
    if (files.any((f) => f.path == file.path)) {
      return this; // Return unchanged if duplicate
    }
    return copyWith(files: [...files, file]);
  }

  /// Adds multiple files to the playlist (filters out duplicates by path)
  Playlist addFiles(List<AudioFile> newFiles) {
    final existingPaths = files.map((f) => f.path).toSet();
    final uniqueNewFiles =
        newFiles.where((f) => !existingPaths.contains(f.path)).toList();
    if (uniqueNewFiles.isEmpty) {
      return this; // Return unchanged if all are duplicates
    }
    return copyWith(files: [...files, ...uniqueNewFiles]);
  }

  /// Checks if a file with the given path already exists in the playlist
  bool containsPath(String path) => files.any((f) => f.path == path);

  /// Removes a file from the playlist by ID
  Playlist removeFile(String fileId) =>
      copyWith(files: files.where((f) => f.id != fileId).toList());

  /// Reorders files in the playlist
  Playlist reorder(int oldIndex, int newIndex) {
    final newFiles = List<AudioFile>.from(files);
    final item = newFiles.removeAt(oldIndex);
    newFiles.insert(newIndex, item);
    return copyWith(files: newFiles);
  }

  /// Returns total duration of all files
  Duration get totalDuration =>
      files.fold(Duration.zero, (total, file) => total + file.duration);

  /// Returns total file count
  int get fileCount => files.length;

  /// Returns true if playlist is empty
  bool get isEmpty => files.isEmpty;

  /// Returns true if playlist is not empty
  bool get isNotEmpty => files.isNotEmpty;

  @override
  List<Object?> get props => [id, name, files, createdAt, updatedAt];
}
