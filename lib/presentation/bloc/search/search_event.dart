import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Events for SearchBloc
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Update the search query
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Update the source list of audio files
class SearchSourceUpdated extends SearchEvent {
  const SearchSourceUpdated(this.files);

  final List<AudioFile> files;

  @override
  List<Object?> get props => [files];
}

/// Clear the search
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
