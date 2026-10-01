import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/artist.dart';

class ArtistAdapter extends TypeAdapter<Artist> {
  @override
  final int typeId = 1;

  @override
  Artist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artist(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String?,
      localImagePath: fields[3] as String?,
      songCount: fields[4] as int,
      albumCount: fields[5] as int,
      provider: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Artist obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.localImagePath)
      ..writeByte(4)
      ..write(obj.songCount)
      ..writeByte(5)
      ..write(obj.albumCount)
      ..writeByte(6)
      ..write(obj.provider);
  }
}
