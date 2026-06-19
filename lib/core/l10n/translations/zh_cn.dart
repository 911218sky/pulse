import 'package:pulse/core/l10n/app_localizations.dart';

/// Simplified Chinese translations
class ZhCnTranslations extends Translations {
  const ZhCnTranslations();

  // ============== Common ==============
  @override
  String get appName => '音乐播放器';
  @override
  String get cancel => '取消';
  @override
  String get confirm => '确定';
  @override
  String get delete => '删除';
  @override
  String get save => '保存';
  @override
  String get reset => '重置';
  @override
  String get start => '开始';
  @override
  String get stop => '停止';
  @override
  String get update => '更新';
  @override
  String get unknownArtist => '未知艺人';
  @override
  String get unknownAlbum => '未知专辑';

  // ============== Home Screen ==============
  @override
  String get musicLibrary => '音乐库';
  @override
  String get searchHint => '搜索歌曲、艺人、专辑...';
  @override
  String get emptyLibrary => '音乐库是空的';
  @override
  String get emptyLibraryHint => '扫描文件夹后，音乐会显示在这里';
  @override
  String get noResults => '找不到匹配结果';
  @override
  String get results => '搜索结果';
  @override
  String get tryOtherKeywords => '试试其他关键词';
  @override
  String get scanMusic => '扫描音乐';
  @override
  String get scanMusicDesc => '查找文件夹、导入文件，让音乐库保持最新';
  @override
  String get refreshLibrary => '重新扫描';
  @override
  String get clearLibrary => '清空音乐库';
  @override
  String get clearLibraryConfirm =>
      '确定要清空整个音乐库吗？\n\n这将移除所有音乐文件记录（不会删除实际文件）。\n\n此操作无法撤销！';
  @override
  String get libraryCleared => '音乐库已清空';
  @override
  String get exploreYourMusic => '整理本地音乐，快速找到想听的歌曲';
  @override
  String get managePlaylist => '播放列表';
  @override
  String get scanNewMusic => '查找新歌曲';
  @override
  String get clearLibraryDesc => '移除记录';
  @override
  String get quickActions => '快捷操作';

  // ============== Player Screen ==============
  @override
  String get nowPlaying => '正在播放';
  @override
  String get playbackSpeed => '播放速度';
  @override
  String get noTrackSelected => '未选择歌曲';
  @override
  String get jumpToTime => '跳转到指定时间';
  @override
  String get jumpToTimeTitle => '跳转到时间';
  @override
  String totalDuration(String duration) => '总长度: $duration';
  @override
  String get hourLabel => '时';
  @override
  String get minuteLabel => '分';
  @override
  String get secondLabel => '秒';
  @override
  String get timeExceedsDuration => '时间不能超过总长度';
  @override
  String get jump => '跳转';
  @override
  String get normalSpeed => '正常';
  @override
  String sleepTimerDisplay(String time) => '睡眠定时器: $time';

