import 'package:pulse/core/l10n/app_localizations.dart';

/// Traditional Chinese (Taiwan) translations
class ZhTwTranslations extends Translations {
  const ZhTwTranslations();

  // ============== Common ==============
  @override
  String get appName => '音樂播放器';
  @override
  String get cancel => '取消';
  @override
  String get confirm => '確定';
  @override
  String get delete => '刪除';
  @override
  String get save => '儲存';
  @override
  String get reset => '重設';
  @override
  String get start => '開始';
  @override
  String get stop => '停止';
  @override
  String get update => '更新';
  @override
  String get unknownArtist => '未知藝人';
  @override
  String get unknownAlbum => '未知專輯';

  // ============== Home Screen ==============
  @override
  String get musicLibrary => '音樂庫';
  @override
  String get searchHint => '搜尋歌曲、藝人、專輯...';
  @override
  String get emptyLibrary => '音樂庫是空的';
  @override
  String get emptyLibraryHint => '點擊右上角的掃描按鈕來新增音樂';
  @override
  String get noResults => '找不到符合的結果';
  @override
  String get tryOtherKeywords => '試試其他關鍵字';
  @override
  String get scanMusic => '掃描音樂';
  @override
  String get refreshLibrary => '重新掃描';
  @override
  String get clearLibrary => '清空音樂庫';
  @override
  String get clearLibraryConfirm =>
      '確定要清空整個音樂庫嗎？\n\n這將移除所有音樂檔案的紀錄（不會刪除實際檔案）。\n\n此操作無法復原！';
  @override
  String get libraryCleared => '音樂庫已清空';
  @override
  String get exploreYourMusic => '探索你的音樂收藏';
  @override
  String get managePlaylist => '管理播放清單';
  @override
  String get scanNewMusic => '掃描新音樂';
  @override
  String get clearLibraryDesc => '清空音樂庫';
  @override
  String get quickActions => '快速操作';

  // ============== Player Screen ==============
  @override
  String get nowPlaying => '正在播放';
  @override
  String get playbackSpeed => '播放速度';
  @override
  String get noTrackSelected => '未選擇歌曲';
  @override
  String get jumpToTime => '跳轉到指定時間';
  @override
  String get jumpToTimeTitle => '跳轉到時間';
  @override
  String totalDuration(String duration) => '總長度: $duration';
  @override
  String get hourLabel => '時';
  @override
  String get minuteLabel => '分';
  @override
  String get secondLabel => '秒';
  @override
  String get timeExceedsDuration => '時間不能超過總長度';
  @override
  String get jump => '跳轉';
  @override
  String get normalSpeed => '正常';
  @override
  String sleepTimerDisplay(String time) => '睡眠定時器: $time';

  // ============== Settings Screen ==============
  @override
  String get settings => '設定';
  @override
  String get appearance => '外觀';
  @override
  String get darkMode => '深色模式';
  @override
  String get darkModeDesc => '使用深色主題';
  @override
  String get language => '語言';
  @override
  String get languageDesc => '選擇應用程式語言';
  @override
  String get playback => '播放';
  @override
  String get defaultVolume => '預設音量';
  @override
  String get defaultSpeed => '預設播放速度';
  @override
  String get autoResume => '自動繼續播放';
  @override
  String get autoResumeDesc => '開啟應用程式時自動繼續上次的播放';
  @override
  String get navigateToPlayerOnResume => '恢復時跳轉到播放器';
  @override
  String get navigateToPlayerOnResumeDesc => '當應用程式從背景恢復且有音樂播放時，自動跳轉到播放器畫面';
  @override
  String get skipSettings => '快進/快退';
  @override
  String get skipForward => '快進秒數';
  @override
  String get skipBackward => '快退秒數';
  @override
  String seconds(int n) => '$n 秒';
  @override
  String get features => '功能';
  @override
  String get sleepTimer => '睡眠定時器';
  @override
  String get sleepTimerDesc => '設定自動停止播放的時間';
  @override
  String get scanFolders => '掃描音樂資料夾';
  @override
  String get scanFoldersDesc => '搜尋裝置上的音樂檔案';
  @override
  String get other => '其他';
  @override
  String get resetSettings => '重設所有設定';
  @override
  String get resetSettingsDesc => '僅恢復設定為預設值';
  @override
  String get resetSettingsConfirm => '確定要將所有設定恢復為預設值嗎？\n\n這不會刪除音樂庫和播放紀錄。';
  @override
  String get settingsReset => '設定已重設為預設值';
  @override
  String get clearAllData => '清除所有資料';
  @override
  String get clearAllDataDesc => '刪除設定、音樂庫、播放紀錄等所有資料';
  @override
  String get clearAllDataConfirm =>
      '確定要清除所有資料嗎？\n\n這將刪除：\n• 所有設定\n• 音樂庫紀錄\n• 播放清單\n• 播放進度紀錄\n\n此操作無法復原！';
  @override
  String get allDataCleared => '所有資料已清除';
  @override
  String get version => '版本';

