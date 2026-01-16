import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/utils/playback_speed_utils.dart';
import 'package:pulse/core/utils/volume_utils.dart';
import 'package:pulse/domain/entities/settings.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';

/// BLoC for managing application settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const SettingsState()) {
    on<SettingsLoad>(_onLoad);
    on<SettingsUpdateDarkMode>(_onUpdateDarkMode);
    on<SettingsUpdateDefaultVolume>(_onUpdateDefaultVolume);
    on<SettingsUpdateDefaultSpeed>(_onUpdateDefaultSpeed);
    on<SettingsUpdateAutoResume>(_onUpdateAutoResume);
    on<SettingsUpdateSkipForward>(_onUpdateSkipForward);
    on<SettingsUpdateSkipBackward>(_onUpdateSkipBackward);
    on<SettingsAddMonitoredFolder>(_onAddMonitoredFolder);
    on<SettingsRemoveMonitoredFolder>(_onRemoveMonitoredFolder);
    on<SettingsReset>(_onReset);
    on<SettingsResetAll>(_onResetAll);
    on<SettingsUpdateLocale>(_onUpdateLocale);
    on<SettingsUpdateNavigateToPlayerOnResume>(
      _onUpdateNavigateToPlayerOnResume,
    );

    _subscribeToSettings();
  }

  final SettingsRepository _settingsRepository;
  StreamSubscription<dynamic>? _settingsSubscription;

  void _subscribeToSettings() {
    _settingsSubscription = _settingsRepository.settingsStream.listen(
      (settings) => add(const SettingsLoad()),
    );
  }

  Future<void> _onLoad(SettingsLoad event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final settings = await _settingsRepository.loadSettings();
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateDarkMode(
    SettingsUpdateDarkMode event,
    Emitter<SettingsState> emit,
  ) async =>
      _updateSettings(emit, state.settings.copyWith(darkMode: event.enabled));

  Future<void> _onUpdateDefaultVolume(
    SettingsUpdateDefaultVolume event,
    Emitter<SettingsState> emit,
  ) async => _updateSettings(
    emit,
    state.settings.copyWith(defaultVolume: VolumeUtils.clamp(event.volume)),
  );

  Future<void> _onUpdateDefaultSpeed(
    SettingsUpdateDefaultSpeed event,
    Emitter<SettingsState> emit,
  ) async => _updateSettings(
    emit,
    state.settings.copyWith(
      defaultPlaybackSpeed: PlaybackSpeedUtils.clamp(event.speed),
    ),
  );

  Future<void> _onUpdateAutoResume(
    SettingsUpdateAutoResume event,
    Emitter<SettingsState> emit,
  ) async =>
      _updateSettings(emit, state.settings.copyWith(autoResume: event.enabled));

  Future<void> _onUpdateSkipForward(
    SettingsUpdateSkipForward event,
    Emitter<SettingsState> emit,
  ) async => _updateSettings(
    emit,
    state.settings.copyWith(skipForwardSeconds: event.seconds.clamp(5, 60)),
  );

  Future<void> _onUpdateSkipBackward(
    SettingsUpdateSkipBackward event,
    Emitter<SettingsState> emit,
  ) async => _updateSettings(
    emit,
    state.settings.copyWith(skipBackwardSeconds: event.seconds.clamp(5, 60)),
  );

  Future<void> _onAddMonitoredFolder(
    SettingsAddMonitoredFolder event,
    Emitter<SettingsState> emit,
  ) async {
    final currentFolders = List<String>.from(state.settings.monitoredFolders);
    if (!currentFolders.contains(event.folderPath)) {
      currentFolders.add(event.folderPath);
      await _updateSettings(
        emit,
        state.settings.copyWith(monitoredFolders: currentFolders),
      );
    }
  }

  Future<void> _onRemoveMonitoredFolder(
    SettingsRemoveMonitoredFolder event,
    Emitter<SettingsState> emit,
  ) async {
    final currentFolders = List<String>.from(state.settings.monitoredFolders)
      ..remove(event.folderPath);
    await _updateSettings(
      emit,
      state.settings.copyWith(monitoredFolders: currentFolders),
    );
  }

  Future<void> _onReset(
    SettingsReset event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.saving));

    try {
      await _settingsRepository.resetSettings();
      final settings = await _settingsRepository.loadSettings();
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onResetAll(
    SettingsResetAll event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.saving));

    try {
      await _settingsRepository.resetAllData();
      final settings = await _settingsRepository.loadSettings();
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateLocale(
    SettingsUpdateLocale event,
    Emitter<SettingsState> emit,
  ) async =>
      _updateSettings(emit, state.settings.copyWith(locale: event.locale));

  Future<void> _onUpdateNavigateToPlayerOnResume(
    SettingsUpdateNavigateToPlayerOnResume event,
    Emitter<SettingsState> emit,
  ) async => _updateSettings(
    emit,
    state.settings.copyWith(navigateToPlayerOnResume: event.enabled),
  );

  Future<void> _updateSettings(
    Emitter<SettingsState> emit,
    Settings newSettings,
  ) async {
    emit(state.copyWith(status: SettingsStatus.saving));

    try {
      await _settingsRepository.saveSettings(newSettings);
      emit(
        state.copyWith(status: SettingsStatus.loaded, settings: newSettings),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
