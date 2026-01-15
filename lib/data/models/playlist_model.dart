import 'package:drift/drift.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/models/audio_file_model.dart';
import 'package:pulse/domain/entities/playlist.dart';

/// Playlist data model for database operations
class PlaylistModel {
  PlaylistModel({
    required this.id,
    required this.name,
    required this.files,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts from domain entity
  factory PlaylistModel.fromEntity(Playlist entity) => PlaylistModel(
    id: entity.id,
    name: entity.name,
    files: entity.files.map(AudioFileModel.fromEntity).toList(),
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  /// Creates from Drift database row (without files - load separately)
  factory PlaylistModel.fromDrift(
    PlaylistsTableData row, [
    List<AudioFileModel>? files,
  ]) => PlaylistModel(
    id: row.id,
    name: row.name,
    files: files ?? [],
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  /// Creates from JSON map
  factory PlaylistModel.fromJson(Map<String, dynamic> json) => PlaylistModel(
    id: json['id'] as String,
    name: json['name'] as String,
    files:
        (json['files'] as List<dynamic>)
            .map((f) => AudioFileModel.fromJson(f as Map<String, dynamic>))
            .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  final String id;
  final String name;
  final List<AudioFileModel> files;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Converts to domain entity
  Playlist toEntity() => Playlist(
    id: id,
    name: name,
    files: files.map((f) => f.toEntity()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Converts to Drift companion for insert/update (without files)
  PlaylistsTableCompanion toCompanion() => PlaylistsTableCompanion(
    id: Value(id),
    name: Value(name),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'files': files.map((f) => f.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create a copy with updated fields
  PlaylistModel copyWith({
    String? id,
    String? name,
    List<AudioFileModel>? files,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlaylistModel(
    id: id ?? this.id,
    name: name ?? this.name,
    files: files ?? this.files,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
