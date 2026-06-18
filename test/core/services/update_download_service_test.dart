import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/domain/entities/app_update.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pulse-update-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('reuses a fully downloaded installer for the same update', () async {
    final cachedFile = File(
      '${tempDir.path}/pulse-0.1.25-pulse-android-universal.apk',
    );
    await cachedFile.writeAsBytes([1, 2, 3]);
    final httpClient = _FailingHttpClient();
    final service = UpdateDownloadService(httpClient: httpClient);

    final file = await service.download(_update());

    expect(file.path, cachedFile.path);
    expect(file.readAsBytesSync(), [1, 2, 3]);
    expect(httpClient.requested, isFalse);
  });

  test('clears older cached installers after a new update downloads', () async {
    final oldFile = File(
      '${tempDir.path}/pulse-0.1.24-pulse-android-universal.apk',
    );
    await oldFile.writeAsBytes([0]);
    final httpClient = _SuccessfulHttpClient([4, 5, 6]);
    final service = UpdateDownloadService(httpClient: httpClient);

    final file = await service.download(_update());

    expect(file.readAsBytesSync(), [4, 5, 6]);
    expect(oldFile.existsSync(), isFalse);
    expect(file.existsSync(), isTrue);
  });

  test('does not cache incomplete downloads as installers', () async {
    final file = File(
      '${tempDir.path}/pulse-0.1.25-pulse-android-universal.apk',
    );
    final httpClient = _SuccessfulHttpClient([7, 8], contentLength: 3);
    final service = UpdateDownloadService(httpClient: httpClient);

    await expectLater(
      service.download(_update()),
      throwsA(isA<HttpException>()),
    );

    expect(file.existsSync(), isFalse);
    expect(File('${file.path}.download').existsSync(), isFalse);
  });
}

AppUpdate _update() => AppUpdate(
  currentVersion: '0.1.24',
  version: '0.1.25',
  releaseUrl: Uri.parse(
    'https://github.com/911218sky/pulse/releases/tag/v0.1.25',
  ),
  selectedAsset: UpdateAsset(
    name: 'pulse-android-universal.apk',
    downloadUrl: Uri.parse(
      'https://github.com/911218sky/pulse/releases/download/v0.1.25/pulse-android-universal.apk',
    ),
    canDownloadDirectly: true,
  ),
);

class _FailingHttpClient implements HttpClient {
  bool requested = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requested = true;
    throw StateError('network should not be used for cached installers');
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SuccessfulHttpClient implements HttpClient {
  _SuccessfulHttpClient(this.bytes, {int? contentLength})
    : contentLength = contentLength ?? bytes.length;

  final List<int> bytes;
  final int contentLength;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _SuccessfulHttpClientRequest(
        _SuccessfulHttpClientResponse(bytes, contentLength: contentLength),
      );

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SuccessfulHttpClientRequest implements HttpClientRequest {
  _SuccessfulHttpClientRequest(this.response);

  final HttpClientResponse response;

  @override
  bool followRedirects = true;

  @override
  Future<HttpClientResponse> close() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SuccessfulHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _SuccessfulHttpClientResponse(this.bytes, {required this.contentLength});

  final List<int> bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  final int contentLength;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.fromIterable([bytes]).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
