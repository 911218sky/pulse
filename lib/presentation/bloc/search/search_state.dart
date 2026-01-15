import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// State for SearchBloc
class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.sourceFiles = const [],
    this.results = const [],
    this.isSearching = false,
  });

  final String query;
  final List<AudioFile> sourceFiles;
  final List<AudioFile> results;
  final bool isSearching;

  /// Whether there is an active search
  bool get hasQuery => query.isNotEmpty;

  /// Number of results found
  int get resultCount => results.length;

  /// Whether no results were found for a non-empty query
  bool get noResults => hasQuery && results.isEmpty;

  SearchState copyWith({
    String? query,
    List<AudioFile>? sourceFiles,
    List<AudioFile>? results,
    bool? isSearching,
  }) => SearchState(
    query: query ?? this.query,
    sourceFiles: sourceFiles ?? this.sourceFiles,
    results: results ?? this.results,
    isSearching: isSearching ?? this.isSearching,
  );

  @override
  List<Object?> get props => [query, sourceFiles, results, isSearching];
}
