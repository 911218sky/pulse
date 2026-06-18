import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/version_utils.dart';

void main() {
  group('VersionUtils display', () {
    test('adds v prefix when missing', () {
      expect(VersionUtils.display('0.1.24'), 'v0.1.24');
    });

    test('keeps existing v prefix', () {
      expect(VersionUtils.display('v0.1.24'), 'v0.1.24');
    });

    test('returns empty string for empty input', () {
      expect(VersionUtils.display(''), '');
    });
  });
}
