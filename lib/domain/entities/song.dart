import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String? artworkUrl;
  final String? localArtworkPath;
  final Duration duration;
  final String? streamUrl;
  final String? localFilePath;
  final String provider;
  final bool isDownloaded;
  final bool isFavorite;
  final DateTime dateAdded;
  final DateTime? dateDownloaded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    this.artworkUrl,
    this.localArtworkPath,
    required this.duration,
    this.streamUrl,
    this.localFilePath,
    required this.provider,
    this.isDownloaded = false,
    this.isFavorite = false,
    required this.dateAdded,
    this.dateDownloaded,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    String? artworkUrl,
    String? localArtworkPath,
    Duration? duration,
    String? streamUrl,
    String? localFilePath,
    String? provider,
    bool? isDownloaded,
    bool? isFavorite,
    DateTime? dateAdded,
    DateTime? dateDownloaded,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      provider: provider ?? this.provider,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      dateDownloaded: dateDownloaded ?? this.dateDownloaded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'album': album,
      'albumId': albumId,
      'artworkUrl': artworkUrl,
      'localArtworkPath': localArtworkPath,
      'durationMs': duration.inMilliseconds,
      'streamUrl': streamUrl,
      'localFilePath': localFilePath,
      'provider': provider,
      'isDownloaded': isDownloaded,
      'isFavorite': isFavorite,
      'dateAdded': dateAdded.toIso8601String(),
      'dateDownloaded': dateDownloaded?.toIso8601String(),
    };
  }

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      artistId: map['artistId'] as String,
      album: map['album'] as String,
      albumId: map['albumId'] as String,
      artworkUrl: map['artworkUrl'] as String?,
      localArtworkPath: map['localArtworkPath'] as String?,
      duration: Duration(milliseconds: map['durationMs'] as int? ?? 0),
      streamUrl: map['streamUrl'] as String?,
      localFilePath: map['localFilePath'] as String?,
      provider: map['provider'] as String,
      isDownloaded: map['isDownloaded'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      dateDownloaded: map['dateDownloaded'] != null
          ? DateTime.parse(map['dateDownloaded'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        artistId,
        album,
        albumId,
        artworkUrl,
        localArtworkPath,
        duration,
        streamUrl,
        localFilePath,
        provider,
        isDownloaded,
        isFavorite,
        dateAdded,
        dateDownloaded,
      ];
}
