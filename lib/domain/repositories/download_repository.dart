import '../entities/download_task.dart';
import '../entities/song.dart';

abstract class DownloadRepository {
  Future<DownloadTask> downloadSong(Song song);
  
  Future<void> cancelDownload(String taskId);
  
  Future<void> deleteDownload(String songId);
  
  Future<List<DownloadTask>> getDownloads();
  
  Stream<List<DownloadTask>> watchDownloads();
  
  Future<List<Song>> getDownloadedSongs();
  
  Future<bool> isDownloaded(String songId);
  
  Stream<double?> getDownloadProgress(String songId);
}
