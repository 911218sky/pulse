import 'package:flutter/material.dart';

import 'package:pulse/core/l10n/translations/en.dart';
import 'package:pulse/core/l10n/translations/zh_tw.dart';

/// Supported locales
enum AppLocale {
  zhTW('zh', 'TW', '繁體中文'),
  en('en', '', 'English');

  const AppLocale(this.languageCode, this.countryCode, this.displayName);

  final String languageCode;
  final String countryCode;
  final String displayName;

  Locale get locale =>
      Locale(languageCode, countryCode.isEmpty ? null : countryCode);

  static AppLocale fromLocale(Locale locale) {
    for (final appLocale in AppLocale.values) {
      if (appLocale.languageCode == locale.languageCode) {
        return appLocale;
      }
    }
    return AppLocale.zhTW;
  }
}

/// App localizations - delegates to language-specific translations
class AppLocalizations {
  AppLocalizations(this.locale) : _t = _getTranslations(locale);

  final Locale locale;
  final Translations _t;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Translations _getTranslations(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const EnTranslations();
      case 'zh':
      default:
        return const ZhTwTranslations();
    }
  }

  // ============== Common ==============
  String get appName => _t.appName;
  String get cancel => _t.cancel;
  String get confirm => _t.confirm;
  String get delete => _t.delete;
  String get save => _t.save;
  String get reset => _t.reset;
  String get start => _t.start;
  String get stop => _t.stop;
  String get update => _t.update;
  String get unknownArtist => _t.unknownArtist;
  String get unknownAlbum => _t.unknownAlbum;

  // ============== Home Screen ==============
  String get musicLibrary => _t.musicLibrary;
  String get searchHint => _t.searchHint;
  String get emptyLibrary => _t.emptyLibrary;
  String get emptyLibraryHint => _t.emptyLibraryHint;
  String get noResults => _t.noResults;
  String get tryOtherKeywords => _t.tryOtherKeywords;
  String get scanMusic => _t.scanMusic;
  String get refreshLibrary => _t.refreshLibrary;
  String get clearLibrary => _t.clearLibrary;
  String get clearLibraryConfirm => _t.clearLibraryConfirm;
  String get libraryCleared => _t.libraryCleared;
  String get exploreYourMusic => _t.exploreYourMusic;
  String get managePlaylist => _t.managePlaylist;
  String get scanNewMusic => _t.scanNewMusic;
  String get clearLibraryDesc => _t.clearLibraryDesc;
  String get quickActions => _t.quickActions;

  // ============== Player Screen ==============
  String get nowPlaying => _t.nowPlaying;
  String get playbackSpeed => _t.playbackSpeed;
  String get noTrackSelected => _t.noTrackSelected;
  String get jumpToTime => _t.jumpToTime;
  String get jumpToTimeTitle => _t.jumpToTimeTitle;
  String totalDuration(String duration) => _t.totalDuration(duration);
  String get hourLabel => _t.hourLabel;
  String get minuteLabel => _t.minuteLabel;
  String get secondLabel => _t.secondLabel;
  String get timeExceedsDuration => _t.timeExceedsDuration;
  String get jump => _t.jump;
  String get normalSpeed => _t.normalSpeed;
  String sleepTimerDisplay(String time) => _t.sleepTimerDisplay(time);

  // ============== Settings Screen ==============
  String get settings => _t.settings;
  String get appearance => _t.appearance;
  String get darkMode => _t.darkMode;
  String get darkModeDesc => _t.darkModeDesc;
  String get language => _t.language;
  String get languageDesc => _t.languageDesc;
  String get playback => _t.playback;
  String get defaultVolume => _t.defaultVolume;
  String get defaultSpeed => _t.defaultSpeed;
  String get autoResume => _t.autoResume;
  String get autoResumeDesc => _t.autoResumeDesc;
  String get skipSettings => _t.skipSettings;
  String get skipForward => _t.skipForward;
  String get skipBackward => _t.skipBackward;
  String seconds(int n) => _t.seconds(n);
  String get features => _t.features;
  String get sleepTimer => _t.sleepTimer;
  String get sleepTimerDesc => _t.sleepTimerDesc;
  String get scanFolders => _t.scanFolders;
  String get scanFoldersDesc => _t.scanFoldersDesc;
  String get other => _t.other;
  String get resetSettings => _t.resetSettings;
  String get resetSettingsDesc => _t.resetSettingsDesc;
  String get resetSettingsConfirm => _t.resetSettingsConfirm;
  String get settingsReset => _t.settingsReset;
  String get clearAllData => _t.clearAllData;
  String get clearAllDataDesc => _t.clearAllDataDesc;
  String get clearAllDataConfirm => _t.clearAllDataConfirm;
  String get allDataCleared => _t.allDataCleared;
  String get version => _t.version;

  // ============== Sleep Timer ==============
  String get sleepTimerTitle => _t.sleepTimerTitle;
  String get sleepTimerActive => _t.sleepTimerActive;
  String get sleepTimerSetTime => _t.sleepTimerSetTime;
  String get minutes => _t.minutes;
  String get hours => _t.hours;
  String get endOfTrack => _t.endOfTrack;
  String get customTime => _t.customTime;
  String get stopTimer => _t.stopTimer;
  String get hour => _t.hour;
  String get minute => _t.minute;
  String get second => _t.second;

  // ============== File Scanner ==============
  String get addMusic => _t.addMusic;
  String get addMusicDesc => _t.addMusicDesc;
  String get autoScan => _t.autoScan;
  String get manualImport => _t.manualImport;
  String get scanning => _t.scanning;
  String get scanComplete => _t.scanComplete;
  String get scanFailed => _t.scanFailed;
  String get retry => _t.retry;
  String get addMore => _t.addMore;
  String filesFound(int n) => _t.filesFound(n);
  String get noMusicFolders => _t.noMusicFolders;
  String get storagePermissionRequired => _t.storagePermissionRequired;
  String get importMusic => _t.importMusic;
  String get importMusicDesc => _t.importMusicDesc;
  String get selectFiles => _t.selectFiles;
  String get selectFolder => _t.selectFolder;
  String get noFilesSelected => _t.noFilesSelected;
  String get import => _t.import;
  String get importedFiles => _t.importedFiles;

  // ============== Playlist ==============
  String get playlist => _t.playlist;
  String get playlistEmpty => _t.playlistEmpty;
  String get noPlaylists => _t.noPlaylists;
  String get noPlaylistsHint => _t.noPlaylistsHint;
  String get createPlaylist => _t.createPlaylist;
  String get deletePlaylist => _t.deletePlaylist;
  String get renamePlaylist => _t.renamePlaylist;
  String get playlistName => _t.playlistName;
  String get playlistNameHint => _t.playlistNameHint;
  String get create => _t.create;
  String songsCount(int n) => _t.songsCount(n);
  String deletePlaylistConfirm(String name) => _t.deletePlaylistConfirm(name);

  // ============== Keyboard Shortcuts ==============
  String get keyboardShortcuts => _t.keyboardShortcuts;
  String get playPause => _t.playPause;
  String get rewind => _t.rewind;
  String get fastForward => _t.fastForward;
  String get volumeUp => _t.volumeUp;
  String get volumeDown => _t.volumeDown;
  String get muteToggle => _t.muteToggle;
  String get nextTrack => _t.nextTrack;
  String get previousTrack => _t.previousTrack;
  String get close => _t.close;

  // ============== Audio Service ==============
  String get musicPlayback => _t.musicPlayback;

  // ============== Delete Music ==============
  String get deleteMusic => _t.deleteMusic;
  String get deleteFile => _t.deleteFile;
  String deleteMusicConfirm(String title) => _t.deleteMusicConfirm(title);
  String musicDeleted(String title) => _t.musicDeleted(title);
  String get removeFromLibrary => _t.removeFromLibrary;

  // ============== Errors ==============
  String get unknownError => _t.unknownError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Base class for all translations
