import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/providers/youtube_music_provider.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/apple_download_button.dart';

class PlaylistScreen extends ConsumerWidget {
  final String id;
  const PlaylistScreen({super.key, required this.id});

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  List<Song> _resolvePlaylistSongs(Playlist pl, Box<Song> songsBox) {
    final allKnown = [
      ...songsBox.values,
      ...YouTubeMusicProvider.rockSongs,
      ...YouTubeMusicProvider.popSongs,
      ...YouTubeMusicProvider.reggaeSongs,
    ];

    final List<Song> list = [];
    for (final songId in pl.songIds) {
      Song? song = songsBox.get(songId);
      song ??= allKnown.cast<Song?>().firstWhere(
        (s) => s?.id == songId,
        orElse: () => null,
      );
      if (song != null) {
        list.add(song);
      }
    }
    return list;
  }

  Future<void> _removeSong(BuildContext context, Playlist pl, Song song) async {
    HapticFeedback.lightImpact();
    final box = Hive.box<Playlist>('playlists');
    final updatedIds = List<String>.from(pl.songIds)..remove(song.id);
    final newDuration = pl.totalDuration >= song.duration
        ? pl.totalDuration - song.duration
        : Duration.zero;

    final updated = pl.copyWith(
      songIds: updatedIds,
      songCount: updatedIds.length,
      totalDuration: newDuration,
      dateModified: DateTime.now(),
    );
    await box.put(pl.id, updated);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eliminada de "${pl.name}"'),
          backgroundColor: const Color(0xFF1E1E24),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deletePlaylist(BuildContext context, Playlist pl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          '¿Eliminar Playlist?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminará "${pl.name}". Las canciones no se borrarán de tu biblioteca.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      HapticFeedback.mediumImpact();
      final box = Hive.box<Playlist>('playlists');
      await box.delete(pl.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistBox = Hive.box<Playlist>('playlists');
    final songsBox = Hive.box<Song>('songs');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: ValueListenableBuilder<Box<Playlist>>(
        valueListenable: playlistBox.listenable(),
        builder: (context, box, _) {
          final playlist = box.get(id);

          if (playlist == null) {
            return Scaffold(
              backgroundColor: const Color(0xFF0D0D0D),
              appBar: AppBar(
                backgroundColor: const Color(0xFF0D0D0D),
                elevation: 0,
              ),
              body: const Center(
                child: Text(
                  'Playlist no encontrada',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            );
          }

          final songs = _resolvePlaylistSongs(playlist, songsBox);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Sliver
              SliverAppBar(
                backgroundColor: const Color(0xFF0D0D0D),
                elevation: 0,
                expandedHeight: 280,
                pinned: true,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    color: const Color(0xFF1E1E24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (val) {
                      if (val == 'delete') {
                        _deletePlaylist(context, playlist);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            SizedBox(width: 10),
                            Text('Eliminar Playlist', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFA8B545).withValues(alpha: 0.25),
                              const Color(0xFF0D0D0D),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFA8B545), Color(0xFF00E5FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFA8B545).withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.queue_music_rounded,
                                size: 54,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                playlist.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (playlist.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                playlist.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              '${playlist.songCount} pistas • ${_formatDuration(playlist.totalDuration)}',
                              style: const TextStyle(
                                color: Color(0xFFA8B545),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Row (Reproducir Todo / Aleatorio)
              if (songs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                            label: const Text(
                              'REPRODUCIR TODO',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA8B545),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              ref.read(playerControllerProvider.notifier).playQueue(songs);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.shuffle_rounded, color: Colors.white, size: 26),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF16161A),
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            final shuffled = List<Song>.from(songs)..shuffle();
                            ref.read(playerControllerProvider.notifier).playQueue(shuffled);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Song List or Empty State
              if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.35,
                            child: Image.asset(
                              'assets/images/distopia_logo_transparent.png',
                              width: 110,
                              height: 110,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'PLAYLIST VACÍA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Añade canciones a esta lista desde la pantalla de Inicio, el buscador o el reproductor completo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 140),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (index + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Color(0xFFA8B545),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ArtworkWidget(
                                  url: song.artworkUrl,
                                  width: 44,
                                  height: 44,
                                  radius: 10,
                                ),
                              ],
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Apple Download Button
                                AppleDownloadButton(song: song, size: 32),
                                const SizedBox(width: 4),
                                // Remove track from playlist
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                  tooltip: 'Quitar de la lista',
                                  onPressed: () => _removeSong(context, playlist, song),
                                ),
                                // Play Button
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Color(0xFFA8B545),
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(playerControllerProvider.notifier).playQueue(songs, startIndex: index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(playerControllerProvider.notifier).playQueue(songs, startIndex: index);
                            },
                          ),
                        );
                      },
                      childCount: songs.length,
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
