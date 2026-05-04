import 'package:isar/isar.dart';

import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/download_url_info.dart';

part 'download_task_model.g.dart';

/// Isar data model for persisted download tasks.
@collection
class DownloadTaskModel {
  Id get id => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String taskId;

  String url;
  String fileName;
  String saveDirectory;

  int statusIndex;
  int engineIndex;
  int progressPercent;
  int? totalBytes;
  int downloadedBytes;
  int? speedBytesPerSec;
  DateTime createdAt;
  DateTime? completedAt;
  String? errorMessage;
  bool wifiOnly;

  DownloadTaskModel({
    required this.taskId,
    required this.url,
    required this.fileName,
    required this.saveDirectory,
    required this.statusIndex,
    required this.engineIndex,
    required this.createdAt,
    this.progressPercent = 0,
    this.totalBytes,
    this.downloadedBytes = 0,
    this.speedBytesPerSec,
    this.completedAt,
    this.errorMessage,
    this.wifiOnly = false,
  });

  DownloadTaskEntity toDomain() {
    return DownloadTaskEntity(
      taskId: taskId,
      url: url,
      fileName: fileName,
      saveDirectory: saveDirectory,
      status: (statusIndex >= 0 && statusIndex < DownloadStatus.values.length)
          ? DownloadStatus.values[statusIndex]
          : DownloadStatus.failed,
      createdAt: createdAt,
      engine: (engineIndex >= 0 && engineIndex < DownloadEngineType.values.length)
          ? DownloadEngineType.values[engineIndex]
          : DownloadEngineType.native,
      progressPercent: progressPercent,
      totalBytes: totalBytes,
      downloadedBytes: downloadedBytes,
      speedBytesPerSec: speedBytesPerSec,
      completedAt: completedAt,
      errorMessage: errorMessage,
      wifiOnly: wifiOnly,
    );
  }

  factory DownloadTaskModel.fromDomain(DownloadTaskEntity entity) {
    return DownloadTaskModel(
      taskId: entity.taskId,
      url: entity.url,
      fileName: entity.fileName,
      saveDirectory: entity.saveDirectory,
      statusIndex: entity.status.index,
      engineIndex: entity.engine.index,
      createdAt: entity.createdAt,
      progressPercent: entity.progressPercent,
      totalBytes: entity.totalBytes,
      downloadedBytes: entity.downloadedBytes,
      speedBytesPerSec: entity.speedBytesPerSec,
      completedAt: entity.completedAt,
      errorMessage: entity.errorMessage,
      wifiOnly: entity.wifiOnly,
    );
  }
}
