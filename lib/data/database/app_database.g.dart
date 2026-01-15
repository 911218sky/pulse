// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AudioFilesTableTable extends AudioFilesTable
    with TableInfo<$AudioFilesTableTable, AudioFilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioFilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkPathMeta = const VerificationMeta(
    'artworkPath',
  );
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
    'artwork_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    title,
    artist,
    album,
    durationMs,
    fileSize,
    addedAt,
    artworkPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioFilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('artwork_path')) {
      context.handle(
        _artworkPathMeta,
        artworkPath.isAcceptableOrUnknown(
          data['artwork_path']!,
          _artworkPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioFilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioFilesTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      durationMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration_ms'],
          )!,
      fileSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}file_size'],
          )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      artworkPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_path'],
      ),
    );
  }

  @override
  $AudioFilesTableTable createAlias(String alias) {
    return $AudioFilesTableTable(attachedDatabase, alias);
  }
}

class AudioFilesTableData extends DataClass
    implements Insertable<AudioFilesTableData> {
  final String id;
  final String filePath;
  final String title;
  final String? artist;
  final String? album;
  final int durationMs;
  final int fileSize;
  final DateTime? addedAt;
  final String? artworkPath;
  const AudioFilesTableData({
    required this.id,
    required this.filePath,
    required this.title,
    this.artist,
    this.album,
    required this.durationMs,
    required this.fileSize,
    this.addedAt,
    this.artworkPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    if (!nullToAbsent || artworkPath != null) {
      map['artwork_path'] = Variable<String>(artworkPath);
    }
    return map;
  }

  AudioFilesTableCompanion toCompanion(bool nullToAbsent) {
    return AudioFilesTableCompanion(
      id: Value(id),
      filePath: Value(filePath),
      title: Value(title),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      album:
          album == null && nullToAbsent ? const Value.absent() : Value(album),
      durationMs: Value(durationMs),
      fileSize: Value(fileSize),
      addedAt:
          addedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(addedAt),
      artworkPath:
          artworkPath == null && nullToAbsent
              ? const Value.absent()
              : Value(artworkPath),
    );
  }

  factory AudioFilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioFilesTableData(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSize': serializer.toJson<int>(fileSize),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'artworkPath': serializer.toJson<String?>(artworkPath),
    };
  }

  AudioFilesTableData copyWith({
    String? id,
    String? filePath,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    int? durationMs,
    int? fileSize,
    Value<DateTime?> addedAt = const Value.absent(),
    Value<String?> artworkPath = const Value.absent(),
  }) => AudioFilesTableData(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    durationMs: durationMs ?? this.durationMs,
    fileSize: fileSize ?? this.fileSize,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
  );
  AudioFilesTableData copyWithCompanion(AudioFilesTableCompanion data) {
    return AudioFilesTableData(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      artworkPath:
          data.artworkPath.present ? data.artworkPath.value : this.artworkPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesTableData(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt, ')
          ..write('artworkPath: $artworkPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    title,
    artist,
    album,
    durationMs,
    fileSize,
    addedAt,
    artworkPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioFilesTableData &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.fileSize == this.fileSize &&
          other.addedAt == this.addedAt &&
          other.artworkPath == this.artworkPath);
}

class AudioFilesTableCompanion extends UpdateCompanion<AudioFilesTableData> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<int> durationMs;
  final Value<int> fileSize;
  final Value<DateTime?> addedAt;
  final Value<String?> artworkPath;
  final Value<int> rowid;
  const AudioFilesTableCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioFilesTableCompanion.insert({
    required String id,
    required String filePath,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    required int durationMs,
    required int fileSize,
    this.addedAt = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       filePath = Value(filePath),
       title = Value(title),
       durationMs = Value(durationMs),
       fileSize = Value(fileSize);
  static Insertable<AudioFilesTableData> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<int>? fileSize,
    Expression<DateTime>? addedAt,
    Expression<String>? artworkPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSize != null) 'file_size': fileSize,
      if (addedAt != null) 'added_at': addedAt,
      if (artworkPath != null) 'artwork_path': artworkPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioFilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? filePath,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<int>? durationMs,
    Value<int>? fileSize,
    Value<DateTime?>? addedAt,
    Value<String?>? artworkPath,
    Value<int>? rowid,
  }) {
    return AudioFilesTableCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      artworkPath: artworkPath ?? this.artworkPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (artworkPath.present) {
      map['artwork_path'] = Variable<String>(artworkPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesTableCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('addedAt: $addedAt, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _darkModeMeta = const VerificationMeta(
    'darkMode',
  );
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
    'dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('zh_TW'),
  );
  static const VerificationMeta _defaultVolumeMeta = const VerificationMeta(
    'defaultVolume',
  );
  @override
  late final GeneratedColumn<double> defaultVolume = GeneratedColumn<double>(
    'default_volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultPlaybackSpeedMeta =
      const VerificationMeta('defaultPlaybackSpeed');
  @override
  late final GeneratedColumn<double> defaultPlaybackSpeed =
      GeneratedColumn<double>(
        'default_playback_speed',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _autoResumeMeta = const VerificationMeta(
    'autoResume',
  );
  @override
  late final GeneratedColumn<bool> autoResume = GeneratedColumn<bool>(
    'auto_resume',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_resume" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _skipForwardSecondsMeta =
      const VerificationMeta('skipForwardSeconds');
  @override
  late final GeneratedColumn<int> skipForwardSeconds = GeneratedColumn<int>(
    'skip_forward_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _skipBackwardSecondsMeta =
      const VerificationMeta('skipBackwardSeconds');
  @override
  late final GeneratedColumn<int> skipBackwardSeconds = GeneratedColumn<int>(
    'skip_backward_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _monitoredFoldersMeta = const VerificationMeta(
    'monitoredFolders',
  );
  @override
  late final GeneratedColumn<String> monitoredFolders = GeneratedColumn<String>(
    'monitored_folders',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sleepTimerFadeOutEnabledMeta =
      const VerificationMeta('sleepTimerFadeOutEnabled');
  @override
  late final GeneratedColumn<bool> sleepTimerFadeOutEnabled =
      GeneratedColumn<bool>(
        'sleep_timer_fade_out_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sleep_timer_fade_out_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _sleepTimerFadeOutSecondsMeta =
      const VerificationMeta('sleepTimerFadeOutSeconds');
  @override
  late final GeneratedColumn<int> sleepTimerFadeOutSeconds =
      GeneratedColumn<int>(
        'sleep_timer_fade_out_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(5),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    darkMode,
    locale,
    defaultVolume,
    defaultPlaybackSpeed,
    autoResume,
    skipForwardSeconds,
    skipBackwardSeconds,
    monitoredFolders,
    sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dark_mode')) {
      context.handle(
        _darkModeMeta,
        darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('default_volume')) {
      context.handle(
        _defaultVolumeMeta,
        defaultVolume.isAcceptableOrUnknown(
          data['default_volume']!,
          _defaultVolumeMeta,
        ),
      );
    }
    if (data.containsKey('default_playback_speed')) {
      context.handle(
        _defaultPlaybackSpeedMeta,
        defaultPlaybackSpeed.isAcceptableOrUnknown(
          data['default_playback_speed']!,
          _defaultPlaybackSpeedMeta,
        ),
      );
    }
    if (data.containsKey('auto_resume')) {
      context.handle(
        _autoResumeMeta,
        autoResume.isAcceptableOrUnknown(data['auto_resume']!, _autoResumeMeta),
      );
    }
    if (data.containsKey('skip_forward_seconds')) {
      context.handle(
        _skipForwardSecondsMeta,
        skipForwardSeconds.isAcceptableOrUnknown(
          data['skip_forward_seconds']!,
          _skipForwardSecondsMeta,
        ),
      );
    }
    if (data.containsKey('skip_backward_seconds')) {
      context.handle(
        _skipBackwardSecondsMeta,
        skipBackwardSeconds.isAcceptableOrUnknown(
          data['skip_backward_seconds']!,
          _skipBackwardSecondsMeta,
        ),
      );
    }
    if (data.containsKey('monitored_folders')) {
      context.handle(
        _monitoredFoldersMeta,
        monitoredFolders.isAcceptableOrUnknown(
          data['monitored_folders']!,
          _monitoredFoldersMeta,
        ),
      );
    }
    if (data.containsKey('sleep_timer_fade_out_enabled')) {
      context.handle(
        _sleepTimerFadeOutEnabledMeta,
        sleepTimerFadeOutEnabled.isAcceptableOrUnknown(
          data['sleep_timer_fade_out_enabled']!,
          _sleepTimerFadeOutEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sleep_timer_fade_out_seconds')) {
      context.handle(
        _sleepTimerFadeOutSecondsMeta,
        sleepTimerFadeOutSeconds.isAcceptableOrUnknown(
          data['sleep_timer_fade_out_seconds']!,
          _sleepTimerFadeOutSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      darkMode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}dark_mode'],
          )!,
      locale:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}locale'],
          )!,
      defaultVolume:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}default_volume'],
          )!,
      defaultPlaybackSpeed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}default_playback_speed'],
          )!,
      autoResume:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}auto_resume'],
          )!,
      skipForwardSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}skip_forward_seconds'],
          )!,
      skipBackwardSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}skip_backward_seconds'],
          )!,
      monitoredFolders:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}monitored_folders'],
          )!,
      sleepTimerFadeOutEnabled:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}sleep_timer_fade_out_enabled'],
          )!,
      sleepTimerFadeOutSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sleep_timer_fade_out_seconds'],
          )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;
  final bool darkMode;
  final String locale;
  final double defaultVolume;
  final double defaultPlaybackSpeed;
  final bool autoResume;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  final String monitoredFolders;
  final bool sleepTimerFadeOutEnabled;
  final int sleepTimerFadeOutSeconds;
  const SettingsTableData({
    required this.id,
    required this.darkMode,
    required this.locale,
    required this.defaultVolume,
    required this.defaultPlaybackSpeed,
    required this.autoResume,
    required this.skipForwardSeconds,
    required this.skipBackwardSeconds,
    required this.monitoredFolders,
    required this.sleepTimerFadeOutEnabled,
    required this.sleepTimerFadeOutSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['locale'] = Variable<String>(locale);
    map['default_volume'] = Variable<double>(defaultVolume);
    map['default_playback_speed'] = Variable<double>(defaultPlaybackSpeed);
    map['auto_resume'] = Variable<bool>(autoResume);
    map['skip_forward_seconds'] = Variable<int>(skipForwardSeconds);
    map['skip_backward_seconds'] = Variable<int>(skipBackwardSeconds);
    map['monitored_folders'] = Variable<String>(monitoredFolders);
    map['sleep_timer_fade_out_enabled'] = Variable<bool>(
      sleepTimerFadeOutEnabled,
    );
    map['sleep_timer_fade_out_seconds'] = Variable<int>(
      sleepTimerFadeOutSeconds,
    );
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      darkMode: Value(darkMode),
      locale: Value(locale),
      defaultVolume: Value(defaultVolume),
      defaultPlaybackSpeed: Value(defaultPlaybackSpeed),
      autoResume: Value(autoResume),
      skipForwardSeconds: Value(skipForwardSeconds),
      skipBackwardSeconds: Value(skipBackwardSeconds),
      monitoredFolders: Value(monitoredFolders),
      sleepTimerFadeOutEnabled: Value(sleepTimerFadeOutEnabled),
      sleepTimerFadeOutSeconds: Value(sleepTimerFadeOutSeconds),
    );
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      locale: serializer.fromJson<String>(json['locale']),
      defaultVolume: serializer.fromJson<double>(json['defaultVolume']),
      defaultPlaybackSpeed: serializer.fromJson<double>(
        json['defaultPlaybackSpeed'],
      ),
      autoResume: serializer.fromJson<bool>(json['autoResume']),
      skipForwardSeconds: serializer.fromJson<int>(json['skipForwardSeconds']),
      skipBackwardSeconds: serializer.fromJson<int>(
        json['skipBackwardSeconds'],
      ),
      monitoredFolders: serializer.fromJson<String>(json['monitoredFolders']),
      sleepTimerFadeOutEnabled: serializer.fromJson<bool>(
        json['sleepTimerFadeOutEnabled'],
      ),
      sleepTimerFadeOutSeconds: serializer.fromJson<int>(
        json['sleepTimerFadeOutSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'darkMode': serializer.toJson<bool>(darkMode),
      'locale': serializer.toJson<String>(locale),
      'defaultVolume': serializer.toJson<double>(defaultVolume),
      'defaultPlaybackSpeed': serializer.toJson<double>(defaultPlaybackSpeed),
      'autoResume': serializer.toJson<bool>(autoResume),
      'skipForwardSeconds': serializer.toJson<int>(skipForwardSeconds),
      'skipBackwardSeconds': serializer.toJson<int>(skipBackwardSeconds),
      'monitoredFolders': serializer.toJson<String>(monitoredFolders),
      'sleepTimerFadeOutEnabled': serializer.toJson<bool>(
        sleepTimerFadeOutEnabled,
      ),
      'sleepTimerFadeOutSeconds': serializer.toJson<int>(
        sleepTimerFadeOutSeconds,
      ),
    };
  }

  SettingsTableData copyWith({
    int? id,
    bool? darkMode,
    String? locale,
    double? defaultVolume,
    double? defaultPlaybackSpeed,
    bool? autoResume,
    int? skipForwardSeconds,
    int? skipBackwardSeconds,
    String? monitoredFolders,
    bool? sleepTimerFadeOutEnabled,
    int? sleepTimerFadeOutSeconds,
  }) => SettingsTableData(
    id: id ?? this.id,
    darkMode: darkMode ?? this.darkMode,
    locale: locale ?? this.locale,
    defaultVolume: defaultVolume ?? this.defaultVolume,
    defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
    autoResume: autoResume ?? this.autoResume,
    skipForwardSeconds: skipForwardSeconds ?? this.skipForwardSeconds,
    skipBackwardSeconds: skipBackwardSeconds ?? this.skipBackwardSeconds,
    monitoredFolders: monitoredFolders ?? this.monitoredFolders,
    sleepTimerFadeOutEnabled:
        sleepTimerFadeOutEnabled ?? this.sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds:
        sleepTimerFadeOutSeconds ?? this.sleepTimerFadeOutSeconds,
  );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      locale: data.locale.present ? data.locale.value : this.locale,
      defaultVolume:
          data.defaultVolume.present
              ? data.defaultVolume.value
              : this.defaultVolume,
      defaultPlaybackSpeed:
          data.defaultPlaybackSpeed.present
              ? data.defaultPlaybackSpeed.value
              : this.defaultPlaybackSpeed,
      autoResume:
          data.autoResume.present ? data.autoResume.value : this.autoResume,
      skipForwardSeconds:
          data.skipForwardSeconds.present
              ? data.skipForwardSeconds.value
              : this.skipForwardSeconds,
      skipBackwardSeconds:
          data.skipBackwardSeconds.present
              ? data.skipBackwardSeconds.value
              : this.skipBackwardSeconds,
      monitoredFolders:
          data.monitoredFolders.present
              ? data.monitoredFolders.value
              : this.monitoredFolders,
      sleepTimerFadeOutEnabled:
          data.sleepTimerFadeOutEnabled.present
              ? data.sleepTimerFadeOutEnabled.value
              : this.sleepTimerFadeOutEnabled,
      sleepTimerFadeOutSeconds:
          data.sleepTimerFadeOutSeconds.present
              ? data.sleepTimerFadeOutSeconds.value
              : this.sleepTimerFadeOutSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('locale: $locale, ')
          ..write('defaultVolume: $defaultVolume, ')
          ..write('defaultPlaybackSpeed: $defaultPlaybackSpeed, ')
          ..write('autoResume: $autoResume, ')
          ..write('skipForwardSeconds: $skipForwardSeconds, ')
          ..write('skipBackwardSeconds: $skipBackwardSeconds, ')
          ..write('monitoredFolders: $monitoredFolders, ')
          ..write('sleepTimerFadeOutEnabled: $sleepTimerFadeOutEnabled, ')
          ..write('sleepTimerFadeOutSeconds: $sleepTimerFadeOutSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    darkMode,
    locale,
    defaultVolume,
    defaultPlaybackSpeed,
    autoResume,
    skipForwardSeconds,
    skipBackwardSeconds,
    monitoredFolders,
    sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.darkMode == this.darkMode &&
          other.locale == this.locale &&
          other.defaultVolume == this.defaultVolume &&
          other.defaultPlaybackSpeed == this.defaultPlaybackSpeed &&
          other.autoResume == this.autoResume &&
          other.skipForwardSeconds == this.skipForwardSeconds &&
          other.skipBackwardSeconds == this.skipBackwardSeconds &&
          other.monitoredFolders == this.monitoredFolders &&
          other.sleepTimerFadeOutEnabled == this.sleepTimerFadeOutEnabled &&
          other.sleepTimerFadeOutSeconds == this.sleepTimerFadeOutSeconds);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<bool> darkMode;
  final Value<String> locale;
  final Value<double> defaultVolume;
  final Value<double> defaultPlaybackSpeed;
  final Value<bool> autoResume;
  final Value<int> skipForwardSeconds;
  final Value<int> skipBackwardSeconds;
  final Value<String> monitoredFolders;
  final Value<bool> sleepTimerFadeOutEnabled;
  final Value<int> sleepTimerFadeOutSeconds;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.defaultVolume = const Value.absent(),
    this.defaultPlaybackSpeed = const Value.absent(),
    this.autoResume = const Value.absent(),
    this.skipForwardSeconds = const Value.absent(),
    this.skipBackwardSeconds = const Value.absent(),
    this.monitoredFolders = const Value.absent(),
    this.sleepTimerFadeOutEnabled = const Value.absent(),
    this.sleepTimerFadeOutSeconds = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.defaultVolume = const Value.absent(),
    this.defaultPlaybackSpeed = const Value.absent(),
    this.autoResume = const Value.absent(),
    this.skipForwardSeconds = const Value.absent(),
    this.skipBackwardSeconds = const Value.absent(),
    this.monitoredFolders = const Value.absent(),
    this.sleepTimerFadeOutEnabled = const Value.absent(),
    this.sleepTimerFadeOutSeconds = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<bool>? darkMode,
    Expression<String>? locale,
    Expression<double>? defaultVolume,
    Expression<double>? defaultPlaybackSpeed,
    Expression<bool>? autoResume,
    Expression<int>? skipForwardSeconds,
    Expression<int>? skipBackwardSeconds,
    Expression<String>? monitoredFolders,
    Expression<bool>? sleepTimerFadeOutEnabled,
    Expression<int>? sleepTimerFadeOutSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darkMode != null) 'dark_mode': darkMode,
      if (locale != null) 'locale': locale,
      if (defaultVolume != null) 'default_volume': defaultVolume,
      if (defaultPlaybackSpeed != null)
        'default_playback_speed': defaultPlaybackSpeed,
      if (autoResume != null) 'auto_resume': autoResume,
      if (skipForwardSeconds != null)
        'skip_forward_seconds': skipForwardSeconds,
      if (skipBackwardSeconds != null)
        'skip_backward_seconds': skipBackwardSeconds,
      if (monitoredFolders != null) 'monitored_folders': monitoredFolders,
      if (sleepTimerFadeOutEnabled != null)
        'sleep_timer_fade_out_enabled': sleepTimerFadeOutEnabled,
      if (sleepTimerFadeOutSeconds != null)
        'sleep_timer_fade_out_seconds': sleepTimerFadeOutSeconds,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? darkMode,
    Value<String>? locale,
    Value<double>? defaultVolume,
    Value<double>? defaultPlaybackSpeed,
    Value<bool>? autoResume,
    Value<int>? skipForwardSeconds,
    Value<int>? skipBackwardSeconds,
    Value<String>? monitoredFolders,
    Value<bool>? sleepTimerFadeOutEnabled,
    Value<int>? sleepTimerFadeOutSeconds,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      locale: locale ?? this.locale,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      autoResume: autoResume ?? this.autoResume,
      skipForwardSeconds: skipForwardSeconds ?? this.skipForwardSeconds,
      skipBackwardSeconds: skipBackwardSeconds ?? this.skipBackwardSeconds,
      monitoredFolders: monitoredFolders ?? this.monitoredFolders,
      sleepTimerFadeOutEnabled:
          sleepTimerFadeOutEnabled ?? this.sleepTimerFadeOutEnabled,
      sleepTimerFadeOutSeconds:
          sleepTimerFadeOutSeconds ?? this.sleepTimerFadeOutSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (defaultVolume.present) {
      map['default_volume'] = Variable<double>(defaultVolume.value);
    }
    if (defaultPlaybackSpeed.present) {
      map['default_playback_speed'] = Variable<double>(
        defaultPlaybackSpeed.value,
      );
    }
    if (autoResume.present) {
      map['auto_resume'] = Variable<bool>(autoResume.value);
    }
    if (skipForwardSeconds.present) {
      map['skip_forward_seconds'] = Variable<int>(skipForwardSeconds.value);
    }
    if (skipBackwardSeconds.present) {
      map['skip_backward_seconds'] = Variable<int>(skipBackwardSeconds.value);
    }
    if (monitoredFolders.present) {
      map['monitored_folders'] = Variable<String>(monitoredFolders.value);
    }
    if (sleepTimerFadeOutEnabled.present) {
      map['sleep_timer_fade_out_enabled'] = Variable<bool>(
        sleepTimerFadeOutEnabled.value,
      );
    }
    if (sleepTimerFadeOutSeconds.present) {
      map['sleep_timer_fade_out_seconds'] = Variable<int>(
        sleepTimerFadeOutSeconds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('locale: $locale, ')
          ..write('defaultVolume: $defaultVolume, ')
          ..write('defaultPlaybackSpeed: $defaultPlaybackSpeed, ')
          ..write('autoResume: $autoResume, ')
          ..write('skipForwardSeconds: $skipForwardSeconds, ')
          ..write('skipBackwardSeconds: $skipBackwardSeconds, ')
          ..write('monitoredFolders: $monitoredFolders, ')
          ..write('sleepTimerFadeOutEnabled: $sleepTimerFadeOutEnabled, ')
          ..write('sleepTimerFadeOutSeconds: $sleepTimerFadeOutSeconds')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStatesTableTable extends PlaybackStatesTable
    with TableInfo<$PlaybackStatesTableTable, PlaybackStatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playbackSpeedMeta = const VerificationMeta(
    'playbackSpeed',
  );
  @override
  late final GeneratedColumn<double> playbackSpeed = GeneratedColumn<double>(
    'playback_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    audioFilePath,
    positionMs,
    savedAt,
    volume,
    playbackSpeed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackStatesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioFilePathMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('playback_speed')) {
      context.handle(
        _playbackSpeedMeta,
        playbackSpeed.isAcceptableOrUnknown(
          data['playback_speed']!,
          _playbackSpeedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playbackSpeedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackStatesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackStatesTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      audioFilePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}audio_file_path'],
          )!,
      positionMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position_ms'],
          )!,
      savedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}saved_at'],
          )!,
      volume:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}volume'],
          )!,
      playbackSpeed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}playback_speed'],
          )!,
    );
  }

  @override
  $PlaybackStatesTableTable createAlias(String alias) {
    return $PlaybackStatesTableTable(attachedDatabase, alias);
  }
}

