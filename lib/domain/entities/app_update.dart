/// Latest app update metadata from GitHub Releases.
class AppUpdate {
  const AppUpdate({
    required this.currentVersion,
    required this.version,
    required this.releaseUrl,
    required this.selectedAsset,
    this.availableAssets = const [],
  });

  final String currentVersion;
  final String version;
  final Uri releaseUrl;
  final UpdateAsset selectedAsset;
  final List<UpdateAsset> availableAssets;

  Uri get downloadUrl => selectedAsset.downloadUrl;
  String get assetName => selectedAsset.name;
  bool get canDownloadDirectly => selectedAsset.canDownloadDirectly;

  AppUpdate selectAsset(UpdateAsset asset) => AppUpdate(
    currentVersion: currentVersion,
    version: version,
    releaseUrl: releaseUrl,
    selectedAsset: asset,
    availableAssets: availableAssets,
  );
}

/// Downloadable release asset for an app update.
class UpdateAsset {
  const UpdateAsset({
    required this.name,
    required this.downloadUrl,
    required this.canDownloadDirectly,
    this.isRecommended = false,
  });

  final String name;
  final Uri downloadUrl;
  final bool canDownloadDirectly;
  final bool isRecommended;

  UpdateAsset copyWith({bool? isRecommended}) => UpdateAsset(
    name: name,
    downloadUrl: downloadUrl,
    canDownloadDirectly: canDownloadDirectly,
    isRecommended: isRecommended ?? this.isRecommended,
  );
}
