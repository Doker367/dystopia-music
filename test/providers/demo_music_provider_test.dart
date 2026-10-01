import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/providers/demo_music_provider.dart';

void main() {
  late DemoMusicProvider provider;

  setUp(() {
    provider = DemoMusicProvider();
  });

  test('providerName and providerId are correct', () {
    expect(provider.providerName, 'Demo Provider');
    expect(provider.providerId, 'demo_provider');
  });

  group('search', () {
    test('search returns matching results', () async {
      final result = await provider.search('Neon');
      expect(result.songs, isNotEmpty);
      expect(result.songs.first.title, 'Neon Nights');
    });

    test('search returns empty for no match', () async {
      final result = await provider.search('NonExistentTerm123');
      expect(result.songs, isEmpty);
      expect(result.artists, isEmpty);
      expect(result.albums, isEmpty);
    });
  });

  group('getters', () {
    test('getSong returns correct song', () async {
      final song = await provider.getSong('song_1');
      expect(song.id, 'song_1');
      expect(song.title, 'Neon Nights');
    });

    test('getSong throws for unknown id', () async {
      expect(() => provider.getSong('unknown_id'), throwsException);
    });

    test('getArtist works', () async {
      final artist = await provider.getArtist('artist_1');
      expect(artist.id, 'artist_1');
      expect(artist.name, 'Cyber Synth');
    });

    test('getAlbum works', () async {
      final album = await provider.getAlbum('album_1');
      expect(album.id, 'album_1');
      expect(album.title, 'Dystopian Dreams');
    });

    test('getTrending returns songs', () async {
      final trending = await provider.getTrending();
      expect(trending, isNotEmpty);
      expect(trending.length, lessThanOrEqualTo(20));
    });
  });
}
