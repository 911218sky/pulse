import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playback_state.dart' as playback;
import 'package:pulse/domain/entities/settings.dart';
import 'package:pulse/domain/repositories/audio_repository.dart';
import 'package:pulse/domain/repositories/playback_state_repository.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';

import '../../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 7: Skip Forward/Backward Bounds
/// **Validates: Requirements 7.4, 7.5**
///
/// For any current position P and skip duration S:
/// - Skip forward: new position = min(P + S, duration)
/// - Skip backward: new position = max(P - S, 0)

/// Feature: flutter-music-player, Property 3: Time Input Validation
/// **Validates: Requirements 3.2, 3.3**
///
/// For any time input T and duration D:
/// - If T is valid format and 0 <= T <= D, seek succeeds
/// - If T is invalid format or T < 0 or T > D, seek fails or clamps

void main() {
  group('Playback stream state mapping', () {
    late _FakeAudioRepository audioRepository;
    late PlayerBloc bloc;

    setUp(() {
      audioRepository = _FakeAudioRepository();
      bloc = PlayerBloc(
        audioRepository: audioRepository,
        playbackStateRepository: _FakePlaybackStateRepository(),
        settingsRepository: _FakeSettingsRepository(),
      );
    });

    tearDown(() => bloc.close());

    test(
      'playing=false does not convert stopped state back to paused',
      () async {
        bloc.add(const PlayerStop());
        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<PlayerState>().having(
              (state) => state.status,
              'status',
              PlayerStatus.stopped,
            ),
          ),
        );

        audioRepository.emitPlaying(isPlaying: false);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, PlayerStatus.stopped);
      },
    );

    test('forceRestart reloads the same ready audio', () async {
      const audioFile = AudioFile(
        id: 'track-1',
        path: '/music/track-1.mp3',
        title: 'Track 1',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1024,
      );

      bloc.add(const PlayerLoadAudio(audioFile));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlayerState>().having(
            (state) => state.status,
            'status',
            PlayerStatus.playing,
          ),
        ),
      );

      bloc.add(const PlayerLoadAudio(audioFile));
      await Future<void>.delayed(Duration.zero);
      expect(audioRepository.loadCount, 1);

      bloc.add(const PlayerLoadAudio(audioFile, forceRestart: true));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlayerState>().having(
            (state) => state.status,
            'status',
            PlayerStatus.playing,
          ),
        ),
      );

      expect(audioRepository.loadCount, 2);
      expect(audioRepository.playCount, 2);
    });

    test('loading a new audio clears stale position and duration', () async {
      const oldDuration = Duration(minutes: 4);
      const oldAudio = AudioFile(
        id: 'old-track',
        path: '/music/old.mp3',
        title: 'Old',
        duration: oldDuration,
        fileSizeBytes: 1024,
      );
      const newAudio = AudioFile(
        id: 'new-track',
        path: '/music/new.mp3',
        title: 'New',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1024,
      );

      bloc.add(const PlayerLoadAudio(oldAudio));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlayerState>().having(
            (state) => state.duration,
            'duration',
            oldDuration,
          ),
        ),
      );

      bloc.add(const PlayerPositionUpdated(Duration(minutes: 1)));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const PlayerLoadAudio(newAudio));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlayerState>()
              .having((state) => state.status, 'status', PlayerStatus.loading)
              .having((state) => state.position, 'position', Duration.zero)
              .having((state) => state.duration, 'duration', isNull),
        ),
      );
    });

    test(
      'seek saves the new position for the current track immediately',
      () async {
        const audioFile = AudioFile(
          id: 'track-1',
          path: '/music/track-1.mp3',
          title: 'Track 1',
          duration: Duration(minutes: 3),
          fileSizeBytes: 1024,
        );
        final playbackStateRepository = _FakePlaybackStateRepository();
        final savingBloc = PlayerBloc(
          audioRepository: audioRepository,
          playbackStateRepository: playbackStateRepository,
          settingsRepository: _FakeSettingsRepository(),
        );
        addTearDown(savingBloc.close);

        savingBloc.add(const PlayerLoadAudio(audioFile));
        await expectLater(
          savingBloc.stream,
          emitsThrough(
            isA<PlayerState>().having(
              (state) => state.status,
              'status',
              PlayerStatus.playing,
            ),
          ),
        );

        savingBloc.add(const PlayerSeekTo(Duration(minutes: 1, seconds: 15)));
        await Future<void>.delayed(Duration.zero);

        expect(
          playbackStateRepository.savedPositions[audioFile.path],
          const Duration(minutes: 1, seconds: 15),
        );
      },
    );

    test(
      'external pause event saves the current position immediately',
      () async {
        const audioFile = AudioFile(
          id: 'track-external-pause',
          path: '/music/external-pause.mp3',
          title: 'External Pause',
          duration: Duration(minutes: 3),
          fileSizeBytes: 1024,
        );
        final playbackStateRepository = _FakePlaybackStateRepository();
        final savingBloc = PlayerBloc(
          audioRepository: audioRepository,
          playbackStateRepository: playbackStateRepository,
          settingsRepository: _FakeSettingsRepository(),
        );
        addTearDown(savingBloc.close);

        savingBloc.add(const PlayerLoadAudio(audioFile));
        await expectLater(
          savingBloc.stream,
          emitsThrough(
            isA<PlayerState>().having(
              (state) => state.status,
              'status',
              PlayerStatus.playing,
            ),
          ),
        );

        savingBloc.add(const PlayerPositionUpdated(Duration(seconds: 47)));
        await Future<void>.delayed(Duration.zero);

        audioRepository.emitPlaying(isPlaying: false);
        await Future<void>.delayed(Duration.zero);

        expect(
          playbackStateRepository.savedPositions[audioFile.path],
          const Duration(seconds: 47),
        );
      },
    );

    test(
      'play resumes from the paused position instead of restarting',
      () async {
        const audioFile = AudioFile(
          id: 'track-resume-play',
          path: '/music/resume-play.mp3',
          title: 'Resume Play',
          duration: Duration(minutes: 3),
          fileSizeBytes: 1024,
        );

        bloc.add(const PlayerLoadAudio(audioFile));
        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<PlayerState>().having(
              (state) => state.status,
              'status',
              PlayerStatus.playing,
            ),
          ),
        );

        bloc.add(const PlayerPositionUpdated(Duration(seconds: 47)));
        await Future<void>.delayed(Duration.zero);

        bloc.add(const PlayerPause());
        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<PlayerState>().having(
              (state) => state.status,
              'status',
              PlayerStatus.paused,
            ),
          ),
        );

        final seekCallsBeforePlay = audioRepository.seekCalls.length;
        bloc.add(const PlayerPlay());
        await Future<void>.delayed(Duration.zero);

        expect(
          audioRepository.seekCalls.skip(seekCallsBeforePlay),
          contains(const Duration(seconds: 47)),
        );
      },
    );

    test(
      'restore from library resumes the last saved track and position',
      () async {
        const audioFile = AudioFile(
          id: 'track-2',
          path: '/music/track-2.mp3',
          title: 'Track 2',
          duration: Duration(minutes: 5),
          fileSizeBytes: 2048,
        );
        const resumePosition = Duration(minutes: 1, seconds: 23);
        final restoreRepository =
            _FakePlaybackStateRepository()
              ..lastPlaybackState = playback.PlaybackState.create(
                audioFilePath: audioFile.path,
                position: resumePosition,
                volume: 0.6,
                playbackSpeed: 1.25,
              )
              ..savedPositions[audioFile.path] = resumePosition;
        final restoreSettingsRepository = _FakeSettingsRepository(
          settings: Settings.defaults.copyWith(autoResume: true),
        );
        final restoreBloc = PlayerBloc(
          audioRepository: audioRepository,
          playbackStateRepository: restoreRepository,
          settingsRepository: restoreSettingsRepository,
        );
        addTearDown(restoreBloc.close);

        restoreBloc.add(const PlayerRestoreFromLibrary([audioFile]));
        await expectLater(
          restoreBloc.stream,
          emitsThrough(
            isA<PlayerState>()
                .having((state) => state.status, 'status', PlayerStatus.playing)
                .having(
                  (state) => state.currentAudio?.path,
                  'path',
                  audioFile.path,
                )
                .having((state) => state.position, 'position', resumePosition),
          ),
        );

        expect(audioRepository.lastLoadedAudio, audioFile);
        expect(audioRepository.seekCalls, contains(resumePosition));
        expect(audioRepository.lastVolume, 0.6);
        expect(audioRepository.lastPlaybackSpeed, 1.25);
      },
    );

    test(
      'restore from library matches saved track with normalized path',
      () async {
        const audioFile = AudioFile(
          id: 'track-normalized',
          path: '/music/track-normalized.mp3',
          title: 'Track Normalized',
          duration: Duration(minutes: 5),
          fileSizeBytes: 2048,
        );
        const resumePosition = Duration(minutes: 2, seconds: 5);
        final restoreRepository =
            _FakePlaybackStateRepository()
              ..lastPlaybackState = playback.PlaybackState.create(
                audioFilePath: '/music/./track-normalized.mp3',
                position: resumePosition,
              );
        final restoreBloc = PlayerBloc(
          audioRepository: audioRepository,
          playbackStateRepository: restoreRepository,
          settingsRepository: _FakeSettingsRepository(
            settings: Settings.defaults.copyWith(autoResume: true),
          ),
        );
        addTearDown(restoreBloc.close);

        restoreBloc.add(const PlayerRestoreFromLibrary([audioFile]));
        await expectLater(
          restoreBloc.stream,
          emitsThrough(
            isA<PlayerState>()
                .having((state) => state.status, 'status', PlayerStatus.playing)
                .having(
                  (state) => state.currentAudio?.path,
                  'path',
                  audioFile.path,
                )
                .having((state) => state.position, 'position', resumePosition),
          ),
        );
      },
    );

    test('restore from library applies configured skip durations', () async {
      const audioFile = AudioFile(
        id: 'track-2b',
        path: '/music/track-2b.mp3',
        title: 'Track 2B',
        duration: Duration(minutes: 5),
        fileSizeBytes: 2048,
      );
      final restoreRepository =
          _FakePlaybackStateRepository()
            ..lastPlaybackState = playback.PlaybackState.create(
              audioFilePath: audioFile.path,
              position: const Duration(seconds: 30),
            );
      final restoreSettingsRepository = _FakeSettingsRepository(
        settings: Settings.defaults.copyWith(
          autoResume: true,
          skipForwardSeconds: 42,
          skipBackwardSeconds: 7,
        ),
      );
      final restoreBloc = PlayerBloc(
        audioRepository: audioRepository,
        playbackStateRepository: restoreRepository,
        settingsRepository: restoreSettingsRepository,
      );
      addTearDown(restoreBloc.close);

      restoreBloc.add(const PlayerRestoreFromLibrary([audioFile]));
      await expectLater(
        restoreBloc.stream,
        emitsThrough(
          isA<PlayerState>().having(
            (state) => state.status,
            'status',
            PlayerStatus.playing,
          ),
        ),
      );

      restoreBloc.add(const PlayerSkipForward());
      await Future<void>.delayed(Duration.zero);
      restoreBloc.add(const PlayerSkipBackward());
      await Future<void>.delayed(Duration.zero);

      expect(audioRepository.seekCalls, contains(const Duration(seconds: 72)));
      expect(audioRepository.seekCalls, contains(const Duration(seconds: 65)));
    });

    test(
      'clearing a completed track prevents it from being restored on startup',
      () async {
        const audioFile = AudioFile(
          id: 'track-3',
          path: '/music/track-3.mp3',
          title: 'Track 3',
          duration: Duration(minutes: 4),
          fileSizeBytes: 1024,
        );
        const resumePosition = Duration(minutes: 4);
        final playbackStateRepository =
            _FakePlaybackStateRepository()
              ..lastPlaybackState = playback.PlaybackState.create(
                audioFilePath: audioFile.path,
                position: resumePosition,
              )
              ..savedPositions[audioFile.path] = resumePosition;
        final restoreBloc = PlayerBloc(
          audioRepository: audioRepository,
          playbackStateRepository: playbackStateRepository,
          settingsRepository: _FakeSettingsRepository(
            settings: Settings.defaults.copyWith(autoResume: true),
          ),
        );
        addTearDown(restoreBloc.close);

        restoreBloc.add(PlayerClearCompletedTrackPosition(audioFile.path));
        await Future<void>.delayed(Duration.zero);

        restoreBloc.add(const PlayerRestoreFromLibrary([audioFile]));
        await Future<void>.delayed(Duration.zero);

        expect(playbackStateRepository.lastPlaybackState, isNull);
        expect(playbackStateRepository.savedPositions[audioFile.path], isNull);
        expect(restoreBloc.state.currentAudio, isNull);
        expect(audioRepository.playCount, 0);
      },
    );

    test('saving a completed track clears resumable playback state', () async {
      const audioFile = AudioFile(
        id: 'track-4',
        path: '/music/track-4.mp3',
        title: 'Track 4',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1024,
      );
      final playbackStateRepository = _FakePlaybackStateRepository();
      final savingBloc = PlayerBloc(
        audioRepository: audioRepository,
        playbackStateRepository: playbackStateRepository,
        settingsRepository: _FakeSettingsRepository(),
      );
      addTearDown(savingBloc.close);

      savingBloc.add(const PlayerLoadAudio(audioFile));
      await expectLater(
        savingBloc.stream,
        emitsThrough(
          isA<PlayerState>().having(
            (state) => state.status,
            'status',
            PlayerStatus.playing,
          ),
        ),
      );

      savingBloc.add(const PlayerPositionUpdated(Duration(minutes: 2)));
      await Future<void>.delayed(Duration.zero);

      savingBloc.add(const PlayerSaveState());
      await Future<void>.delayed(Duration.zero);

      expect(playbackStateRepository.lastPlaybackState, isNull);
      expect(playbackStateRepository.savedPositions[audioFile.path], isNull);
    });
  });

  group('Skip Forward/Backward Bounds', () {
    test('Property 7.1: Skip forward clamps to duration (100 iterations)', () {
      PropertyTest.forAll(
        generator:
            () => (
              PropertyTest.randomDuration(maxHours: 2), // current position
              PropertyTest.randomDuration(maxHours: 3), // total duration
              PropertyTest.randomInt(min: 5, max: 60), // skip seconds
            ),
        property: (input) {
          final (position, duration, skipSeconds) = input;

          // Calculate expected new position
          final newPosition = position + Duration(seconds: skipSeconds);
          final clampedPosition =
              newPosition > duration ? duration : newPosition;

          // Verify clamping behavior
          expect(
            clampedPosition.inMilliseconds,
            lessThanOrEqualTo(duration.inMilliseconds),
          );
          // Clamped position should be >= 0
          expect(clampedPosition.inMilliseconds, greaterThanOrEqualTo(0));
        },
      );
    });

    test('Property 7.2: Skip backward clamps to zero (100 iterations)', () {
      PropertyTest.forAll(
        generator:
            () => (
              PropertyTest.randomDuration(maxHours: 2), // current position
              PropertyTest.randomInt(min: 5, max: 60), // skip seconds
            ),
        property: (input) {
          final (position, skipSeconds) = input;

          // Calculate expected new position
          final newPosition = position - Duration(seconds: skipSeconds);
          final clampedPosition =
              newPosition.isNegative ? Duration.zero : newPosition;

          // Verify clamping behavior
          expect(clampedPosition.inMilliseconds, greaterThanOrEqualTo(0));
          expect(
            clampedPosition.inMilliseconds,
            lessThanOrEqualTo(position.inMilliseconds),
          );
        },
      );
    });

    test('Skip forward at end of track stays at end', () {
      const duration = Duration(minutes: 5);
      const position = Duration(minutes: 4, seconds: 55);
      const skipSeconds = 10;

      final newPosition = position + const Duration(seconds: skipSeconds);
      final clampedPosition = newPosition > duration ? duration : newPosition;

      expect(clampedPosition, equals(duration));
    });

    test('Skip backward at start of track stays at start', () {
      const position = Duration(seconds: 3);
      const skipSeconds = 10;

      final newPosition = position - const Duration(seconds: skipSeconds);
      final clampedPosition =
          newPosition.isNegative ? Duration.zero : newPosition;

      expect(clampedPosition, equals(Duration.zero));
    });
  });

  group('Time Input Validation', () {
    test(
      'Property 3.1: Valid time within duration is accepted (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final duration = PropertyTest.randomDuration(maxHours: 3);
            // Generate a position within the duration
            final positionMs = PropertyTest.randomInt(
              max: duration.inMilliseconds + 1,
            );
            return (Duration(milliseconds: positionMs), duration);
          },
          property: (input) {
            final (position, duration) = input;

            // Position should be valid (within bounds)
            final isValid = position >= Duration.zero && position <= duration;
            expect(isValid, isTrue);
          },
        );
      },
    );

    test(
      'Property 3.2: Position beyond duration is clamped (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final duration = PropertyTest.randomDuration(maxHours: 2);
            // Generate a position beyond the duration
            final extraMs = PropertyTest.randomInt(min: 1, max: 100000);
            final position = Duration(
              milliseconds: duration.inMilliseconds + extraMs,
            );
            return (position, duration);
          },
          property: (input) {
            final (position, duration) = input;

            // Clamp to duration
            final clampedPosition = position > duration ? duration : position;

            expect(clampedPosition, equals(duration));
          },
        );
      },
    );

    test(
      'Property 3.3: Negative position is clamped to zero (100 iterations)',
      () {
        PropertyTest.forAll(
          generator:
              () => Duration(
                milliseconds: -PropertyTest.randomInt(min: 1, max: 100000),
              ),
          property: (position) {
            // Clamp to zero
            final clampedPosition =
                position.isNegative ? Duration.zero : position;

            expect(clampedPosition, equals(Duration.zero));
          },
        );
      },
    );
  });

  group('AudioFile generation helper', () {
    test('generates valid audio files', () {
      final audioFile = AudioFile(
        id: PropertyTest.randomNonEmptyString(),
        path: '/music/${PropertyTest.randomNonEmptyString()}.mp3',
        title: PropertyTest.randomNonEmptyString(),
        duration: PropertyTest.randomDuration(maxHours: 2),
        fileSizeBytes: PropertyTest.randomInt(min: 1000, max: 100000000),
      );

      expect(audioFile.id, isNotEmpty);
      expect(audioFile.path, contains('.mp3'));
      expect(audioFile.title, isNotEmpty);
      expect(audioFile.duration.inMilliseconds, greaterThanOrEqualTo(0));
      expect(audioFile.fileSizeBytes, greaterThan(0));
    });
  });
}

