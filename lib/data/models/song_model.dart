import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/song.dart';

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      artistId: fields[3] as String,
      album: fields[4] as String,
      albumId: fields[5] as String,
      artworkUrl: fields[6] as String?,
      localArtworkPath: fields[7] as String?,
      duration: Duration(milliseconds: fields[8] as int),
      streamUrl: fields[9] as String?,
      localFilePath: fields[10] as String?,
      provider: fields[11] as String,
      isDownloaded: fields[12] as bool,
      isFavorite: fields[13] as bool,
      dateAdded: DateTime.parse(fields[14] as String),
      dateDownloaded: fields[15] != null ? DateTime.parse(fields[15] as String) : null,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.artistId)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.albumId)
      ..writeByte(6)
      ..write(obj.artworkUrl)
      ..writeByte(7)
      ..write(obj.localArtworkPath)
      ..writeByte(8)
      ..write(obj.duration.inMilliseconds)
      ..writeByte(9)
      ..write(obj.streamUrl)
      ..writeByte(10)
      ..write(obj.localFilePath)
      ..writeByte(11)
      ..write(obj.provider)
      ..writeByte(12)
      ..write(obj.isDownloaded)
      ..writeByte(13)
      ..write(obj.isFavorite)
      ..writeByte(14)
      ..write(obj.dateAdded.toIso8601String())
      ..writeByte(15)
      ..write(obj.dateDownloaded?.toIso8601String());
  }
}
