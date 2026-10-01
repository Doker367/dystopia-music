import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/playlist.dart';

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 3;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      artworkUrl: fields[3] as String?,
      songIds: (fields[4] as List).cast<String>(),
      songCount: fields[5] as int,
      totalDuration: Duration(milliseconds: fields[6] as int),
      dateCreated: DateTime.parse(fields[7] as String),
      dateModified: DateTime.parse(fields[8] as String),
      isLocal: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.artworkUrl)
      ..writeByte(4)
      ..write(obj.songIds)
      ..writeByte(5)
      ..write(obj.songCount)
      ..writeByte(6)
      ..write(obj.totalDuration.inMilliseconds)
      ..writeByte(7)
      ..write(obj.dateCreated.toIso8601String())
      ..writeByte(8)
      ..write(obj.dateModified.toIso8601String())
      ..writeByte(9)
      ..write(obj.isLocal);
  }
}
