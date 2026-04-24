// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_file_metadata_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EncryptedFileMetadataModelAdapter
    extends TypeAdapter<EncryptedFileMetadataModel> {
  @override
  final int typeId = 0;

  @override
  EncryptedFileMetadataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EncryptedFileMetadataModel(
      id: fields[0] as String,
      originalFileName: fields[1] as String,
      mimeType: fields[2] as String,
      originalFileSizeBytes: fields[3] as int,
      encFileName: fields[4] as String,
      wrappedKey: (fields[5] as List).cast<int>(),
      iv: (fields[6] as List).cast<int>(),
      pbkdf2Salt: (fields[7] as List).cast<int>(),
      encryptedAt: fields[8] as DateTime,
      originalFilePath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EncryptedFileMetadataModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalFileName)
      ..writeByte(2)
      ..write(obj.mimeType)
      ..writeByte(3)
      ..write(obj.originalFileSizeBytes)
      ..writeByte(4)
      ..write(obj.encFileName)
      ..writeByte(5)
      ..write(obj.wrappedKey)
      ..writeByte(6)
      ..write(obj.iv)
      ..writeByte(7)
      ..write(obj.pbkdf2Salt)
      ..writeByte(8)
      ..write(obj.encryptedAt)
      ..writeByte(9)
      ..write(obj.originalFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedFileMetadataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
