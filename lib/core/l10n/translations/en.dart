import 'package:pulse/core/l10n/app_localizations.dart';

/// English translations
class EnTranslations extends Translations {
  const EnTranslations();

  // ============== Common ==============
  @override
  String get appName => 'Music Player';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get delete => 'Delete';
  @override
  String get save => 'Save';
  @override
  String get reset => 'Reset';
  @override
  String get start => 'Start';
  @override
  String get stop => 'Stop';
  @override
  String get update => 'Update';
  @override
  String get unknownArtist => 'Unknown Artist';
  @override
  String get unknownAlbum => 'Unknown Album';

  // ============== Home Screen ==============
  @override
  String get musicLibrary => 'Music Library';
  @override
  String get searchHint => 'Search music, artists, albums...';
  @override
  String get emptyLibrary => 'Music library is empty';
  @override
  String get emptyLibraryHint => 'Tap the scan button to add music';
  @override
  String get noResults => 'No results found';
  @override
  String get results => 'Results';
  @override
  String get tryOtherKeywords => 'Try other keywords';
  @override
  String get scanMusic => 'Scan Music';
  @override
  String get scanMusicDesc =>
      'Find folders, import files, and keep your library current';
  @override
  String get refreshLibrary => 'Rescan';
  @override
  String get clearLibrary => 'Clear Library';
  @override
  String get clearLibraryConfirm =>
      'Clear entire music library?\n\nThis will remove all music file records (actual files will not be deleted).\n\nThis cannot be undone!';
  @override
  String get libraryCleared => 'Library cleared';
  @override
  String get exploreYourMusic =>
      'Your local music, organized for fast playback';
  @override
  String get managePlaylist => 'Playlists';
  @override
  String get scanNewMusic => 'Find new tracks';
  @override
  String get clearLibraryDesc => 'Remove records';
  @override
  String get quickActions => 'Quick Actions';

  // ============== Player Screen ==============
  @override
  String get nowPlaying => 'Now Playing';
  @override
  String get playbackSpeed => 'Playback Speed';
  @override
  String get noTrackSelected => 'No track selected';
  @override
  String get jumpToTime => 'Jump to time';
  @override
  String get jumpToTimeTitle => 'Jump to Time';
  @override
  String totalDuration(String duration) => 'Total: $duration';
  @override
  String get hourLabel => 'H';
  @override
  String get minuteLabel => 'M';
  @override
  String get secondLabel => 'S';
  @override
  String get timeExceedsDuration => 'Time cannot exceed duration';
  @override
  String get jump => 'Jump';
  @override
  String get normalSpeed => 'Normal';
  @override
  String sleepTimerDisplay(String time) => 'Sleep Timer: $time';

