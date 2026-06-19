import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/domain/entities/settings.dart';

/// Settings data model for database operations
class SettingsModel {
  SettingsModel({
    required this.darkMode,
    required this.locale,
    required this.defaultVolume,
    required this.defaultPlaybackSpeed,
    required this.autoResume,
    required this.resumePlaybackOnTrackTap,
    required this.skipForwardSeconds,
    required this.skipBackwardSeconds,
    required this.monitoredFolders,
    required this.sleepTimerFadeOutEnabled,
    required this.sleepTimerFadeOutSeconds,
    required this.navigateToPlayerOnResume,
    required this.autoUpdateEnabled,
  });

  factory SettingsModel.fromEntity(Settings entity) => SettingsModel(
    darkMode: entity.darkMode,
    locale: entity.locale,
    defaultVolume: entity.defaultVolume,
    defaultPlaybackSpeed: entity.defaultPlaybackSpeed,
    autoResume: entity.autoResume,
    resumePlaybackOnTrackTap: entity.resumePlaybackOnTrackTap,
    skipForwardSeconds: entity.skipForwardSeconds,
    skipBackwardSeconds: entity.skipBackwardSeconds,
    monitoredFolders: entity.monitoredFolders,
    sleepTimerFadeOutEnabled: entity.sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds: entity.sleepTimerFadeOutSeconds,
    navigateToPlayerOnResume: entity.navigateToPlayerOnResume,
    autoUpdateEnabled: entity.autoUpdateEnabled,
  );

  factory SettingsModel.fromDrift(SettingsTableData row) => SettingsModel(
    darkMode: row.darkMode,
    locale: row.locale,
    defaultVolume: row.defaultVolume,
    defaultPlaybackSpeed: row.defaultPlaybackSpeed,
    autoResume: row.autoResume,
    resumePlaybackOnTrackTap: row.resumePlaybackOnTrackTap,
    skipForwardSeconds: row.skipForwardSeconds,
    skipBackwardSeconds: row.skipBackwardSeconds,
    monitoredFolders: _parseMonitoredFolders(row.monitoredFolders),
    sleepTimerFadeOutEnabled: row.sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds: row.sleepTimerFadeOutSeconds,
    navigateToPlayerOnResume: row.navigateToPlayerOnResume,
    autoUpdateEnabled: row.autoUpdateEnabled,
  );

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    darkMode: json['darkMode'] as bool? ?? true,
    locale: json['locale'] as String? ?? 'zh_TW',
    defaultVolume: (json['defaultVolume'] as num?)?.toDouble() ?? 1,
    defaultPlaybackSpeed:
        (json['defaultPlaybackSpeed'] as num?)?.toDouble() ?? 1,
    autoResume: json['autoResume'] as bool? ?? true,
    resumePlaybackOnTrackTap: json['resumePlaybackOnTrackTap'] as bool? ?? true,
    skipForwardSeconds: json['skipForwardSeconds'] as int? ?? 10,
    skipBackwardSeconds: json['skipBackwardSeconds'] as int? ?? 10,
    monitoredFolders:
        (json['monitoredFolders'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    sleepTimerFadeOutEnabled: json['sleepTimerFadeOutEnabled'] as bool? ?? true,
    sleepTimerFadeOutSeconds: json['sleepTimerFadeOutSeconds'] as int? ?? 5,
    navigateToPlayerOnResume:
        json['navigateToPlayerOnResume'] as bool? ?? false,
    autoUpdateEnabled: json['autoUpdateEnabled'] as bool? ?? true,
  );

  factory SettingsModel.defaults() => SettingsModel(
    darkMode: true,
    locale: 'zh_TW',
    defaultVolume: 1,
    defaultPlaybackSpeed: 1,
    autoResume: true,
    resumePlaybackOnTrackTap: true,
    skipForwardSeconds: 10,
    skipBackwardSeconds: 10,
    monitoredFolders: [],
    sleepTimerFadeOutEnabled: true,
    sleepTimerFadeOutSeconds: 5,
    navigateToPlayerOnResume: false,
    autoUpdateEnabled: true,
  );

  final bool darkMode;
  final String locale;
  final double defaultVolume;
  final double defaultPlaybackSpeed;
  final bool autoResume;
  final bool resumePlaybackOnTrackTap;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  final List<String> monitoredFolders;
  final bool sleepTimerFadeOutEnabled;
  final int sleepTimerFadeOutSeconds;
  final bool navigateToPlayerOnResume;
  final bool autoUpdateEnabled;

  Settings toEntity() => Settings(
    darkMode: darkMode,
    locale: locale,
    defaultVolume: defaultVolume,
    defaultPlaybackSpeed: defaultPlaybackSpeed,
    autoResume: autoResume,
    resumePlaybackOnTrackTap: resumePlaybackOnTrackTap,
    skipForwardSeconds: skipForwardSeconds,
    skipBackwardSeconds: skipBackwardSeconds,
    monitoredFolders: monitoredFolders,
    sleepTimerFadeOutEnabled: sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds: sleepTimerFadeOutSeconds,
    navigateToPlayerOnResume: navigateToPlayerOnResume,
    autoUpdateEnabled: autoUpdateEnabled,
  );

  SettingsTableCompanion toCompanion() => SettingsTableCompanion(
    darkMode: Value(darkMode),
    locale: Value(locale),
    defaultVolume: Value(defaultVolume),
    defaultPlaybackSpeed: Value(defaultPlaybackSpeed),
    autoResume: Value(autoResume),
    resumePlaybackOnTrackTap: Value(resumePlaybackOnTrackTap),
    skipForwardSeconds: Value(skipForwardSeconds),
    skipBackwardSeconds: Value(skipBackwardSeconds),
    monitoredFolders: Value(jsonEncode(monitoredFolders)),
    sleepTimerFadeOutEnabled: Value(sleepTimerFadeOutEnabled),
    sleepTimerFadeOutSeconds: Value(sleepTimerFadeOutSeconds),
    navigateToPlayerOnResume: Value(navigateToPlayerOnResume),
    autoUpdateEnabled: Value(autoUpdateEnabled),
  );

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'locale': locale,
    'defaultVolume': defaultVolume,
    'defaultPlaybackSpeed': defaultPlaybackSpeed,
    'autoResume': autoResume,
    'resumePlaybackOnTrackTap': resumePlaybackOnTrackTap,
    'skipForwardSeconds': skipForwardSeconds,
    'skipBackwardSeconds': skipBackwardSeconds,
    'monitoredFolders': monitoredFolders,
    'sleepTimerFadeOutEnabled': sleepTimerFadeOutEnabled,
    'sleepTimerFadeOutSeconds': sleepTimerFadeOutSeconds,
    'navigateToPlayerOnResume': navigateToPlayerOnResume,
    'autoUpdateEnabled': autoUpdateEnabled,
  };

  static List<String> _parseMonitoredFolders(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } on FormatException {
      return [];
    }
  }
}
