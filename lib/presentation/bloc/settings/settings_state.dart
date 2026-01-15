import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/settings.dart';

/// Status of settings operations
enum SettingsStatus { initial, loading, loaded, saving, error }

/// State for SettingsBloc
class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = Settings.defaults,
    this.errorMessage,
  });

  final SettingsStatus status;
  final Settings settings;
  final String? errorMessage;

  /// Whether settings are loaded
  bool get isLoaded => status == SettingsStatus.loaded;

  SettingsState copyWith({
    SettingsStatus? status,
    Settings? settings,
    String? errorMessage,
  }) => SettingsState(
    status: status ?? this.status,
    settings: settings ?? this.settings,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