  // ============== Settings Screen ==============
  @override
  String get settings => 'Settings';
  @override
  String get settingsDesc =>
      'Tune playback, updates, language, and library behavior';
  @override
  String get appearance => 'Appearance';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get darkModeDesc => 'Use dark theme';
  @override
  String get language => 'Language';
  @override
  String get languageDesc => 'Select app language';
  @override
  String get playback => 'Playback';
  @override
  String get defaultVolume => 'Default Volume';
  @override
  String get defaultSpeed => 'Default Playback Speed';
  @override
  String get autoResume => 'Auto Resume';
  @override
  String get autoResumeDesc => 'Resume playback when app opens';
  @override
  String get resumePlaybackOnTrackTap => 'Resume Track on Tap';
  @override
  String get resumePlaybackOnTrackTapDesc =>
      'When opening a track manually, continue from the saved position instead of starting from the beginning';
  @override
  String get navigateToPlayerOnResume => 'Navigate to Player on Resume';
  @override
  String get navigateToPlayerOnResumeDesc =>
      'Automatically go to player screen when app resumes with music playing';
  @override
  String get autoUpdate => 'Automatic Updates';
  @override
  String get autoUpdateDesc =>
      'Check for new versions at startup and download the right installer';
  @override
  String get checkForUpdates => 'Check for Updates';
  @override
  String get checkForUpdatesDesc => 'Manually check GitHub Releases now';
  @override
  String get checkingForUpdates => 'Checking for Updates...';
  @override
  String get updateCheckInProgress => 'Update check is already running';
  @override
  String get updateUpToDate => 'You are using the latest version';
  @override
  String get updateCheckFailed => 'Update check failed';
  @override
  String get skipSettings => 'Skip Forward/Backward';
  @override
  String get skipForward => 'Skip Forward';
  @override
  String get skipBackward => 'Skip Backward';
  @override
  String seconds(int n) => '$n sec';
  @override
  String get features => 'Features';
  @override
  String get sleepTimer => 'Sleep Timer';
  @override
  String get sleepTimerDesc => 'Set auto-stop playback time';
  @override
  String get scanFolders => 'Scan Music Folders';
  @override
  String get scanFoldersDesc => 'Search for music files on device';
  @override
  String get other => 'Other';
  @override
  String get resetSettings => 'Reset All Settings';
  @override
  String get resetSettingsDesc => 'Only reset settings to defaults';
  @override
  String get resetSettingsConfirm =>
      'Reset all settings to defaults?\n\nThis will not delete music library or playback history.';
  @override
  String get settingsReset => 'Settings reset to defaults';
  @override
  String get clearAllData => 'Clear All Data';
  @override
  String get clearAllDataDesc =>
      'Delete settings, music library, playback history, etc.';
  @override
  String get clearAllDataConfirm =>
      'Clear all data?\n\nThis will delete:\n• All settings\n• Music library\n• Playlists\n• Playback history\n\nThis cannot be undone!';
  @override
  String get allDataCleared => 'All data cleared';
  @override
  String get version => 'Version';
  @override
  String get updateAvailable => 'Update Available';
  @override
  String updateAvailableMessage(
    String currentVersion,
    String latestVersion,
    String assetName,
  ) =>
      'Current version: $currentVersion\nLatest version: $latestVersion\nPackage: $assetName';
  @override
  String get downloadUpdate => 'Download Update';
  @override
  String get installNow => 'Install Now';
  @override
  String get maybeLater => 'Later';
  @override
  String get skipThisVersion => 'Skip This Version';
  @override
  String get updatePackage => 'Update package';
  @override
  String get recommended => 'recommended';
  @override
  String updateSkippedVersion(String version) =>
      'Version $version will be skipped';
  @override
  String updateDownloadProgress(int percent) =>
      'Downloading update... $percent%';
  @override
  String get updateDownloadPreparing => 'Preparing download...';
  @override
  String get updateDownloadComplete =>
      'Download complete. Opening installer...';
  @override
  String get updateDownloadFailed => 'Update download failed';
  @override
  String get updateInstallerOpenFailed =>
      'Download complete, but the installer could not be opened';
  @override
  String get updateOpenLinkFailed => 'Pulse could not open the update link';
  @override
  String get updateInstallPermissionRequired =>
      'Allow Pulse to install unknown apps, then run the update again';

  // ============== Sleep Timer ==============
  @override
  String get sleepTimerTitle => 'Sleep Timer';
  @override
  String get sleepTimerActive => 'Timer is running';
  @override
  String get sleepTimerSetTime => 'Set auto-stop playback time';
  @override
  String get minutes => 'min';
  @override
  String get hours => 'hr';
  @override
  String get endOfTrack => 'End of track';
  @override
  String get customTime => 'Custom time';
  @override
  String get stopTimer => 'Stop Timer';
  @override
  String get hour => 'Hour';
  @override
  String get minute => 'Min';
  @override
  String get second => 'Sec';

