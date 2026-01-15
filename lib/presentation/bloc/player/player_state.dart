import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Status of the player
enum PlayerStatus { initial, loading, ready, playing, paused, stopped, error }

/// State for PlayerBloc
class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentAudio,
    this.position = Duration.zero,
    this.duration,
    this.volume = 1.0,
    this.speed = 1.0,
    this.isMuted = false,
    this.previousVolume = 1.0,
    this.errorMessage,
  });

  final PlayerStatus status;
  final AudioFile? currentAudio;
  final Duration position;
  final Duration? duration;
  final double volume;
  final double speed;
  final bool isMuted;
  final double previousVolume;
  final String? errorMessage;

  /// Whether audio is currently playing
  bool get isPlaying => status == PlayerStatus.playing;

  /// Whether audio is loaded and ready
  bool get isReady =>
      status == PlayerStatus.ready ||
      status == PlayerStatus.playing ||
      status == PlayerStatus.paused;

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (duration == null || duration!.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration!.inMilliseconds;
  }

  /// Remaining time
  Duration get remaining {
    if (duration == null) return Duration.zero;
    final diff = duration! - position;
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Effective volume (considering mute state)
  double get effectiveVolume => isMuted ? 0 : volume;

  PlayerState copyWith({
    PlayerStatus? status,
    AudioFile? currentAudio,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? isMuted,
    double? previousVolume,
    String? errorMessage,
  }) => PlayerState(
    status: status ?? this.status,
    currentAudio: currentAudio ?? this.currentAudio,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    volume: volume ?? this.volume,
    speed: speed ?? this.speed,
    isMuted: isMuted ?? this.isMuted,
    previousVolume: previousVolume ?? this.previousVolume,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    currentAudio,
    position,
    duration,
    volume,
    speed,
    isMuted,
    previousVolume,
    errorMessage,
  ];
}