  // ============== Sleep Timer ==============
  @override
  String get sleepTimerTitle => '睡眠定時器';
  @override
  String get sleepTimerActive => '定時器運行中';
  @override
  String get sleepTimerSetTime => '設定自動停止播放的時間';
  @override
  String get minutes => '分鐘';
  @override
  String get hours => '小時';
  @override
  String get endOfTrack => '播完這首';
  @override
  String get customTime => '自訂時間';
  @override
  String get stopTimer => '停止定時器';
  @override
  String get hour => '小時';
  @override
  String get minute => '分鐘';
  @override
  String get second => '秒';

  // ============== File Scanner ==============
  @override
  String get addMusic => '新增音樂到音樂庫';
  @override
  String get addMusicDesc => '自動掃描裝置上的音樂資料夾，\n或手動選擇要匯入的檔案和資料夾。';
  @override
  String get autoScan => '自動掃描';
  @override
  String get manualImport => '手動匯入';
  @override
  String get scanning => '掃描中...';
  @override
  String get scanComplete => '掃描完成';
  @override
  String get scanFailed => '掃描失敗';
  @override
  String get retry => '重試';
  @override
  String get addMore => '手動加入';
  @override
  String filesFound(int n) => '找到 $n 個檔案';
  @override
  String get noMusicFolders => '找不到音樂資料夾，請使用手動匯入';
  @override
  String get storagePermissionRequired => '需要存儲權限才能掃描音樂檔案';
  @override
  String get importMusic => '匯入音樂';
  @override
  String get importMusicDesc => '選擇要匯入的音樂檔案或資料夾';
  @override
  String get selectFiles => '選擇檔案';
  @override
  String get selectFolder => '選擇資料夾';
  @override
  String get noFilesSelected => '尚未選擇任何檔案或資料夾';
  @override
  String get import => '匯入';
  @override
  String get importedFiles => '匯入的檔案';

  // ============== Playlist ==============
  @override
  String get playlist => '播放清單';
  @override
  String get playlistEmpty => '播放清單是空的';
  @override
  String get noPlaylists => '還沒有播放清單';
  @override
  String get noPlaylistsHint => '點擊右下角的按鈕建立新的播放清單';
  @override
  String get createPlaylist => '建立播放清單';
  @override
  String get deletePlaylist => '刪除播放清單';
  @override
  String get playlistDeleted => '播放清單已刪除';
  @override
  String get renamePlaylist => '重新命名';
  @override
  String get playlistName => '名稱';
  @override
  String get playlistNameHint => '輸入播放清單名稱';
  @override
  String get create => '建立';
  @override
  String songsCount(int n) => '$n 首歌曲';
  @override
  String deletePlaylistConfirm(String name) => '確定要刪除「$name」嗎？此操作無法復原。';
  @override
  String get addSongs => '新增歌曲';
  @override
  String get add => '新增';
  @override
  String get tapToAddSongs => '點擊下方按鈕新增歌曲';
  @override
  String get noSongsAvailable => '沒有可新增的歌曲';
  @override
  String songsAdded(int n) => '已新增 $n 首歌曲';
  @override
  String selectedCount(int n) => '已選擇 $n 首';

  // ============== Keyboard Shortcuts ==============
  @override
  String get keyboardShortcuts => '鍵盤快捷鍵';
  @override
  String get playPause => '播放/暫停';
  @override
  String get rewind => '快退';
  @override
  String get fastForward => '快進';
  @override
  String get volumeUp => '音量增加';
  @override
  String get volumeDown => '音量減少';
  @override
  String get muteToggle => '靜音切換';
  @override
  String get nextTrack => '下一首';
  @override
  String get previousTrack => '上一首';
  @override
  String get close => '關閉';

  // ============== Audio Service ==============
  @override
  String get musicPlayback => '音樂播放';

  // ============== Delete Music ==============
  @override
  String get deleteMusic => '刪除音樂';
  @override
  String get deleteFile => '刪除檔案';
  @override
  String deleteMusicConfirm(String title) =>
      '確定要永久刪除「$title」嗎？\n\n此操作會刪除實際的音樂檔案，無法復原！';
  @override
  String musicDeleted(String title) => '已刪除「$title」';
  @override
  String get removeFromLibrary => '刪除檔案';

  // ============== Errors ==============
  @override
  String get unknownError => '發生未知錯誤';
}
