import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/playlist.dart';
import '../entities/search_result.dart';
import '../entities/song.dart';

abstract class MusicRepository {
  Future<SearchResult> search(String query, {int limit = 20, int offset = 0});
  
  Future<Song> getSong(String id);
  
  Future<Artist> getArtist(String id);
  
  Future<Album> getAlbum(String id);
  
  Future<Playlist> getPlaylist(String id);
  
  Future<List<Song>> getArtistSongs(String artistId, {int limit = 50, int offset = 0});
  
  Future<List<Song>> getAlbumSongs(String albumId);
  
  Future<List<Song>> getTrending({int limit = 20, int offset = 0});
  
  Future<String> getStreamUrl(String songId);
  
  Future<String?> getArtworkUrl(String id, {String type = 'song'});
}
