import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/download_task.dart';

class LocalDataSource {
  final Box<Song> _songsBox = Hive.box<Song>('songs');
  final Box<Playlist> _playlistsBox = Hive.box<Playlist>('playlists');
  final Box<DownloadTask> _downloadsBox = Hive.box<DownloadTask>('downloads');
  final Box<String> _favoritesBox = Hive.box<String>('favorites');
  final Box<Song> _historyBox = Hive.box<Song>('history');
  final Box<dynamic> _settingsBox = Hive.box<dynamic>('settings');

  // Song methods
  Future<void> saveSong(Song song) async => _songsBox.put(song.id, song);
  Song? getSong(String id) => _songsBox.get(id);
  List<Song> getAllSongs() => _songsBox.values.toList();
  Future<void> deleteSong(String id) async => _songsBox.delete(id);

  // Favorites methods
  Future<void> saveFavorite(String songId) async {
    await _favoritesBox.put(songId, songId);
  }
  Future<void> removeFavorite(String songId) async {
    await _favoritesBox.delete(songId);
    final legacyKeys = _favoritesBox.keys.where((k) => _favoritesBox.get(k) == songId).toList();
    for (final k in legacyKeys) {
      await _favoritesBox.delete(k);
    }
  }
  List<String> getFavorites() {
    final set = <String>{};
    for (final k in _favoritesBox.keys) {
      final val = _favoritesBox.get(k);
      if (val != null && val.toString().isNotEmpty) {
        set.add(val.toString());
      } else {
        set.add(k.toString());
      }
    }
    return set.toList();
  }
  bool isFavorite(String songId) =>
      _favoritesBox.containsKey(songId) || _favoritesBox.values.contains(songId);

  // History methods
  Future<void> addToHistory(Song song) async {
    await _historyBox.add(song);
    // Keep history bounded if needed, e.g., max 100
    if (_historyBox.length > 100) {
      await _historyBox.deleteAt(0);
    }
  }
  List<Song> getHistory() => _historyBox.values.toList().reversed.toList();
  Future<void> clearHistory() async => _historyBox.clear();

  // Playlist methods
  Future<void> savePlaylist(Playlist playlist) async => _playlistsBox.put(playlist.id, playlist);
  Playlist? getPlaylist(String id) => _playlistsBox.get(id);
  List<Playlist> getAllPlaylists() => _playlistsBox.values.toList();
  Future<void> deletePlaylist(String id) async => _playlistsBox.delete(id);

  // Download methods
  Future<void> saveDownloadTask(DownloadTask task) async => _downloadsBox.put(task.id, task);
  DownloadTask? getDownloadTask(String id) => _downloadsBox.get(id);
  List<DownloadTask> getAllDownloadTasks() => _downloadsBox.values.toList();
  Future<void> deleteDownloadTask(String id) async => _downloadsBox.delete(id);

  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async => _settingsBox.put(key, value);
  dynamic getSetting(String key, {dynamic defaultValue}) => _settingsBox.get(key, defaultValue: defaultValue);
}