  // ============== Settings Screen ==============
  @override
  String get settings => '设置';
  @override
  String get settingsDesc => '调整播放、更新、语言与音乐库行为';
  @override
  String get appearance => '外观';
  @override
  String get darkMode => '深色模式';
  @override
  String get darkModeDesc => '使用深色主题';
  @override
  String get language => '语言';
  @override
  String get languageDesc => '选择应用语言';
  @override
  String get playback => '播放';
  @override
  String get defaultVolume => '默认音量';
  @override
  String get defaultSpeed => '默认播放速度';
  @override
  String get autoResume => '自动恢复播放';
  @override
  String get autoResumeDesc => '打开应用时自动继续上次的播放';
  @override
  String get resumePlaybackOnTrackTap => '点按歌曲时恢复进度';
  @override
  String get resumePlaybackOnTrackTapDesc => '手动打开歌曲时，直接从上次保存的位置继续播放，而不是从头开始';
  @override
  String get navigateToPlayerOnResume => '恢复时跳转到播放器';
  @override
  String get navigateToPlayerOnResumeDesc => '当应用从后台恢复且有音乐播放时，自动跳转到播放器页面';
  @override
  String get autoUpdate => '自动更新';
  @override
  String get autoUpdateDesc => '启动时检查新版本，并自动下载适合此设备的安装包';
  @override
  String get checkForUpdates => '检查更新';
  @override
  String get checkForUpdatesDesc => '立即手动检查 GitHub Releases';
  @override
  String get checkingForUpdates => '正在检查更新...';
  @override
  String get updateCheckInProgress => '已经在检查更新中';
  @override
  String get updateUpToDate => '当前已是最新版本';
  @override
  String get updateCheckFailed => '检查更新失败';
  @override
  String get skipSettings => '快进/快退';
  @override
  String get skipForward => '快进秒数';
  @override
  String get skipBackward => '快退秒数';
  @override
  String seconds(int n) => '$n 秒';
  @override
  String get features => '功能';
  @override
  String get sleepTimer => '睡眠定时器';
  @override
  String get sleepTimerDesc => '设置自动停止播放的时间';
  @override
  String get scanFolders => '扫描音乐文件夹';
  @override
  String get scanFoldersDesc => '搜索设备上的音乐文件';
  @override
  String get other => '其他';
  @override
  String get resetSettings => '重置所有设置';
  @override
  String get resetSettingsDesc => '仅将设置恢复为默认值';
  @override
  String get resetSettingsConfirm => '确定要将所有设置恢复为默认值吗？\n\n这不会删除音乐库和播放记录。';
  @override
  String get settingsReset => '设置已恢复为默认值';
  @override
  String get clearAllData => '清除所有数据';
  @override
  String get clearAllDataDesc => '删除设置、音乐库、播放记录等所有数据';
  @override
  String get clearAllDataConfirm =>
      '确定要清除所有数据吗？\n\n这将删除：\n• 所有设置\n• 音乐库记录\n• 播放列表\n• 播放进度记录\n\n此操作无法撤销！';
  @override
  String get allDataCleared => '所有数据已清除';
  @override
  String get version => '版本';
  @override
  String get updateAvailable => '有新版本';
  @override
  String updateAvailableMessage(
    String currentVersion,
    String latestVersion,
    String assetName,
  ) => '当前版本：$currentVersion\n最新版本：$latestVersion\n安装包：$assetName';
  @override
  String get downloadUpdate => '下载更新';
  @override
  String get installNow => '立即安装';
  @override
  String get maybeLater => '稍后';
  @override
  String get skipThisVersion => '永久跳过此版本';
  @override
  String get updatePackage => '更新安装包';
  @override
  String get recommended => '推荐';
  @override
  String updateSkippedVersion(String version) => '已永久跳过版本 $version';
  @override
  String updateDownloadProgress(int percent) => '正在下载更新... $percent%';
  @override
  String get updateDownloadPreparing => '正在准备下载...';
  @override
  String get updateDownloadComplete => '下载完成，正在打开安装程序...';
  @override
  String get updateDownloadFailed => '更新下载失败';
  @override
  String get updateInstallerOpenFailed => '下载完成，但无法打开安装包';
  @override
  String get updateInstallPermissionRequired => '请允许 Pulse 安装未知来源应用，然后再重新执行更新';

  @override
  String get updateOpenLinkFailed => 'Pulse 无法打开更新链接';

  // ============== Sleep Timer ==============
  @override
  String get sleepTimerTitle => '睡眠定时器';
  @override
  String get sleepTimerActive => '定时器运行中';
  @override
  String get sleepTimerSetTime => '设置自动停止播放的时间';
  @override
  String get minutes => '分钟';
  @override
  String get hours => '小时';
  @override
  String get endOfTrack => '播完这首';
  @override
  String get customTime => '自定义时间';
  @override
  String get stopTimer => '停止定时器';
  @override
  String get hour => '小时';
  @override
  String get minute => '分钟';
  @override
  String get second => '秒';

