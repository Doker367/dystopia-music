import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/presentation/providers/download_provider.dart';

class AppleDownloadButton extends ConsumerWidget {
  final Song song;
  final double size;
  final VoidCallback? onCompleted;

  const AppleDownloadButton({
    super.key,
    required this.song,
    this.size = 36.0,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadMap = ref.watch(downloadProvider);
    final isDownloading = downloadMap.containsKey(song.id);
    final progress = downloadMap[song.id] ?? 0.0;

    final songsBox = Hive.box<Song>('songs');

    return ValueListenableBuilder<Box<Song>>(
      valueListenable: songsBox.listenable(),
      builder: (context, box, _) {
        final hiveSong = box.get(song.id);
        final isDownloaded = hiveSong?.isDownloaded ?? song.isDownloaded;

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: isDownloading
                ? _buildProgressIndicator(context, progress)
                : isDownloaded
                    ? _buildDownloadedButton(context, ref)
                    : _buildIdleButton(context, ref),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context, double progress) {
    final percentage = (progress * 100).toInt();

    return Container(
      key: const ValueKey('downloading'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF16161A),
        border: Border.all(
          color: const Color(0xFFA8B545).withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8B545).withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Active animated progress
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 250),
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 2.8,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFA8B545),
                ),
              );
            },
          ),
          // Real percentage text or center square
          if (size >= 34)
            Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFA8B545),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadedButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      key: const ValueKey('downloaded'),
      onTap: () => _showDownloadedSheet(context, ref),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFA8B545).withValues(alpha: 0.2),
          border: Border.all(
            color: const Color(0xFFA8B545),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA8B545).withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_downward_rounded,
          color: Color(0xFFA8B545),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildIdleButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      key: const ValueKey('idle'),
      onTap: () async {
        HapticFeedback.mediumImpact();
        final success =
            await ref.read(downloadProvider.notifier).startDownload(song);
        if (context.mounted) {
          if (success) {
            onCompleted?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.offline_pin_rounded,
                        color: Color(0xFFA8B545)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡"${song.title}" descargada offline!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E1E24),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al descargar la pista'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E1E24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_downward_rounded,
          color: Colors.white.withValues(alpha: 0.8),
          size: 18,
        ),
      ),
    );
  }

  void _showDownloadedSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFA8B545)),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Canción disponible sin conexión',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  title: const Text(
                    'Eliminar descarga offline',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(downloadProvider.notifier)
                        .removeDownload(song);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Descarga eliminada'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF1E1E24),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
