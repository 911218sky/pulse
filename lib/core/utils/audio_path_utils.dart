import 'dart:io';

import 'package:path/path.dart' as p;

/// Normalizes audio file paths so imports can be compared idempotently.
class AudioPathUtils {
  const AudioPathUtils._();

  static String canonicalize(String filePath) {
    final trimmed = filePath.trim();
    final normalized = p.normalize(trimmed);

    if (Platform.isWindows) {
      // Windows file systems are usually case-insensitive; keeping one casing in
      // storage prevents the same file being imported with different path case.
      return normalized.toLowerCase();
    }

    return normalized;
  }

  static String dirname(String filePath) => p.dirname(canonicalize(filePath));

  static String basenameWithoutExtension(String filePath) =>
      p.basenameWithoutExtension(canonicalize(filePath));

  /// True when [filePath] is directly in [folderPath] or any subdirectory.
  static bool isUnderFolder(String folderPath, String filePath) {
    final folder = canonicalize(folderPath);
    final file = canonicalize(filePath);
    if (file == folder) return false;
    final parent = dirname(file);
    if (parent == folder) return true;
    return p.isWithin(folder, file);
  }
}
