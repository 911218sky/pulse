import 'package:equatable/equatable.dart';

/// Represents the saved playback state for resuming playback
class PlaybackState extends Equatable {
  const PlaybackState({
    required this.audioFilePath,
    required this.position,
    required this.savedAt,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
  });

  /// Creates a new playback state with current timestamp
  factory PlaybackState.create({
    required String audioFilePath,
    required Duration position,
    double volume = 1.0,
    double playbackSpeed = 1.0,
  }) => PlaybackState(
    audioFilePath: audioFilePath,
    position: position,
    savedAt: DateTime.now(),
    volume: volume,
    playbackSpeed: playbackSpeed,
  );

  final String audioFilePath;
  final Duration position;
  final DateTime savedAt;
  final double volume;
  final double playbackSpeed;

  /// Creates a copy with updated fields
  PlaybackState copyWith({
    String? audioFilePath,
    Duration? position,
    DateTime? savedAt,
    double? volume,
    double? playbackSpeed,
  }) => PlaybackState(
    audioFilePath: audioFilePath ?? this.audioFilePath,
    position: position ?? this.position,
    savedAt: savedAt ?? this.savedAt,
    volume: volume ?? this.volume,
    playbackSpeed: playbackSpeed ?? this.playbackSpeed,
  );

  @override
  List<Object?> get props => [
    audioFilePath,
    position,
    savedAt,
    volume,
    playbackSpeed,
  ];
}
