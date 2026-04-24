import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/encrypted_file_metadata.dart';

part 'encrypted_file_metadata_model.g.dart';

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
