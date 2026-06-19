import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/services/update_check_service.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/domain/entities/app_update.dart';
import 'package:pulse/presentation/controllers/update_flow_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await resetServiceLocator();
  });

  test('clearSkippedVersion removes the skipped update marker', () async {
    SharedPreferences.setMockInitialValues({
      'skipped_update_version': '0.1.28',
    });
    const controller = UpdateFlowController();

    await controller.clearSkippedVersion();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('skipped_update_version'), isNull);
  });

  testWidgets(
    'downloadAndOpen shows a link error when release page fallback cannot be opened',
    (tester) async {
      late BuildContext context;
      final controller = UpdateFlowController(
        launchExternalUrl: (_, {required mode}) async => false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('zh', 'CN'),
            Locale('en'),
          ],
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await controller.downloadAndOpen(context, _releasePageUpdate);
      await tester.pump();

      expect(find.text('Pulse could not open the update link'), findsOneWidget);
    },
  );

  testWidgets(
    'download failures fall back to the release page instead of the asset URL',
    (tester) async {
      await resetServiceLocator();
      sl.registerSingleton<UpdateDownloadService>(
        const _FakeUpdateDownloadService(),
      );

      late BuildContext context;
      final launchedUrls = <Uri>[];
      final controller = UpdateFlowController(
        launchExternalUrl: (url, {required mode}) async {
          launchedUrls.add(url);
          return true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('zh', 'CN'),
            Locale('en'),
          ],
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await controller.downloadAndOpen(context, _directDownloadUpdate);
      await tester.pump();

      expect(launchedUrls, [_directDownloadUpdate.releaseUrl]);
    },
  );

  testWidgets(
    'manual update install failures do not surface update check failed',
    (tester) async {
      await resetServiceLocator();
      sl
        ..registerSingleton<UpdateCheckService>(
          _FakeUpdateCheckService(_directDownloadUpdate),
        )
        ..registerSingleton<UpdateDownloadService>(
          const _FakeUpdateDownloadService(),
        );

      late BuildContext context;
      final controller = UpdateFlowController(
        launchExternalUrl: (_, {required mode}) async => false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('zh', 'CN'),
            Locale('en'),
          ],
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final outcomeFuture = controller.checkForUpdate(context);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Install Now'));
      await tester.pumpAndSettle();

      final outcome = await outcomeFuture;
      expect(outcome, UpdateCheckOutcome.updateAvailable);
      expect(find.text('Update check failed'), findsNothing);
      expect(find.text('Pulse could not open the update link'), findsOneWidget);
    },
  );
}

final _releasePageUpdate = AppUpdate(
  currentVersion: '0.1.27',
  version: '0.1.28',
  releaseUrl: Uri.parse(
    'https://github.com/911218sky/pulse/releases/tag/v0.1.28',
  ),
  selectedAsset: UpdateAsset(
    name: 'GitHub Releases',
    downloadUrl: Uri.parse(
      'https://github.com/911218sky/pulse/releases/tag/v0.1.28',
    ),
    canDownloadDirectly: false,
  ),
);

final _directDownloadUpdate = AppUpdate(
  currentVersion: '0.1.27',
  version: '0.1.28',
  releaseUrl: Uri.parse(
    'https://github.com/911218sky/pulse/releases/tag/v0.1.28',
  ),
  selectedAsset: UpdateAsset(
    name: 'pulse-android-universal.apk',
    downloadUrl: Uri.parse(
      'https://github.com/911218sky/pulse/releases/download/v0.1.28/pulse-android-universal.apk',
    ),
    canDownloadDirectly: true,
  ),
);

class _FakeUpdateCheckService implements UpdateCheckService {
  _FakeUpdateCheckService(this.update);

  final AppUpdate? update;

  @override
  Future<AppUpdate?> checkForUpdate() async => update;
}

class _FakeUpdateDownloadService implements UpdateDownloadService {
  const _FakeUpdateDownloadService();

  @override
  Future<void> cleanDownloadedInstallers({
    File? keep,
    Duration delay = Duration.zero,
  }) async {}

  @override
  Future<File> download(
    AppUpdate update, {
    UpdateDownloadProgress? onProgress,
  }) async => throw const FileSystemException('network failed');

  @override
  Future<void> openInstaller(File file) async {}
}
