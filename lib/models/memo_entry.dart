import 'package:hive/hive.dart';

class MemoEntry extends HiveObject {
  late String id;
  late DateTime date;
  late String title;
  late String body;
  late int moodIndex;
  String? imagePath;
  late DateTime createdAt;
  late DateTime updatedAt;
}

class MemoEntryAdapter extends TypeAdapter<MemoEntry> {
  @override
  final int typeId = 0;

  @override
  MemoEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoEntry()
      ..id = fields[0] as String
      ..date = fields[1] as DateTime
      ..title = fields[2] as String
      ..body = fields[3] as String
      ..moodIndex = fields[4] as int
      ..imagePath = fields[5] as String?
      ..createdAt = fields[6] as DateTime
      ..updatedAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, MemoEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.moodIndex)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
