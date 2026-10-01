import 'package:equatable/equatable.dart';
import 'album.dart';
import 'artist.dart';
import 'playlist.dart';
import 'song.dart';

class SearchResult extends Equatable {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final String query;
  final bool hasMore;

  const SearchResult({
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    required this.query,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [
        songs,
        artists,
        albums,
        playlists,
        query,
        hasMore,
      ];
}
