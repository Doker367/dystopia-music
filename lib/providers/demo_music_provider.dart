import 'package:dystopia/domain/entities/album.dart';
import 'package:dystopia/domain/entities/artist.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/search_result.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/providers/music_provider.dart';

/// A demo music provider that returns local mock data.
class DemoMusicProvider implements MusicProviderInterface {
  @override
  String get providerName => 'Demo Provider';

  @override
  String get providerId => 'demo_provider';

  @override
  bool get supportsDownload => true;

  @override
  bool get supportsStreaming => true;

  @override
  Future<bool> isAvailable() async => true;

  final List<Song> _demoSongs = [
    Song(
      id: 'song_1',
      title: 'Neon Nights',
      artist: 'Cyber Synth',
      artistId: 'artist_1',
      album: 'Dystopian Dreams',
      albumId: 'album_1',
      artworkUrl: 'https://picsum.photos/seed/song1/500/500',
      duration: const Duration(minutes: 6, seconds: 12),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      provider: 'demo_provider',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'song_2',
      title: 'Digital Decay',
      artist: 'Byte Master',
      artistId: 'artist_2',
      album: 'Corrupted Sectors',
      albumId: 'album_2',
      artworkUrl: 'https://picsum.photos/seed/song2/500/500',
      duration: const Duration(minutes: 7, seconds: 05),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      provider: 'demo_provider',
      dateAdded: DateTime.now(),
    ),
    Song(
      id: 'song_3',
      title: 'Acid Rain',
      artist: 'Cyber Synth',
      artistId: 'artist_1',
      album: 'Dystopian Dreams',
      albumId: 'album_1',
      artworkUrl: 'https://picsum.photos/seed/song3/500/500',
      duration: const Duration(minutes: 5, seconds: 44),
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      provider: 'demo_provider',
      dateAdded: DateTime.now(),
    ),
  ];

  final List<Artist> _demoArtists = [
    Artist(
      id: 'artist_1',
      name: 'Cyber Synth',
      imageUrl: 'https://picsum.photos/seed/artist1/500/500',
      songCount: 2,
      albumCount: 1,
      provider: 'demo_provider',
    ),
    Artist(
      id: 'artist_2',
      name: 'Byte Master',
      imageUrl: 'https://picsum.photos/seed/artist2/500/500',
      songCount: 1,
      albumCount: 1,
      provider: 'demo_provider',
    ),
  ];

  final List<Album> _demoAlbums = [
    Album(
      id: 'album_1',
      title: 'Dystopian Dreams',
      artist: 'Cyber Synth',
      artistId: 'artist_1',
      artworkUrl: 'https://picsum.photos/seed/album1/500/500',
      year: 2042,
      songCount: 2,
      totalDuration: const Duration(minutes: 8, seconds: 47),
      provider: 'demo_provider',
    ),
    Album(
      id: 'album_2',
      title: 'Corrupted Sectors',
      artist: 'Byte Master',
      artistId: 'artist_2',
      artworkUrl: 'https://picsum.photos/seed/album2/500/500',
      year: 2043,
      songCount: 1,
      totalDuration: const Duration(minutes: 4, seconds: 12),
      provider: 'demo_provider',
    ),
  ];

  final List<Playlist> _demoPlaylists = [
    Playlist(
      id: 'playlist_1',
      name: 'Cyberpunk Essentials',
      description: 'The best synthwave tracks for your midnight drives.',
      artworkUrl: 'https://picsum.photos/seed/playlist1/500/500',
      songIds: ['song_1', 'song_2', 'song_3'],
      songCount: 3,
      totalDuration: const Duration(minutes: 12, seconds: 59),
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
      isLocal: false,
    ),
  ];

  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network latency
    final lowerQuery = query.toLowerCase();

    final songs = _demoSongs
        .where((s) => s.title.toLowerCase().contains(lowerQuery))
        .toList();
    final artists = _demoArtists
        .where((a) => a.name.toLowerCase().contains(lowerQuery))
        .toList();
    final albums = _demoAlbums
        .where((a) => a.title.toLowerCase().contains(lowerQuery))
        .toList();
    final playlists = _demoPlaylists
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    return SearchResult(
      songs: songs,
      artists: artists,
      albums: albums,
      playlists: playlists,
      query: query,
      hasMore: false,
    );
  }

  @override
  Future<Song> getSong(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoSongs.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Song not found: $id'),
    );
  }

  @override
  Future<Artist> getArtist(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoArtists.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Artist not found: $id'),
    );
  }

  @override
  Future<Album> getAlbum(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoAlbums.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Album not found: $id'),
    );
  }

  @override
  Future<Playlist> getPlaylist(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoPlaylists.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Playlist not found: $id'),
    );
  }

  @override
  Future<List<Song>> getArtistSongs(
    String artistId, {
    int limit = 50,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoSongs.where((s) => s.artistId == artistId).toList();
  }

  @override
  Future<List<Song>> getAlbumSongs(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoSongs.where((s) => s.albumId == albumId).toList();
  }

  @override
  Future<List<Song>> getTrending({int limit = 20, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoSongs.take(limit).toList();
  }

  @override
  Future<String> getStreamUrl(String songId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final song = await getSong(songId);
    return song.streamUrl!;
  }

  @override
  Future<String?> getArtworkUrl(String id, {String type = 'song'}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final song = await getSong(id);
    return song.artworkUrl;
  }
}