/// To add a new language:
/// 1. Create a new file in translations/ folder (e.g., ja.dart)
/// 2. Extend this class and implement all getters
/// 3. Add the locale to AppLocale enum
/// 4. Add the case in AppLocalizations._getTranslations()
abstract class Translations {
  const Translations();

  // ============== Common ==============
  String get appName;
  String get cancel;
  String get confirm;
  String get delete;
  String get save;
  String get reset;
  String get start;
  String get stop;
  String get update;
  String get unknownArtist;
  String get unknownAlbum;

  // ============== Home Screen ==============
  String get musicLibrary;
  String get searchHint;
  String get emptyLibrary;
  String get emptyLibraryHint;
  String get noResults;
  String get tryOtherKeywords;
  String get scanMusic;
  String get refreshLibrary;
  String get clearLibrary;
  String get clearLibraryConfirm;
  String get libraryCleared;
  String get exploreYourMusic;
  String get managePlaylist;
  String get scanNewMusic;
  String get clearLibraryDesc;
  String get quickActions;

  // ============== Player Screen ==============
  String get nowPlaying;
  String get playbackSpeed;
  String get noTrackSelected;
  String get jumpToTime;
  String get jumpToTimeTitle;
  String totalDuration(String duration);
  String get hourLabel;
  String get minuteLabel;
  String get secondLabel;
  String get timeExceedsDuration;
  String get jump;
  String get normalSpeed;
  String sleepTimerDisplay(String time);

