import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/presentation/screens/playlist/create_playlist_dialog.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  Future<void> _toggleSongInPlaylist(
    BuildContext context,
    Playlist playlist,
    bool isAlreadyInPlaylist,
  ) async {
    HapticFeedback.lightImpact();
    final box = Hive.box<Playlist>('playlists');
    final songsBox = Hive.box<Song>('songs');

    // Ensure song metadata is stored locally
    await songsBox.put(song.id, song);

    final updatedSongIds = List<String>.from(playlist.songIds);

    if (isAlreadyInPlaylist) {
      updatedSongIds.remove(song.id);
      final newDuration = playlist.totalDuration >= song.duration
          ? playlist.totalDuration - song.duration
          : Duration.zero;

      final updated = playlist.copyWith(
        songIds: updatedSongIds,
        songCount: updatedSongIds.length,
        totalDuration: newDuration,
        dateModified: DateTime.now(),
      );
      await box.put(playlist.id, updated);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminada de "${playlist.name}"'),
            backgroundColor: const Color(0xFF1E1E24),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      updatedSongIds.add(song.id);
      final updated = playlist.copyWith(
        songIds: updatedSongIds,
        songCount: updatedSongIds.length,
        totalDuration: playlist.totalDuration + song.duration,
        dateModified: DateTime.now(),
      );
      await box.put(playlist.id, updated);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Añadida a "${playlist.name}"'),
            backgroundColor: const Color(0xFF1E1E24),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistBox = Hive.box<Playlist>('playlists');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF16161A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Card with Song Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                ArtworkWidget(
                  url: song.artworkUrl,
                  width: 48,
                  height: 48,
                  radius: 12,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AÑADIR A PLAYLIST',
                        style: TextStyle(
                          color: Color(0xFFA8B545),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
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

          const Divider(color: Colors.white10, height: 1),

          // Create Playlist Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                HapticFeedback.lightImpact();
                final created = await showDialog<Playlist>(
                  context: context,
                  builder: (_) => const CreatePlaylistDialog(),
                );
                if (created != null && context.mounted) {
                  await _toggleSongInPlaylist(context, created, false);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                  ),
                  color: const Color(0xFFA8B545).withValues(alpha: 0.08),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFFA8B545),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Nueva Playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Playlists List
          Flexible(
            child: ValueListenableBuilder<Box<Playlist>>(
              valueListenable: playlistBox.listenable(),
              builder: (context, box, _) {
                final playlists = box.values.toList();

                if (playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    child: Center(
                      child: Text(
                        'Aún no has creado ninguna playlist.\nCrea una arriba para guardar tus canciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final pl = playlists[index];
                    final isAdded = pl.songIds.contains(song.id);

                    return Container(
                      decoration: BoxDecoration(
                        color: isAdded
                            ? const Color(0xFF1E1F1A)
                            : const Color(0xFF111114),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isAdded
                              ? const Color(0xFFA8B545).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: isAdded
                                  ? [const Color(0xFFA8B545), const Color(0xFF869230)]
                                  : [const Color(0xFF2A2A32), const Color(0xFF1C1C22)],
                            ),
                          ),
                          child: Icon(
                            Icons.queue_music_rounded,
                            color: isAdded ? Colors.black : Colors.white70,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          pl.name,
                          style: TextStyle(
                            color: isAdded ? const Color(0xFFA8B545) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${pl.songCount} canciones',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                        trailing: isAdded
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFFA8B545),
                                size: 24,
                              )
                            : const Icon(
                                Icons.add_rounded,
                                color: Colors.white38,
                                size: 24,
                              ),
                        onTap: () => _toggleSongInPlaylist(context, pl, isAdded),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
