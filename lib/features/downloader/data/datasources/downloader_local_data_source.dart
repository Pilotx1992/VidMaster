import 'package:isar/isar.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/download_task_entity.dart';
import '../models/download_task_model.dart';

/// Local data source for download tasks backed by Isar.
///
/// All methods throw [CacheException] on failure so that the repository
/// can catch and convert them to [CacheFailure].
class DownloaderLocalDataSource {
  final Isar _isar;

  DownloaderLocalDataSource({required Isar isar}) : _isar = isar;

  IsarCollection<DownloadTaskModel> get _box => _isar.downloadTaskModels;

  // ─── CREATE / UPDATE ──────────────────────────────────────────────────

  /// Inserts or updates a download task.
  /// Returns the Isar-assigned row ID.
  int putTask(DownloadTaskModel model) {
    try {
      return _isar.writeTxnSync(() {
        return _box.putSync(model);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to save download task: $e');
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────

  /// Returns the task matching [taskId] (the engine-opaque ID), or `null`.
  DownloadTaskModel? getTaskByTaskId(String taskId) {
    try {
      return _box.filter().taskIdEqualTo(taskId).findFirstSync();
    } catch (e) {
      throw CacheException(message: 'Failed to query task by taskId: $e');
    }
  }

  /// Returns all persisted download tasks, ordered by [createdAt] descending.
  List<DownloadTaskModel> getAllTasks() {
    try {
      return _box.where().sortByCreatedAtDesc().findAllSync();
    } catch (e) {
      throw CacheException(message: 'Failed to fetch all tasks: $e');
    }
  }

  /// Returns tasks whose [statusIndex] matches any of [statuses].
  List<DownloadTaskModel> getTasksByStatuses(List<DownloadStatus> statuses) {
    try {
      final indices = statuses.map((s) => s.index).toList();
      return _box
          .filter()
          .anyOf(indices, (q, int idx) => q.statusIndexEqualTo(idx))
          .sortByCreatedAtDesc()
          .findAllSync();
    } catch (e) {
      throw CacheException(message: 'Failed to query tasks by status: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────

  /// Removes the task with the given engine [taskId].
  /// Returns `true` if a record was actually deleted.
  bool deleteByTaskId(String taskId) {
    try {
      final existing = getTaskByTaskId(taskId);
      if (existing == null) return false;
      return _isar.writeTxnSync(() {
        return _box.deleteSync(existing.id);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to delete task: $e');
    }
  }

  // ─── STREAM ───────────────────────────────────────────────────────────

  /// Watches all download tasks for real-time UI updates.
  ///
  /// Emits the full list of models whenever any record changes.
  Stream<List<DownloadTaskModel>> watchAllTasks() {
    try {
      // Isar watch doesn't emit immediately, but `.watchFast` triggers on any change to the collection.
      // This is a naive watch that emits all objects when anything changes.
      return _box.watchLazy(fireImmediately: true).map((_) {
        return _box.where().sortByCreatedAtDesc().findAllSync();
      });
    } catch (e) {
      throw CacheException(message: 'Failed to watch tasks: $e');
    }
  }
}

