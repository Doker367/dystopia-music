import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/domain/entities/song.dart';

void main() {
  final testDate = DateTime(2023, 1, 1);
  final tSong = Song(
    id: '1',
    title: 'Test Title',
    artist: 'Test Artist',
    artistId: 'a1',
    album: 'Test Album',
    albumId: 'al1',
    duration: const Duration(seconds: 120),
    provider: 'test',
    dateAdded: testDate,
  );

  test('Creation with required fields', () {
    expect(tSong.id, '1');
    expect(tSong.title, 'Test Title');
    expect(tSong.artist, 'Test Artist');
  });

  test('copyWith creates new instance with changed fields', () {
    final updated = tSong.copyWith(title: 'New Title', isFavorite: true);
    expect(updated.title, 'New Title');
    expect(updated.isFavorite, true);
    expect(updated.id, '1'); // unchanged field
  });

  test('copyWith preserves unchanged fields', () {
    final updated = tSong.copyWith();
    expect(updated, tSong);
  });

  test('toJson/fromJson round-trip', () {
    final json = tSong.toJson();
    final fromJson = Song.fromJson(json);
    expect(fromJson, tSong);
  });

  test('Equatable equality', () {
    final tSong2 = tSong.copyWith();
    expect(tSong, equals(tSong2));
    
    final tSongDifferent = tSong.copyWith(id: '2');
    expect(tSong, isNot(equals(tSongDifferent)));
  });
}
