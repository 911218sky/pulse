import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';

/// Repository interface for scanning device for music files
abstract class FileScannerRepository {
  /// Scans the device for music files
  /// Returns a stream of scan progress updates
  Stream<ScanProgress> scanForMusicFiles();

  /// Gets common music directories on the device
  Future<List<String>> getCommonMusicDirectories();

  /// Scans a specific folder for audio files
  Future<List<AudioFile>> scanFolder(String folderPath);

  /// Gets all scanned folders with their audio files
  Future<List<ScannedFolder>> getScannedFolders();

  /// Saves the user's selected folders for future scans
  Future<void> saveSelectedFolders(List<String> folderPaths);

  /// Gets the user's saved folder preferences
  Future<List<String>> getSavedFolderPreferences();

  /// Checks if a file is a supported audio format
  bool isSupportedAudioFile(String filePath);

  /// Extracts metadata from an audio file
  Future<AudioFile?> extractMetadata(String filePath);

  /// Saves audio files to the music library (database)
  Future<void> saveToLibrary(List<AudioFile> files);

  /// Gets all audio files from the music library (database)
  Future<List<AudioFile>> getLibraryFiles();

  /// Deletes an audio file from the music library
  Future<void> deleteFromLibrary(String fileId);

  /// Deletes multiple audio files from the music library
  Future<void> deleteMultipleFromLibrary(List<String> fileIds);

  /// Deletes an audio file from disk and library
  Future<bool> deleteFileFromDisk(String fileId, String filePath);

  /// Clears entire music library
  Future<void> clearLibrary();

  /// Cleans up database by removing entries for files that no longer exist on disk
  /// Returns the number of removed entries
  Future<int> cleanupOrphanedEntries();

  /// Supported audio file extensions
  static const List<String> supportedExtensions = [
    '.mp3',
    '.wav',
    '.flac',
    '.aac',
    '.ogg',
    '.m4a',
    '.wma',
  ];
}
