import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';

part 'app_database.g.dart';

// ============== Tables ==============

/// Audio files table
class AudioFilesTable extends Table {
  @override
  String get tableName => 'audio_files';

  TextColumn get id => text()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  TextColumn get artworkPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Settings table (single row)
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer().autoIncrement()();
  BoolColumn get darkMode => boolean().withDefault(const Constant(true))();
  TextColumn get locale => text().withDefault(const Constant('zh_TW'))();
  RealColumn get defaultVolume => real().withDefault(const Constant(1))();
  RealColumn get defaultPlaybackSpeed =>
      real().withDefault(const Constant(1))();
  BoolColumn get autoResume => boolean().withDefault(const Constant(true))();
  IntColumn get skipForwardSeconds =>
      integer().withDefault(const Constant(10))();
  IntColumn get skipBackwardSeconds =>
      integer().withDefault(const Constant(10))();
  TextColumn get monitoredFolders =>
      text().withDefault(const Constant('[]'))(); // JSON array
  BoolColumn get sleepTimerFadeOutEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get sleepTimerFadeOutSeconds =>
      integer().withDefault(const Constant(5))();
  BoolColumn get navigateToPlayerOnResume =>
      boolean().withDefault(const Constant(false))();
}

/// Playback state table (single row for last state)
class PlaybackStatesTable extends Table {
  @override
  String get tableName => 'playback_states';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get audioFilePath => text()();
  IntColumn get positionMs => integer()();
  DateTimeColumn get savedAt => dateTime()();
  RealColumn get volume => real()();
  RealColumn get playbackSpeed => real()();
}

/// Playlists table
class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table for playlist-audiofile many-to-many relationship
class PlaylistFilesTable extends Table {
  @override
  String get tableName => 'playlist_files';

  TextColumn get playlistId =>
      text().references(PlaylistsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get audioFileId =>
      text().references(AudioFilesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {playlistId, audioFileId};
}

/// File positions table (for remembering playback position per file)
class FilePositionsTable extends Table {
  @override
  String get tableName => 'file_positions';

  TextColumn get filePath => text()();
  IntColumn get positionMs => integer()();

  @override
  Set<Column> get primaryKey => {filePath};
}

// ============== Database ==============

@DriftDatabase(
  tables: [
    AudioFilesTable,
    SettingsTable,
    PlaybackStatesTable,
    PlaylistsTable,
    PlaylistFilesTable,
    FilePositionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await repairDuplicateAudioFilesByPath();
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS '
          'idx_audio_files_file_path ON audio_files (file_path)',
        );
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static LazyDatabase _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pulse.db'));
    return NativeDatabase.createInBackground(file);
  });

  // ============== Settings Operations ==============

