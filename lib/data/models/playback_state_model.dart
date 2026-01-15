import 'package:drift/drift.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/domain/entities/playback_state.dart';

/// Playback state data model for database operations
class PlaybackStateModel {
  PlaybackStateModel({
    required this.audioFilePath,
    required this.positionMilliseconds,
    required this.savedAt,
    required this.volume,
    required this.playbackSpeed,
  });

  /// Converts from domain entity
  factory PlaybackStateModel.fromEntity(PlaybackState entity) =>
      PlaybackStateModel(
        audioFilePath: entity.audioFilePath,
        positionMilliseconds: entity.position.inMilliseconds,
        savedAt: entity.savedAt,
        volume: entity.volume,
        playbackSpeed: entity.playbackSpeed,
      );

  /// Creates from Drift database row
  factory PlaybackStateModel.fromDrift(PlaybackStatesTableData row) =>
      PlaybackStateModel(
        audioFilePath: row.audioFilePath,
        positionMilliseconds: row.positionMs,
        savedAt: row.savedAt,
        volume: row.volume,
        playbackSpeed: row.playbackSpeed,
      );

  /// Creates from JSON map
  factory PlaybackStateModel.fromJson(Map<String, dynamic> json) =>
      PlaybackStateModel(
        audioFilePath: json['audioFilePath'] as String,
        positionMilliseconds: json['positionMilliseconds'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
        volume: (json['volume'] as num).toDouble(),
        playbackSpeed: (json['playbackSpeed'] as num).toDouble(),
      );

  final String audioFilePath;
  final int positionMilliseconds;
  final DateTime savedAt;
  final double volume;
  final double playbackSpeed;

  /// Converts to domain entity
  PlaybackState toEntity() => PlaybackState(
    audioFilePath: audioFilePath,
    position: Duration(milliseconds: positionMilliseconds),
    savedAt: savedAt,
    volume: volume,
    playbackSpeed: playbackSpeed,
  );

  /// Converts to Drift companion for insert/update
  PlaybackStatesTableCompanion toCompanion() => PlaybackStatesTableCompanion(
    audioFilePath: Value(audioFilePath),
    positionMs: Value(positionMilliseconds),
    savedAt: Value(savedAt),
    volume: Value(volume),
    playbackSpeed: Value(playbackSpeed),
  );

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
    'audioFilePath': audioFilePath,
    'positionMilliseconds': positionMilliseconds,
    'savedAt': savedAt.toIso8601String(),
    'volume': volume,
    'playbackSpeed': playbackSpeed,
  };
}
