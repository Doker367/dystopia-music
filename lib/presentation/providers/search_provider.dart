import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dystopia/domain/entities/search_result.dart';
import 'package:dystopia/presentation/providers/app_providers.dart';

class SearchState {
  final String query;
  final SearchResult? results;
  final bool isLoading;
  final String? error;
  final List<String> history;

  const SearchState({
    this.query = '',
    this.results,
    this.isLoading = false,
    this.error,
    this.history = const [],
  });

  SearchState copyWith({
    String? query,
    SearchResult? results,
    bool? isLoading,
    String? error,
    List<String>? history,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      history: history ?? this.history,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounceTimer;

  SearchNotifier(this._ref) : super(const SearchState());

  void search(String query) {
    if (query == state.query && !state.isLoading && state.results != null) return;

    state = state.copyWith(query: query, isLoading: true, error: null);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final currentQuery = query.trim();
      if (currentQuery.isEmpty) {
        state = state.copyWith(isLoading: false, results: null);
        return;
      }

      try {
        final musicProvider = _ref.read(musicProviderProvider);
        final results = await musicProvider.search(currentQuery);
        
        // Ensure the results match the current query
        if (state.query == query) {
          state = state.copyWith(isLoading: false, results: results);
        }
      } catch (e) {
        if (state.query == query) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      }
    });
  }

  void clearSearch() {
    state = state.copyWith(
      query: '',
      results: null,
      isLoading: false,
      error: null,
    );
  }

  void addToHistory(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;
    
    final newHistory = List<String>.from(state.history);
    // Remove if exists to bubble it up to the top
    newHistory.remove(cleanQuery);
    newHistory.insert(0, cleanQuery);
    
    // Keep only the most recent 20 entries
    if (newHistory.length > 20) {
      newHistory.removeLast();
    }
    
    state = state.copyWith(history: newHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: const []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
