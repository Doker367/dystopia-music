import '../entities/playlist.dart';
import '../entities/song.dart';

abstract class LibraryRepository {
  // Favorites
  Future<List<Song>> getFavorites();
  Future<void> addFavorite(Song song);
  Future<void> removeFavorite(String songId);
  Future<bool> isFavorite(String songId);
  Stream<List<Song>> watchFavorites();

  // History
  Future<List<Song>> getHistory({int limit = 50});
  Future<void> addToHistory(Song song);
  Future<void> clearHistory();
  
  // Playlists
  Future<List<Playlist>> getPlaylists();
  Stream<List<Playlist>> watchPlaylists();
  Future<Playlist> createPlaylist(String name, {String description = ''});
  Future<void> deletePlaylist(String id);
  Future<void> updatePlaylist(Playlist playlist);
  
  // Playlist Songs
  Future<List<Song>> getPlaylistSongs(String playlistId);
  Future<void> addSongToPlaylist(String playlistId, Song song);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
  Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex);
}
