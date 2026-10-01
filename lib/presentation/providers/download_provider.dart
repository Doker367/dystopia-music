import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/providers/youtube_music_provider.dart';

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, double>>((ref) {
  return DownloadNotifier();
});

class DownloadNotifier extends StateNotifier<Map<String, double>> {
  DownloadNotifier() : super({});

  bool isDownloading(String songId) => state.containsKey(songId);

  double getProgress(String songId) => state[songId] ?? 0.0;

  Future<bool> startDownload(Song song) async {
    if (state.containsKey(song.id)) return false;

    // Set initial progress
    state = {...state, song.id: 0.02};

    try {
      final file = await YouTubeMusicProvider.downloadSongOffline(
        song,
        onProgress: (progress) {
          if (mounted) {
            state = {...state, song.id: progress.clamp(0.02, 0.99)};
          }
        },
      );

      if (file != null && await file.exists()) {
        final box = Hive.box<Song>('songs');
        final downloadedSong = song.copyWith(
          isDownloaded: true,
          localFilePath: file.path,
          dateDownloaded: DateTime.now(),
        );
        await box.put(song.id, downloadedSong);

        // Remove from downloading map
        final updated = Map<String, double>.from(state)..remove(song.id);
        state = updated;
        return true;
      } else {
        final updated = Map<String, double>.from(state)..remove(song.id);
        state = updated;
        return false;
      }
    } catch (e) {
      debugPrint('[DownloadNotifier] Error downloading ${song.title}: $e');
      final updated = Map<String, double>.from(state)..remove(song.id);
      state = updated;
      return false;
    }
  }

  Future<void> removeDownload(Song song) async {
    try {
      if (song.localFilePath != null) {
        final file = File(song.localFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final box = Hive.box<Song>('songs');
      final updatedSong = song.copyWith(
        isDownloaded: false,
        localFilePath: null,
      );
      await box.put(song.id, updatedSong);
    } catch (e) {
      debugPrint('[DownloadNotifier] Error removing download: $e');
    }
  }
}
