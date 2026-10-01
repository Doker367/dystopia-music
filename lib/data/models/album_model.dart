import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/album.dart';

class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = 2;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      artistId: fields[3] as String,
      artworkUrl: fields[4] as String?,
      localArtworkPath: fields[5] as String?,
      year: fields[6] as int,
      songCount: fields[7] as int,
      totalDuration: Duration(milliseconds: fields[8] as int),
      provider: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.artistId)
      ..writeByte(4)
      ..write(obj.artworkUrl)
      ..writeByte(5)
      ..write(obj.localArtworkPath)
      ..writeByte(6)
      ..write(obj.year)
      ..writeByte(7)
      ..write(obj.songCount)
      ..writeByte(8)
      ..write(obj.totalDuration.inMilliseconds)
      ..writeByte(9)
      ..write(obj.provider);
  }
}
