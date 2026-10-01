import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? localImagePath;
  final int songCount;
  final int albumCount;
  final String provider;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.localImagePath,
    this.songCount = 0,
    this.albumCount = 0,
    required this.provider,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? localImagePath,
    int? songCount,
    int? albumCount,
    String? provider,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      songCount: songCount ?? this.songCount,
      albumCount: albumCount ?? this.albumCount,
      provider: provider ?? this.provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'songCount': songCount,
      'albumCount': albumCount,
      'provider': provider,
    };
  }

  factory Artist.fromJson(Map<String, dynamic> map) {
    return Artist(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      songCount: map['songCount'] as int? ?? 0,
      albumCount: map['albumCount'] as int? ?? 0,
      provider: map['provider'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        localImagePath,
        songCount,
        albumCount,
        provider,
      ];
}
