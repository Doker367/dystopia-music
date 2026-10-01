import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? artworkUrl;
  final List<String> songIds;
  final int songCount;
  final Duration totalDuration;
  final DateTime dateCreated;
  final DateTime dateModified;
  final bool isLocal;

  const Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.artworkUrl,
    this.songIds = const [],
    this.songCount = 0,
    required this.totalDuration,
    required this.dateCreated,
    required this.dateModified,
    this.isLocal = true,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? artworkUrl,
    List<String>? songIds,
    int? songCount,
    Duration? totalDuration,
    DateTime? dateCreated,
    DateTime? dateModified,
    bool? isLocal,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      songIds: songIds ?? this.songIds,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'artworkUrl': artworkUrl,
      'songIds': songIds,
      'songCount': songCount,
      'totalDurationMs': totalDuration.inMilliseconds,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'isLocal': isLocal,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      artworkUrl: map['artworkUrl'] as String?,
      songIds: List<String>.from(map['songIds'] ?? []),
      songCount: map['songCount'] as int? ?? 0,
      totalDuration: Duration(milliseconds: map['totalDurationMs'] as int? ?? 0),
      dateCreated: DateTime.parse(map['dateCreated'] as String),
      dateModified: DateTime.parse(map['dateModified'] as String),
      isLocal: map['isLocal'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        artworkUrl,
        songIds,
        songCount,
        totalDuration,
        dateCreated,
        dateModified,
        isLocal,
      ];
}
