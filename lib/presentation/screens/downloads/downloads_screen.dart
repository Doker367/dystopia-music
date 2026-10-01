import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/presentation/widgets/artwork_widget.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsBox = Hive.box<Song>('songs');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'DESCARGAS OFFLINE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 19,
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<Song>>(
        valueListenable: songsBox.listenable(),
        builder: (context, box, _) {
          final downloadedSongs = box.values.where((s) => s.isDownloaded).toList();

          if (downloadedSongs.isEmpty) {
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
                        width: 140,
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SIN DESCARGAS OFFLINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tu biblioteca offline está vacía. Pulsa el icono de descarga en cualquier pista de Rock, Pop o Reggae para guardarla y reproducirla sin internet.',
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

          // Calculate storage used
          double totalMb = 0.0;
          for (final s in downloadedSongs) {
            if (s.localFilePath != null) {
              final f = File(s.localFilePath!);
              if (f.existsSync()) {
                totalMb += f.lengthSync() / (1024 * 1024);
              }
            }
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 140),
            children: [
              // Storage Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFA8B545).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.offline_pin_rounded, color: Color(0xFFA8B545), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'ALMACENAMIENTO OFFLINE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${downloadedSongs.length} ${downloadedSongs.length == 1 ? 'pista' : 'pistas'}',
                          style: const TextStyle(color: Color(0xFFA8B545), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (totalMb / 500).clamp(0.02, 1.0),
                        backgroundColor: const Color(0xFF242424),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA8B545)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${totalMb.toStringAsFixed(1)} MB utilizados',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                        const Text(
                          'Modo Offline Listo',
                          style: TextStyle(color: Color(0xFFA8B545), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'PISTAS DESCARGADAS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: downloadedSongs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final song = downloadedSongs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    tileColor: const Color(0xFF16161A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    leading: ArtworkWidget(url: song.artworkUrl, width: 44, height: 44, radius: 8),
                    title: Text(
                      song.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFFA8B545), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Reproducción local 100%',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            if (song.localFilePath != null) {
                              final f = File(song.localFilePath!);
                              if (f.existsSync()) f.deleteSync();
                            }
                            await box.delete(song.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFA8B545), size: 30),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref.read(playerControllerProvider.notifier).playSong(song);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(playerControllerProvider.notifier).playSong(song);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