class PlaybackStatesTableData extends DataClass
    implements Insertable<PlaybackStatesTableData> {
  final int id;
  final String audioFilePath;
  final int positionMs;
  final DateTime savedAt;
  final double volume;
  final double playbackSpeed;
  const PlaybackStatesTableData({
    required this.id,
    required this.audioFilePath,
    required this.positionMs,
    required this.savedAt,
    required this.volume,
    required this.playbackSpeed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audio_file_path'] = Variable<String>(audioFilePath);
    map['position_ms'] = Variable<int>(positionMs);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['volume'] = Variable<double>(volume);
    map['playback_speed'] = Variable<double>(playbackSpeed);
    return map;
  }

  PlaybackStatesTableCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStatesTableCompanion(
      id: Value(id),
      audioFilePath: Value(audioFilePath),
      positionMs: Value(positionMs),
      savedAt: Value(savedAt),
      volume: Value(volume),
      playbackSpeed: Value(playbackSpeed),
    );
  }

  factory PlaybackStatesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackStatesTableData(
      id: serializer.fromJson<int>(json['id']),
      audioFilePath: serializer.fromJson<String>(json['audioFilePath']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      volume: serializer.fromJson<double>(json['volume']),
      playbackSpeed: serializer.fromJson<double>(json['playbackSpeed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audioFilePath': serializer.toJson<String>(audioFilePath),
      'positionMs': serializer.toJson<int>(positionMs),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'volume': serializer.toJson<double>(volume),
      'playbackSpeed': serializer.toJson<double>(playbackSpeed),
    };
  }

  PlaybackStatesTableData copyWith({
    int? id,
    String? audioFilePath,
    int? positionMs,
    DateTime? savedAt,
    double? volume,
    double? playbackSpeed,
  }) => PlaybackStatesTableData(
    id: id ?? this.id,
    audioFilePath: audioFilePath ?? this.audioFilePath,
    positionMs: positionMs ?? this.positionMs,
    savedAt: savedAt ?? this.savedAt,
    volume: volume ?? this.volume,
    playbackSpeed: playbackSpeed ?? this.playbackSpeed,
  );
  PlaybackStatesTableData copyWithCompanion(PlaybackStatesTableCompanion data) {
    return PlaybackStatesTableData(
      id: data.id.present ? data.id.value : this.id,
      audioFilePath:
          data.audioFilePath.present
              ? data.audioFilePath.value
              : this.audioFilePath,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      volume: data.volume.present ? data.volume.value : this.volume,
      playbackSpeed:
          data.playbackSpeed.present
              ? data.playbackSpeed.value
              : this.playbackSpeed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStatesTableData(')
          ..write('id: $id, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('positionMs: $positionMs, ')
          ..write('savedAt: $savedAt, ')
          ..write('volume: $volume, ')
          ..write('playbackSpeed: $playbackSpeed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    audioFilePath,
    positionMs,
    savedAt,
    volume,
    playbackSpeed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackStatesTableData &&
          other.id == this.id &&
          other.audioFilePath == this.audioFilePath &&
          other.positionMs == this.positionMs &&
          other.savedAt == this.savedAt &&
          other.volume == this.volume &&
          other.playbackSpeed == this.playbackSpeed);
}

class PlaybackStatesTableCompanion
    extends UpdateCompanion<PlaybackStatesTableData> {
  final Value<int> id;
  final Value<String> audioFilePath;
  final Value<int> positionMs;
  final Value<DateTime> savedAt;
  final Value<double> volume;
  final Value<double> playbackSpeed;
  const PlaybackStatesTableCompanion({
    this.id = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.volume = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
  });
  PlaybackStatesTableCompanion.insert({
    this.id = const Value.absent(),
    required String audioFilePath,
    required int positionMs,
    required DateTime savedAt,
    required double volume,
    required double playbackSpeed,
  }) : audioFilePath = Value(audioFilePath),
       positionMs = Value(positionMs),
       savedAt = Value(savedAt),
       volume = Value(volume),
       playbackSpeed = Value(playbackSpeed);
  static Insertable<PlaybackStatesTableData> custom({
    Expression<int>? id,
    Expression<String>? audioFilePath,
    Expression<int>? positionMs,
    Expression<DateTime>? savedAt,
    Expression<double>? volume,
    Expression<double>? playbackSpeed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (positionMs != null) 'position_ms': positionMs,
      if (savedAt != null) 'saved_at': savedAt,
      if (volume != null) 'volume': volume,
      if (playbackSpeed != null) 'playback_speed': playbackSpeed,
    });
  }

  PlaybackStatesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? audioFilePath,
    Value<int>? positionMs,
    Value<DateTime>? savedAt,
    Value<double>? volume,
    Value<double>? playbackSpeed,
  }) {
    return PlaybackStatesTableCompanion(
      id: id ?? this.id,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      positionMs: positionMs ?? this.positionMs,
      savedAt: savedAt ?? this.savedAt,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (playbackSpeed.present) {
      map['playback_speed'] = Variable<double>(playbackSpeed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStatesTableCompanion(')
          ..write('id: $id, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('positionMs: $positionMs, ')
          ..write('savedAt: $savedAt, ')
          ..write('volume: $volume, ')
          ..write('playbackSpeed: $playbackSpeed')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistFilesTableTable extends PlaylistFilesTable
    with TableInfo<$PlaylistFilesTableTable, PlaylistFilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistFilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _audioFileIdMeta = const VerificationMeta(
    'audioFileId',
  );
  @override
  late final GeneratedColumn<String> audioFileId = GeneratedColumn<String>(
    'audio_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_files (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, audioFileId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistFilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('audio_file_id')) {
      context.handle(
        _audioFileIdMeta,
        audioFileId.isAcceptableOrUnknown(
          data['audio_file_id']!,
          _audioFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioFileIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, audioFileId};
  @override
  PlaylistFilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistFilesTableData(
      playlistId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}playlist_id'],
          )!,
      audioFileId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}audio_file_id'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $PlaylistFilesTableTable createAlias(String alias) {
    return $PlaylistFilesTableTable(attachedDatabase, alias);
  }
}

class PlaylistFilesTableData extends DataClass
    implements Insertable<PlaylistFilesTableData> {
  final String playlistId;
  final String audioFileId;
  final int sortOrder;
  const PlaylistFilesTableData({
    required this.playlistId,
    required this.audioFileId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['audio_file_id'] = Variable<String>(audioFileId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PlaylistFilesTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistFilesTableCompanion(
      playlistId: Value(playlistId),
      audioFileId: Value(audioFileId),
      sortOrder: Value(sortOrder),
    );
  }

  factory PlaylistFilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistFilesTableData(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      audioFileId: serializer.fromJson<String>(json['audioFileId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'audioFileId': serializer.toJson<String>(audioFileId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PlaylistFilesTableData copyWith({
    String? playlistId,
    String? audioFileId,
    int? sortOrder,
  }) => PlaylistFilesTableData(
    playlistId: playlistId ?? this.playlistId,
    audioFileId: audioFileId ?? this.audioFileId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PlaylistFilesTableData copyWithCompanion(PlaylistFilesTableCompanion data) {
    return PlaylistFilesTableData(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      audioFileId:
          data.audioFileId.present ? data.audioFileId.value : this.audioFileId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistFilesTableData(')
          ..write('playlistId: $playlistId, ')
          ..write('audioFileId: $audioFileId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, audioFileId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistFilesTableData &&
          other.playlistId == this.playlistId &&
          other.audioFileId == this.audioFileId &&
          other.sortOrder == this.sortOrder);
}

class PlaylistFilesTableCompanion
    extends UpdateCompanion<PlaylistFilesTableData> {
  final Value<String> playlistId;
  final Value<String> audioFileId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PlaylistFilesTableCompanion({
    this.playlistId = const Value.absent(),
    this.audioFileId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistFilesTableCompanion.insert({
    required String playlistId,
    required String audioFileId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       audioFileId = Value(audioFileId);
  static Insertable<PlaylistFilesTableData> custom({
    Expression<String>? playlistId,
    Expression<String>? audioFileId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (audioFileId != null) 'audio_file_id': audioFileId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistFilesTableCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? audioFileId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PlaylistFilesTableCompanion(
      playlistId: playlistId ?? this.playlistId,
      audioFileId: audioFileId ?? this.audioFileId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (audioFileId.present) {
      map['audio_file_id'] = Variable<String>(audioFileId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistFilesTableCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('audioFileId: $audioFileId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FilePositionsTableTable extends FilePositionsTable
    with TableInfo<$FilePositionsTableTable, FilePositionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilePositionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [filePath, positionMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilePositionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {filePath};
  @override
  FilePositionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilePositionsTableData(
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      positionMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position_ms'],
          )!,
    );
  }

  @override
  $FilePositionsTableTable createAlias(String alias) {
    return $FilePositionsTableTable(attachedDatabase, alias);
  }
}

class FilePositionsTableData extends DataClass
    implements Insertable<FilePositionsTableData> {
  final String filePath;
  final int positionMs;
  const FilePositionsTableData({
    required this.filePath,
    required this.positionMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_path'] = Variable<String>(filePath);
    map['position_ms'] = Variable<int>(positionMs);
    return map;
  }

  FilePositionsTableCompanion toCompanion(bool nullToAbsent) {
    return FilePositionsTableCompanion(
      filePath: Value(filePath),
      positionMs: Value(positionMs),
    );
  }

  factory FilePositionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilePositionsTableData(
      filePath: serializer.fromJson<String>(json['filePath']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'filePath': serializer.toJson<String>(filePath),
      'positionMs': serializer.toJson<int>(positionMs),
    };
  }

  FilePositionsTableData copyWith({String? filePath, int? positionMs}) =>
      FilePositionsTableData(
        filePath: filePath ?? this.filePath,
        positionMs: positionMs ?? this.positionMs,
      );
  FilePositionsTableData copyWithCompanion(FilePositionsTableCompanion data) {
    return FilePositionsTableData(
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilePositionsTableData(')
          ..write('filePath: $filePath, ')
          ..write('positionMs: $positionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(filePath, positionMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilePositionsTableData &&
          other.filePath == this.filePath &&
          other.positionMs == this.positionMs);
}

class FilePositionsTableCompanion
    extends UpdateCompanion<FilePositionsTableData> {
  final Value<String> filePath;
  final Value<int> positionMs;
  final Value<int> rowid;
  const FilePositionsTableCompanion({
    this.filePath = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilePositionsTableCompanion.insert({
    required String filePath,
    required int positionMs,
    this.rowid = const Value.absent(),
  }) : filePath = Value(filePath),
       positionMs = Value(positionMs);
  static Insertable<FilePositionsTableData> custom({
    Expression<String>? filePath,
    Expression<int>? positionMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (filePath != null) 'file_path': filePath,
      if (positionMs != null) 'position_ms': positionMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilePositionsTableCompanion copyWith({
    Value<String>? filePath,
    Value<int>? positionMs,
    Value<int>? rowid,
  }) {
    return FilePositionsTableCompanion(
      filePath: filePath ?? this.filePath,
      positionMs: positionMs ?? this.positionMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilePositionsTableCompanion(')
          ..write('filePath: $filePath, ')
          ..write('positionMs: $positionMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AudioFilesTableTable audioFilesTable = $AudioFilesTableTable(
    this,
  );
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $PlaybackStatesTableTable playbackStatesTable =
      $PlaybackStatesTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistFilesTableTable playlistFilesTable =
      $PlaylistFilesTableTable(this);
  late final $FilePositionsTableTable filePositionsTable =
      $FilePositionsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    audioFilesTable,
    settingsTable,
    playbackStatesTable,
    playlistsTable,
    playlistFilesTable,
    filePositionsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audio_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_files', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AudioFilesTableTableCreateCompanionBuilder =
    AudioFilesTableCompanion Function({
      required String id,
      required String filePath,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      required int durationMs,
      required int fileSize,
      Value<DateTime?> addedAt,
      Value<String?> artworkPath,
      Value<int> rowid,
    });
typedef $$AudioFilesTableTableUpdateCompanionBuilder =
    AudioFilesTableCompanion Function({
      Value<String> id,
      Value<String> filePath,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<int> durationMs,
      Value<int> fileSize,
      Value<DateTime?> addedAt,
      Value<String?> artworkPath,
      Value<int> rowid,
    });

final class $$AudioFilesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AudioFilesTableTable,
          AudioFilesTableData
        > {
  $$AudioFilesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistFilesTableTable,
    List<PlaylistFilesTableData>
  >
  _playlistFilesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistFilesTable,
        aliasName: $_aliasNameGenerator(
          db.audioFilesTable.id,
          db.playlistFilesTable.audioFileId,
        ),
      );

  $$PlaylistFilesTableTableProcessedTableManager get playlistFilesTableRefs {
    final manager = $$PlaylistFilesTableTableTableManager(
      $_db,
      $_db.playlistFilesTable,
    ).filter((f) => f.audioFileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistFilesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioFilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioFilesTableTable> {
  $$AudioFilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistFilesTableRefs(
    Expression<bool> Function($$PlaylistFilesTableTableFilterComposer f) f,
  ) {
    final $$PlaylistFilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistFilesTable,
      getReferencedColumn: (t) => t.audioFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistFilesTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistFilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioFilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioFilesTableTable> {
  $$AudioFilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioFilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioFilesTableTable> {
  $$AudioFilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get artworkPath => $composableBuilder(
    column: $table.artworkPath,
    builder: (column) => column,
  );

  Expression<T> playlistFilesTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistFilesTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistFilesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistFilesTable,
          getReferencedColumn: (t) => t.audioFileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistFilesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistFilesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudioFilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioFilesTableTable,
          AudioFilesTableData,
          $$AudioFilesTableTableFilterComposer,
          $$AudioFilesTableTableOrderingComposer,
          $$AudioFilesTableTableAnnotationComposer,
          $$AudioFilesTableTableCreateCompanionBuilder,
          $$AudioFilesTableTableUpdateCompanionBuilder,
          (AudioFilesTableData, $$AudioFilesTableTableReferences),
          AudioFilesTableData,
          PrefetchHooks Function({bool playlistFilesTableRefs})
        > {
  $$AudioFilesTableTableTableManager(
    _$AppDatabase db,
    $AudioFilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$AudioFilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AudioFilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AudioFilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioFilesTableCompanion(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                fileSize: fileSize,
                addedAt: addedAt,
                artworkPath: artworkPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String filePath,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                required int durationMs,
                required int fileSize,
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> artworkPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioFilesTableCompanion.insert(
                id: id,
                filePath: filePath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                fileSize: fileSize,
                addedAt: addedAt,
                artworkPath: artworkPath,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AudioFilesTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistFilesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistFilesTableRefs) db.playlistFilesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistFilesTableRefs)
                    await $_getPrefetchedData<
                      AudioFilesTableData,
                      $AudioFilesTableTable,
                      PlaylistFilesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$AudioFilesTableTableReferences
                          ._playlistFilesTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AudioFilesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistFilesTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.audioFileId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AudioFilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioFilesTableTable,
      AudioFilesTableData,
      $$AudioFilesTableTableFilterComposer,
      $$AudioFilesTableTableOrderingComposer,
      $$AudioFilesTableTableAnnotationComposer,
      $$AudioFilesTableTableCreateCompanionBuilder,
      $$AudioFilesTableTableUpdateCompanionBuilder,
      (AudioFilesTableData, $$AudioFilesTableTableReferences),
      AudioFilesTableData,
      PrefetchHooks Function({bool playlistFilesTableRefs})
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<bool> darkMode,
      Value<String> locale,
      Value<double> defaultVolume,
      Value<double> defaultPlaybackSpeed,
      Value<bool> autoResume,
      Value<int> skipForwardSeconds,
      Value<int> skipBackwardSeconds,
      Value<String> monitoredFolders,
      Value<bool> sleepTimerFadeOutEnabled,
      Value<int> sleepTimerFadeOutSeconds,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<bool> darkMode,
      Value<String> locale,
      Value<double> defaultVolume,
      Value<double> defaultPlaybackSpeed,
      Value<bool> autoResume,
      Value<int> skipForwardSeconds,
      Value<int> skipBackwardSeconds,
      Value<String> monitoredFolders,
      Value<bool> sleepTimerFadeOutEnabled,
      Value<int> sleepTimerFadeOutSeconds,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultPlaybackSpeed => $composableBuilder(
    column: $table.defaultPlaybackSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoResume => $composableBuilder(
    column: $table.autoResume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipForwardSeconds => $composableBuilder(
    column: $table.skipForwardSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipBackwardSeconds => $composableBuilder(
    column: $table.skipBackwardSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monitoredFolders => $composableBuilder(
    column: $table.monitoredFolders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sleepTimerFadeOutEnabled => $composableBuilder(
    column: $table.sleepTimerFadeOutEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepTimerFadeOutSeconds => $composableBuilder(
    column: $table.sleepTimerFadeOutSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultPlaybackSpeed => $composableBuilder(
    column: $table.defaultPlaybackSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoResume => $composableBuilder(
    column: $table.autoResume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipForwardSeconds => $composableBuilder(
    column: $table.skipForwardSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipBackwardSeconds => $composableBuilder(
    column: $table.skipBackwardSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monitoredFolders => $composableBuilder(
    column: $table.monitoredFolders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sleepTimerFadeOutEnabled => $composableBuilder(
    column: $table.sleepTimerFadeOutEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepTimerFadeOutSeconds => $composableBuilder(
    column: $table.sleepTimerFadeOutSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<double> get defaultVolume => $composableBuilder(
    column: $table.defaultVolume,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultPlaybackSpeed => $composableBuilder(
    column: $table.defaultPlaybackSpeed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoResume => $composableBuilder(
    column: $table.autoResume,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipForwardSeconds => $composableBuilder(
    column: $table.skipForwardSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipBackwardSeconds => $composableBuilder(
    column: $table.skipBackwardSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monitoredFolders => $composableBuilder(
    column: $table.monitoredFolders,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sleepTimerFadeOutEnabled => $composableBuilder(
    column: $table.sleepTimerFadeOutEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepTimerFadeOutSeconds => $composableBuilder(
    column: $table.sleepTimerFadeOutSeconds,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<double> defaultVolume = const Value.absent(),
                Value<double> defaultPlaybackSpeed = const Value.absent(),
                Value<bool> autoResume = const Value.absent(),
                Value<int> skipForwardSeconds = const Value.absent(),
                Value<int> skipBackwardSeconds = const Value.absent(),
                Value<String> monitoredFolders = const Value.absent(),
                Value<bool> sleepTimerFadeOutEnabled = const Value.absent(),
                Value<int> sleepTimerFadeOutSeconds = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                darkMode: darkMode,
                locale: locale,
                defaultVolume: defaultVolume,
                defaultPlaybackSpeed: defaultPlaybackSpeed,
                autoResume: autoResume,
                skipForwardSeconds: skipForwardSeconds,
                skipBackwardSeconds: skipBackwardSeconds,
                monitoredFolders: monitoredFolders,
                sleepTimerFadeOutEnabled: sleepTimerFadeOutEnabled,
                sleepTimerFadeOutSeconds: sleepTimerFadeOutSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<double> defaultVolume = const Value.absent(),
                Value<double> defaultPlaybackSpeed = const Value.absent(),
                Value<bool> autoResume = const Value.absent(),
                Value<int> skipForwardSeconds = const Value.absent(),
                Value<int> skipBackwardSeconds = const Value.absent(),
                Value<String> monitoredFolders = const Value.absent(),
                Value<bool> sleepTimerFadeOutEnabled = const Value.absent(),
                Value<int> sleepTimerFadeOutSeconds = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                darkMode: darkMode,
                locale: locale,
                defaultVolume: defaultVolume,
                defaultPlaybackSpeed: defaultPlaybackSpeed,
                autoResume: autoResume,
                skipForwardSeconds: skipForwardSeconds,
                skipBackwardSeconds: skipBackwardSeconds,
                monitoredFolders: monitoredFolders,
                sleepTimerFadeOutEnabled: sleepTimerFadeOutEnabled,
                sleepTimerFadeOutSeconds: sleepTimerFadeOutSeconds,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaybackStatesTableTableCreateCompanionBuilder =
    PlaybackStatesTableCompanion Function({
      Value<int> id,
      required String audioFilePath,
      required int positionMs,
      required DateTime savedAt,
      required double volume,
      required double playbackSpeed,
    });
typedef $$PlaybackStatesTableTableUpdateCompanionBuilder =
    PlaybackStatesTableCompanion Function({
      Value<int> id,
      Value<String> audioFilePath,
      Value<int> positionMs,
      Value<DateTime> savedAt,
      Value<double> volume,
      Value<double> playbackSpeed,
    });

class $$PlaybackStatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTableTable> {
  $$PlaybackStatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackStatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTableTable> {
  $$PlaybackStatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackStatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTableTable> {
  $$PlaybackStatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => column,
  );
}

class $$PlaybackStatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackStatesTableTable,
          PlaybackStatesTableData,
          $$PlaybackStatesTableTableFilterComposer,
          $$PlaybackStatesTableTableOrderingComposer,
          $$PlaybackStatesTableTableAnnotationComposer,
          $$PlaybackStatesTableTableCreateCompanionBuilder,
          $$PlaybackStatesTableTableUpdateCompanionBuilder,
          (
            PlaybackStatesTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaybackStatesTableTable,
              PlaybackStatesTableData
            >,
          ),
          PlaybackStatesTableData,
          PrefetchHooks Function()
        > {
  $$PlaybackStatesTableTableTableManager(
    _$AppDatabase db,
    $PlaybackStatesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlaybackStatesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$PlaybackStatesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PlaybackStatesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> audioFilePath = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<double> volume = const Value.absent(),
                Value<double> playbackSpeed = const Value.absent(),
              }) => PlaybackStatesTableCompanion(
                id: id,
                audioFilePath: audioFilePath,
                positionMs: positionMs,
                savedAt: savedAt,
                volume: volume,
                playbackSpeed: playbackSpeed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String audioFilePath,
                required int positionMs,
                required DateTime savedAt,
                required double volume,
                required double playbackSpeed,
              }) => PlaybackStatesTableCompanion.insert(
                id: id,
                audioFilePath: audioFilePath,
                positionMs: positionMs,
                savedAt: savedAt,
                volume: volume,
                playbackSpeed: playbackSpeed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackStatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackStatesTableTable,
      PlaybackStatesTableData,
      $$PlaybackStatesTableTableFilterComposer,
      $$PlaybackStatesTableTableOrderingComposer,
      $$PlaybackStatesTableTableAnnotationComposer,
      $$PlaybackStatesTableTableCreateCompanionBuilder,
      $$PlaybackStatesTableTableUpdateCompanionBuilder,
      (
        PlaybackStatesTableData,
        BaseReferences<
          _$AppDatabase,
          $PlaybackStatesTableTable,
          PlaybackStatesTableData
        >,
      ),
      PlaybackStatesTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PlaylistsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData
        > {
  $$PlaylistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistFilesTableTable,
    List<PlaylistFilesTableData>
  >
  _playlistFilesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistFilesTable,
        aliasName: $_aliasNameGenerator(
          db.playlistsTable.id,
          db.playlistFilesTable.playlistId,
        ),
      );

  $$PlaylistFilesTableTableProcessedTableManager get playlistFilesTableRefs {
    final manager = $$PlaylistFilesTableTableTableManager(
      $_db,
      $_db.playlistFilesTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistFilesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistFilesTableRefs(
    Expression<bool> Function($$PlaylistFilesTableTableFilterComposer f) f,
  ) {
    final $$PlaylistFilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistFilesTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistFilesTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistFilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistFilesTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistFilesTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistFilesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistFilesTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistFilesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistFilesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (PlaylistsTableData, $$PlaylistsTableTableReferences),
          PlaylistsTableData,
          PrefetchHooks Function({bool playlistFilesTableRefs})
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PlaylistsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PlaylistsTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistFilesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistFilesTableRefs) db.playlistFilesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistFilesTableRefs)
                    await $_getPrefetchedData<
                      PlaylistsTableData,
                      $PlaylistsTableTable,
                      PlaylistFilesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableTableReferences
                          ._playlistFilesTableRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PlaylistsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistFilesTableRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.playlistId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (PlaylistsTableData, $$PlaylistsTableTableReferences),
      PlaylistsTableData,
      PrefetchHooks Function({bool playlistFilesTableRefs})
    >;
typedef $$PlaylistFilesTableTableCreateCompanionBuilder =
    PlaylistFilesTableCompanion Function({
      required String playlistId,
      required String audioFileId,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PlaylistFilesTableTableUpdateCompanionBuilder =
    PlaylistFilesTableCompanion Function({
      Value<String> playlistId,
      Value<String> audioFileId,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PlaylistFilesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistFilesTableTable,
          PlaylistFilesTableData
        > {
  $$PlaylistFilesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTableTable _playlistIdTable(_$AppDatabase db) =>
      db.playlistsTable.createAlias(
        $_aliasNameGenerator(
          db.playlistFilesTable.playlistId,
          db.playlistsTable.id,
        ),
      );

  $$PlaylistsTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableTableManager(
      $_db,
      $_db.playlistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AudioFilesTableTable _audioFileIdTable(_$AppDatabase db) =>
      db.audioFilesTable.createAlias(
        $_aliasNameGenerator(
          db.playlistFilesTable.audioFileId,
          db.audioFilesTable.id,
        ),
      );

  $$AudioFilesTableTableProcessedTableManager get audioFileId {
    final $_column = $_itemColumn<String>('audio_file_id')!;

    final manager = $$AudioFilesTableTableTableManager(
      $_db,
      $_db.audioFilesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audioFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistFilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistFilesTableTable> {
  $$PlaylistFilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableTableFilterComposer get playlistId {
    final $$PlaylistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioFilesTableTableFilterComposer get audioFileId {
    final $$AudioFilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioFileId,
      referencedTable: $db.audioFilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioFilesTableTableFilterComposer(
            $db: $db,
            $table: $db.audioFilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistFilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistFilesTableTable> {
  $$PlaylistFilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableTableOrderingComposer get playlistId {
    final $$PlaylistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioFilesTableTableOrderingComposer get audioFileId {
    final $$AudioFilesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioFileId,
      referencedTable: $db.audioFilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioFilesTableTableOrderingComposer(
            $db: $db,
            $table: $db.audioFilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistFilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistFilesTableTable> {
  $$PlaylistFilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PlaylistsTableTableAnnotationComposer get playlistId {
    final $$PlaylistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioFilesTableTableAnnotationComposer get audioFileId {
    final $$AudioFilesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioFileId,
      referencedTable: $db.audioFilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioFilesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.audioFilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistFilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistFilesTableTable,
          PlaylistFilesTableData,
          $$PlaylistFilesTableTableFilterComposer,
          $$PlaylistFilesTableTableOrderingComposer,
          $$PlaylistFilesTableTableAnnotationComposer,
          $$PlaylistFilesTableTableCreateCompanionBuilder,
          $$PlaylistFilesTableTableUpdateCompanionBuilder,
          (PlaylistFilesTableData, $$PlaylistFilesTableTableReferences),
          PlaylistFilesTableData,
          PrefetchHooks Function({bool playlistId, bool audioFileId})
        > {
  $$PlaylistFilesTableTableTableManager(
    _$AppDatabase db,
    $PlaylistFilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlaylistFilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$PlaylistFilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PlaylistFilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> audioFileId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistFilesTableCompanion(
                playlistId: playlistId,
                audioFileId: audioFileId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String audioFileId,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistFilesTableCompanion.insert(
                playlistId: playlistId,
                audioFileId: audioFileId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PlaylistFilesTableTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({playlistId = false, audioFileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (playlistId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.playlistId,
                            referencedTable: $$PlaylistFilesTableTableReferences
                                ._playlistIdTable(db),
                            referencedColumn:
                                $$PlaylistFilesTableTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (audioFileId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.audioFileId,
                            referencedTable: $$PlaylistFilesTableTableReferences
                                ._audioFileIdTable(db),
                            referencedColumn:
                                $$PlaylistFilesTableTableReferences
                                    ._audioFileIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistFilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistFilesTableTable,
      PlaylistFilesTableData,
      $$PlaylistFilesTableTableFilterComposer,
      $$PlaylistFilesTableTableOrderingComposer,
      $$PlaylistFilesTableTableAnnotationComposer,
      $$PlaylistFilesTableTableCreateCompanionBuilder,
      $$PlaylistFilesTableTableUpdateCompanionBuilder,
      (PlaylistFilesTableData, $$PlaylistFilesTableTableReferences),
      PlaylistFilesTableData,
      PrefetchHooks Function({bool playlistId, bool audioFileId})
    >;
typedef $$FilePositionsTableTableCreateCompanionBuilder =
    FilePositionsTableCompanion Function({
      required String filePath,
      required int positionMs,
      Value<int> rowid,
    });
typedef $$FilePositionsTableTableUpdateCompanionBuilder =
    FilePositionsTableCompanion Function({
      Value<String> filePath,
      Value<int> positionMs,
      Value<int> rowid,
    });

class $$FilePositionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FilePositionsTableTable> {
  $$FilePositionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FilePositionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FilePositionsTableTable> {
  $$FilePositionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FilePositionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FilePositionsTableTable> {
  $$FilePositionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );
}

class $$FilePositionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FilePositionsTableTable,
          FilePositionsTableData,
          $$FilePositionsTableTableFilterComposer,
          $$FilePositionsTableTableOrderingComposer,
          $$FilePositionsTableTableAnnotationComposer,
          $$FilePositionsTableTableCreateCompanionBuilder,
          $$FilePositionsTableTableUpdateCompanionBuilder,
          (
            FilePositionsTableData,
            BaseReferences<
              _$AppDatabase,
              $FilePositionsTableTable,
              FilePositionsTableData
            >,
          ),
          FilePositionsTableData,
          PrefetchHooks Function()
        > {
  $$FilePositionsTableTableTableManager(
    _$AppDatabase db,
    $FilePositionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FilePositionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$FilePositionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FilePositionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> filePath = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilePositionsTableCompanion(
                filePath: filePath,
                positionMs: positionMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String filePath,
                required int positionMs,
                Value<int> rowid = const Value.absent(),
              }) => FilePositionsTableCompanion.insert(
                filePath: filePath,
                positionMs: positionMs,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FilePositionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FilePositionsTableTable,
      FilePositionsTableData,
      $$FilePositionsTableTableFilterComposer,
      $$FilePositionsTableTableOrderingComposer,
      $$FilePositionsTableTableAnnotationComposer,
      $$FilePositionsTableTableCreateCompanionBuilder,
      $$FilePositionsTableTableUpdateCompanionBuilder,
      (
        FilePositionsTableData,
        BaseReferences<
          _$AppDatabase,
          $FilePositionsTableTable,
          FilePositionsTableData
        >,
      ),
      FilePositionsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AudioFilesTableTableTableManager get audioFilesTable =>
      $$AudioFilesTableTableTableManager(_db, _db.audioFilesTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$PlaybackStatesTableTableTableManager get playbackStatesTable =>
      $$PlaybackStatesTableTableTableManager(_db, _db.playbackStatesTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistFilesTableTableTableManager get playlistFilesTable =>
      $$PlaylistFilesTableTableTableManager(_db, _db.playlistFilesTable);
  $$FilePositionsTableTableTableManager get filePositionsTable =>
      $$FilePositionsTableTableTableManager(_db, _db.filePositionsTable);
}
