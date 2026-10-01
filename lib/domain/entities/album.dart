import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String? artworkUrl;
  final String? localArtworkPath;
  final int year;
  final int songCount;
  final Duration totalDuration;
  final String provider;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    this.artworkUrl,
    this.localArtworkPath,
    required this.year,
    this.songCount = 0,
    required this.totalDuration,
    required this.provider,
  });

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? artworkUrl,
    String? localArtworkPath,
    int? year,
    int? songCount,
    Duration? totalDuration,
    String? provider,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      provider: provider ?? this.provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'artworkUrl': artworkUrl,
      'localArtworkPath': localArtworkPath,
      'year': year,
      'songCount': songCount,
      'totalDurationMs': totalDuration.inMilliseconds,
      'provider': provider,
    };
  }

  factory Album.fromJson(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      artistId: map['artistId'] as String,
      artworkUrl: map['artworkUrl'] as String?,
      localArtworkPath: map['localArtworkPath'] as String?,
      year: map['year'] as int? ?? 0,
      songCount: map['songCount'] as int? ?? 0,
      totalDuration: Duration(milliseconds: map['totalDurationMs'] as int? ?? 0),
      provider: map['provider'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        artistId,
        artworkUrl,
        localArtworkPath,
        year,
        songCount,
        totalDuration,
        provider,
      ];
}
