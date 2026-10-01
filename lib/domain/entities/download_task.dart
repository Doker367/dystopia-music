import 'package:equatable/equatable.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled
}

class DownloadTask extends Equatable {
  final String id;
  final String songId;
  final String url;
  final String filePath;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final DateTime dateStarted;
  final DateTime? dateCompleted;
  final String? error;

  const DownloadTask({
    required this.id,
    required this.songId,
    required this.url,
    required this.filePath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    required this.dateStarted,
    this.dateCompleted,
    this.error,
  });

  DownloadTask copyWith({
    String? id,
    String? songId,
    String? url,
    String? filePath,
    double? progress,
    DownloadStatus? status,
    DateTime? dateStarted,
    DateTime? dateCompleted,
    String? error,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        id,
        songId,
        url,
        filePath,
        progress,
        status,
        dateStarted,
        dateCompleted,
        error,
      ];
}
