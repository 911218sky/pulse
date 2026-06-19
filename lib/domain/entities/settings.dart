import 'package:equatable/equatable.dart';

/// Application settings
class Settings extends Equatable {
  const Settings({
    this.darkMode = true,
    this.locale = 'zh_TW',
    this.defaultVolume = 1.0,
    this.defaultPlaybackSpeed = 1.0,
    this.autoResume = true,
    this.resumePlaybackOnTrackTap = true,
    this.skipForwardSeconds = 10,
    this.skipBackwardSeconds = 10,
    this.monitoredFolders = const [],
    this.sleepTimerFadeOutEnabled = true,
    this.sleepTimerFadeOutSeconds = 5,
    this.navigateToPlayerOnResume = false,
    this.autoUpdateEnabled = true,
  });

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

  static const Settings defaults = Settings();

  Settings copyWith({
    bool? darkMode,
    String? locale,
    double? defaultVolume,
    double? defaultPlaybackSpeed,
    bool? autoResume,
    bool? resumePlaybackOnTrackTap,
    int? skipForwardSeconds,
    int? skipBackwardSeconds,
    List<String>? monitoredFolders,
    bool? sleepTimerFadeOutEnabled,
    int? sleepTimerFadeOutSeconds,
    bool? navigateToPlayerOnResume,
    bool? autoUpdateEnabled,
  }) => Settings(
    darkMode: darkMode ?? this.darkMode,
    locale: locale ?? this.locale,
    defaultVolume: defaultVolume ?? this.defaultVolume,
    defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
    autoResume: autoResume ?? this.autoResume,
    resumePlaybackOnTrackTap:
        resumePlaybackOnTrackTap ?? this.resumePlaybackOnTrackTap,
    skipForwardSeconds: skipForwardSeconds ?? this.skipForwardSeconds,
    skipBackwardSeconds: skipBackwardSeconds ?? this.skipBackwardSeconds,
    monitoredFolders: monitoredFolders ?? this.monitoredFolders,
    sleepTimerFadeOutEnabled:
        sleepTimerFadeOutEnabled ?? this.sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds:
        sleepTimerFadeOutSeconds ?? this.sleepTimerFadeOutSeconds,
    navigateToPlayerOnResume:
        navigateToPlayerOnResume ?? this.navigateToPlayerOnResume,
    autoUpdateEnabled: autoUpdateEnabled ?? this.autoUpdateEnabled,
  );

  @override
  List<Object?> get props => [
    darkMode,
    locale,
    defaultVolume,
    defaultPlaybackSpeed,
    autoResume,
    resumePlaybackOnTrackTap,
    skipForwardSeconds,
    skipBackwardSeconds,
    monitoredFolders,
    sleepTimerFadeOutEnabled,
    sleepTimerFadeOutSeconds,
    navigateToPlayerOnResume,
    autoUpdateEnabled,
  ];
}
