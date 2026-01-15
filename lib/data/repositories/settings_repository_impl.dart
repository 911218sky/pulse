import 'dart:async';

import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/settings_model.dart';
import 'package:pulse/domain/entities/settings.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';

/// Implementation of SettingsRepository using local storage
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final LocalStorageDataSource _dataSource;
  final _settingsController = StreamController<Settings>.broadcast();

  @override
  Future<Settings> loadSettings() async {
    final model = await _dataSource.getSettings();
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    final model = SettingsModel.fromEntity(settings);
    await _dataSource.saveSettings(model);
    _settingsController.add(settings);
  }

  @override
  Future<void> resetSettings() async {
    await _dataSource.clearSettings();
    _settingsController.add(Settings.defaults);
  }

  @override
  Future<void> resetAllData() async {
    await _dataSource.clearAllData();
    _settingsController.add(Settings.defaults);
  }

  @override
  Stream<Settings> get settingsStream => _settingsController.stream;

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    final current = await loadSettings();
    final updated = _updateSettingByKey(current, key, value);
    await saveSettings(updated);
  }

  Settings _updateSettingByKey<T>(Settings settings, String key, T value) {
    switch (key) {
      case 'darkMode':
        return settings.copyWith(darkMode: value as bool);
      case 'defaultVolume':
        return settings.copyWith(defaultVolume: value as double);
      case 'defaultPlaybackSpeed':
        return settings.copyWith(defaultPlaybackSpeed: value as double);
      case 'autoResume':
        return settings.copyWith(autoResume: value as bool);
      case 'skipForwardSeconds':
        return settings.copyWith(skipForwardSeconds: value as int);
      case 'skipBackwardSeconds':
        return settings.copyWith(skipBackwardSeconds: value as int);
      case 'monitoredFolders':
        return settings.copyWith(monitoredFolders: value as List<String>);
      default:
        return settings;
    }
  }

  void dispose() {
    _settingsController.close();
  }
}
