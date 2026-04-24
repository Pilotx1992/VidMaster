import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../di.dart';
import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/download_url_info.dart';
import '../../domain/usecases/download_usecases.dart';

// ── State ──────────────────────────────────────────────────────────────────

class DownloaderState {
  final List<DownloadTaskEntity> tasks;
  final bool isLoading;
  final String? errorMessage;
  final DownloadUrlInfo? probedUrl;     // Result of last URL probe
  final bool isProbing;

  const DownloaderState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.probedUrl,
    this.isProbing = false,
  });

  List<DownloadTaskEntity> get activeTasks =>
      tasks.where((t) => t.isActive).toList();

  List<DownloadTaskEntity> get completedTasks =>
      tasks.where((t) => t.isFinished).toList();

  List<DownloadTaskEntity> get failedTasks =>
      tasks.where((t) => t.status == DownloadStatus.failed).toList();

  int get activeCount => activeTasks.length;

  DownloaderState copyWith({
    List<DownloadTaskEntity>? tasks,
    bool? isLoading,
    String? errorMessage,
    DownloadUrlInfo? probedUrl,
    bool? isProbing,
    bool clearError = false,
    bool clearProbed = false,
  }) =>
      DownloaderState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        probedUrl: clearProbed ? null : (probedUrl ?? this.probedUrl),
        isProbing: isProbing ?? this.isProbing,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class DownloaderNotifier extends StateNotifier<DownloaderState> {
  final ValidateDownloadUrl _probeUrl;
  final StartDownload _startDownload;
  final PauseDownload _pauseDownload;
  final ResumeDownload _resumeDownload;
  final CancelDownload _cancelDownload;
  final RetryDownload _retryDownload;
  final GetAllDownloads _getAllDownloads;
  final DeleteDownloadRecord _deleteDownload;

  // flutter_downloader communicates via a static ReceivePort.
  // We register a callback to receive progress updates.
  static DownloaderNotifier? _instance;

  DownloaderNotifier({
    required ValidateDownloadUrl probeUrl,
    required StartDownload startDownload,
    required PauseDownload pauseDownload,
    required ResumeDownload resumeDownload,
    required CancelDownload cancelDownload,
    required RetryDownload retryDownload,
    required GetAllDownloads getAllDownloads,
    required DeleteDownloadRecord deleteDownload,
  })  : _probeUrl = probeUrl,
        _startDownload = startDownload,
        _pauseDownload = pauseDownload,
        _resumeDownload = resumeDownload,
        _cancelDownload = cancelDownload,
        _retryDownload = retryDownload,
        _getAllDownloads = getAllDownloads,
        _deleteDownload = deleteDownload,
        super(const DownloaderState()) {
    _instance = this;
    _registerDownloaderCallback();
    loadDownloads();
  }

  // ── flutter_downloader callback (must be a top-level/static function) ─────

  void _registerDownloaderCallback() {
    FlutterDownloader.registerCallback(_downloaderCallback);
  }

  /// Top-level callback required by flutter_downloader.
  /// Routes progress updates back into the notifier state.
  @pragma('vm:entry-point')
  static void _downloaderCallback(String id, int status, int progress) {
    _instance?._onDownloadProgress(id, status, progress);
  }

  void _onDownloadProgress(String taskId, int statusCode, int progress) {
    if (!mounted) return;

    final dlStatus = _mapStatus(statusCode);
    final updated = state.tasks.map((t) {
      if (t.taskId != taskId) return t;
      return t.copyWith(
        status: dlStatus,
        progressPercent: progress,
        completedAt: dlStatus == DownloadStatus.completed ? DateTime.now() : null,
      );
    }).toList();

    state = state.copyWith(tasks: updated);
  }

  // ── Public Actions ────────────────────────────────────────────────────────

  Future<void> loadDownloads() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAllDownloads(const NoParams());
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (tasks) => state = state.copyWith(isLoading: false, tasks: tasks),
    );
  }

  Future<void> probeUrl(String url) async {
    state = state.copyWith(isProbing: true, clearProbed: true, clearError: true);
    final result = await _probeUrl(ValidateDownloadUrlParams(url: url));
    result.fold(
      (f) => state = state.copyWith(isProbing: false, errorMessage: f.message),
      (probed) => state = state.copyWith(isProbing: false, probedUrl: probed),
    );
  }

  Future<bool> startDownload({
    required String url,
    required String fileName,
    bool wifiOnly = false,
  }) async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path ?? '/storage/emulated/0/Download'}/VidMaster';

    final result = await _startDownload(StartDownloadParams(
      url: url,
      fileName: fileName,
      saveDirectory: path,
      wifiOnly: wifiOnly,
    ));

    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (task) {
        state = state.copyWith(
          tasks: [task, ...state.tasks],
          clearProbed: true,
        );
        return true;
      },
    );
  }

  Future<void> pauseDownload(String taskId) async {
    await _pauseDownload(TaskIdParams(taskId: taskId));
    _updateTaskStatus(taskId, DownloadStatus.paused);
  }

  Future<void> resumeDownload(String taskId) async {
    final result = await _resumeDownload(TaskIdParams(taskId: taskId));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (_) => _updateTaskStatus(taskId, DownloadStatus.running),
    );
  }

  Future<void> cancelDownload(String taskId) async {
    await _cancelDownload(TaskIdParams(taskId: taskId));
    final updated = state.tasks.where((t) => t.taskId != taskId).toList();
    state = state.copyWith(tasks: updated);
  }

  Future<void> retryDownload(String taskId) async {
    await _retryDownload(TaskIdParams(taskId: taskId));
    // Reload downloads after retry to get latest state.
    await loadDownloads();
  }

  Future<void> deleteDownload({
    required String taskId,
    required bool deleteFile,
  }) async {
    await _deleteDownload(DeleteDownloadRecordParams(
      taskId: taskId,
      deleteFile: deleteFile,
    ));
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.taskId != taskId).toList(),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
  void clearProbed() => state = state.copyWith(clearProbed: true);

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updateTaskStatus(String taskId, DownloadStatus status) {
    final updated = state.tasks.map((t) {
      if (t.taskId != taskId) return t;
      return t.copyWith(status: status);
    }).toList();
    state = state.copyWith(tasks: updated);
  }

  DownloadStatus _mapStatus(int code) => switch (code) {
        1 => DownloadStatus.queued,
        2 => DownloadStatus.running,
        3 => DownloadStatus.completed,
        4 => DownloadStatus.failed,
        5 => DownloadStatus.cancelled,
        6 => DownloadStatus.paused,
        _ => DownloadStatus.failed,
      };

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }
}

final downloaderProvider =
    StateNotifierProvider<DownloaderNotifier, DownloaderState>((ref) {
  return DownloaderNotifier(
    probeUrl: ref.watch(probeUrlProvider),
    startDownload: ref.watch(startDownloadProvider),
    pauseDownload: ref.watch(pauseDownloadProvider),
    resumeDownload: ref.watch(resumeDownloadProvider),
    cancelDownload: ref.watch(cancelDownloadProvider),
    retryDownload: ref.watch(retryDownloadProvider),
    getAllDownloads: ref.watch(getAllDownloadsProvider),
    deleteDownload: ref.watch(deleteDownloadProvider),
  );
});