  // ============== Settings Screen ==============
  String get settings;
  String get appearance;
  String get darkMode;
  String get darkModeDesc;
  String get language;
  String get languageDesc;
  String get playback;
  String get defaultVolume;
  String get defaultSpeed;
  String get autoResume;
  String get autoResumeDesc;
  String get skipSettings;
  String get skipForward;
  String get skipBackward;
  String seconds(int n);
  String get features;
  String get sleepTimer;
  String get sleepTimerDesc;
  String get scanFolders;
  String get scanFoldersDesc;
  String get other;
  String get resetSettings;
  String get resetSettingsDesc;
  String get resetSettingsConfirm;
  String get settingsReset;
  String get clearAllData;
  String get clearAllDataDesc;
  String get clearAllDataConfirm;
  String get allDataCleared;
  String get version;

  // ============== Sleep Timer ==============
  String get sleepTimerTitle;
  String get sleepTimerActive;
  String get sleepTimerSetTime;
  String get minutes;
  String get hours;
  String get endOfTrack;
  String get customTime;
  String get stopTimer;
  String get hour;
  String get minute;
  String get second;

  // ============== File Scanner ==============
  String get addMusic;
  String get addMusicDesc;
  String get autoScan;
  String get manualImport;
  String get scanning;
  String get scanComplete;
  String get scanFailed;
  String get retry;
  String get addMore;
  String filesFound(int n);
  String get noMusicFolders;
  String get storagePermissionRequired;
  String get importMusic;
  String get importMusicDesc;
  String get selectFiles;
  String get selectFolder;
  String get noFilesSelected;
  String get import;
  String get importedFiles;

  // ============== Playlist ==============
  String get playlist;
  String get playlistEmpty;
  String get noPlaylists;
  String get noPlaylistsHint;
  String get createPlaylist;
  String get deletePlaylist;
  String get renamePlaylist;
  String get playlistName;
  String get playlistNameHint;
  String get create;
  String songsCount(int n);
  String deletePlaylistConfirm(String name);

  // ============== Keyboard Shortcuts ==============
  String get keyboardShortcuts;
  String get playPause;
  String get rewind;
  String get fastForward;
  String get volumeUp;
  String get volumeDown;
  String get muteToggle;
  String get nextTrack;
  String get previousTrack;
  String get close;

  // ============== Audio Service ==============
  String get musicPlayback;

  // ============== Delete Music ==============
  String get deleteMusic;
  String get deleteFile;
  String deleteMusicConfirm(String title);
  String musicDeleted(String title);
  String get removeFromLibrary;

  // ============== Errors ==============
  String get unknownError;
}
