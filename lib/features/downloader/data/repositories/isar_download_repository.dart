import '../../domain/entities/download_task_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/downloader_local_data_source.dart';
import '../models/download_task_model.dart';

class IsarDownloadRepository implements DownloadRepository {
  final DownloaderLocalDataSource _localDataSource;

  IsarDownloadRepository({required DownloaderLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<void> clearCompleted() async {
    final completedTasks = await _localDataSource.getTasksByStatuses([
      DownloadStatus.completed,
      DownloadStatus.cancelled,
      DownloadStatus.failed,
    ]);

    for (final task in completedTasks) {
      await _localDataSource.deleteByTaskId(task.taskId);
    }
  }

  @override
  Future<void> delete(String taskId) async {
    await _localDataSource.deleteByTaskId(taskId);
  }

  @override
  Future<List<DownloadTaskEntity>> loadAll() async {
    final models = await _localDataSource.getAllTasks();
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> save(DownloadTaskEntity task) async {
    final model = DownloadTaskModel.fromDomain(task);
    await _localDataSource.putTask(model);
  }

  @override
  Future<void> update(DownloadTaskEntity task) async {
    final model = DownloadTaskModel.fromDomain(task);
    await _localDataSource.putTask(model);
  }
}
