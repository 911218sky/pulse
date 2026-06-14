import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/update_check_service.dart';

void main() {
  group('UpdateCheckService version comparison', () {
    test('detects newer semantic versions', () {
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.16', '0.1.15'),
        isTrue,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('v0.2.0', '0.1.99'),
        isTrue,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('1.0.0', '0.9.9'),
        isTrue,
      );
    });

    test('does not update for equal or older versions', () {
      expect(
        UpdateCheckService.isNewerVersionForTesting('v0.1.15', '0.1.15'),
        isFalse,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.15+99', '0.1.15'),
        isFalse,
      );
      expect(
        UpdateCheckService.isNewerVersionForTesting('0.1.14', '0.1.15'),
        isFalse,
      );
    });
  });
}
