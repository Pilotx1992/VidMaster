import 'package:flutter/foundation.dart';
import 'extraction_result.dart';
import 'download_task_entity.dart';

enum ExtractionStatus { idle, loading, success, error }

@immutable
class SocialDownloaderState {
  final ExtractionStatus      extractionStatus;
  final ExtractionResult?     extractionResult;
  final String?               extractionError;
  final List<DownloadTaskEntity>    activeTasks;
  final List<DownloadTaskEntity>    completedTasks;
  final String?               clipboardUrl;      // Detected link in clipboard
  final bool                  showClipboardSnack;

  const SocialDownloaderState({
    this.extractionStatus    = ExtractionStatus.idle,
    this.extractionResult,
    this.extractionError,
    this.activeTasks         = const [],
    this.completedTasks      = const [],
    this.clipboardUrl,
    this.showClipboardSnack  = false,
  });

  bool get isExtracting => extractionStatus == ExtractionStatus.loading;
  bool get hasResult    => extractionResult != null;

  SocialDownloaderState copyWith({
    ExtractionStatus?    extractionStatus,
    ExtractionResult?    extractionResult,
    String?              extractionError,
    List<DownloadTaskEntity>?  activeTasks,
    List<DownloadTaskEntity>?  completedTasks,
    String?              clipboardUrl,
    bool?                showClipboardSnack,
  }) =>
      SocialDownloaderState(
        extractionStatus:   extractionStatus   ?? this.extractionStatus,
        extractionResult:   extractionResult   ?? this.extractionResult,
        extractionError:    extractionError    ?? this.extractionError,
        activeTasks:        activeTasks        ?? this.activeTasks,
        completedTasks:     completedTasks     ?? this.completedTasks,
        clipboardUrl:       clipboardUrl       ?? this.clipboardUrl,
        showClipboardSnack: showClipboardSnack ?? this.showClipboardSnack,
      );
}
