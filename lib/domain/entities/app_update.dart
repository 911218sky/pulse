/// Latest app update metadata from GitHub Releases.
class AppUpdate {
  const AppUpdate({
    required this.currentVersion,
    required this.version,
    required this.releaseUrl,
    required this.downloadUrl,
    required this.assetName,
    required this.canDownloadDirectly,
  });

  final String currentVersion;
  final String version;
  final Uri releaseUrl;
  final Uri downloadUrl;
  final String assetName;
  final bool canDownloadDirectly;
}
