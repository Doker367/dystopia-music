import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/playback_state.dart' as domain;
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';
import 'package:dystopia/presentation/widgets/apple_download_button.dart';
import 'package:dystopia/presentation/widgets/add_to_playlist_sheet.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final song = state.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: Text('No hay canción en reproducción', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Ambient glowing artwork backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.16,
              child: song.artworkUrl != null
                  ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                  : Image.asset('assets/images/distopia_logo.png', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: const Color(0xFF0D0D0D).withValues(alpha: 0.85)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 24),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'DYSTOPIA AUDIO',
                            style: TextStyle(
                              color: const Color(0xFFA8B545).withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Reproduciendo Ahora',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 22),
                        ),
                        onPressed: () => context.push('/queue'),
                      ),
                    ],
                  ),

                  // Large Artwork with Cyberpunk Glow Frame
                  Hero(
                    tag: 'mini_artwork_${song.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.22),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: ArtworkWidget(
                          url: song.artworkUrl,
                          width: MediaQuery.of(context).size.width - 64,
                          height: MediaQuery.of(context).size.width - 64,
                          radius: 22,
                        ),
                      ),
                    ),
                  ),

                  // Song Title & Artist
                  Column(
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Actions row: Favorite, Add, Download
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Favorite Button
                      ValueListenableBuilder<Box>(
                        valueListenable: Hive.box('favorites').listenable(),
                        builder: (context, favBox, _) {
                          final isFav = favBox.containsKey(song.id) || favBox.values.contains(song.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (isFav) {
                                favBox.delete(song.id);
                                final legacyKeys = favBox.keys.where((k) => favBox.get(k) == song.id).toList();
                                for (final k in legacyKeys) {
                                  favBox.delete(k);
                                }
                              } else {
                                Hive.box<Song>('songs').put(song.id, song);
                                favBox.put(song.id, song.id);
                              }
                            },
                          );
                        },
                      ),
                      // Add to playlist button
                      IconButton(
                        icon: const Icon(Icons.playlist_add_rounded, color: Colors.white, size: 26),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddToPlaylistSheet(song: song),
                          );
                        },
                      ),
                      // Apple Music Style Animated Download Button
                      AppleDownloadButton(song: song, size: 36),
                    ],
                  ),

                  // Progress Bar & Duration Labels
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: const Color(0xFFA8B545),
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                          thumbColor: const Color(0xFFA8B545),
                          overlayColor: const Color(0xFFA8B545).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: state.position.inMilliseconds.toDouble().clamp(
                                0.0,
                                (state.duration.inMilliseconds > 0 ? state.duration.inMilliseconds.toDouble() : 1.0),
                              ),
                          max: state.duration.inMilliseconds > 0
                              ? state.duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            ref
                                .read(playerControllerProvider.notifier)
                                .seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(state.position),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _formatDuration(state.duration),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Controls: Shuffle, Prev, Play/Pause, Next, Repeat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: state.shuffleEnabled ? const Color(0xFFA8B545) : Colors.white.withValues(alpha: 0.4),
                          size: 24,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(playerControllerProvider.notifier).toggleShuffle();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 42),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(playerControllerProvider.notifier).skipPrevious();
                        },
                      ),
                      // Play / Pause Neon Glow Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(playerControllerProvider.notifier).togglePlayPause();
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8B545),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA8B545).withValues(alpha: 0.45),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 44,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 42),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(playerControllerProvider.notifier).skipNext();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          state.repeatMode == domain.RepeatMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: state.repeatMode != domain.RepeatMode.off
                              ? const Color(0xFFA8B545)
                              : Colors.white.withValues(alpha: 0.4),
                          size: 24,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(playerControllerProvider.notifier).cycleRepeatMode();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
