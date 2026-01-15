import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/playback_state_model.dart';
import 'package:pulse/domain/entities/playback_state.dart';
import 'package:pulse/domain/repositories/playback_state_repository.dart';

/// Implementation of PlaybackStateRepository using local storage
class PlaybackStateRepositoryImpl implements PlaybackStateRepository {
  PlaybackStateRepositoryImpl(this._dataSource);

  final LocalStorageDataSource _dataSource;

  @override
  Future<void> savePlaybackState(PlaybackState state) async {
    final model = PlaybackStateModel.fromEntity(state);
    await _dataSource.savePlaybackState(model);
  }

  @override
  Future<PlaybackState?> getLastPlaybackState() async {
    final model = await _dataSource.getLastPlaybackState();
    return model?.toEntity();
  }

  @override
  Future<void> clearPlaybackState() async {
    await _dataSource.clearPlaybackState();
  }

  @override
  Future<Duration?> getPositionForFile(String filePath) async {
    final positionMs = await _dataSource.getFilePosition(filePath);
    return positionMs != null ? Duration(milliseconds: positionMs) : null;
  }

  @override
  Future<void> savePositionForFile(String filePath, Duration position) async {
    await _dataSource.saveFilePosition(filePath, position.inMilliseconds);
  }

  @override
  Future<Map<String, Duration>> getAllFilePositions() async {
    final positions = await _dataSource.getAllFilePositions();
    return positions.map(
      (key, value) => MapEntry(key, Duration(milliseconds: value)),
    );
  }

  @override
  Future<void> clearPositionForFile(String filePath) async {
    await _dataSource.clearFilePosition(filePath);
  }
}
