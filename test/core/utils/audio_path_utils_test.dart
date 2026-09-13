import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';

void main() {
  group('AudioPathUtils.isUnderFolder', () {
    test('returns true for direct children and nested files', () {
      expect(AudioPathUtils.isUnderFolder('/music', '/music/song.mp3'), isTrue);
      expect(
        AudioPathUtils.isUnderFolder('/music', '/music/album/song.mp3'),
        isTrue,
      );
    });

    test('returns false for siblings and the folder itself', () {
      expect(AudioPathUtils.isUnderFolder('/music', '/music'), isFalse);
      expect(
        AudioPathUtils.isUnderFolder('/music', '/other/song.mp3'),
        isFalse,
      );
    });
  });
}
