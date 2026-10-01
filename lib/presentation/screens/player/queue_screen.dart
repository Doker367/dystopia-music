import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final queue = state.queue;
    final currentSong = state.currentSong;
    final currentIndex = state.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'COLA DE REPRODUCCIÓN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            fontSize: 16,
          ),
        ),
        actions: [
          if (queue.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.shuffle_rounded,
                color: state.shuffleEnabled ? const Color(0xFFA8B545) : Colors.white60,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(playerControllerProvider.notifier).toggleShuffle();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white60, size: 22),
              tooltip: 'Limpiar cola',
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(playerControllerProvider.notifier).clearQueue();
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: queue.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.35,
                      child: Image.asset(
                        'assets/images/distopia_logo_transparent.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'COLA VACÍA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona una canción en Explorar o Inicio para comenzar la reproducción.',
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
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Now Playing Section
                if (currentSong != null) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, top: 12, bottom: 8),
                      child: Text(
                        'REPRODUCIENDO AHORA',
                        style: TextStyle(
                          color: Color(0xFFA8B545),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA8B545).withValues(alpha: 0.15),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ArtworkWidget(
                              url: currentSong.artworkUrl,
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
                                    currentSong.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    currentSong.artist,
                                    style: const TextStyle(
                                      color: Color(0xFFA8B545),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Equalizer icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFA8B545).withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.graphic_eq_rounded,
                                color: Color(0xFFA8B545),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Upcoming in Queue Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'A CONTINUACIÓN',
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                        ),
                        Text(
                          '${queue.length} pistas',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Reorderable Queue List
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = queue[index];
                        final isCurrent = index == currentIndex;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF1E1F1A)
                                : const Color(0xFF16161A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFFA8B545).withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (index + 1).toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    color: isCurrent ? const Color(0xFFA8B545) : Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ArtworkWidget(
                                  url: song.artworkUrl,
                                  width: 42,
                                  height: 42,
                                  radius: 8,
                                ),
                              ],
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color: isCurrent ? const Color(0xFFA8B545) : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(song.duration),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    ref.read(playerControllerProvider.notifier).removeFromQueue(index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(playerControllerProvider.notifier).skipToIndex(index);
                            },
                          ),
                        );
                      },
                      childCount: queue.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
