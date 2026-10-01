import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/local_data_source.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LocalDataSource localDataSource;
  
  LibraryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Song>> getFavorites() async {
    final favoritesBox = Hive.box('favorites');
    final songsBox = Hive.box<Song>('songs');
    final ids = <String>{};
    for (final k in favoritesBox.keys) {
      final val = favoritesBox.get(k);
      if (val != null && val.toString().isNotEmpty) {
        ids.add(val.toString());
      } else {
        ids.add(k.toString());
      }
    }
    return ids
        .map((id) => songsBox.get(id))
        .whereType<Song>()
        .toList();
  }

  @override
  Future<void> addFavorite(Song song) async {
    final favoritesBox = Hive.box('favorites');
    final songsBox = Hive.box<Song>('songs');
    
    await songsBox.put(song.id, song);
    await favoritesBox.put(song.id, song.id);
  }

  @override
  Future<void> removeFavorite(String songId) async {
    final favoritesBox = Hive.box('favorites');
    await favoritesBox.delete(songId);
    final legacyKeys = favoritesBox.keys.where((k) => favoritesBox.get(k) == songId).toList();
    for (final k in legacyKeys) {
      await favoritesBox.delete(k);
    }
  }

  @override
  Future<bool> isFavorite(String songId) async {
    final favoritesBox = Hive.box('favorites');
    return favoritesBox.containsKey(songId) || favoritesBox.values.contains(songId);
  }

  @override
  Stream<List<Song>> watchFavorites() async* {
    yield await getFavorites();
    final favoritesBox = Hive.box('favorites');
    yield* favoritesBox.watch().asyncMap((event) => getFavorites());
  }

  @override
  Future<List<Song>> getHistory({int limit = 50}) async {
    final historyBox = Hive.box<Song>('history');
    return historyBox.values.take(limit).toList();
  }

  @override
  Future<void> addToHistory(Song song) async {
    final historyBox = Hive.box<Song>('history');
    await historyBox.add(song);
  }

  @override
  Future<void> clearHistory() async {
    final historyBox = Hive.box<Song>('history');
    await historyBox.clear();
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    return playlistsBox.values.toList();
  }

  @override
  Stream<List<Playlist>> watchPlaylists() async* {
    yield await getPlaylists();
    final playlistsBox = Hive.box<Playlist>('playlists');
    yield* playlistsBox.watch().asyncMap((event) => getPlaylists());
  }

  @override
  Future<Playlist> createPlaylist(String name, {String description = ''}) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(
      id: id,
      name: name,
      description: description,
      artworkUrl: null,
      songIds: const [],
      songCount: 0,
      totalDuration: Duration.zero,
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
      isLocal: true,
    );
    await playlistsBox.put(id, playlist);
    return playlist;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    await playlistsBox.delete(id);
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    await playlistsBox.put(playlist.id, playlist);
  }

  @override
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    final playlist = playlistsBox.get(playlistId);
    if (playlist == null) return [];
    
    final songsBox = Hive.box<Song>('songs');
    return playlist.songIds
        .map((id) => songsBox.get(id))
        .whereType<Song>()
        .toList();
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    final songsBox = Hive.box<Song>('songs');
    
    final playlist = playlistsBox.get(playlistId);
    if (playlist != null) {
      await songsBox.put(song.id, song);
      final newSongIds = List<String>.from(playlist.songIds);
      if (!newSongIds.contains(song.id)) {
        newSongIds.add(song.id);
        
        final updated = Playlist(
          id: playlist.id,
          name: playlist.name,
          description: playlist.description,
          artworkUrl: playlist.artworkUrl,
          songIds: newSongIds,
          songCount: newSongIds.length,
          totalDuration: playlist.totalDuration + song.duration,
          dateCreated: playlist.dateCreated,
          dateModified: DateTime.now(),
          isLocal: playlist.isLocal,
        );
        await playlistsBox.put(playlist.id, updated);
      }
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    final songsBox = Hive.box<Song>('songs');
    
    final playlist = playlistsBox.get(playlistId);
    if (playlist != null) {
      final newSongIds = List<String>.from(playlist.songIds);
      if (newSongIds.contains(songId)) {
        newSongIds.remove(songId);
        final song = songsBox.get(songId);
        final durationToSubtract = song?.duration ?? Duration.zero;
        
        var newDuration = playlist.totalDuration - durationToSubtract;
        if (newDuration.isNegative) newDuration = Duration.zero;

        final updated = Playlist(
          id: playlist.id,
          name: playlist.name,
          description: playlist.description,
          artworkUrl: playlist.artworkUrl,
          songIds: newSongIds,
          songCount: newSongIds.length,
          totalDuration: newDuration,
          dateCreated: playlist.dateCreated,
          dateModified: DateTime.now(),
          isLocal: playlist.isLocal,
        );
        await playlistsBox.put(playlist.id, updated);
      }
    }
  }

  @override
  Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
    final playlist = playlistsBox.get(playlistId);
    if (playlist != null) {
      final newSongIds = List<String>.from(playlist.songIds);
      if (oldIndex < 0 || oldIndex >= newSongIds.length || newIndex < 0) return;
      if (newIndex > newSongIds.length) newIndex = newSongIds.length;
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = newSongIds.removeAt(oldIndex);
      newSongIds.insert(newIndex, item);
      
      final updated = Playlist(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        artworkUrl: playlist.artworkUrl,
        songIds: newSongIds,
        songCount: playlist.songCount,
        totalDuration: playlist.totalDuration,
        dateCreated: playlist.dateCreated,
        dateModified: DateTime.now(),
        isLocal: playlist.isLocal,
      );
      await playlistsBox.put(playlist.id, updated);
    }
  }
}
