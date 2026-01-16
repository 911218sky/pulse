import 'package:equatable/equatable.dart';

/// Events for SettingsBloc
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings from storage
class SettingsLoad extends SettingsEvent {
  const SettingsLoad();
}

/// Update dark mode setting
class SettingsUpdateDarkMode extends SettingsEvent {
  const SettingsUpdateDarkMode({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Update default volume setting
class SettingsUpdateDefaultVolume extends SettingsEvent {
  const SettingsUpdateDefaultVolume(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

/// Update default playback speed setting
class SettingsUpdateDefaultSpeed extends SettingsEvent {
  const SettingsUpdateDefaultSpeed(this.speed);

  final double speed;

  @override
  List<Object?> get props => [speed];
}

/// Update auto resume setting
class SettingsUpdateAutoResume extends SettingsEvent {
  const SettingsUpdateAutoResume({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Update skip forward seconds setting
class SettingsUpdateSkipForward extends SettingsEvent {
  const SettingsUpdateSkipForward(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

/// Update skip backward seconds setting
class SettingsUpdateSkipBackward extends SettingsEvent {
  const SettingsUpdateSkipBackward(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

/// Add a monitored folder
class SettingsAddMonitoredFolder extends SettingsEvent {
  const SettingsAddMonitoredFolder(this.folderPath);

  final String folderPath;

  @override
  List<Object?> get props => [folderPath];
}

/// Remove a monitored folder
class SettingsRemoveMonitoredFolder extends SettingsEvent {
  const SettingsRemoveMonitoredFolder(this.folderPath);

  final String folderPath;

  @override
  List<Object?> get props => [folderPath];
}

/// Reset all settings to defaults
class SettingsReset extends SettingsEvent {
  const SettingsReset();
}

/// Reset all data (settings, music library, playback history, etc.)
class SettingsResetAll extends SettingsEvent {
  const SettingsResetAll();
}

/// Update locale setting
class SettingsUpdateLocale extends SettingsEvent {
  const SettingsUpdateLocale(this.locale);

  final String locale;

  @override
  List<Object?> get props => [locale];
}

/// Update sleep timer duration
class SettingsUpdateSleepTimer extends SettingsEvent {
  const SettingsUpdateSleepTimer(this.duration);

  final Duration duration;

  @override
  List<Object?> get props => [duration];
}
