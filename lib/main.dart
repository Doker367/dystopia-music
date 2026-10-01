import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dystopia/data/models/song_model.dart';
import 'package:dystopia/data/models/artist_model.dart';
import 'package:dystopia/data/models/album_model.dart';
import 'package:dystopia/data/models/playlist_model.dart';
import 'package:dystopia/data/models/download_task_model.dart';

import 'package:dystopia/domain/entities/song.dart';
import 'package:dystopia/domain/entities/artist.dart';
import 'package:dystopia/domain/entities/album.dart';
import 'package:dystopia/domain/entities/playlist.dart';
import 'package:dystopia/domain/entities/download_task.dart';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dystopia/core/services/local_stream_server.dart';
import 'package:dystopia/core/theme/app_theme.dart';
import 'package:dystopia/player/audio_player_service.dart';
import 'package:dystopia/player/player_controller.dart';
import 'package:dystopia/player/queue_manager.dart';
import 'package:dystopia/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(ArtistAdapter());
  Hive.registerAdapter(AlbumAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(DownloadTaskAdapter());
  
  await Future.wait([
    Hive.openBox<Song>('songs'),
    Hive.openBox<Artist>('artists'),
    Hive.openBox<Album>('albums'),
    Hive.openBox<Playlist>('playlists'),
    Hive.openBox<DownloadTask>('downloads'),
    Hive.openBox('favorites'),
    Hive.openBox('history'),
    Hive.openBox('settings'),
  ]);

  // Start local loopback audio stream proxy
  await LocalStreamServer.start();

  // Initialize AudioService for background notification and media controls
  final audioHandler = await AudioService.init<AudioPlayerService>(
    builder: () {
      AndroidEqualizer? equalizer;
      AndroidLoudnessEnhancer? loudnessEnhancer;
      AudioPlayer player;

      if (!kIsWeb && Platform.isAndroid) {
        equalizer = AndroidEqualizer();
        loudnessEnhancer = AndroidLoudnessEnhancer();
        player = AudioPlayer(
          audioPipeline: AudioPipeline(
            androidAudioEffects: [
              loudnessEnhancer,
              equalizer,
            ],
          ),
        );
      } else {
        player = AudioPlayer();
      }

      final qm = QueueManager();
      return AudioPlayerService(
        player,
        qm,
        equalizer: equalizer,
        loudnessEnhancer: loudnessEnhancer,
      );
    },
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.dystopia.dystopia.audio',
      androidNotificationChannelName: 'DYSTOPIA Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      notificationColor: Color(0xFFA8B545),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioPlayerServiceProvider.overrideWithValue(audioHandler),
      ],
      child: const DystopiaApp(),
    ),
  );
}

class DystopiaApp extends ConsumerWidget {
  const DystopiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DYSTOPIA',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
