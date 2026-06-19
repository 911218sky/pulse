import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/sync/update_check_sync.dart';
import 'package:pulse/domain/entities/settings.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/controllers/update_flow_controller.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  final Settings settings;
  final _controller = StreamController<Settings>.broadcast();

  @override
  Future<Settings> loadSettings() async => settings;

  @override
  Future<void> resetAllData() async {}

  @override
  Future<void> resetSettings() async {}

  @override
  Future<void> saveSettings(Settings settings) async {}

  @override
  Stream<Settings> get settingsStream => _controller.stream;

  @override
  Future<void> updateSetting<T>(String key, T value) async {}

  Future<void> dispose() => _controller.close();
}

class _FakeUpdateFlowController extends UpdateFlowController {
  _FakeUpdateFlowController(this.outcomes);

  final List<UpdateCheckOutcome> outcomes;
  final List<UpdateCheckTrigger> triggers = [];

  @override
  Future<UpdateCheckOutcome> checkForUpdate(
    BuildContext context, {
    UpdateCheckTrigger trigger = UpdateCheckTrigger.manual,
  }) async {
    triggers.add(trigger);
    if (outcomes.isEmpty) return UpdateCheckOutcome.upToDate;
    return outcomes.removeAt(0);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUpdateCheckSync(
    WidgetTester tester, {
    required UpdateFlowController updateFlow,
    required _FakeSettingsRepository repository,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    final settingsBloc = SettingsBloc(settingsRepository: repository);
    BuildContext? updateContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            updateContext ??= context;
            return BlocProvider.value(
              value: settingsBloc..add(const SettingsLoad()),
              child: UpdateCheckSync(
                updateFlow: updateFlow,
                retryDelay: retryDelay,
                updateContextProvider: () => updateContext,
                child: const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'does not retry automatic update checks when already up to date',
    (tester) async {
      final repository = _FakeSettingsRepository(
        Settings.defaults.copyWith(autoUpdateEnabled: true),
      );
      final updateFlow = _FakeUpdateFlowController([
        UpdateCheckOutcome.upToDate,
      ]);

      await pumpUpdateCheckSync(
        tester,
        updateFlow: updateFlow,
        repository: repository,
      );
      await tester.pump();

      expect(updateFlow.triggers, [UpdateCheckTrigger.automatic]);

      await tester.pump(const Duration(milliseconds: 150));
      expect(updateFlow.triggers, [UpdateCheckTrigger.automatic]);

      await repository.dispose();
    },
  );

  testWidgets('retries automatic update checks once after a failure', (
    tester,
  ) async {
    final repository = _FakeSettingsRepository(
      Settings.defaults.copyWith(autoUpdateEnabled: true),
    );
    final updateFlow = _FakeUpdateFlowController([
      UpdateCheckOutcome.failed,
      UpdateCheckOutcome.upToDate,
    ]);

    await pumpUpdateCheckSync(
      tester,
      updateFlow: updateFlow,
      repository: repository,
    );

    expect(updateFlow.triggers, [UpdateCheckTrigger.automatic]);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();

    expect(updateFlow.triggers, [
      UpdateCheckTrigger.automatic,
      UpdateCheckTrigger.automatic,
    ]);

    await repository.dispose();
  });
}