  // ============== File Scanner ==============
  @override
  String get addMusic => '添加音乐到音乐库';
  @override
  String get addMusicDesc => '自动扫描设备上的音乐文件夹，\n或手动选择要导入的文件和文件夹。';
  @override
  String get autoScan => '自动扫描';
  @override
  String get manualImport => '手动导入';
  @override
  String get scanning => '扫描中...';
  @override
  String get scanComplete => '扫描完成';
  @override
  String get scanFailed => '扫描失败';
  @override
  String get retry => '重试';
  @override
  String get addMore => '手动添加';
  @override
  String filesFound(int n) => '找到 $n 个文件';
  @override
  String get noMusicFolders => '找不到音乐文件夹，请使用手动导入';
  @override
  String get storagePermissionRequired => '需要存储权限才能扫描音乐文件';
  @override
  String get importMusic => '导入音乐';
  @override
  String get importMusicDesc => '选择要导入的音乐文件或文件夹';
  @override
  String get selectFiles => '选择文件';
  @override
  String get selectFolder => '选择文件夹';
  @override
  String get selectAll => '全选';
  @override
  String get selectNone => '全不选';
  @override
  String get noFilesSelected => '尚未选择任何文件或文件夹';
  @override
  String get import => '导入';
  @override
  String get importedFiles => '导入的文件';
  @override
  String foldersCount(int n) => '$n 个文件夹';
  @override
  String tracksCount(int n) => '$n 首歌曲';

  // ============== Playlist ==============
  @override
  String get playlist => '播放列表';
  @override
  String get playlistDesc => '建立播放队列，整理常听与喜爱的歌曲';
  @override
  String get playlistEmpty => '播放列表是空的';
  @override
  String get noPlaylists => '还没有播放列表';
  @override
  String get noPlaylistsHint => '点击按钮创建新的播放列表';
  @override
  String get createPlaylist => '创建播放列表';
  @override
  String get deletePlaylist => '删除播放列表';
  @override
  String get playlistDeleted => '播放列表已删除';
  @override
  String get playlistNotFound => '找不到播放列表';
  @override
  String get renamePlaylist => '重命名';
  @override
  String get playlistName => '名称';
  @override
  String get playlistNameHint => '输入播放列表名称';
  @override
  String get create => '创建';
  @override
  String songsCount(int n) => '$n 首歌曲';
  @override
  String deletePlaylistConfirm(String name) => '确定要删除“$name”吗？此操作无法撤销。';
  @override
  String get removeFromPlaylist => '从播放列表移除';
  @override
  String removeFromPlaylistConfirm(String title) => '要从播放列表移除“$title”吗？';
  @override
  String get addSongs => '添加歌曲';
  @override
  String get add => '添加';
  @override
  String get tapToAddSongs => '点击下方按钮添加歌曲';
  @override
  String get noSongsAvailable => '没有可添加的歌曲';
  @override
  String songsAdded(int n) => '已添加 $n 首歌曲';
  @override
  String selectedCount(int n) => '已选择 $n 首';

  // ============== Keyboard Shortcuts ==============
  @override
  String get keyboardShortcuts => '键盘快捷键';
  @override
  String get playPause => '播放/暂停';
  @override
  String get rewind => '快退';
  @override
  String get fastForward => '快进';
  @override
  String get volumeUp => '增大音量';
  @override
  String get volumeDown => '减小音量';
  @override
  String get muteToggle => '静音切换';
  @override
  String get nextTrack => '下一首';
  @override
  String get previousTrack => '上一首';
  @override
  String get close => '关闭';

  // ============== Audio Service ==============
  @override
  String get musicPlayback => '音乐播放';

  // ============== Resume Prompt ==============
  @override
  String get resumePlaybackPromptTitle => '要恢复播放吗？';
  @override
  String resumePlaybackPromptMessage(String trackTitle, String position) =>
      '要从 $position 继续播放“$trackTitle”，还是从头开始？';
  @override
  String get resumePlaybackPromptResume => '继续播放';
  @override
  String get resumePlaybackPromptStartOver => '从头开始';

  // ============== Delete Music ==============
  @override
  String get deleteMusic => '删除音乐';
  @override
  String get deleteFile => '删除文件';
  @override
  String deleteMusicConfirm(String title) =>
      '确定要永久删除“$title”吗？\n\n此操作会删除实际的音乐文件，无法撤销！';
  @override
  String musicDeleted(String title) => '已删除“$title”';
  @override
  String get removeFromLibrary => '删除文件';

  // ============== Errors ==============
  @override
  String get unknownError => '发生未知错误';
}
