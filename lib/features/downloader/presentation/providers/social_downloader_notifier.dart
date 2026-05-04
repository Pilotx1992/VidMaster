import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/link_parser.dart';
import '../../application/use_cases/extract_metadata_use_case.dart';
import '../../application/use_cases/start_download_use_case.dart';
import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/social_downloader_state.dart';
import '../../domain/entities/media_format.dart';

class SocialDownloaderNotifier extends StateNotifier<SocialDownloaderState> {
  final ExtractMetadataUseCase _extractUseCase;
  final StartDownloadUseCase   _downloadUseCase;

  SocialDownloaderNotifier({
    required ExtractMetadataUseCase extractUseCase,
    required StartDownloadUseCase   downloadUseCase,
  })  : _extractUseCase  = extractUseCase,
        _downloadUseCase = downloadUseCase,
        super(const SocialDownloaderState());

  // ── Extraction ─────────────────────────────────────────────

  Future<void> extractUrl(String url) async {
    if (!LinkParser.isVideoUrl(url)) {
      state = state.copyWith(
        extractionStatus: ExtractionStatus.error,
        extractionError:  'This URL is not supported by VidMaster',
      );
      return;
    }

    state = state.copyWith(
      extractionStatus: ExtractionStatus.loading,
      extractionError:  null,
      extractionResult: null,
    );

    final result = await _extractUseCase(url);
    
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        extractionStatus: ExtractionStatus.error,
        extractionError:  failure.message,
      ),
      (extractionResult) => state = state.copyWith(
        extractionStatus: ExtractionStatus.success,
        extractionResult: extractionResult,
      ),
    );
  }

  void clearExtraction() {
    state = state.copyWith(
      extractionStatus: ExtractionStatus.idle,
      extractionResult: null,
      extractionError:  null,
    );
  }

  // ── Downloads ──────────────────────────────────────────────

  Future<void> startDownload(MediaFormat format) async {
    final result = state.extractionResult;
    if (result == null) return;

    try {
      final task = await _downloadUseCase(
        result: result,
        format: format,
      );
      state = state.copyWith(
        activeTasks: [...state.activeTasks, task],
      );
    } catch (e) {
      debugPrint('[Downloader] startDownload error: $e');
      // Surface error to UI if needed
    }
  }

  void updateTaskProgress(String taskId, int progress, DownloadStatus status) {
    final updated = state.activeTasks.map((t) {
      if (t.taskId != taskId) return t;
      return t.copyWith(progressPercent: progress, status: status);
    }).toList();

    state = state.copyWith(activeTasks: updated);

    // Move to completed list if done
    if (status == DownloadStatus.completed) {
      final taskIndex = updated.indexWhere((t) => t.taskId == taskId);
      if (taskIndex != -1) {
        final task = updated[taskIndex];
        state = state.copyWith(
          activeTasks:    state.activeTasks.where((t) => t.taskId != taskId).toList(),
          completedTasks: [...state.completedTasks, task],
        );
      }
    }
  }

  // ── Clipboard ──────────────────────────────────────────────

  void onClipboardLinkDetected(String url) {
    if (LinkParser.isVideoUrl(url)) {
      state = state.copyWith(
        clipboardUrl:       url,
        showClipboardSnack: true,
      );
    }
  }

  void dismissClipboardSnack() {
    state = state.copyWith(showClipboardSnack: false);
  }

  void acceptClipboardLink() {
    final url = state.clipboardUrl;
    state = state.copyWith(showClipboardSnack: false);
    if (url != null && mounted) extractUrl(url);
  }
}
