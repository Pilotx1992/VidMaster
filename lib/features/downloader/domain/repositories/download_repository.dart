import '../entities/download_task_entity.dart';

abstract class DownloadRepository {
  Future<List<DownloadTaskEntity>> loadAll();
  Future<void>               save(DownloadTaskEntity task);
  Future<void>               update(DownloadTaskEntity task);
  Future<void>               delete(String taskId);
  Future<void>               clearCompleted();
}
