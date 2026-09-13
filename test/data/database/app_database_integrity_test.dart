import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  group('AppDatabase library integrity', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'upsertAudioFileByPath keeps a single row per canonical path',
      () async {
        final path = AudioPathUtils.canonicalize('/library/Song.mp3');

        final first = await db.upsertAudioFileByPath(
          AudioFilesTableCompanion.insert(
            id: 'id-1',
            filePath: path,
            title: 'Song',
            durationMs: 1000,
            fileSize: 10,
          ),
        );
        final second = await db.upsertAudioFileByPath(
          AudioFilesTableCompanion.insert(
            id: 'id-2',
            filePath: path,
            title: 'Song Updated',
            durationMs: 2000,
            fileSize: 20,
          ),
        );

        final rows = await db.getAllAudioFiles();
        expect(rows, hasLength(1));
        expect(second.id, first.id);
        expect(rows.single.title, 'Song Updated');
        expect(rows.single.durationMs, 2000);
      },
    );

    test(
      'repairDuplicateAudioFilesByPath collapses case-variant duplicates',
      () async {
        await db
            .into(db.audioFilesTable)
            .insert(
              AudioFilesTableCompanion.insert(
                id: 'keep',
                filePath: '/Library/Song.mp3',
                title: 'Keep',
                durationMs: 1,
                fileSize: 1,
                addedAt: Value(DateTime(2026, 1, 1)),
              ),
            );
        await db
            .into(db.audioFilesTable)
            .insert(
              AudioFilesTableCompanion.insert(
                id: 'drop',
                filePath: '/library/song.mp3',
                title: 'Drop',
                durationMs: 1,
                fileSize: 1,
                addedAt: Value(DateTime(2026, 2, 1)),
              ),
            );
        await db
            .into(db.playlistsTable)
            .insert(
              PlaylistsTableCompanion.insert(
                id: 'pl',
                name: 'Playlist',
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            );
        await db
            .into(db.playlistFilesTable)
            .insert(
              PlaylistFilesTableCompanion.insert(
                playlistId: 'pl',
                audioFileId: 'keep',
              ),
            );
        await db
            .into(db.playlistFilesTable)
            .insert(
              PlaylistFilesTableCompanion.insert(
                playlistId: 'pl',
                audioFileId: 'drop',
                sortOrder: const Value(1),
              ),
            );

        // Force Windows-style case folding semantics for this assertion when needed.
        final removed = await db.repairDuplicateAudioFilesByPath();
        if (AudioPathUtils.canonicalize('/Library/Song.mp3') ==
            AudioPathUtils.canonicalize('/library/song.mp3')) {
          expect(removed, 1);
          final audioRows = await db.getAllAudioFiles();
          expect(audioRows, hasLength(1));
          expect(audioRows.single.id, 'keep');
          final playlistFiles = await db.getPlaylistFiles('pl');
          expect(playlistFiles, hasLength(1));
          expect(playlistFiles.single.id, 'keep');
        } else {
          // Case-sensitive platforms keep both rows unless paths normalize equal.
          expect(removed, 0);
          expect(await db.getAllAudioFiles(), hasLength(2));
        }
      },
    );

    test('schemaVersion stays monotonic for published releases', () {
      expect(db.schemaVersion, greaterThanOrEqualTo(6));
    });
  });
}
