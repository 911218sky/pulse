import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ============== Tables ==============

/// Audio files table
class AudioFilesTable extends Table {
  @override
  String get tableName => 'audio_files';

  TextColumn get id => text()();
  TextColumn get filePath => text()();
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add sleep timer settings columns
        try {
          await m.addColumn(
            settingsTable,
            settingsTable.sleepTimerFadeOutEnabled,
          );
        } on Exception {
          // Column might already exist
        }
        try {
          await m.addColumn(
            settingsTable,
            settingsTable.sleepTimerFadeOutSeconds,
          );
        } on Exception {
          // Column might already exist
        }
      }
      if (from < 3) {
        // Add locale column
        try {
          await m.addColumn(settingsTable, settingsTable.locale);
        } on Exception {
          // Column might already exist
        }
      }
    },
    beforeOpen: (details) async {
      // Ensure all columns exist (for corrupted migrations)
      if (details.wasCreated) return;

      try {
        // Try to add locale column if it doesn't exist
        await customStatement(
          "ALTER TABLE settings ADD COLUMN locale TEXT NOT NULL DEFAULT 'zh_TW'",
        );
      } on Exception {
        // Column already exists, ignore
      }
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
    final result =
        await (select(filePositionsTable)
          ..where((t) => t.filePath.equals(path))).getSingleOrNull();
    return result?.positionMs;
  }

  Future<void> saveFilePosition(String path, int positionMs) =>
      into(filePositionsTable).insert(
        FilePositionsTableCompanion(
          filePath: Value(path),
          positionMs: Value(positionMs),
        ),
        mode: InsertMode.insertOrReplace,
      );

  Future<Map<String, int>> getAllFilePositions() async {
    final results = await select(filePositionsTable).get();
    return {for (final r in results) r.filePath: r.positionMs};
  }

  Future<int> clearFilePosition(String path) =>
      (delete(filePositionsTable)..where((t) => t.filePath.equals(path))).go();

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
          await (delete(audioFilesTable)
            ..where((t) => t.filePath.equals(path))).go();
    }
    return count;
  }

  // ============== Audio File Operations ==============

  Future<List<AudioFilesTableData>> getAllAudioFiles() =>
      select(audioFilesTable).get();

  Future<AudioFilesTableData?> getAudioFileById(String id) =>
      (select(audioFilesTable)
        ..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertAudioFile(AudioFilesTableCompanion entry) =>
      into(audioFilesTable).insert(entry, mode: InsertMode.insertOrReplace);

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
          ..orderBy([OrderingTerm.asc(playlistFilesTable.sortOrder)]);

    final results = await query.get();
    return results.map((row) => row.readTable(audioFilesTable)).toList();
  }

  Future<void> updatePlaylistFiles(
    String playlistId,
    List<String> audioFileIds,
  ) async {
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
