import 'package:flutter_test/flutter_test.dart';
import 'package:dystopia/domain/entities/playlist.dart';

void main() {
  final testDate = DateTime(2023, 1, 1);
  final tPlaylist = Playlist(
    id: '1',
    name: 'Test Playlist',
    totalDuration: const Duration(minutes: 10),
    dateCreated: testDate,
    dateModified: testDate,
  );

  test('Creation', () {
    expect(tPlaylist.id, '1');
    expect(tPlaylist.name, 'Test Playlist');
    expect(tPlaylist.isLocal, true);
    expect(tPlaylist.songIds, isEmpty);
  });

  test('copyWith', () {
    final updated = tPlaylist.copyWith(name: 'New Name', isLocal: false);
    expect(updated.name, 'New Name');
    expect(updated.isLocal, false);
    expect(updated.id, '1'); // unchanged
  });

  test('Equatable', () {
    final tPlaylist2 = tPlaylist.copyWith();
    expect(tPlaylist, equals(tPlaylist2));
    
    final tPlaylistDifferent = tPlaylist.copyWith(id: '2');
    expect(tPlaylist, isNot(equals(tPlaylistDifferent)));
  });
}
