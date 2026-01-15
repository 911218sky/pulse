import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/data/models/settings_model.dart';
import 'package:pulse/domain/entities/settings.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 10: Settings Persistence Round-Trip
/// **Validates: Requirements 11.1, 11.2**
///
/// For any valid Settings object, saving and loading SHALL produce an
/// equivalent Settings with all fields preserved.

Settings generateRandomSettings() => Settings(
      darkMode: PropertyTest.randomBool(),
      defaultVolume: PropertyTest.randomDouble(),
      defaultPlaybackSpeed: PropertyTest.randomDouble(min: 0.5, max: 2),
      autoResume: PropertyTest.randomBool(),
      skipForwardSeconds: PropertyTest.randomInt(min: 5, max: 60),
      skipBackwardSeconds: PropertyTest.randomInt(min: 5, max: 60),
      monitoredFolders: List.generate(
        PropertyTest.randomInt(max: 5),
        (_) => '/music/${PropertyTest.randomNonEmptyString()}',
      ),
    );

void main() {
  group('SettingsModel', () {
    test(
      'Property 10: Settings round-trip through model conversion preserves all fields (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: generateRandomSettings,
          property: (settings) {
            // Convert to model
            final model = SettingsModel.fromEntity(settings);

            // Convert back to entity
            final restored = model.toEntity();

            // Verify all fields are preserved
            expect(restored.darkMode, equals(settings.darkMode));
            expect(restored.defaultVolume, equals(settings.defaultVolume));
            expect(
              restored.defaultPlaybackSpeed,
              equals(settings.defaultPlaybackSpeed),
            );
            expect(restored.autoResume, equals(settings.autoResume));
            expect(
              restored.skipForwardSeconds,
              equals(settings.skipForwardSeconds),
            );
            expect(
              restored.skipBackwardSeconds,
              equals(settings.skipBackwardSeconds),
            );
            expect(
              restored.monitoredFolders,
              equals(settings.monitoredFolders),
            );
          },
        );
      },
    );

    test(
      'Property 10: Settings round-trip through JSON preserves all fields (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: generateRandomSettings,
          property: (settings) {
            // Convert to model then to JSON
            final model = SettingsModel.fromEntity(settings);
            final json = model.toJson();

            // Convert back from JSON to model to entity
            final restoredModel = SettingsModel.fromJson(json);
            final restored = restoredModel.toEntity();

            // Verify all fields are preserved
            expect(restored.darkMode, equals(settings.darkMode));
            expect(restored.defaultVolume, equals(settings.defaultVolume));
            expect(
              restored.defaultPlaybackSpeed,
              equals(settings.defaultPlaybackSpeed),
            );
            expect(restored.autoResume, equals(settings.autoResume));
            expect(
              restored.skipForwardSeconds,
              equals(settings.skipForwardSeconds),
            );
            expect(
              restored.skipBackwardSeconds,
              equals(settings.skipBackwardSeconds),
            );
            expect(
              restored.monitoredFolders,
              equals(settings.monitoredFolders),
            );
          },
        );
      },
    );

    test('SettingsModel.defaults returns correct default values', () {
      final defaults = SettingsModel.defaults();
      final entity = defaults.toEntity();

      expect(entity.darkMode, isTrue);
      expect(entity.defaultVolume, equals(1));
      expect(entity.defaultPlaybackSpeed, equals(1));
      expect(entity.autoResume, isTrue);
      expect(entity.skipForwardSeconds, equals(10));
      expect(entity.skipBackwardSeconds, equals(10));
      expect(entity.monitoredFolders, isEmpty);
    });
  });
}
