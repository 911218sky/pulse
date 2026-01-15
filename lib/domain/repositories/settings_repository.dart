import 'package:pulse/domain/entities/settings.dart';

/// Repository interface for application settings
abstract class SettingsRepository {
  /// Loads the saved settings
  Future<Settings> loadSettings();

  /// Saves the settings
  Future<void> saveSettings(Settings settings);

  /// Resets settings to defaults
  Future<void> resetSettings();

  /// Resets all data (settings, music library, playlists, playback history, etc.)
  Future<void> resetAllData();

  /// Stream of settings changes
  Stream<Settings> get settingsStream;

  /// Updates a single setting value
  Future<void> updateSetting<T>(String key, T value);
}