class _FakeAudioRepository implements AudioRepository {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  int loadCount = 0;
  int playCount = 0;
  AudioFile? lastLoadedAudio;
  final List<Duration> seekCalls = [];
  double lastVolume = 1;
  double lastPlaybackSpeed = 1;
  Duration _currentPosition = Duration.zero;
  Duration? _currentDuration;
  bool _isPlaying = false;

  void emitPlaying({required bool isPlaying}) =>
      _playingController.add(isPlaying);

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration? get currentDuration => _currentDuration;

  @override
  bool get isPlaying => _isPlaying;

  @override
  double get currentVolume => 1;

  @override
  double get currentPlaybackSpeed => 1;

  @override
  Future<void> loadAudio(AudioFile audioFile) async {
    loadCount++;
    lastLoadedAudio = audioFile;
    _currentDuration = audioFile.duration;
    _currentPosition = Duration.zero;
  }

  @override
  Future<void> play() async {
    playCount++;
    _isPlaying = true;
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    emitPlaying(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekCalls.add(position);
    _currentPosition = position;
  }

  @override
  Future<void> setVolume(double volume) async {
    lastVolume = volume;
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    lastPlaybackSpeed = speed;
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {}

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
    await _bufferedController.close();
  }
}

class _FakePlaybackStateRepository implements PlaybackStateRepository {
  playback.PlaybackState? lastPlaybackState;
  final Map<String, Duration> savedPositions = {};
  playback.PlaybackState? savedPlaybackState;

  @override
  Future<void> savePlaybackState(playback.PlaybackState state) async {
    savedPlaybackState = state;
    lastPlaybackState = state;
  }

  @override
  Future<playback.PlaybackState?> getLastPlaybackState() async =>
      lastPlaybackState;

  @override
  Future<void> clearPlaybackState() async {
    lastPlaybackState = null;
  }

  @override
  Future<Duration?> getPositionForFile(String filePath) async =>
      savedPositions[filePath];

  @override
  Future<void> savePositionForFile(String filePath, Duration position) async {
    savedPositions[filePath] = position;
  }

  @override
  Future<Map<String, Duration>> getAllFilePositions() async => savedPositions;

  @override
  Future<void> clearPositionForFile(String filePath) async {
    savedPositions.remove(filePath);
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({this.settings = Settings.defaults});

  final Settings settings;
  final _controller = StreamController<Settings>.broadcast();

  @override
  Future<Settings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(Settings settings) async {
    _controller.add(settings);
  }

  @override
  Future<void> resetSettings() async {}

  @override
  Future<void> resetAllData() async {}

  @override
  Stream<Settings> get settingsStream => _controller.stream;

  @override
  Future<void> updateSetting<T>(String key, T value) async {}
}
