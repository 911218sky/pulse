import 'package:equatable/equatable.dart';

/// Represents an audio file with its metadata
class AudioFile extends Equatable {
  const AudioFile({
    required this.id,
    required this.path,
    required this.title,
    required this.duration,
    required this.fileSizeBytes,
    this.artist,
    this.album,
    this.addedAt,
    this.artworkPath,
  });

  final String id;
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final Duration duration;
  final int fileSizeBytes;
  final DateTime? addedAt;
  final String? artworkPath;

  /// Creates a copy with updated fields
  AudioFile copyWith({
    String? id,
    String? path,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    int? fileSizeBytes,
    DateTime? addedAt,
    String? artworkPath,
  }) => AudioFile(
    id: id ?? this.id,
    path: path ?? this.path,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    duration: duration ?? this.duration,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    addedAt: addedAt ?? this.addedAt,
    artworkPath: artworkPath ?? this.artworkPath,
  );

  /// Returns file size in human readable format
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Returns display name (title or filename)
  String get displayName => title.isNotEmpty ? title : path.split('/').last;

  /// Alias for displayName for convenience
  String get displayTitle => displayName;

  @override
  List<Object?> get props => [
    id,
    path,
    title,
    artist,
    album,
    duration,
    fileSizeBytes,
    addedAt,
    artworkPath,
  ];
}
