import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/sync/file_scanner_sync.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';

void main() {
  group('folder playlist naming', () {
    test('keeps basename when unused', () {
      const folder = ScannedFolder(
        path: '/storage/Music',
        name: 'Music',
        files: [],
      );

      expect(
        resolveFolderPlaylistName(folder: folder, existingPlaylists: const []),
        'Music',
      );
    });

    test('disambiguates when another folder already owns the basename', () {
      final existing = Playlist(
        id: 'p1',
        name: 'Music',
        files: const [
          AudioFile(
            id: 'a',
            path: '/storage/Download/Music/a.mp3',
            title: 'a',
            duration: Duration.zero,
            fileSizeBytes: 1,
          ),
        ],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      const folder = ScannedFolder(
        path: '/storage/Music',
        name: 'Music',
        files: [
          AudioFile(
            id: 'b',
            path: '/storage/Music/b.mp3',
            title: 'b',
            duration: Duration.zero,
            fileSizeBytes: 1,
          ),
        ],
      );

      expect(
        resolveFolderPlaylistName(
          folder: folder,
          existingPlaylists: [existing],
        ),
        isNot('Music'),
      );
    });

    test('reuses playlist that already belongs to the same folder', () {
      final existing = Playlist(
        id: 'p1',
        name: 'Music',
        files: const [
          AudioFile(
            id: 'a',
            path: '/storage/Music/a.mp3',
            title: 'a',
            duration: Duration.zero,
            fileSizeBytes: 1,
          ),
        ],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      const folder = ScannedFolder(
        path: '/storage/Music',
        name: 'Music',
        files: [
          AudioFile(
            id: 'b',
            path: '/storage/Music/b.mp3',
            title: 'b',
            duration: Duration.zero,
            fileSizeBytes: 1,
          ),
        ],
      );

      expect(
        findPlaylistForFolder(
          folder: folder,
          playlistName: 'Music',
          existingPlaylists: [existing],
        ),
        existing,
      );
    });

    test(
      'treats nested album files as belonging to the selected root folder',
      () {
        final existing = Playlist(
          id: 'p1',
          name: 'Music',
          files: const [
            AudioFile(
              id: 'a',
              path: '/storage/Music/Album/a.mp3',
              title: 'a',
              duration: Duration.zero,
              fileSizeBytes: 1,
            ),
          ],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        const folder = ScannedFolder(
          path: '/storage/Music',
          name: 'Music',
          files: [
            AudioFile(
              id: 'b',
              path: '/storage/Music/Album/b.mp3',
              title: 'b',
              duration: Duration.zero,
              fileSizeBytes: 1,
            ),
          ],
        );

        expect(
          findPlaylistForFolder(
            folder: folder,
            playlistName: 'Music',
            existingPlaylists: [existing],
          ),
          existing,
        );
      },
    );
  });
}
