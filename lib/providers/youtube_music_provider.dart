import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide SearchResult, Playlist;
import 'package:dystopia/domain/entities/album.dart';
import 'package:dystopia/domain/entities/artist.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/search_result.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/providers/music_provider.dart';

class YouTubeMusicProvider implements MusicProviderInterface {
  static final YoutubeExplode _yt = YoutubeExplode();
  static final Map<String, String> _streamCache = {};

  @override
  String get providerName => 'Dystopia Core (YouTube / Offline)';

  @override
  String get providerId => 'youtube_dystopia';

  @override
  bool get supportsDownload => true;

  @override
  bool get supportsStreaming => true;

  @override
  Future<bool> isAvailable() async => true;

  /// Fast audio stream resolver with caching
  static Future<String> resolveAudioStream(String videoId) async {
    if (_streamCache.containsKey(videoId)) {
      return _streamCache[videoId]!;
    }
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        requireWatchPage: false,
        ytClients: [YoutubeApiClient.androidSdkless],
      );
      final StreamInfo streamInfo = manifest.muxed.firstWhereOrNull((s) => s.tag == 18) ??
          (manifest.muxed.isNotEmpty ? manifest.muxed.first : manifest.audioOnly.withHighestBitrate());
      final url = streamInfo.url.toString();
      _streamCache[videoId] = url;
      return url;
    } catch (e) {
      debugPrint('Error resolving audio stream for $videoId: $e');
      return '';
    }
  }

  /// Curated Rock, Pop, and Reggae catalog with authentic, iconic original songs
  static final List<Song> rockSongs = [
    Song(
      id: 'fJ9rUzIMcZQ',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      artistId: 'queen',
      album: 'A Night at the Opera',
      albumId: 'night_at_opera',
      artworkUrl: 'https://i.ytimg.com/vi/fJ9rUzIMcZQ/hqdefault.jpg',
      duration: const Duration(minutes: 5, seconds: 55),
      streamUrl: 'fJ9rUzIMcZQ',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'pAgnJDJN4VA',
      title: 'Back in Black',
      artist: 'AC/DC',
      artistId: 'acdc',
      album: 'Back in Black',
      albumId: 'back_in_black',
      artworkUrl: 'https://i.ytimg.com/vi/pAgnJDJN4VA/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 15),
      streamUrl: 'pAgnJDJN4VA',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),

    Song(
      id: 'hTWKbfoikeg',
      title: 'Smells Like Teen Spirit',
      artist: 'Nirvana',
      artistId: 'nirvana',
      album: 'Nevermind',
      albumId: 'nevermind',
      artworkUrl: 'https://i.ytimg.com/vi/hTWKbfoikeg/hqdefault.jpg',
      duration: const Duration(minutes: 5, seconds: 01),
      streamUrl: 'hTWKbfoikeg',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: '1w7OgIMMRc4',
      title: 'Sweet Child O\' Mine',
      artist: 'Guns N\' Roses',
      artistId: 'gnr',
      album: 'Appetite for Destruction',
      albumId: 'appetite',
      artworkUrl: 'https://i.ytimg.com/vi/1w7OgIMMRc4/hqdefault.jpg',
      duration: const Duration(minutes: 5, seconds: 56),
      streamUrl: '1w7OgIMMRc4',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'eVTXPUF4Oz4',
      title: 'In The End',
      artist: 'Linkin Park',
      artistId: 'linkin_park',
      album: 'Hybrid Theory',
      albumId: 'hybrid_theory',
      artworkUrl: 'https://i.ytimg.com/vi/eVTXPUF4Oz4/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 36),
      streamUrl: 'eVTXPUF4Oz4',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'kXYiU_JCYtU',
      title: 'Numb',
      artist: 'Linkin Park',
      artistId: 'linkin_park',
      album: 'Meteora',
      albumId: 'meteora',
      artworkUrl: 'https://i.ytimg.com/vi/kXYiU_JCYtU/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 07),
      streamUrl: 'kXYiU_JCYtU',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'gEPmA3USJdI',
      title: 'Highway to Hell',
      artist: 'AC/DC',
      artistId: 'acdc',
      album: 'Highway to Hell',
      albumId: 'highway_to_hell',
      artworkUrl: 'https://i.ytimg.com/vi/gEPmA3USJdI/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 28),
      streamUrl: 'gEPmA3USJdI',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'rY0WxgSXdEE',
      title: 'Another One Bites the Dust',
      artist: 'Queen',
      artistId: 'queen',
      album: 'The Game',
      albumId: 'the_game',
      artworkUrl: 'https://i.ytimg.com/vi/rY0WxgSXdEE/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 36),
      streamUrl: 'rY0WxgSXdEE',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
  ];

  static final List<Song> popSongs = [
    Song(
      id: 'Zi_XLOBDo_Y',
      title: 'Billie Jean',
      artist: 'Michael Jackson',
      artistId: 'mj',
      album: 'Thriller',
      albumId: 'thriller',
      artworkUrl: 'https://i.ytimg.com/vi/Zi_XLOBDo_Y/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 54),
      streamUrl: 'Zi_XLOBDo_Y',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: '4NRXx6U8ABQ',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      artistId: 'the_weeknd',
      album: 'After Hours',
      albumId: 'after_hours',
      artworkUrl: 'https://i.ytimg.com/vi/4NRXx6U8ABQ/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 20),
      streamUrl: '4NRXx6U8ABQ',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'TUVcZfQe-Kw',
      title: 'Levitating',
      artist: 'Dua Lipa',
      artistId: 'dua_lipa',
      album: 'Future Nostalgia',
      albumId: 'future_nostalgia',
      artworkUrl: 'https://i.ytimg.com/vi/TUVcZfQe-Kw/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 23),
      streamUrl: 'TUVcZfQe-Kw',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: '5NV6Rdv1a3I',
      title: 'Get Lucky',
      artist: 'Daft Punk ft. Pharrell',
      artistId: 'daft_punk',
      album: 'Random Access Memories',
      albumId: 'ram',
      artworkUrl: 'https://i.ytimg.com/vi/5NV6Rdv1a3I/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 08),
      streamUrl: '5NV6Rdv1a3I',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'oRdxUFDoQe0',
      title: 'Beat It',
      artist: 'Michael Jackson',
      artistId: 'mj',
      album: 'Thriller',
      albumId: 'thriller',
      artworkUrl: 'https://i.ytimg.com/vi/oRdxUFDoQe0/hqdefault.jpg',
      duration: const Duration(minutes: 4, seconds: 58),
      streamUrl: 'oRdxUFDoQe0',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'XXYlFuWEuKI',
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      artistId: 'the_weeknd',
      album: 'After Hours',
      albumId: 'after_hours',
      artworkUrl: 'https://i.ytimg.com/vi/XXYlFuWEuKI/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 35),
      streamUrl: 'XXYlFuWEuKI',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
  ];

  static final List<Song> reggaeSongs = [
    Song(
      id: 'LanCLS_hIo4',
      title: 'Three Little Birds',
      artist: 'Bob Marley & The Wailers',
      artistId: 'bob_marley',
      album: 'Exodus',
      albumId: 'exodus',
      artworkUrl: 'https://i.ytimg.com/vi/LanCLS_hIo4/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 00),
      streamUrl: 'LanCLS_hIo4',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'uf9DjrIEEwc',
      title: 'Could You Be Loved',
      artist: 'Bob Marley & The Wailers',
      artistId: 'bob_marley',
      album: 'Uprising',
      albumId: 'uprising',
      artworkUrl: 'https://i.ytimg.com/vi/uf9DjrIEEwc/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 57),
      streamUrl: 'uf9DjrIEEwc',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'zXt56MB-3vc',
      title: 'Red Red Wine',
      artist: 'UB40',
      artistId: 'ub40',
      album: 'Labour of Love',
      albumId: 'labour_love',
      artworkUrl: 'https://i.ytimg.com/vi/zXt56MB-3vc/hqdefault.jpg',
      duration: const Duration(minutes: 5, seconds: 20),
      streamUrl: 'zXt56MB-3vc',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'qYeZo50yFLw',
      title: 'Welcome To Jamrock',
      artist: 'Damian Marley',
      artistId: 'damian_marley',
      album: 'Welcome to Jamrock',
      albumId: 'jamrock',
      artworkUrl: 'https://i.ytimg.com/vi/qYeZo50yFLw/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 33),
      streamUrl: 'qYeZo50yFLw',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: '69RdQFDuYPI',
      title: 'Is This Love',
      artist: 'Bob Marley',
      artistId: 'bob_marley',
      album: 'Kaya',
      albumId: 'kaya',
      artworkUrl: 'https://i.ytimg.com/vi/69RdQFDuYPI/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 52),
      streamUrl: '69RdQFDuYPI',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: '2UOY1JeFvAw',
      title: 'Kingston Town',
      artist: 'UB40',
      artistId: 'ub40',
      album: 'Labour of Love II',
      albumId: 'labour_love_2',
      artworkUrl: 'https://i.ytimg.com/vi/2UOY1JeFvAw/hqdefault.jpg',
      duration: const Duration(minutes: 3, seconds: 48),
      streamUrl: '2UOY1JeFvAw',
      provider: 'youtube_dystopia',
      dateAdded: DateTime.now(),
    ),
  ];


  @override
  Future<List<Song>> getTrending({int limit = 20, int offset = 0}) async {
    final all = [...rockSongs, ...popSongs, ...reggaeSongs];
    return all.take(limit).toList();
  }

  /// Clean display title from video decorators
  static String cleanTrackTitle(String rawTitle) {
    return rawTitle
        .replaceAll(RegExp(r'\(Official (Video|Music Video|Audio|Remastered|HD|4K|Lyrics)[^\)]*\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Official (Video|Music Video|Audio|Remastered|HD|4K|Lyrics)[^\]]*\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Remastered [0-9]+\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Audio\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Audio\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\|.*$'), '')
        .trim();
  }

  /// Live search allowing all genres, artists, and songs
  @override
  Future<SearchResult> search(String query, {int limit = 25, int offset = 0}) async {
    final lower = query.toLowerCase().trim();

    try {
      final searchResults = await _yt.search.search(query);
      final List<Song> songs = [];

      for (final video in searchResults) {
        if (songs.length >= limit) break;

        final rawTitle = video.title;
        final author = video.author;
        final duration = video.duration ?? Duration.zero;

        // Skip videos longer than 15 minutes (long podcasts, DJ sets) or shorter than 20 seconds
        if (duration.inSeconds > 900 || duration.inSeconds < 20) {
          continue;
        }

        final cleanTitle = cleanTrackTitle(rawTitle);

        songs.add(
          Song(
            id: video.id.value,
            title: cleanTitle.isNotEmpty ? cleanTitle : rawTitle,
            artist: author,
            artistId: author.toLowerCase().replaceAll(' ', '_'),
            album: 'Original Track',
            albumId: 'track_${video.id.value}',
            artworkUrl: video.thumbnails.highResUrl,
            duration: duration,
            streamUrl: video.id.value,
            provider: 'youtube_dystopia',
            dateAdded: DateTime.now(),
          ),
        );
      }

      return SearchResult(
        songs: songs,
        artists: const [],
        albums: const [],
        playlists: const [],
        query: query,
        hasMore: false,
      );
    } catch (e) {
      debugPrint('Error searching YouTube: $e');
      final all = [...rockSongs, ...popSongs, ...reggaeSongs];
      final filtered = all
          .where((s) =>
              s.title.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower))
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
        streamUrl: id,
        provider: 'youtube_dystopia',
        dateAdded: DateTime.now(),
      ),
    );
  }

  @override
  Future<Artist> getArtist(String id) async {
    return Artist(
      id: id,
      name: id.replaceAll('_', ' ').toUpperCase(),
      provider: 'youtube_dystopia',
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
      provider: 'youtube_dystopia',
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
    return resolveAudioStream(songId);
  }

  @override
  Future<String?> getArtworkUrl(String id, {String type = 'song'}) async {
    final song = await getSong(id);
    return song.artworkUrl;
  }

  /// Download audio stream to local device storage using resilient chunked fetching
  static Future<File?> downloadSongOffline(Song song, {Function(double)? onProgress}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/Dystopia/Music');
      if (!musicDir.existsSync()) {
        musicDir.createSync(recursive: true);
      }

      final filePath = '${musicDir.path}/${song.id}.mp4';
      final file = File(filePath);

      // If already downloaded and complete, return immediately
      if (file.existsSync() && file.lengthSync() > 100000) {
        onProgress?.call(1.0);
        return file;
      }

      // Resolve audio stream manifest
      final videoId = (song.streamUrl != null &&
              song.streamUrl!.isNotEmpty &&
              !song.streamUrl!.startsWith('http'))
          ? song.streamUrl!
          : song.id;

      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        requireWatchPage: false,
        ytClients: [YoutubeApiClient.androidSdkless],
      );
      final StreamInfo streamInfo = manifest.muxed.firstWhereOrNull((s) => s.tag == 18) ??
          (manifest.muxed.isNotEmpty ? manifest.muxed.first : manifest.audioOnly.withHighestBitrate());
      final totalBytes = streamInfo.size.totalBytes;

      if (totalBytes <= 0) return null;

      final tempPath = '$filePath.tmp';
      final tempFile = File(tempPath);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }

      final client = HttpClient();
      final req = await client.getUrl(streamInfo.url);
      req.headers.set('User-Agent', 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip');
      final resp = await req.close();

      if (resp.statusCode != 200 && resp.statusCode != 206) {
        client.close();
        return null;
      }

      final sink = tempFile.openWrite();
      int downloaded = 0;

      await for (final chunk in resp) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (onProgress != null && totalBytes > 0) {
          onProgress(downloaded / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      // Move tmp file to final file
      if (tempFile.existsSync() && tempFile.lengthSync() > 100000) {
        if (file.existsSync()) {
          file.deleteSync();
        }
        await tempFile.rename(filePath);
        debugPrint('[YouTubeMusicProvider] Download complete for ${song.title}: $filePath (${file.lengthSync()} bytes)');
        return file;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading song ${song.title}: $e');
      return null;
    }
  }
}

