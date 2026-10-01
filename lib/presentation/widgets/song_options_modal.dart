import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/providers/download_provider.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/add_to_playlist_sheet.dart';

class SongOptionsModal extends StatelessWidget {
  final Song song;
  final WidgetRef ref;

  const SongOptionsModal({
    super.key,
    required this.song,
    required this.ref,
  });

  static void show(BuildContext context, WidgetRef ref, Song song) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SongOptionsModal(song: song, ref: ref),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    HapticFeedback.lightImpact();
    final favBox = Hive.box('favorites');
    final songsBox = Hive.box<Song>('songs');
    final isFav = favBox.containsKey(song.id) || favBox.values.contains(song.id);

    if (isFav) {
      await favBox.delete(song.id);
      final legacyKeys = favBox.keys.where((k) => favBox.get(k) == song.id).toList();
      for (final k in legacyKeys) {
        await favBox.delete(k);
      }
    } else {
      await songsBox.put(song.id, song);
      await favBox.put(song.id, song.id);
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFav ? 'Eliminada de Favoritos' : 'Añadida a Favoritos'),
          backgroundColor: const Color(0xFF1E1E24),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favBox = Hive.box('favorites');
    final isFav = favBox.containsKey(song.id) || favBox.values.contains(song.id);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Song Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  ArtworkWidget(
                    url: song.artworkUrl,
                    width: 52,
                    height: 52,
                    radius: 12,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 20),

            // Option: Play Next
            _buildOptionTile(
              icon: Icons.playlist_play_rounded,
              title: 'Reproducir a continuación',
              onTap: () {
                Navigator.pop(context);
                ref.read(playerControllerProvider.notifier).playNext(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Se reproducirá a continuación'),
                    backgroundColor: Color(0xFF1E1E24),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Option: Add to Queue
            _buildOptionTile(
              icon: Icons.queue_music_rounded,
              title: 'Añadir al final de la cola',
              onTap: () {
                Navigator.pop(context);
                ref.read(playerControllerProvider.notifier).addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Añadida a la cola'),
                    backgroundColor: Color(0xFF1E1E24),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Option: Add to Playlist
            _buildOptionTile(
              icon: Icons.playlist_add_rounded,
              title: 'Añadir a playlist...',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddToPlaylistSheet(song: song),
                );
              },
            ),

            // Option: Favorite
            _buildOptionTile(
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              title: isFav ? 'Eliminar de Favoritos' : 'Añadir a Favoritos',
              iconColor: isFav ? Colors.redAccent : Colors.white70,
              onTap: () => _toggleFavorite(context),
            ),

            // Option: Download
            _buildOptionTile(
              icon: Icons.arrow_circle_down_rounded,
              title: 'Descargar canción',
              onTap: () {
                Navigator.pop(context);
                ref.read(downloadProvider.notifier).startDownload(song);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white70, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
