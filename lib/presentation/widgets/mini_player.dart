import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final song = state.currentSong;

    if (song == null) return const SizedBox.shrink();

    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/player');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF16161A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFA8B545).withValues(alpha: 0.32),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Slim neon progress indicator
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA8B545)),
                      minHeight: 2.5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'mini_artwork_${song.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFA8B545).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: ArtworkWidget(
                                url: song.artworkUrl,
                                width: 44,
                                height: 44,
                                radius: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: state.isPlaying
                                            ? const Color(0xFFA8B545)
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        song.artist,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Play/pause button with glowing touch target
                          IconButton(
                            splashRadius: 22,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFA8B545).withValues(alpha: 0.18),
                                border: Border.all(
                                  color: const Color(0xFFA8B545).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: const Color(0xFFA8B545),
                                size: 20,
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref.read(playerControllerProvider.notifier).togglePlayPause();
                            },
                          ),
                          // Skip next track
                          IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 24,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref.read(playerControllerProvider.notifier).skipNext();
                            },
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
      ),
    );
  }
}
