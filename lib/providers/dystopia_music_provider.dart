import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dystopia/domain/entities/album.dart';
import 'package:dystopia/domain/entities/artist.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/search_result.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/providers/music_provider.dart';

class DystopiaMusicProvider implements MusicProviderInterface {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static const String _appName = 'DYSTOPIA';
  static const String _baseUrl = 'https://discoveryprovider.audius.co/v1';

  @override
  String get providerName => 'Dystopia Stream Engine';

  @override
  String get providerId => 'dystopia_engine';

  @override
  bool get supportsDownload => true;

  @override
  bool get supportsStreaming => true;

  @override
  Future<bool> isAvailable() async => true;

  // Curated Rock Tracks
  static final List<Song> rockSongs = [
    Song(
      id: 'rock_1',
      title: 'Keep Rising [Anthemic Rock]',
      artist: 'Comte de Lupac',
      artistId: 'comte',
      album: 'Rock Vault',
      albumId: 'rock_vault',
      artworkUrl: 'https://audius-nodes.com/content/01J0AFPP2JY8NEH9NEQ3347T93/480x480.jpg',
      duration: const Duration(minutes: 3, seconds: 48),
      streamUrl: 'https://discoveryprovider.audius.co/v1/tracks/NzNWZMZ/stream?app_name=$_appName',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'rock_2',
      title: 'SoundHelix Rock Fusion',
      artist: 'Cyber Synth Rock',
      artistId: 'cyber_rock',
      album: 'Neon Overdrive',
      albumId: 'neon_overdrive',
      artworkUrl: 'https://picsum.photos/seed/rock2/500/500',
      duration: const Duration(minutes: 6, seconds: 12),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'rock_3',
      title: 'Electric Distortion',
      artist: 'Glitch Protocol',
      artistId: 'glitch',
      album: 'Rebel Signal',
      albumId: 'rebel_signal',
      artworkUrl: 'https://picsum.photos/seed/rock3/500/500',
      duration: const Duration(minutes: 4, seconds: 35),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
  ];

  // Curated Pop Tracks
  static final List<Song> popSongs = [
    Song(
      id: 'pop_1',
      title: 'Digital Heartbeat [Synth Pop]',
      artist: 'Byte Master',
      artistId: 'byte_master',
      album: 'Corrupted Sectors',
      albumId: 'corrupted',
      artworkUrl: 'https://picsum.photos/seed/pop1/500/500',
      duration: const Duration(minutes: 7, seconds: 05),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'pop_2',
      title: 'Cyberpunk Disco Pop',
      artist: 'Neon Star',
      artistId: 'neon_star',
      album: 'Starlight Avenue',
      albumId: 'starlight',
      artworkUrl: 'https://picsum.photos/seed/pop2/500/500',
      duration: const Duration(minutes: 5, seconds: 14),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
  ];

  // Curated Reggae Tracks
  static final List<Song> reggaeSongs = [
    Song(
      id: 'reggae_1',
      title: 'Love & Reggae',
      artist: 'Roots Syndicate',
      artistId: 'roots_syn',
      album: 'Island Echoes',
      albumId: 'island_echoes',
      artworkUrl: 'https://picsum.photos/seed/reggae1/500/500',
      duration: const Duration(minutes: 5, seconds: 44),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'reggae_2',
      title: 'Rebel Dub Reggae',
      artist: 'Kingston Sound',
      artistId: 'kingston_sound',
      album: 'Dub Vibrations',
      albumId: 'dub_vibes',
      artworkUrl: 'https://picsum.photos/seed/reggae2/500/500',
      duration: const Duration(minutes: 6, seconds: 20),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      provider: 'dystopia_engine',
      dateAdded: DateTime.now(),
    ),
  ];

  @override
  Future<List<Song>> getTrending({int limit = 20, int offset = 0}) async {
    final combined = [...rockSongs, ...popSongs, ...reggaeSongs];
    return combined.take(limit).toList();
  }

  /// Live Search querying Audius API
  @override
  Future<SearchResult> search(String query, {int limit = 25, int offset = 0}) async {
    final lower = query.toLowerCase();

    try {
      final response = await _dio.get(
        '$_baseUrl/tracks/search',
        queryParameters: {
          'query': query,
          'limit': limit,
          'app_name': _appName,
        },
      );

      final List<Song> foundSongs = [];
      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        for (final item in data) {
          final title = item['title']?.toString() ?? 'Pista';

          final trackId = item['id']?.toString() ?? item['track_id']?.toString() ?? '';
          if (trackId.isEmpty) continue;


          final user = item['user'] ?? {};
          final artistName = user['name']?.toString() ?? 'Artista';
          final artistId = user['id']?.toString() ?? 'unknown';

          String? artwork;
          if (item['artwork'] != null) {
            artwork = item['artwork']['480x480'] ?? item['artwork']['150x150'];
          }

          foundSongs.add(
            Song(
              id: trackId,
              title: title,
              artist: artistName,
              artistId: artistId,
              album: item['genre']?.toString() ?? 'Single',
              albumId: 'album_$trackId',
              artworkUrl: artwork ?? 'https://picsum.photos/seed/$trackId/500/500',
              duration: Duration(seconds: item['duration'] as int? ?? 210),
              streamUrl: '$_baseUrl/tracks/$trackId/stream?app_name=$_appName',
              provider: 'dystopia_engine',
              dateAdded: DateTime.now(),
            ),
          );
        }
      }

      if (foundSongs.isNotEmpty) {
        return SearchResult(
          songs: foundSongs,
          artists: const [],
          albums: const [],
          playlists: const [],
          query: query,
          hasMore: false,
        );
      }
    } catch (e) {
      debugPrint('Audius search error: $e');
    }

    // Fallback: search in local curated catalog
    final all = [...rockSongs, ...popSongs, ...reggaeSongs];
    final filtered = all
        .where((s) => s.title.toLowerCase().contains(lower) || s.artist.toLowerCase().contains(lower))
        .toList();

    return SearchResult(
      songs: filtered,
      artists: const [],
      albums: const [],
      playlists: const [],
      query: query,
      hasMore: false,
    );
  }

  @override
  Future<Song> getSong(String id) async {
    final all = [...rockSongs, ...popSongs, ...reggaeSongs];
    return all.firstWhere(
      (s) => s.id == id,
      orElse: () => Song(
        id: id,
        title: 'Pista de Audio',
        artist: 'Dystopia Core',
        artistId: 'dystopia',
        album: 'Cyber Sound',
        albumId: 'cyber',
        duration: const Duration(minutes: 3),
        streamUrl: '$_baseUrl/tracks/$id/stream?app_name=$_appName',
        provider: 'dystopia_engine',
        dateAdded: DateTime.now(),
      ),
    );
  }

  @override
  Future<Artist> getArtist(String id) async {
    return Artist(
      id: id,
      name: id.replaceAll('_', ' ').toUpperCase(),
      provider: 'dystopia_engine',
      imageUrl: 'https://picsum.photos/seed/$id/500/500',
    );
  }

  @override
  Future<Album> getAlbum(String id) async {
    return Album(
      id: id,
      title: id.replaceAll('_', ' ').toUpperCase(),
      artist: 'Dystopia Artist',
      artistId: 'artist_1',
      year: 2026,
      totalDuration: const Duration(minutes: 25),
      provider: 'dystopia_engine',
    );
  }

  @override
  Future<Playlist> getPlaylist(String id) async {
    return Playlist(
      id: id,
      name: 'Cyber Collection',
      songIds: rockSongs.map((s) => s.id).toList(),
      totalDuration: const Duration(minutes: 25),
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
      isLocal: false,
    );
  }

  @override
  Future<List<Song>> getArtistSongs(String artistId, {int limit = 50, int offset = 0}) async {
    final all = [...rockSongs, ...popSongs, ...reggaeSongs];
    return all.where((s) => s.artistId == artistId).toList();
  }

  @override
  Future<List<Song>> getAlbumSongs(String albumId) async {
    final all = [...rockSongs, ...popSongs, ...reggaeSongs];
    return all.where((s) => s.albumId == albumId).toList();
  }

  @override
  Future<String> getStreamUrl(String songId) async {
    final song = await getSong(songId);
    return song.streamUrl!;
  }

  @override
  Future<String?> getArtworkUrl(String id, {String type = 'song'}) async {
    final song = await getSong(id);
    return song.artworkUrl;
  }

  /// Download audio stream to local device storage for 100% offline playback
  static Future<File?> downloadSongOffline(Song song, {Function(double)? onProgress}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/Dystopia/Music');
      if (!musicDir.existsSync()) {
        musicDir.createSync(recursive: true);
      }

      final filePath = '${musicDir.path}/${song.id}.mp3';
      final file = File(filePath);

      // If already downloaded, return immediately
      if (file.existsSync() && file.lengthSync() > 1000) {
        return file;
      }

      final streamUrl = song.streamUrl;
      if (streamUrl == null || streamUrl.isEmpty) return null;

      final dio = Dio();
      await dio.download(
        streamUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return file;
    } catch (e) {
      debugPrint('Error downloading song ${song.title}: $e');
      return null;
    }
  }
}
