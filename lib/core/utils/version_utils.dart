class VersionUtils {
  const VersionUtils._();

  static String display(String version) {
    final trimmed = version.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith('v') ? trimmed : 'v$trimmed';
  }
}
