import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/providers/music_provider.dart';
import 'package:dystopia/providers/youtube_music_provider.dart';

// --- Services & Data Sources ---
// Uses UnimplementedError for providers that need to be overridden in ProviderScope
// after initialization (e.g., Hive database access, preferences).

final storageServiceProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});

final localDataSourceProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('localDataSourceProvider must be overridden');
});

final connectivityServiceProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('connectivityServiceProvider must be overridden');
});

final permissionServiceProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('permissionServiceProvider must be overridden');
});

// --- Music Provider ---
final musicProviderProvider = Provider<MusicProviderInterface>((ref) {
  return YouTubeMusicProvider();
});

// --- Repositories ---
final libraryRepositoryProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('libraryRepositoryProvider must be overridden');
});

final downloadRepositoryProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('downloadRepositoryProvider must be overridden');
});

final settingsRepositoryProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});

// --- Application State ---
final favoritesProvider = StreamProvider<List<Song>>((ref) {
  // Placeholder implementation returning empty lists
  return Stream.value([]);
});

final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  // Placeholder implementation returning empty lists
  return Stream.value([]);
});

final historyProvider = FutureProvider<List<Song>>((ref) async {
  // Placeholder for recent history
  return [];
});

final downloadsProvider = StreamProvider<List<Song>>((ref) {
  return Stream.value([]);
});

final currentThemeModeProvider = StateProvider<dynamic>((ref) {
  // Can provide ThemeMode.dark by default once ThemeMode is imported, returning null as placeholder
  return null;
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  // Assume always connected initially
  return Stream.value(true);
});

// --- Search Flow (Legacy, most search logic is in search_provider.dart) ---
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return null;
  
  // Minimal debounce to avoid spamming the provider on every keystroke
  await Future.delayed(const Duration(milliseconds: 500));
  
  final musicProvider = ref.watch(musicProviderProvider);
  return musicProvider.search(query);
});
