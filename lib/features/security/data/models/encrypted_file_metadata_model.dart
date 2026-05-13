import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/encrypted_file_metadata.dart';

@HiveType(typeId: 0)
class EncryptedFileMetadataModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String originalFileName;

  @HiveField(2)
  String mimeType;

  @HiveField(3)
  int originalFileSizeBytes;

  @HiveField(4)
  String encFileName;

  @HiveField(5)
  List<int> wrappedKey;

  @HiveField(6)
  List<int> iv;

  @HiveField(7)
  List<int> pbkdf2Salt;

  @HiveField(8)
  DateTime encryptedAt;

  @HiveField(9)
  String originalFilePath;

  EncryptedFileMetadataModel({
    required this.id,
    required this.originalFileName,
    required this.mimeType,
    required this.originalFileSizeBytes,
    required this.encFileName,
    required this.wrappedKey,
    required this.iv,
    required this.pbkdf2Salt,
    required this.encryptedAt,
    required this.originalFilePath,
  });

  EncryptedFileMetadata toDomain() {
    return EncryptedFileMetadata(
      id: id,
      originalFileName: originalFileName,
      mimeType: mimeType,
      originalFileSizeBytes: originalFileSizeBytes,
      encFileName: encFileName,
      wrappedKey: wrappedKey,
      iv: iv,
      pbkdf2Salt: pbkdf2Salt,
      encryptedAt: encryptedAt,
      originalFilePath: originalFilePath,
    );
  }

  factory EncryptedFileMetadataModel.fromDomain(EncryptedFileMetadata entity) {
    return EncryptedFileMetadataModel(
      id: entity.id,
      originalFileName: entity.originalFileName,
      mimeType: entity.mimeType,
      originalFileSizeBytes: entity.originalFileSizeBytes,
      encFileName: entity.encFileName,
      wrappedKey: entity.wrappedKey,
      iv: entity.iv,
      pbkdf2Salt: entity.pbkdf2Salt,
      encryptedAt: entity.encryptedAt,
      originalFilePath: entity.originalFilePath,
    );
  }
}

/// Manual adapter used because this project already depends on the Isar
/// generator stack, which conflicts with `hive_generator`.
class EncryptedFileMetadataModelAdapter
    extends TypeAdapter<EncryptedFileMetadataModel> {
  @override
  final int typeId = 0;

  @override
  EncryptedFileMetadataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return EncryptedFileMetadataModel(
      id: fields[0] as String,
      originalFileName: fields[1] as String,
      mimeType: fields[2] as String,
      originalFileSizeBytes: fields[3] as int,
      encFileName: fields[4] as String,
      wrappedKey: List<int>.from(fields[5] as List),
      iv: List<int>.from(fields[6] as List),
      pbkdf2Salt: List<int>.from(fields[7] as List),
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
}
