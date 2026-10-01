import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/providers/youtube_music_provider.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/apple_download_button.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  List<Song> _getFavoriteSongs(Box favBox, Box<Song> songsBox) {
    final List<Song> list = [];
    final allKnown = [
      ...songsBox.values,
      ...YouTubeMusicProvider.rockSongs,
      ...YouTubeMusicProvider.popSongs,
      ...YouTubeMusicProvider.reggaeSongs,
    ];

    final favoriteIds = <String>{};
    for (final key in favBox.keys) {
      final val = favBox.get(key);
      if (val != null && val.toString().isNotEmpty) {
        favoriteIds.add(val.toString());
      } else {
        favoriteIds.add(key.toString());
      }
    }

    for (final songId in favoriteIds) {
      Song? song = songsBox.get(songId);
      song ??= allKnown.cast<Song?>().firstWhere(
        (s) => s?.id == songId,
        orElse: () => null,
      );
      song ??= Song(
        id: songId,
        title: 'Pista Favorita',
        artist: 'Dystopia',
        artistId: 'dystopia',
        album: 'Favoritos',
        albumId: 'fav',
        duration: const Duration(minutes: 3, seconds: 30),
        provider: 'youtube_dystopia',
        streamUrl: songId,
        dateAdded: DateTime.now(),
      );

      if (!list.any((s) => s.id == song!.id)) {
        list.add(song);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favBox = Hive.box('favorites');
    final songsBox = Hive.box<Song>('songs');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'FAVORITOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: favBox.listenable(),
        builder: (context, box, _) {
          final favoriteSongs = _getFavoriteSongs(box, songsBox);

          if (favoriteSongs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.35,
                      child: Image.asset(
                        'assets/images/distopia_logo_transparent.png',
                        width: 130,
                        height: 130,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SIN FAVORITOS AÚN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Marca tus canciones favoritas con el icono de corazón en el reproductor o en las listas para encontrarlas rápidamente aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Action Header Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TUS FAVORITOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${favoriteSongs.length} pistas guardadas',
                                style: const TextStyle(
                                  color: Color(0xFFA8B545),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play All Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(playerControllerProvider.notifier).playQueue(favoriteSongs);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8B545),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Reproducir',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Favorites List
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = favoriteSongs[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: ArtworkWidget(url: song.artworkUrl, width: 44, height: 44, radius: 10),
                          title: Text(
                            song.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song.artist,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Apple Download Button
                              AppleDownloadButton(song: song, size: 32),
                              const SizedBox(width: 4),
                              // Remove from favorites button
                              IconButton(
                                icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  favBox.delete(song.id);
                                  final legacyKeys = favBox.keys.where((k) => favBox.get(k) == song.id).toList();
                                  for (final k in legacyKeys) {
                                    favBox.delete(k);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Eliminada de Favoritos'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Color(0xFF1E1E24),
                                    ),
                                  );
                                },
                              ),
                              // Play Button
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFA8B545), size: 30),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref.read(playerControllerProvider.notifier).playQueue(favoriteSongs, startIndex: index);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(playerControllerProvider.notifier).playQueue(favoriteSongs, startIndex: index);
                          },
                        ),
                      );
                    },
                    childCount: favoriteSongs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
