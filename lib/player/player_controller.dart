import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/playback_state.dart' as domain;
import 'package:dystopia/player/queue_manager.dart';
import 'package:dystopia/player/audio_player_service.dart';

final queueManagerProvider = Provider<QueueManager>((ref) {
  final qm = QueueManager();
  ref.onDispose(() {
    qm.dispose();
  });
  return qm;
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  throw UnimplementedError('audioPlayerServiceProvider must be initialized via AudioService.init in main.dart');
});

final playerControllerProvider =
    StateNotifierProvider<PlayerController, domain.PlaybackState>((ref) {
      final service = ref.watch(audioPlayerServiceProvider);
      return PlayerController(service);
    });

class PlayerController extends StateNotifier<domain.PlaybackState> {
  final AudioPlayerService _audioService;
  StreamSubscription? _playbackStateSub;

  PlayerController(this._audioService) : super(_audioService.currentState) {
    _init();
  }

  void _init() {
    _playbackStateSub = _audioService.playbackStateStream.listen((state) {
      if (mounted) {
        this.state = state;
      }
    });
  }

  Future<void> playSong(Song song) async {
    await _audioService.playSong(song);
  }

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    await _audioService.playQueue(songs, startIndex: startIndex);
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> resume() async {
    await _audioService.play();
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> skipNext() async {
    await _audioService.skipToNext();
  }

  Future<void> skipPrevious() async {
    await _audioService.skipToPrevious();
  }

  Future<void> toggleShuffle() async {
    final mode = state.shuffleEnabled
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all;
    await _audioService.setShuffleMode(mode);
  }

  Future<void> cycleRepeatMode() async {
    AudioServiceRepeatMode mode;
    switch (state.repeatMode) {
      case domain.RepeatMode.off:
        mode = AudioServiceRepeatMode.all;
        break;
      case domain.RepeatMode.all:
        mode = AudioServiceRepeatMode.one;
        break;
      case domain.RepeatMode.one:
        mode = AudioServiceRepeatMode.none;
        break;
    }
    await _audioService.setRepeatMode(mode);
  }

  Future<void> addToQueue(Song song) async {
    await _audioService.addToQueue(song);
  }

  Future<void> playNext(Song song) async {
    await _audioService.playNext(song);
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  Future<void> clearQueue() async {
    await _audioService.clearQueue();
  }

  Future<void> skipToIndex(int index) async {
    await _audioService.skipToIndex(index);
  }

  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _audioService.reorderQueue(oldIndex, newIndex);
  }

  Future<void> setDspMode(String mode) async {
    await _audioService.setDspMode(mode);
  }

  Future<void> toggleCrossfade() async {
    await _audioService.toggleCrossfade();
  }

  @override
  void dispose() {
    _playbackStateSub?.cancel();
    super.dispose();
  }
}
