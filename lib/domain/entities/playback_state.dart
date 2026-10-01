import 'package:equatable/equatable.dart';
import 'song.dart';

enum RepeatMode {
  off,
  one,
  all
}

class PlaybackState extends Equatable {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final double volume;

  const PlaybackState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = -1,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
  });

  PlaybackState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    double? volume,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
        currentSong,
        queue,
        currentIndex,
        isPlaying,
        position,
        bufferedPosition,
        duration,
        shuffleEnabled,
        repeatMode,
        volume,
      ];
}
