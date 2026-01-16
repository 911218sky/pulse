import 'package:equatable/equatable.dart';

/// Application settings
class Settings extends Equatable {
  const Settings({
    this.darkMode = true,
    this.locale = 'en',
    this.defaultVolume = 1.0,
    this.defaultPlaybackSpeed = 1.0,
    this.autoResume = true,
    this.skipForwardSeconds = 10,
    this.skipBackwardSeconds = 10,
    this.monitoredFolders = const [],
    this.sleepTimerFadeOutEnabled = true,
    this.sleepTimerFadeOutSeconds = 5,
  });

  final bool darkMode;
  final String locale; // 'zh_TW' or 'en'
  final double defaultVolume;
  final double defaultPlaybackSpeed;
  final bool autoResume;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  final List<String> monitoredFolders;
  final bool sleepTimerFadeOutEnabled;
  final int sleepTimerFadeOutSeconds;

  /// Default settings
  static const Settings defaults = Settings();

  /// Creates a copy with updated fields
  Settings copyWith({
    bool? darkMode,
    String? locale,
    double? defaultVolume,
    double? defaultPlaybackSpeed,
    bool? autoResume,
    int? skipForwardSeconds,
    int? skipBackwardSeconds,
    List<String>? monitoredFolders,
    bool? sleepTimerFadeOutEnabled,
    int? sleepTimerFadeOutSeconds,
  }) => Settings(
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

  @override
  List<Object?> get props => [
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
}
