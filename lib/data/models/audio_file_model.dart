import 'package:drift/drift.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Audio file data model for database operations
class AudioFileModel {
  AudioFileModel({
    required this.id,
    required this.path,
    required this.title,
    required this.durationMilliseconds,
    required this.fileSizeBytes,
    this.artist,
    this.album,
    this.addedAt,
    this.artworkPath,
  });

  /// Converts from domain entity
  factory AudioFileModel.fromEntity(AudioFile entity) => AudioFileModel(
    id: entity.id,
    path: entity.path,
    title: entity.title,
    artist: entity.artist,
    album: entity.album,
    durationMilliseconds: entity.duration.inMilliseconds,
    fileSizeBytes: entity.fileSizeBytes,
    addedAt: entity.addedAt,
    artworkPath: entity.artworkPath,
  );

  /// Creates from Drift database row
  factory AudioFileModel.fromDrift(AudioFilesTableData row) => AudioFileModel(
    id: row.id,
    path: row.filePath,
    title: row.title,
    artist: row.artist,
    album: row.album,
    durationMilliseconds: row.durationMs,
    fileSizeBytes: row.fileSize,
    addedAt: row.addedAt,
    artworkPath: row.artworkPath,
  );

  /// Creates from JSON map
  factory AudioFileModel.fromJson(Map<String, dynamic> json) => AudioFileModel(
    id: json['id'] as String,
    path: json['path'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String?,
    album: json['album'] as String?,
    durationMilliseconds: json['durationMilliseconds'] as int,
    fileSizeBytes: json['fileSizeBytes'] as int,
    addedAt:
        json['addedAt'] != null
            ? DateTime.parse(json['addedAt'] as String)
            : null,
    artworkPath: json['artworkPath'] as String?,
  );

  final String id;
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final int durationMilliseconds;
  final int fileSizeBytes;
  final DateTime? addedAt;
  final String? artworkPath;

  /// Converts to domain entity
  AudioFile toEntity() => AudioFile(
    id: id,
    path: path,
    title: title,
    artist: artist,
    album: album,
    duration: Duration(milliseconds: durationMilliseconds),
    fileSizeBytes: fileSizeBytes,
    addedAt: addedAt,
    artworkPath: artworkPath,
  );

  /// Converts to Drift companion for insert/update
  AudioFilesTableCompanion toCompanion() => AudioFilesTableCompanion(
    id: Value(id),
    filePath: Value(path),
    title: Value(title),
    artist: Value(artist),
    album: Value(album),
    durationMs: Value(durationMilliseconds),
    fileSize: Value(fileSizeBytes),
    addedAt: Value(addedAt),
    artworkPath: Value(artworkPath),
  );

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'title': title,
    'artist': artist,
    'album': album,
    'durationMilliseconds': durationMilliseconds,
    'fileSizeBytes': fileSizeBytes,
    'addedAt': addedAt?.toIso8601String(),
    'artworkPath': artworkPath,
  };
}