  Future<SettingsTableData?> getSettings() =>
      (select(settingsTable)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> saveSettings(SettingsTableCompanion entry) async {
    final existing = await getSettings();
    if (existing != null) {
      await (update(settingsTable)..where((t) => t.id.equals(1))).write(entry);
    } else {
      await into(settingsTable).insert(entry.copyWith(id: const Value(1)));
    }
  }

  Future<int> deleteSettings() =>
      (delete(settingsTable)..where((t) => t.id.equals(1))).go();

  // ============== Playback State Operations ==============

  Future<PlaybackStatesTableData?> getLastPlaybackState() =>
      (select(playbackStatesTable)
        ..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> savePlaybackState(PlaybackStatesTableCompanion entry) async {
    final existing = await getLastPlaybackState();
    if (existing != null) {
      await (update(playbackStatesTable)
        ..where((t) => t.id.equals(1))).write(entry);
    } else {
      await into(
        playbackStatesTable,
      ).insert(entry.copyWith(id: const Value(1)));
    }
  }

  Future<int> clearPlaybackState() =>
      (delete(playbackStatesTable)..where((t) => t.id.equals(1))).go();

  // ============== File Position Operations ==============

  Future<int?> getFilePosition(String path) async {
    final canonicalPath = AudioPathUtils.canonicalize(path);
    final result =
        await (select(filePositionsTable)
          ..where((t) => t.filePath.equals(canonicalPath))).getSingleOrNull();
    return result?.positionMs;
  }

  Future<void> saveFilePosition(String path, int positionMs) =>
      into(filePositionsTable).insert(
        FilePositionsTableCompanion(
          filePath: Value(AudioPathUtils.canonicalize(path)),
          positionMs: Value(positionMs),
        ),
        mode: InsertMode.insertOrReplace,
      );

  Future<Map<String, int>> getAllFilePositions() async {
    final results = await select(filePositionsTable).get();
    return {for (final r in results) r.filePath: r.positionMs};
  }

  Future<int> clearFilePosition(String path) =>
      (delete(filePositionsTable)..where(
        (t) => t.filePath.equals(AudioPathUtils.canonicalize(path)),
      )).go();

  /// Clears file positions for multiple paths
  Future<void> clearFilePositions(List<String> paths) async {
    for (final path in paths) {
      await clearFilePosition(path);
    }
  }

  /// Gets all file paths from audio_files table
  Future<List<String>> getAllAudioFilePaths() async {
    final results = await select(audioFilesTable).get();
    return results.map((r) => r.filePath).toList();
  }

  /// Gets all file paths from file_positions table
  Future<List<String>> getAllFilePositionPaths() async {
    final results = await select(filePositionsTable).get();
    return results.map((r) => r.filePath).toList();
  }

  /// Deletes audio files by their file paths
  Future<int> deleteAudioFilesByPaths(List<String> paths) async {
    var count = 0;
    for (final path in paths) {
      count +=
          await (delete(audioFilesTable)..where(
            (t) => t.filePath.equals(AudioPathUtils.canonicalize(path)),
          )).go();
    }
    return count;
  }

  // ============== Audio File Operations ==============

  Future<List<AudioFilesTableData>> getAllAudioFiles() =>
      select(audioFilesTable).get();

  Future<AudioFilesTableData?> getAudioFileById(String id) =>
      (select(audioFilesTable)
        ..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<AudioFilesTableData?> getAudioFileByPath(String filePath) =>
      (select(audioFilesTable)..where(
        (t) => t.filePath.equals(AudioPathUtils.canonicalize(filePath)),
      )).getSingleOrNull();

  Future<AudioFilesTableData> upsertAudioFileByPath(
    AudioFilesTableCompanion entry,
  ) async => transaction(() async {
    final canonicalPath = AudioPathUtils.canonicalize(entry.filePath.value);
    final existing = await getAudioFileByPath(canonicalPath);

    if (existing != null) {
      final updatedEntry = entry.copyWith(
        id: Value(existing.id),
        filePath: Value(canonicalPath),
        addedAt: Value(existing.addedAt ?? entry.addedAt.value),
      );
      await (update(audioFilesTable)
        ..where((t) => t.id.equals(existing.id))).write(updatedEntry);
      return (await getAudioFileById(existing.id))!;
    }

    final insertEntry = entry.copyWith(filePath: Value(canonicalPath));
    try {
      await into(audioFilesTable).insert(insertEntry);
    } on Exception {
      final racedExisting = await getAudioFileByPath(canonicalPath);
      if (racedExisting != null) return racedExisting;
      rethrow;
    }
    return (await getAudioFileById(insertEntry.id.value))!;
  });

  Future<int> insertAudioFile(AudioFilesTableCompanion entry) async {
    await upsertAudioFileByPath(entry);
    return 1;
  }

  Future<int> deleteAudioFile(String id) =>
      (delete(audioFilesTable)..where((t) => t.id.equals(id))).go();

  Future<int> clearAllAudioFiles() => delete(audioFilesTable).go();

  // ============== Playlist Operations ==============

  Future<List<PlaylistsTableData>> getAllPlaylists() =>
      select(playlistsTable).get();

  Stream<List<PlaylistsTableData>> watchAllPlaylists() =>
      select(playlistsTable).watch();

  Future<PlaylistsTableData?> getPlaylistById(String id) =>
      (select(playlistsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertPlaylist(PlaylistsTableCompanion entry) =>
      into(playlistsTable).insert(entry, mode: InsertMode.insertOrReplace);

  Future<int> deletePlaylist(String id) async {
    await (delete(playlistFilesTable)
      ..where((t) => t.playlistId.equals(id))).go();
    return (delete(playlistsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<AudioFilesTableData>> getPlaylistFiles(String playlistId) async {
    final query =
        select(audioFilesTable).join([
            innerJoin(
              playlistFilesTable,
              playlistFilesTable.audioFileId.equalsExp(audioFilesTable.id),
            ),
          ])
          ..where(playlistFilesTable.playlistId.equals(playlistId))
          ..orderBy([
            OrderingTerm.asc(playlistFilesTable.sortOrder),
            OrderingTerm.asc(audioFilesTable.id),
          ]);

    final results = await query.get();
    return results.map((row) => row.readTable(audioFilesTable)).toList();
  }

  Future<void> updatePlaylistFiles(
    String playlistId,
    List<String> audioFileIds,
  ) async => transaction(() async {
    await (delete(playlistFilesTable)
      ..where((t) => t.playlistId.equals(playlistId))).go();

    await batch((batch) {
      for (var i = 0; i < audioFileIds.length; i++) {
        batch.insert(
          playlistFilesTable,
          PlaylistFilesTableCompanion(
            playlistId: Value(playlistId),
            audioFileId: Value(audioFileIds[i]),
            sortOrder: Value(i),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  });

  /// Collapses duplicate audio rows by canonical path and rewrites playlists.
  Future<int> repairDuplicateAudioFilesByPath() async {
    final rows =
        await customSelect(
          'SELECT id, file_path FROM audio_files '
          'ORDER BY added_at IS NULL, added_at, id',
          readsFrom: {audioFilesTable},
        ).get();

    final keptIdByPath = <String, String>{};
    final canonicalPathByKeptId = <String, String>{};
    var removedCount = 0;

    await transaction(() async {
      for (final row in rows) {
        final id = row.read<String>('id');
        final filePath = row.read<String>('file_path');
        final canonicalPath = AudioPathUtils.canonicalize(filePath);
        final keptId = keptIdByPath[canonicalPath];

        if (keptId == null) {
          keptIdByPath[canonicalPath] = id;
          canonicalPathByKeptId[id] = canonicalPath;
          continue;
        }

        await customStatement(
          'UPDATE playlist_files '
          'SET sort_order = MIN(sort_order, ('
          'SELECT duplicate.sort_order FROM playlist_files AS duplicate '
          'WHERE duplicate.playlist_id = playlist_files.playlist_id '
          'AND duplicate.audio_file_id = ?'
          ')) '
          'WHERE audio_file_id = ? '
          'AND EXISTS ('
          'SELECT 1 FROM playlist_files AS duplicate '
          'WHERE duplicate.playlist_id = playlist_files.playlist_id '
          'AND duplicate.audio_file_id = ?'
          ')',
          [id, keptId, id],
        );
        await customStatement(
          'INSERT OR IGNORE INTO playlist_files '
          '(playlist_id, audio_file_id, sort_order) '
          'SELECT playlist_id, ?, sort_order FROM playlist_files '
          'WHERE audio_file_id = ?',
          [keptId, id],
        );
        await (delete(playlistFilesTable)
          ..where((t) => t.audioFileId.equals(id))).go();
        await (delete(audioFilesTable)..where((t) => t.id.equals(id))).go();
        removedCount++;
      }

      for (final entry in canonicalPathByKeptId.entries) {
        await (update(audioFilesTable)..where(
          (t) => t.id.equals(entry.key),
        )).write(AudioFilesTableCompanion(filePath: Value(entry.value)));
      }

      await _normalizePlaylistSortOrders();
    });

    return removedCount;
  }

  Future<void> _normalizePlaylistSortOrders() async {
    final playlistIds =
        await customSelect(
          'SELECT DISTINCT playlist_id FROM playlist_files',
          readsFrom: {playlistFilesTable},
        ).get();

    for (final playlistRow in playlistIds) {
      final playlistId = playlistRow.read<String>('playlist_id');
      final entries =
          await customSelect(
            'SELECT audio_file_id FROM playlist_files '
            'WHERE playlist_id = ? '
            'ORDER BY sort_order, audio_file_id',
            variables: [Variable.withString(playlistId)],
            readsFrom: {playlistFilesTable},
          ).get();

      for (var i = 0; i < entries.length; i++) {
        final audioFileId = entries[i].read<String>('audio_file_id');
        await (update(playlistFilesTable)..where(
          (t) =>
              t.playlistId.equals(playlistId) &
              t.audioFileId.equals(audioFileId),
        )).write(PlaylistFilesTableCompanion(sortOrder: Value(i)));
      }
    }
  }

  // ============== Clear All Data ==============

  /// Clears all data from all tables
  Future<void> clearAllData() async {
    await delete(playlistFilesTable).go();
    await delete(playlistsTable).go();
    await delete(audioFilesTable).go();
    await delete(filePositionsTable).go();
    await delete(playbackStatesTable).go();
    await delete(settingsTable).go();
  }
}
