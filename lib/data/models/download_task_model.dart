import 'package:hive/hive.dart';
import 'package:dystopia/domain/entities/download_task.dart';

class DownloadTaskAdapter extends TypeAdapter<DownloadTask> {
  @override
  final int typeId = 4;

  @override
  DownloadTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadTask(
      id: fields[0] as String,
      songId: fields[1] as String,
      url: fields[2] as String,
      filePath: fields[3] as String,
      progress: fields[4] as double,
      status: DownloadStatus.values[fields[5] as int],
      dateStarted: DateTime.parse(fields[6] as String),
      dateCompleted: fields[7] != null ? DateTime.parse(fields[7] as String) : null,
      error: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadTask obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.songId)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.status.index)
      ..writeByte(6)
      ..write(obj.dateStarted.toIso8601String())
      ..writeByte(7)
      ..write(obj.dateCompleted?.toIso8601String())
      ..writeByte(8)
      ..write(obj.error);
  }
}