  // ============== File Scanner ==============
  @override
  String get addMusic => 'Add Music to Library';
  @override
  String get addMusicDesc =>
      'Auto scan music folders on device,\nor manually select files and folders to import.';
  @override
  String get autoScan => 'Auto Scan';
  @override
  String get manualImport => 'Manual Import';
  @override
  String get scanning => 'Scanning...';
  @override
  String get scanComplete => 'Scan Complete';
  @override
  String get scanFailed => 'Scan Failed';
  @override
  String get retry => 'Retry';
  @override
  String get addMore => 'Add More';
  @override
  String filesFound(int n) => '$n files found';
  @override
  String get noMusicFolders =>
      'No music folders found, please use manual import';
  @override
  String get storagePermissionRequired =>
      'Storage permission required to scan music files';
  @override
  String get importMusic => 'Import Music';
  @override
  String get importMusicDesc => 'Select music files or folders to import';
  @override
  String get selectFiles => 'Select Files';
  @override
  String get selectFolder => 'Select Folder';
  @override
  String get selectAll => 'All';
  @override
  String get selectNone => 'None';
  @override
  String get noFilesSelected => 'No files or folders selected';
  @override
  String get import => 'Import';
  @override
  String get importedFiles => 'Imported Files';
  @override
  String foldersCount(int n) => '$n ${n == 1 ? 'folder' : 'folders'}';
  @override
  String tracksCount(int n) => '$n ${n == 1 ? 'track' : 'tracks'}';

  // ============== Playlist ==============
  @override
  String get playlist => 'Playlist';
  @override
  String get playlistDesc =>
      'Build listening queues and organize your favorite tracks';
  @override
  String get playlistEmpty => 'Playlist is empty';
  @override
  String get noPlaylists => 'No playlists yet';
  @override
  String get noPlaylistsHint => 'Tap the button to create a new playlist';
  @override
  String get createPlaylist => 'Create Playlist';
  @override
  String get deletePlaylist => 'Delete Playlist';
  @override
  String get playlistDeleted => 'Playlist deleted';
  @override
  String get playlistNotFound => 'Playlist not found';
  @override
  String get renamePlaylist => 'Rename';
  @override
  String get playlistName => 'Name';
  @override
  String get playlistNameHint => 'Enter playlist name';
  @override
  String get create => 'Create';
  @override
  String songsCount(int n) => '$n songs';
  @override
  String deletePlaylistConfirm(String name) =>
      'Delete "$name"? This cannot be undone.';
  @override
  String get removeFromPlaylist => 'Remove from playlist';
  @override
  String removeFromPlaylistConfirm(String title) =>
      'Remove "$title" from this playlist?';
  @override
  String get addSongs => 'Add Songs';
  @override
  String get add => 'Add';
  @override
  String get tapToAddSongs => 'Tap the button below to add songs';
  @override
  String get noSongsAvailable => 'No songs available to add';
  @override
  String songsAdded(int n) => '$n songs added';
  @override
  String selectedCount(int n) => '$n selected';

  // ============== Keyboard Shortcuts ==============
  @override
  String get keyboardShortcuts => 'Keyboard Shortcuts';
  @override
  String get playPause => 'Play/Pause';
  @override
  String get rewind => 'Rewind';
  @override
  String get fastForward => 'Fast Forward';
  @override
  String get volumeUp => 'Volume Up';
  @override
  String get volumeDown => 'Volume Down';
  @override
  String get muteToggle => 'Mute Toggle';
  @override
  String get nextTrack => 'Next Track';
  @override
  String get previousTrack => 'Previous Track';
  @override
  String get close => 'Close';

  // ============== Audio Service ==============
  @override
  String get musicPlayback => 'Music Playback';

  // ============== Resume Prompt ==============
  @override
  String get resumePlaybackPromptTitle => 'Resume playback?';
  @override
  String resumePlaybackPromptMessage(String trackTitle, String position) =>
      'Resume "$trackTitle" from $position, or start from the beginning?';
  @override
  String get resumePlaybackPromptResume => 'Resume';
  @override
  String get resumePlaybackPromptStartOver => 'Start from beginning';

  // ============== Delete Music ==============
  @override
  String get deleteMusic => 'Delete Music';
  @override
  String get deleteFile => 'Delete File';
  @override
  String deleteMusicConfirm(String title) =>
      'Permanently delete "$title"?\n\nThis will delete the actual file and cannot be undone!';
  @override
  String musicDeleted(String title) => 'Deleted "$title"';
  @override
  String get removeFromLibrary => 'Delete file';

  // ============== Errors ==============
  @override
  String get unknownError => 'An unknown error occurred';
}
