import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/media_file_delete_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.pulse.app/device');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('maps Android deleted payload to deleted outcome', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'deleteMediaFile');
      expect(call.arguments, {'path': '/music/a.mp3'});
      return {'deleted': true};
    });

    final service = MediaFileDeleteService(
      isAndroid: true,
      ioDelete: (_) async => fail('ioDelete should not be used on Android'),
    );

    expect(
      await service.deleteFile('/music/a.mp3'),
      MediaDeleteOutcome.deleted,
    );
  });

  test('maps Android cancelled payload to cancelled outcome', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => {'deleted': false, 'cancelled': true},
    );

    final service = MediaFileDeleteService(
      isAndroid: true,
      ioDelete: (_) async => true,
    );

    expect(
      await service.deleteFile('/music/a.mp3'),
      MediaDeleteOutcome.cancelled,
    );
  });

  test('maps Android failure payload to failed outcome', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => {'deleted': false, 'reason': 'media_store_uri_not_found'},
    );

    final service = MediaFileDeleteService(
      isAndroid: true,
      ioDelete: (_) async => true,
    );

    expect(await service.deleteFile('/music/a.mp3'), MediaDeleteOutcome.failed);
  });

  test('falls back to ioDelete when plugin is missing', () async {
    messenger.setMockMethodCallHandler(channel, null);

    var ioCalled = false;
    final service = MediaFileDeleteService(
      isAndroid: true,
      ioDelete: (path) async {
        ioCalled = true;
        expect(path, '/music/a.mp3');
        return true;
      },
    );

    expect(
      await service.deleteFile('/music/a.mp3'),
      MediaDeleteOutcome.deleted,
    );
    expect(ioCalled, isTrue);
  });

  test('empty path fails without calling channel', () async {
    var channelCalled = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      channelCalled = true;
      return {'deleted': true};
    });

    final service = MediaFileDeleteService();
    expect(await service.deleteFile('  '), MediaDeleteOutcome.failed);
    expect(channelCalled, isFalse);
  });
}
