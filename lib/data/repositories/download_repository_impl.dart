import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/download_repository.dart';
import '../../providers/youtube_music_provider.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final Dio dio;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, StreamController<double?>> _progressControllers = {};
  
  DownloadRepositoryImpl({required this.dio});

  Box<DownloadTask> get _downloadsBox => Hive.box<DownloadTask>('downloads');
  Box<Song> get _songsBox => Hive.box<Song>('songs');

  @override
  Future<DownloadTask> downloadSong(Song song) async {
    if (song.streamUrl == null) {
      throw Exception('Song has no stream URL');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${appDir.path}/Dystopia/Music');
    final artworkDir = Directory('${appDir.path}/Dystopia/Artwork');
    
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    if (!await artworkDir.exists()) {
      await artworkDir.create(recursive: true);
    }

    final safeTitle = song.title.replaceAll(RegExp(r'[^\w\s]+'), '');
    final filePath = '${musicDir.path}/${song.id}_$safeTitle.mp3';
    
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    var task = DownloadTask(
      id: taskId,
      songId: song.id,
      url: song.streamUrl!,
      filePath: filePath,
      progress: 0.0,
      status: DownloadStatus.pending,
      dateStarted: DateTime.now(),
      dateCompleted: null,
      error: null,
    );

    await _downloadsBox.put(taskId, task);

    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;
    
    if (!_progressControllers.containsKey(song.id)) {
      _progressControllers[song.id] = StreamController<double?>.broadcast();
    }

    // Start download asynchronously without awaiting
    _startDownload(task, song);

    return task;
  }

  Future<void> _startDownload(DownloadTask task, Song song) async {
    try {
      task = _updateTask(task.id, status: DownloadStatus.downloading);
      
      final downloadedFile = await YouTubeMusicProvider.downloadSongOffline(
        song,
        onProgress: (progress) {
          _updateTask(task.id, progress: progress);
          _progressControllers[song.id]?.add(progress);
        },
      );

      if (downloadedFile == null || !await downloadedFile.exists()) {
        throw Exception('Download failed to produce audio file');
      }

      // Download artwork if available
      String? localArtworkPath;
      if (song.artworkUrl != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final artworkPath = '${appDir.path}/Dystopia/Artwork/${song.id}.jpg';
        try {
          await dio.download(song.artworkUrl!, artworkPath);
          localArtworkPath = artworkPath;
        } catch (_) {
          // Ignore artwork download failures
        }
      }

      _updateTask(
        task.id,
        status: DownloadStatus.completed,
        progress: 1.0,
        dateCompleted: DateTime.now(),
      );
      
      _progressControllers[song.id]?.add(1.0);
      _progressControllers[song.id]?.close();
      _progressControllers.remove(song.id);
      _cancelTokens.remove(task.id);

      // Update song status
      final updatedSong = Song(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artistId: song.artistId,
        album: song.album,
        albumId: song.albumId,
        artworkUrl: song.artworkUrl,
        localArtworkPath: localArtworkPath,
        duration: song.duration,
        streamUrl: song.streamUrl,
        localFilePath: downloadedFile.path,
        provider: song.provider,
        isDownloaded: true,
        isFavorite: song.isFavorite,
        dateAdded: song.dateAdded,
        dateDownloaded: DateTime.now(),
      );
      await _songsBox.put(song.id, updatedSong);

    } catch (e) {
      _updateTask(task.id, status: DownloadStatus.failed, error: e.toString());
      _progressControllers[song.id]?.add(null);
      _cancelTokens.remove(task.id);
    }
  }


  DownloadTask _updateTask(
    String taskId, {
    DownloadStatus? status,
    double? progress,
    DateTime? dateCompleted,
    String? error,
  }) {
    final task = _downloadsBox.get(taskId);
    if (task == null) throw Exception('Task not found');
    
    final updated = DownloadTask(
      id: task.id,
      songId: task.songId,
      url: task.url,
      filePath: task.filePath,
      progress: progress ?? task.progress,
      status: status ?? task.status,
      dateStarted: task.dateStarted,
      dateCompleted: dateCompleted ?? task.dateCompleted,
      error: error ?? task.error,
    );
    
    _downloadsBox.put(taskId, updated);
    return updated;
  }

  @override
  Future<void> cancelDownload(String taskId) async {
    _cancelTokens[taskId]?.cancel();
  }

  @override
  Future<void> deleteDownload(String songId) async {
    final song = _songsBox.get(songId);
    if (song != null && song.localFilePath != null) {
      final file = File(song.localFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
      
      if (song.localArtworkPath != null) {
        final artFile = File(song.localArtworkPath!);
        if (await artFile.exists()) {
          await artFile.delete();
        }
      }

      final updatedSong = Song(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artistId: song.artistId,
        album: song.album,
        albumId: song.albumId,
        artworkUrl: song.artworkUrl,
        localArtworkPath: null,
        duration: song.duration,
        streamUrl: song.streamUrl,
        localFilePath: null,
        provider: song.provider,
        isDownloaded: false,
        isFavorite: song.isFavorite,
        dateAdded: song.dateAdded,
        dateDownloaded: null,
      );
      await _songsBox.put(song.id, updatedSong);
    }

    final taskKey = _downloadsBox.keys.firstWhere(
      (key) {
        final t = _downloadsBox.get(key);
        return t != null && t.songId == songId;
      },
      orElse: () => null,
    );

    if (taskKey != null) {
      final task = _downloadsBox.get(taskKey);
      if (task != null && task.filePath.isNotEmpty) {
        final f = File(task.filePath);
        if (await f.exists()) await f.delete();
      }
      await _downloadsBox.delete(taskKey);
    }
  }

  @override
  Future<List<DownloadTask>> getDownloads() async {
    return _downloadsBox.values.toList();
  }

  @override
  Stream<List<DownloadTask>> watchDownloads() async* {
    yield await getDownloads();
    yield* _downloadsBox.watch().asyncMap((event) => getDownloads());
  }

  @override
  Future<List<Song>> getDownloadedSongs() async {
    return _songsBox.values.where((song) => song.isDownloaded).toList();
  }

  @override
  Future<bool> isDownloaded(String songId) async {
    final song = _songsBox.get(songId);
    return song?.isDownloaded ?? false;
  }

  @override
  Stream<double?> getDownloadProgress(String songId) {
    if (!_progressControllers.containsKey(songId)) {
      _progressControllers[songId] = StreamController<double?>.broadcast();
    }
    return _progressControllers[songId]!.stream;
  }
}
