import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/data/services/audio_handler.dart';

class _MockPlayer extends Mock implements Player {}

class _FakePlayable extends Fake implements Playable {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePlayable());
    registerFallbackValue(Duration.zero);
  });

  group('MusicPlayerAudioHandler', () {
    late _MockPlayer player;
    late _PlayerTestHarness harness;
    late MusicPlayerAudioHandler handler;

    setUp(() {
      player = _MockPlayer();
      harness = _PlayerTestHarness(player);
      handler = MusicPlayerAudioHandler(player: player);
    });

    tearDown(() async {
      await handler.dispose();
      await harness.dispose();
    });

    test(
      're-seeks to the saved position when playback reports a delayed zero position',
      () async {
        const resumePosition = Duration(minutes: 1, seconds: 5);

        await handler.loadAudio(
          path: '/music/resume.mp3',
          title: 'Resume',
          initialPosition: resumePosition,
        );
        harness.seekCalls.clear();
        harness.emitDelayedZeroOnNextPlay = true;

        await handler.play();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(
          harness.seekCalls.where((position) => position == resumePosition),
          hasLength(3),
        );
        expect(handler.position, resumePosition);
      },
    );

    test('manual seek clears resume recovery guard', () async {
      const resumePosition = Duration(minutes: 1, seconds: 5);
      const manualSeekPosition = Duration(seconds: 12);

      await handler.loadAudio(
        path: '/music/manual-seek.mp3',
        title: 'Manual Seek',
        initialPosition: resumePosition,
      );
      harness.seekCalls.clear();

      await handler.seek(manualSeekPosition);
      harness.emitPosition(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(harness.seekCalls, [manualSeekPosition]);
      expect(harness.seekCalls, isNot(contains(resumePosition)));
    });

    test(
      'reopens current media when play does not resume immediately',
      () async {
        const resumePosition = Duration(minutes: 1, seconds: 5);

        await handler.loadAudio(
          path: '/music/reopen.mp3',
          title: 'Reopen',
          initialPosition: resumePosition,
        );
        harness.openCalls.clear();
        harness.seekCalls.clear();
        harness.playEmitsPlaying = false;

        await handler.play();

        expect(harness.openCalls, ['/music/reopen.mp3']);
        expect(
          harness.seekCalls.where((position) => position == resumePosition),
          hasLength(3),
        );
        expect(handler.position, resumePosition);
        expect(handler.playing, isFalse);
      },
    );

    test('clearSession clears media item and skip controls', () async {
      await handler.loadAudio(path: '/music/clear.mp3', title: 'Clear');
      handler.setSkipCallbacks(onNext: () {}, onPrevious: () {});

      await handler.clearSession();

      expect(handler.mediaItem.value, isNull);
      final controls = handler.playbackState.value.controls;
      expect(
        controls.where((control) => control.action == MediaAction.skipToNext),
        isEmpty,
      );
      expect(
        controls.where(
          (control) => control.action == MediaAction.skipToPrevious,
        ),
        isEmpty,
      );
    });
  });
}

class _PlayerTestHarness {
  _PlayerTestHarness(this.player) {
    when(() => player.stream).thenReturn(
      PlayerStream(
        _playlistController.stream,
        _playingController.stream,
        _completedController.stream,
        _positionController.stream,
        _durationController.stream,
        const Stream<double>.empty(),
        const Stream<double>.empty(),
        const Stream<double>.empty(),
        const Stream<bool>.empty(),
        const Stream<double>.empty(),
        _bufferController.stream,
        const Stream<PlaylistMode>.empty(),
        const Stream<bool>.empty(),
        const Stream<AudioParams>.empty(),
        const Stream<VideoParams>.empty(),
        const Stream<double?>.empty(),
        const Stream<AudioDevice>.empty(),
        const Stream<List<AudioDevice>>.empty(),
        const Stream<Track>.empty(),
        const Stream<Tracks>.empty(),
        const Stream<int?>.empty(),
        const Stream<int?>.empty(),
        const Stream<List<String>>.empty(),
        const Stream<PlayerLog>.empty(),
        const Stream<String>.empty(),
      ),
    );
    when(() => player.state).thenAnswer((_) => state);
    when(() => player.open(any(), play: any(named: 'play'))).thenAnswer((
      invocation,
    ) async {
      final playable = invocation.positionalArguments.first as Playable;
      final playlist =
          playable is Playlist ? playable : Playlist([playable as Media]);
      final firstMedia = playlist.medias.firstOrNull;
      if (firstMedia != null) {
        openCalls.add(firstMedia.uri);
      }
      state = state.copyWith(
        playlist: playlist,
        completed: false,
        playing: false,
        position: Duration.zero,
      );
      _playlistController.add(playlist);
    });
    when(() => player.seek(any())).thenAnswer((invocation) async {
      final position = invocation.positionalArguments.first as Duration;
      seekCalls.add(position);
      state = state.copyWith(position: position, completed: false);
      _positionController.add(position);
    });
    when(player.play).thenAnswer((_) async {
      state = state.copyWith(playing: playEmitsPlaying, completed: false);
      if (playEmitsPlaying) {
        _playingController.add(true);
      }
      if (emitDelayedZeroOnNextPlay) {
        emitDelayedZeroOnNextPlay = false;
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 1), () {
            state = state.copyWith(position: Duration.zero);
            _positionController.add(Duration.zero);
          }),
        );
      }
    });
    when(player.pause).thenAnswer((_) async {
      state = state.copyWith(playing: false);
      _playingController.add(false);
    });
    when(player.stop).thenAnswer((_) async {
      state = state.copyWith(playing: false, playlist: const Playlist([]));
      _playingController.add(false);
    });
    when(() => player.setRate(any())).thenAnswer((_) async {});
    when(() => player.setVolume(any())).thenAnswer((_) async {});
    when(player.dispose).thenAnswer((_) async {});
  }

  final _MockPlayer player;
  final List<String> openCalls = [];
  final List<Duration> seekCalls = [];
  final _playlistController = StreamController<Playlist>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _completedController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _bufferController = StreamController<Duration>.broadcast();

  PlayerState state = const PlayerState();
  bool emitDelayedZeroOnNextPlay = false;
  bool playEmitsPlaying = true;

  void emitPosition(Duration position) {
    state = state.copyWith(position: position);
    _positionController.add(position);
  }

  Future<void> dispose() async {
    await _playlistController.close();
    await _playingController.close();
    await _completedController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferController.close();
  }
}
