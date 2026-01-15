import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';
import 'package:pulse/presentation/bloc/search/search_state.dart';
import 'package:rxdart/rxdart.dart';

/// BLoC for managing search functionality
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceTransformer(),
    );
    on<SearchSourceUpdated>(_onSourceUpdated);
    on<SearchCleared>(_onCleared);
  }

  /// Debounce search queries to avoid excessive filtering
  EventTransformer<SearchQueryChanged> _debounceTransformer() =>
      (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .flatMap(mapper);

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          results: state.sourceFiles,
          isSearching: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true));

    final results = _filterFiles(state.sourceFiles, query);

    emit(
      state.copyWith(query: event.query, results: results, isSearching: false),
    );
  }

  void _onSourceUpdated(SearchSourceUpdated event, Emitter<SearchState> emit) {
    final query = state.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(state.copyWith(sourceFiles: event.files, results: event.files));
    } else {
      final results = _filterFiles(event.files, query);
      emit(state.copyWith(sourceFiles: event.files, results: results));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(query: '', results: state.sourceFiles, isSearching: false),
    );
  }

  /// Filter files based on search query
  /// Matches against title, artist, and album
  List<AudioFile> _filterFiles(List<AudioFile> files, String query) =>
      files.where((file) => _matchesQuery(file, query)).toList();

  /// Check if a file matches the search query
  bool _matchesQuery(AudioFile file, String query) {
    // Match against title
    if (file.title.toLowerCase().contains(query)) return true;

    // Match against artist
    if (file.artist?.toLowerCase().contains(query) ?? false) return true;

    // Match against album
    if (file.album?.toLowerCase().contains(query) ?? false) return true;

    // Match against file path (filename)
    final filename = file.path.split('/').last.toLowerCase();
    if (filename.contains(query)) return true;

    return false;
  }
}
