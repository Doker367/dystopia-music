import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/playback_state.dart' as domain;
import 'package:dystopia/player/queue_manager.dart';
import 'package:dystopia/core/services/widget_service.dart';
import 'package:dystopia/core/services/local_stream_server.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AudioPlayerService extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _audioPlayer;
  final QueueManager _queueManager;
  final AndroidEqualizer? equalizer;
  final AndroidLoudnessEnhancer? loudnessEnhancer;

  final _playbackStateController =
      StreamController<domain.PlaybackState>.broadcast();
  final _currentSongController = StreamController<Song?>.broadcast();

  domain.PlaybackState _state = const domain.PlaybackState();

  AudioPlayerService(
    this._audioPlayer,
    this._queueManager, {
    this.equalizer,
    this.loudnessEnhancer,
  }) {
    _initStreams();
  }

  Stream<domain.PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<List<Song>> get queueStream => _queueManager.queueStream;
  domain.PlaybackState get currentState => _state;

  void _initStreams() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _audioPlayer.playing;
      final oldState = playbackState.hasValue ? playbackState.value : PlaybackState();
      playbackState.add(
        oldState.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_audioPlayer.processingState] ?? AudioProcessingState.idle,
          playing: playing,
          updatePosition: _audioPlayer.position,
          bufferedPosition: _audioPlayer.bufferedPosition,
          speed: _audioPlayer.speed,
          queueIndex: event.currentIndex,
        ),
      );

      _updatePlaybackState(
        _state.copyWith(
          isPlaying: playing,
          position: _audioPlayer.position,
          bufferedPosition: _audioPlayer.bufferedPosition,
          duration: _audioPlayer.duration ?? Duration.zero,
        ),
      );
    });

    _audioPlayer.positionStream.listen((pos) {
      _updatePlaybackState(_state.copyWith(position: pos));
      _applyCrossfade(pos);
    });

    _audioPlayer.bufferedPositionStream.listen((pos) {
      _updatePlaybackState(_state.copyWith(bufferedPosition: pos));
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        _updatePlaybackState(_state.copyWith(duration: dur));
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongEnded();
      }
    });

    _queueManager.queueStream.listen((queue) {
      _updatePlaybackState(
        _state.copyWith(
          queue: queue,
          currentIndex: _queueManager.currentIndex,
          currentSong: _queueManager.currentSong,
        ),
      );

      this.queue.add(queue.map(_songToMediaItem).toList());
    });
  }

  void _updatePlaybackState(domain.PlaybackState newState) {
    _state = newState;
    _playbackStateController.add(_state);

    final current = _queueManager.currentSong;
    if (current != null) {
      WidgetService.updateWidget(
        title: current.title,
        artist: current.artist,
        isPlaying: _state.isPlaying,
      );
    }
  }

  void _applyCrossfade(Duration pos) {
    if (!Hive.isBoxOpen('settings')) return;
    final crossfade = Hive.box('settings').get('crossfade', defaultValue: true);
    if (!crossfade) {
      if (_audioPlayer.volume < 1.0) _audioPlayer.setVolume(1.0);
      return;
    }

    final current = _queueManager.currentSong;
    final total = (_audioPlayer.duration != null && _audioPlayer.duration! > Duration.zero)
        ? _audioPlayer.duration!
        : (current?.duration ?? Duration.zero);

    // Fade in at the start (first 2.5 seconds)
    if (pos < const Duration(milliseconds: 2500)) {
      final progress = (pos.inMilliseconds / 2500.0).clamp(0.0, 1.0);
      final vol = 0.15 + (0.85 * progress);
      _audioPlayer.setVolume(vol);
    }
    // Fade out at the end (last 3.5 seconds) if track length is known
    else if (total > const Duration(seconds: 10) && pos >= total - const Duration(milliseconds: 3500)) {
      final remainingMs = (total - pos).inMilliseconds;
      final progress = (remainingMs / 3500.0).clamp(0.0, 1.0);
      final vol = 0.15 + (0.85 * progress);
      _audioPlayer.setVolume(vol);
    }
    // Full volume in between
    else {
      if (_audioPlayer.volume < 0.98) {
        _audioPlayer.setVolume(1.0);
      }
    }
  }

  Future<void> _handleSongEnded() async {
    if (_state.repeatMode == domain.RepeatMode.one) {
      await seek(Duration.zero);
      await play();
    } else {
      await skipToNext();
    }
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: song.artworkUrl != null
          ? Uri.parse(song.artworkUrl!)
          : (song.localArtworkPath != null
                ? Uri.file(song.localArtworkPath!)
                : null),
    );
  }

  Future<void> playSong(Song song) async {
    final existingIdx = _queueManager.queue.indexWhere((s) => s.id == song.id);
    if (existingIdx != -1) {
      _queueManager.skipToIndex(existingIdx);
    } else {
      _queueManager.setQueue([song]);
    }
    await _playCurrent();
  }

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queueManager.setQueue(songs, startIndex: startIndex);
    await _playCurrent();
  }

  Future<void> addToQueue(Song song) async {
    _queueManager.addSong(song);
  }

  Future<void> playNext(Song song) async {
    _queueManager.addSongNext(song);
  }

  Future<void> _playCurrent() async {
    final current = _queueManager.currentSong;
    if (current == null) return;

    _currentSongController.add(current);
    mediaItem.add(_songToMediaItem(current));

    final crossfade = Hive.isBoxOpen('settings')
        ? Hive.box('settings').get('crossfade', defaultValue: true)
        : true;
    if (crossfade) {
      await _audioPlayer.setVolume(0.15);
    } else {
      await _audioPlayer.setVolume(1.0);
    }

    try {
      if (current.localFilePath != null && File(current.localFilePath!).existsSync()) {
        debugPrint('[AudioPlayerService] Playing local file: ${current.localFilePath}');
        await _audioPlayer.setFilePath(current.localFilePath!);
      } else {
        if (!LocalStreamServer.isRunning) {
          await LocalStreamServer.start();
        }

        final videoId = (current.streamUrl != null &&
                current.streamUrl!.isNotEmpty &&
                !current.streamUrl!.startsWith('http'))
            ? current.streamUrl!
            : current.id;

        final proxyUrl = LocalStreamServer.getStreamUrl(videoId);
        debugPrint('[AudioPlayerService] Playing via local stream proxy: $proxyUrl (track: ${current.title})');
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(proxyUrl)));
      }
      await _audioPlayer.play();
      final currentDsp = Hive.isBoxOpen('settings')
          ? Hive.box('settings').get('audioDspMode', defaultValue: 'HIFI 320K')
          : 'HIFI 320K';
      _applyDspModeInternal(currentDsp);
    } catch (e) {
      debugPrint('[AudioPlayerService] Error playing audio: $e');
    }
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_queueManager.hasNext) {
      _queueManager.skipToIndex(_queueManager.currentIndex + 1);
      await _playCurrent();
    } else if (_state.repeatMode == domain.RepeatMode.all &&
        _queueManager.queue.isNotEmpty) {
      _queueManager.skipToIndex(0);
      await _playCurrent();
    } else {
      await _audioPlayer.stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioPlayer.position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
    } else if (_queueManager.hasPrevious) {
      _queueManager.skipToIndex(_queueManager.currentIndex - 1);
      await _playCurrent();
    } else if (_state.repeatMode == domain.RepeatMode.all &&
        _queueManager.queue.isNotEmpty) {
      _queueManager.skipToIndex(_queueManager.queue.length - 1);
      await _playCurrent();
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> skipToIndex(int index) async {
    if (_queueManager.skipToIndex(index)) {
      await _playCurrent();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    domain.RepeatMode appMode;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        appMode = domain.RepeatMode.off;
        break;
      case AudioServiceRepeatMode.one:
        appMode = domain.RepeatMode.one;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        appMode = domain.RepeatMode.all;
        break;
    }

    _updatePlaybackState(_state.copyWith(repeatMode: appMode));

    // just_audio's repeat mode handling
    LoopMode loopMode;
    switch (appMode) {
      case domain.RepeatMode.off:
        loopMode = LoopMode.off;
        break;
      case domain.RepeatMode.one:
        loopMode = LoopMode.one;
        break;
      case domain.RepeatMode.all:
        loopMode =
            LoopMode.all; // Handled custom above, but we can set it anyway
        break;
    }
    await _audioPlayer.setLoopMode(loopMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      _queueManager.shuffle();
    } else {
      _queueManager.unshuffle();
    }
    _updatePlaybackState(_state.copyWith(shuffleEnabled: enabled));
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    _updatePlaybackState(_state.copyWith(volume: volume));
  }

  Future<void> clearQueue() async {
    _queueManager.clear();
    await _audioPlayer.stop();
  }

  void removeFromQueue(int index) {
    _queueManager.removeSong(index);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _queueManager.reorder(oldIndex, newIndex);
  }

  Future<void> setDspMode(String mode) async {
    if (Hive.isBoxOpen('settings')) {
      await Hive.box('settings').put('audioDspMode', mode);
    }
    await _applyDspModeInternal(mode);
  }

  Future<void> _applyDspModeInternal(String mode) async {
    try {
      final eq = equalizer;
      if (eq == null) return;
      final le = loudnessEnhancer;

      if (mode == 'HIFI 320K') {
        // Pure unadulterated high fidelity: flat curve, dynamic range intact
        await eq.setEnabled(false);
        if (le != null) {
          await le.setEnabled(false);
          await le.setTargetGain(0.0);
        }
      } else if (mode == 'BASS BOOST') {
        // Deep bass boost for EDM, Hip-Hop, Rock and intense kick drums
        await eq.setEnabled(true);
        if (le != null) {
          await le.setEnabled(true);
          await le.setTargetGain(3.2);
        }
        try {
          final params = await eq.parameters.timeout(
            const Duration(milliseconds: 600),
          );
          for (final band in params.bands) {
            if (band.centerFrequency <= 300) {
              final maxG = params.maxDecibels;
              band.setGain((maxG * 0.75).clamp(params.minDecibels, maxG));
            } else if (band.centerFrequency <= 1000) {
              band.setGain(1.0);
            } else {
              band.setGain(0.0);
            }
          }
        } catch (_) {}
      } else if (mode == 'REVERB NEON') {
        // Cyberpunk stage: high sparkling treble and warm atmospheric spread
        await eq.setEnabled(true);
        if (le != null) {
          await le.setEnabled(true);
          await le.setTargetGain(1.8);
        }
        try {
          final params = await eq.parameters.timeout(
            const Duration(milliseconds: 600),
          );
          for (final band in params.bands) {
            if (band.centerFrequency >= 3000) {
              final maxG = params.maxDecibels;
              band.setGain((maxG * 0.70).clamp(params.minDecibels, maxG));
            } else if (band.centerFrequency <= 250) {
              band.setGain(2.5);
            } else {
              band.setGain(0.0);
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[AudioPlayerService] Error applying DSP mode $mode: $e');
    }
  }

  Future<void> toggleCrossfade() async {
    if (!Hive.isBoxOpen('settings')) return;
    final current = Hive.box('settings').get('crossfade', defaultValue: true);
    await Hive.box('settings').put('crossfade', !current);
  }

  Future<void> dispose() async {
    await _playbackStateController.close();
    await _currentSongController.close();
    await _audioPlayer.dispose();
  }
}
