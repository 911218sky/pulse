import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/repositories/settings_repository_impl.dart';
import 'package:pulse/presentation/controllers/update_flow_controller.dart';

class _MockLocalStorageDataSource extends Mock
    implements LocalStorageDataSource {}

class _MockUpdateFlowController extends Mock implements UpdateFlowController {}

void main() {
  late _MockLocalStorageDataSource dataSource;
  late _MockUpdateFlowController updateFlowController;
  late SettingsRepositoryImpl repository;

  setUp(() {
    dataSource = _MockLocalStorageDataSource();
    updateFlowController = _MockUpdateFlowController();
    repository = SettingsRepositoryImpl(
      dataSource,
      updateFlowController: updateFlowController,
    );
    when(() => dataSource.clearAllData()).thenAnswer((_) async {});
    when(
      () => updateFlowController.clearSkippedVersion(),
    ).thenAnswer((_) async {});
  });

  test('resetAllData clears all persisted local data', () async {
    await repository.resetAllData();

    verify(() => dataSource.clearAllData()).called(1);
    verify(() => updateFlowController.clearSkippedVersion()).called(1);
  });
}
