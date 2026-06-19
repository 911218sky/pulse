import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/sync/playlist_audio_sync.dart';
import 'package:pulse/domain/entities/audio_file.dart';

void main() {
  group('findAudioFileIndexByCanonicalPath', () {
    test('returns the matching index when the track exists', () {
      const first = AudioFile(
        id: 'first',
        path: '/music/first.mp3',
        title: 'First',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );
      const second = AudioFile(
        id: 'second',
        path: '/music/second.mp3',
        title: 'Second',
        duration: Duration(minutes: 4),
        fileSizeBytes: 2000,
      );

      final index = findAudioFileIndexByCanonicalPath(
        currentAudio: second,
        candidateFiles: const [first, second],
      );

      expect(index, 1);
    });

    test('matches using canonicalized paths', () {
      const current = AudioFile(
        id: 'normalized',
        path: '/music/folder/track.mp3',
        title: 'Normalized',
        duration: Duration(minutes: 5),
        fileSizeBytes: 3000,
      );
      const candidate = AudioFile(
        id: 'normalized-copy',
        path: '/music/folder/./track.mp3',
        title: 'Normalized',
        duration: Duration(minutes: 5),
        fileSizeBytes: 3000,
      );

      final index = findAudioFileIndexByCanonicalPath(
        currentAudio: current,
        candidateFiles: const [candidate],
      );

      expect(index, 0);
    });

    test('returns null when the track does not exist', () {
      const current = AudioFile(
        id: 'current',
        path: '/music/current.mp3',
        title: 'Current',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1000,
      );
      const other = AudioFile(
        id: 'other',
        path: '/music/other.mp3',
        title: 'Other',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1000,
      );

      final index = findAudioFileIndexByCanonicalPath(
        currentAudio: current,
        candidateFiles: const [other],
      );

      expect(index, isNull);
    });
  });

  group('resolveTemporaryQueueForCurrentAudio', () {
    test('returns a queue and start index when the current track exists', () {
      const first = AudioFile(
        id: 'first',
        path: '/music/first.mp3',
        title: 'First',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );
      const second = AudioFile(
        id: 'second',
        path: '/music/second.mp3',
        title: 'Second',
        duration: Duration(minutes: 4),
        fileSizeBytes: 2000,
      );

      final queue = resolveTemporaryQueueForCurrentAudio(
        currentAudio: second,
        candidateFiles: const [first, second],
      );

      expect(queue, isNotNull);
      expect(queue!.files, const [first, second]);
      expect(queue.startIndex, 1);
    });

    test('matches the current track using canonicalized paths', () {
      const current = AudioFile(
        id: 'normalized',
        path: '/music/folder/track.mp3',
        title: 'Normalized',
        duration: Duration(minutes: 5),
        fileSizeBytes: 3000,
      );
      const candidate = AudioFile(
        id: 'normalized-copy',
        path: '/music/folder/./track.mp3',
        title: 'Normalized',
        duration: Duration(minutes: 5),
        fileSizeBytes: 3000,
      );

      final queue = resolveTemporaryQueueForCurrentAudio(
        currentAudio: current,
        candidateFiles: const [candidate],
      );

      expect(queue, isNotNull);
      expect(queue!.startIndex, 0);
    });

    test('returns null when the current track is not in the candidates', () {
      const current = AudioFile(
        id: 'current',
        path: '/music/current.mp3',
        title: 'Current',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1000,
      );
      const other = AudioFile(
        id: 'other',
        path: '/music/other.mp3',
        title: 'Other',
        duration: Duration(minutes: 2),
        fileSizeBytes: 1000,
      );

      final queue = resolveTemporaryQueueForCurrentAudio(
        currentAudio: current,
        candidateFiles: const [other],
      );

      expect(queue, isNull);
    });
  });
}
