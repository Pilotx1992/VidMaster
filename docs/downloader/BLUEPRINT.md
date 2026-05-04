# VidMaster — Downloader Engine
## Implementation Blueprint v1.0 — Snaptube/XPlayer Grade

> **Document Type:** Implementation Blueprint
> **Companion To:** Downloader PRD v2.0 · Integration Roadmap v2.0 · Technical Blueprint v2.0
> **Project Stack:** Flutter 3.x · yt-dlp (Chaquopy) · FFmpeg · Riverpod · Isar
> **Scope:** Social Media Extraction · DASH Merging · In-App Browser · Clipboard Detection
> **Last Updated:** 2026

---

## Document Purpose

This blueprint answers: **"How do we build a Snaptube-grade downloader inside VidMaster — correctly, safely, and without breaking what exists?"**

It covers every file to create, every Android config to touch, and every integration point with the existing codebase.

---

## Table of Contents

1. [Constraints & Rules of Engagement](#1-constraints--rules-of-engagement)
2. [Verified Existing State](#2-verified-existing-state)
3. [Architecture Overview](#3-architecture-overview)
4. [Dependency Map](#4-dependency-map)
5. [Required Packages](#5-required-packages)
6. [Android Native Configuration](#6-android-native-configuration)
7. [Phase 1 — File Skeleton](#7-phase-1--file-skeleton)
8. [Phase 2 — Domain Layer](#8-phase-2--domain-layer)
9. [Phase 3 — Extraction Engine (yt-dlp via Chaquopy)](#9-phase-3--extraction-engine-yt-dlp-via-chaquopy)
10. [Phase 4 — Merging Pipeline (FFmpeg)](#10-phase-4--merging-pipeline-ffmpeg)
11. [Phase 5 — Download Manager](#11-phase-5--download-manager)
12. [Phase 6 — State Management](#12-phase-6--state-management)
13. [Phase 7 — UI Layer](#13-phase-7--ui-layer)
14. [Phase 8 — Clipboard & Browser](#14-phase-8--clipboard--browser)
15. [Phase 9 — Isar Persistence](#15-phase-9--isar-persistence)
16. [Integration with Existing Downloader Feature](#16-integration-with-existing-downloader-feature)
17. [Unit Test Suite](#17-unit-test-suite)
18. [Pre-Release Checklist](#18-pre-release-checklist)
19. [Known Risks & Mitigations](#19-known-risks--mitigations)

---

## 1. Constraints & Rules of Engagement

### Absolute Rules

```
RULE-01  Never delete existing files in features/downloader/ — only extend.
RULE-02  Read every existing file in features/downloader/ before touching it.
RULE-03  One phase at a time. flutter analyze must pass before advancing.
RULE-04  Never modify features/video_player/, features/music_player/, core/.
RULE-05  All new files go inside lib/features/downloader/ only.
RULE-06  Isar only — no Hive, no SharedPreferences for complex objects.
RULE-07  Never run FFmpeg on the main thread. Always use Isolates or background service.
RULE-08  Never call yt-dlp synchronously. Always async with timeout.
RULE-09  ABI splits must be configured BEFORE adding Chaquopy to avoid APK bloat.
RULE-10  Always check storage availability before starting any download.
```

### Code Quality Standards

```
- All public APIs have doc comments
- All async methods wrapped in try/catch
- debugPrint('[Downloader] ...') prefix for all debug output
- No magic numbers — use named constants in downloader_constants.dart
- Every background operation runs in an Isolate or WorkManager job
- Storage check: available space ≥ 2.5× combined stream size before download
```

---

## 2. Verified Existing State

### Step 0 — Read Before Writing

Run these commands and report results before any code:

```bash
# What exists in downloader?
Get-ChildItem -Path "lib/features/downloader" -Include "*.dart" -Recurse |
  Select-Object FullName

# What Isar collections exist?
Select-String -Path "lib/**/*.dart" -Pattern "@collection" -Recurse

# What providers exist?
Select-String -Path "lib/features/downloader/**/*.dart" -Pattern "Provider" -Recurse

# Check pubspec for existing download packages
Select-String -Path "pubspec.yaml" -Pattern "downloader|ffmpeg|dio|chaquopy"

# Check build.gradle for existing native config
Get-Content "android/app/build.gradle"
```

**Do NOT proceed past Phase 1 until you have read and reported these results.**

---

## 3. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                 │
│  DownloaderScreen                                                   │
│    ├── LinkInputBar          (paste/scan clipboard)                 │
│    ├── QualitySelectionSheet (video grid + audio list)              │
│    ├── ActiveDownloadsList   (progress cards)                       │
│    ├── CompletedDownloadsList                                       │
│    └── InAppBrowser          (webview + floating detect button)     │
├─────────────────────────────────────────────────────────────────────┤
│  STATE LAYER (Riverpod)                                             │
│  DownloaderState  ←→  DownloaderNotifier                           │
│    { extractionStatus, downloads, clipboard, browser }             │
├─────────────────────────────────────────────────────────────────────┤
│  APPLICATION LAYER                                                  │
│  ExtractionUseCase       → fetches MediaFormat list                │
│  DownloadUseCase         → starts single or DASH download           │
│  MergeUseCase            → runs FFmpeg merge                        │
│  ClipboardUseCase        → monitors clipboard for video links       │
├─────────────────────────────────────────────────────────────────────┤
│  ENGINE LAYER                                                       │
│  ExtractionService       → yt-dlp via Chaquopy Isolate             │
│  YoutubeExplodeService   → lightweight YT fallback                  │
│  FFmpegMerger            → merge + convert + embed metadata         │
│  DownloadManager         → parallel tasks, progress tracking        │
│  StorageService          → availability checks, path resolution     │
│  ClipboardMonitor        → background clipboard polling             │
├─────────────────────────────────────────────────────────────────────┤
│  DATA LAYER (Isar)                                                  │
│  DownloadRecordIsar      → persists all download history            │
│  ExtractionCacheIsar     → caches metadata for 24h                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow: Link → Download

```
User pastes link
      │
      ▼
LinkParser.identify(url) → Platform enum (YouTube | Instagram | TikTok | ...)
      │
      ▼
ExtractionService.fetchMetadata(url)
  ├── Primary:  yt-dlp via Chaquopy (Dart Isolate)
  └── Fallback: youtube_explode_dart (YouTube only)
      │
      ▼ List<MediaFormat>
QualitySelectionSheet (user picks format + quality)
      │
      ▼ SelectedFormat
DownloadUseCase.start(format)
  ├── Direct stream  → DownloadManager.startSingle(url, path)
  └── DASH (1080p+)  → DownloadManager.startDouble(videoUrl, audioUrl)
                              │
                              ▼ Both complete
                        FFmpegMerger.merge(video, audio, output)
                              │
                              ▼
                        CleanupService.deleteTemp(video, audio)
                              │
                              ▼
                        IsarRepository.save(DownloadRecord)
                              │
                              ▼
                        VideoLibrary notified → file appears in player
```

---

## 4. Dependency Map

```
domain/entities/      ← imports nothing from this project
domain/repositories/  ← imports domain/entities only
domain/services/      ← imports domain/entities only
data/models/          ← imports domain/entities, isar
data/repositories/    ← imports domain/, data/models, isar
data/services/        ← imports domain/services, platform packages
application/          ← imports domain/, data/
presentation/         ← imports domain/, application/, riverpod

FORBIDDEN:
  domain/ → data/
  domain/ → presentation/
  data/   → presentation/
```

---

## 5. Required Packages

### 5.1 Packages to Add to pubspec.yaml

> Run `flutter pub add <package>` for each, then verify with `flutter pub get`.

```yaml
# Extraction
youtube_explode_dart: ^2.2.0     # Lightweight YouTube fallback (no Python needed)

# Download
flutter_downloader: ^1.11.6      # Background downloads with WorkManager

# FFmpeg
ffmpeg_kit_flutter_full_gpl: ^6.0.3  # Full GPL build for merging + conversion

# Browser
flutter_inappwebview: ^6.0.0     # In-app browser with JS injection

# Clipboard
super_clipboard: ^0.8.0           # Cross-platform clipboard monitoring

# Storage
path_provider: ^2.1.2            # Already likely installed
disk_space: ^0.2.0               # Available storage check
```

> **Note on Chaquopy:** Chaquopy (Python runtime for Android) is added via
> `build.gradle`, not pubspec.yaml. It is configured in Phase 6.

### 5.2 Verify No Conflicts

```bash
flutter pub outdated
flutter pub deps
```

---

## 6. Android Native Configuration

> ⚠️ **Do this BEFORE writing any Dart code.** Native config mistakes are hard to undo.

### 6.1 ABI Splits — build.gradle (app level)

Add this **first**, before Chaquopy, to keep APK size manageable:

```groovy
// android/app/build.gradle

android {
    // ... existing config ...

    splits {
        abi {
            enable true
            reset()
            include "arm64-v8a", "armeabi-v7a", "x86_64"
            universalApk false
        }
    }

    defaultConfig {
        // ... existing config ...
        ndk {
            abiFilters "arm64-v8a", "armeabi-v7a"
        }
    }
}
```

**Result:** Separate APKs (~80-120MB arm64 vs one 350MB+ universal). Users get only their architecture.

---

### 6.2 Chaquopy (yt-dlp Python Bridge)

```groovy
// android/build.gradle (project level) — add to buildscript.repositories:
buildscript {
    repositories {
        // ... existing ...
        maven { url "https://chaquo.com/maven" }
    }
    dependencies {
        // ... existing ...
        classpath "com.chaquo.python:gradle:15.0.1"
    }
}

// android/app/build.gradle — add plugin and configuration:
plugins {
    // ... existing plugins ...
    id "com.chaquo.python"
}

android {
    defaultConfig {
        // ... existing ...

        python {
            pip {
                install "yt-dlp==2024.8.6"
                install "certifi"
            }
            // Python version
            version "3.8"
        }
    }
}
```

**Expected build time increase:** 3-5 minutes first build (downloads Python + yt-dlp).

---

### 6.3 Permissions — AndroidManifest.xml

```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Required for downloads -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29" />
<!-- Android 13+ granular media permission -->
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Required for WorkManager (flutter_downloader) -->
<application>
    <!-- ... existing ... -->

    <provider
        android:name="androidx.work.impl.WorkManagerInitializer"
        android:authorities="${applicationId}.workmanager-init"
        android:exported="false"
        tools:node="remove" />

    <provider
        android:name="vn.hunghd.flutterdownloader.DownloadedFileProvider"
        android:authorities="${applicationId}.flutterdownloader.provider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/provider_paths" />
    </provider>

    <!-- Foreground download service -->
    <service
        android:name="vn.hunghd.flutterdownloader.DownloadWorker"
        android:exported="false"
        android:foregroundServiceType="dataSync" />
</application>
```

Create `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <files-path name="internal_files" path="." />
    <cache-path name="cache" path="." />
</paths>
```

### 6.4 Initialize flutter_downloader in main.dart

Add to your **existing** `main()` function (do not replace it):

```dart
// In main.dart — add inside main() before runApp()
await FlutterDownloader.initialize(
  debug: kDebugMode,
  ignoreSsl: false,
);
```

---

## 7. Phase 1 — File Skeleton

Create all files with `// TODO: implement` content.

```bash
New-Item -ItemType Directory -Force -Path @(
  "lib/features/downloader/domain/entities",
  "lib/features/downloader/domain/repositories",
  "lib/features/downloader/domain/services",
  "lib/features/downloader/data/models",
  "lib/features/downloader/data/repositories",
  "lib/features/downloader/data/services",
  "lib/features/downloader/application/use_cases",
  "lib/features/downloader/presentation/providers",
  "lib/features/downloader/presentation/screens",
  "lib/features/downloader/presentation/widgets",
  "lib/features/downloader/core"
)
```

**Files to create** *(skip any that already exist)*:

```
lib/features/downloader/core/downloader_constants.dart
lib/features/downloader/core/link_parser.dart

lib/features/downloader/domain/entities/media_format.dart
lib/features/downloader/domain/entities/download_task.dart
lib/features/downloader/domain/entities/extraction_result.dart
lib/features/downloader/domain/entities/downloader_state.dart

lib/features/downloader/domain/repositories/download_repository.dart
lib/features/downloader/domain/repositories/extraction_cache_repository.dart

lib/features/downloader/domain/services/extraction_service.dart
lib/features/downloader/domain/services/merge_service.dart
lib/features/downloader/domain/services/storage_service.dart

lib/features/downloader/data/models/download_record_isar.dart
lib/features/downloader/data/models/extraction_cache_isar.dart
lib/features/downloader/data/models/subtitle_settings_isar_model.dart
lib/features/downloader/data/repositories/isar_download_repository.dart
lib/features/downloader/data/repositories/isar_extraction_cache_repository.dart
lib/features/downloader/data/repositories/isar_resume_repository.dart
lib/features/downloader/data/services/ytdlp_extraction_service.dart
lib/features/downloader/data/services/youtube_explode_service.dart
lib/features/downloader/data/services/ffmpeg_merge_service.dart
lib/features/downloader/data/services/storage_service_impl.dart

lib/features/downloader/application/use_cases/extract_metadata_use_case.dart
lib/features/downloader/application/use_cases/start_download_use_case.dart
lib/features/downloader/application/use_cases/merge_streams_use_case.dart
lib/features/downloader/application/use_cases/clipboard_monitor_use_case.dart

lib/features/downloader/presentation/providers/downloader_notifier.dart
lib/features/downloader/presentation/providers/downloader_provider.dart

lib/features/downloader/presentation/screens/downloader_screen.dart
lib/features/downloader/presentation/screens/in_app_browser_screen.dart

lib/features/downloader/presentation/widgets/link_input_bar.dart
lib/features/downloader/presentation/widgets/quality_selection_sheet.dart
lib/features/downloader/presentation/widgets/download_progress_card.dart
lib/features/downloader/presentation/widgets/format_badge.dart
```

### Phase 1 Gate

```bash
flutter analyze lib/features/downloader/
```

**Expected:** 0 errors.

---

## 8. Phase 2 — Domain Layer

### 8.1 Constants

**File:** `lib/features/downloader/core/downloader_constants.dart`

```dart
/// Application-wide constants for the downloader feature.
class DownloaderConstants {
  DownloaderConstants._();

  // ── Extraction ─────────────────────────────────────────────
  static const int  extractionTimeoutSeconds  = 30;
  static const int  metadataCacheDurationHours = 24;
  static const int  maxConcurrentDownloads     = 3;

  // ── Storage ────────────────────────────────────────────────
  /// Minimum free space multiplier before starting a DASH download.
  static const double storageBufferMultiplier = 2.5;

  /// Minimum free space multiplier for single-stream downloads.
  static const double storageBufferSingle     = 1.5;

  // ── Download directory names ───────────────────────────────
  static const String videoSubDir  = 'VidMaster/Videos';
  static const String audioSubDir  = 'VidMaster/Music';
  static const String tempSubDir   = 'VidMaster/.temp';

  // ── FFmpeg ─────────────────────────────────────────────────
  static const int  ffmpegTimeoutSeconds = 120;

  // ── Clipboard polling ──────────────────────────────────────
  static const int  clipboardPollIntervalMs = 1500;

  // ── Supported platforms ────────────────────────────────────
  static const List<String> supportedDomains = [
    'youtube.com', 'youtu.be',
    'instagram.com',
    'facebook.com', 'fb.watch',
    'tiktok.com',
    'twitter.com', 'x.com',
    'vimeo.com',
    'dailymotion.com',
    'twitch.tv',
  ];
}
```

---

### 8.2 Link Parser

**File:** `lib/features/downloader/core/link_parser.dart`

```dart
import 'downloader_constants.dart';

/// Supported social media platforms.
enum VideoPlatform {
  youtube,
  instagram,
  facebook,
  tiktok,
  twitter,
  vimeo,
  dailymotion,
  twitch,
  unknown,
}

/// Parses and classifies video URLs.
class LinkParser {
  LinkParser._();

  /// Returns true if [url] is a recognisable video URL.
  static bool isVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return DownloaderConstants.supportedDomains
          .any((domain) => uri.host.contains(domain));
    } catch (_) {
      return false;
    }
  }

  /// Identifies the platform of [url].
  static VideoPlatform identify(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be'))
      return VideoPlatform.youtube;
    if (lower.contains('instagram.com'))   return VideoPlatform.instagram;
    if (lower.contains('facebook.com') || lower.contains('fb.watch'))
      return VideoPlatform.facebook;
    if (lower.contains('tiktok.com'))      return VideoPlatform.tiktok;
    if (lower.contains('twitter.com') || lower.contains('x.com'))
      return VideoPlatform.twitter;
    if (lower.contains('vimeo.com'))       return VideoPlatform.vimeo;
    if (lower.contains('dailymotion.com')) return VideoPlatform.dailymotion;
    if (lower.contains('twitch.tv'))       return VideoPlatform.twitch;
    return VideoPlatform.unknown;
  }

  /// Returns a cleaned canonical URL (removes tracking params).
  static String clean(String url) {
    try {
      final uri = Uri.parse(url);
      // YouTube: keep only 'v' query param
      if (uri.host.contains('youtu')) {
        final v = uri.queryParameters['v'];
        if (v != null) {
          return 'https://www.youtube.com/watch?v=$v';
        }
      }
      return url;
    } catch (_) {
      return url;
    }
  }
}
```

---

### 8.3 MediaFormat Entity

**File:** `lib/features/downloader/domain/entities/media_format.dart`

```dart
import 'package:flutter/foundation.dart';

/// Represents a single downloadable stream format from the extraction engine.
@immutable
class MediaFormat {
  /// Platform-specific format identifier (e.g. "137+140" for YouTube DASH).
  final String formatId;

  /// File extension without dot (e.g. "mp4", "webm", "m4a").
  final String extension;

  /// Video width in pixels. Null for audio-only formats.
  final int? width;

  /// Video height in pixels. Null for audio-only formats.
  final int? height;

  /// Human-readable quality note (e.g. "1080p", "720p HD", "Audio 320kbps").
  final String note;

  /// Estimated file size in bytes. Null if unknown.
  final int? fileSizeBytes;

  /// Direct stream URL. May be null for DASH (uses separate videoUrl + audioUrl).
  final String? url;

  /// Separate video-only URL for DASH streams (1080p+).
  final String? videoUrl;

  /// Separate audio-only URL for DASH streams (1080p+).
  final String? audioUrl;

  /// Bitrate in kbps for audio formats.
  final int? audioBitrate;

  const MediaFormat({
    required this.formatId,
    required this.extension,
    required this.note,
    this.width,
    this.height,
    this.fileSizeBytes,
    this.url,
    this.videoUrl,
    this.audioUrl,
    this.audioBitrate,
  });

  /// True for audio-only formats (MP3, M4A, etc.).
  bool get isAudioOnly => width == null && height == null;

  /// True when this format requires a separate DASH merge operation.
  bool get requiresMerge =>
      videoUrl != null && audioUrl != null && url == null;

  /// Formatted file size string (e.g. "245 MB").
  String get formattedSize {
    if (fileSizeBytes == null) return 'Unknown size';
    final mb = fileSizeBytes! / (1024 * 1024);
    return mb >= 1024
        ? '${(mb / 1024).toStringAsFixed(1)} GB'
        : '${mb.toStringAsFixed(0)} MB';
  }

  /// Quality label for display (e.g. "1080p", "720p HD", "320kbps").
  String get qualityLabel {
    if (height != null) return '${height}p';
    if (audioBitrate != null) return '${audioBitrate}kbps';
    return note;
  }

  @override
  String toString() =>
      'MediaFormat($formatId, ${qualityLabel}, ${isAudioOnly ? "audio" : "video"})';
}
```

---

### 8.4 ExtractionResult Entity

**File:** `lib/features/downloader/domain/entities/extraction_result.dart`

```dart
import 'package:flutter/foundation.dart';
import 'media_format.dart';

/// Result of a successful metadata extraction from a video URL.
@immutable
class ExtractionResult {
  final String              originalUrl;
  final String              title;
  final String?             thumbnailUrl;
  final Duration?           duration;
  final String?             uploaderName;
  final List<MediaFormat>   videoFormats;
  final List<MediaFormat>   audioFormats;
  final DateTime            fetchedAt;

  const ExtractionResult({
    required this.originalUrl,
    required this.title,
    required this.videoFormats,
    required this.audioFormats,
    required this.fetchedAt,
    this.thumbnailUrl,
    this.duration,
    this.uploaderName,
  });

  /// All formats combined, video first then audio.
  List<MediaFormat> get allFormats => [...videoFormats, ...audioFormats];

  /// Best available video quality (highest resolution).
  MediaFormat? get bestVideoFormat {
    if (videoFormats.isEmpty) return null;
    return videoFormats.reduce(
      (a, b) => (a.height ?? 0) > (b.height ?? 0) ? a : b,
    );
  }

  /// Best available audio quality (highest bitrate).
  MediaFormat? get bestAudioFormat {
    if (audioFormats.isEmpty) return null;
    return audioFormats.reduce(
      (a, b) => (a.audioBitrate ?? 0) > (b.audioBitrate ?? 0) ? a : b,
    );
  }
}
```

---

### 8.5 DownloadTask Entity

**File:** `lib/features/downloader/domain/entities/download_task.dart`

```dart
import 'package:flutter/foundation.dart';
import 'media_format.dart';

enum DownloadStatus {
  queued,
  extracting,
  downloading,
  merging,
  completed,
  failed,
  cancelled,
}

/// Represents a single download job, including DASH multi-stream jobs.
@immutable
class DownloadTask {
  final String        id;           // UUID
  final String        url;          // Original page URL
  final String        title;
  final String?       thumbnailUrl;
  final MediaFormat   format;
  final DownloadStatus status;
  final double        progress;     // 0.0 → 1.0

  /// For DASH: progress of video stream separately.
  final double        videoProgress;

  /// For DASH: progress of audio stream separately.
  final double        audioProgress;

  final String?       outputPath;   // Final file path when completed
  final String?       errorMessage;
  final DateTime      createdAt;

  const DownloadTask({
    required this.id,
    required this.url,
    required this.title,
    required this.format,
    required this.createdAt,
    this.status       = DownloadStatus.queued,
    this.progress     = 0.0,
    this.videoProgress = 0.0,
    this.audioProgress = 0.0,
    this.thumbnailUrl,
    this.outputPath,
    this.errorMessage,
  });

  bool get isDash      => format.requiresMerge;
  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed    => status == DownloadStatus.failed;
  bool get isActive    =>
      status == DownloadStatus.downloading ||
      status == DownloadStatus.merging ||
      status == DownloadStatus.extracting;

  DownloadTask copyWith({
    DownloadStatus? status,
    double?        progress,
    double?        videoProgress,
    double?        audioProgress,
    String?        outputPath,
    String?        errorMessage,
  }) =>
      DownloadTask(
        id:            id,
        url:           url,
        title:         title,
        format:        format,
        createdAt:     createdAt,
        thumbnailUrl:  thumbnailUrl,
        status:        status        ?? this.status,
        progress:      progress      ?? this.progress,
        videoProgress: videoProgress ?? this.videoProgress,
        audioProgress: audioProgress ?? this.audioProgress,
        outputPath:    outputPath    ?? this.outputPath,
        errorMessage:  errorMessage  ?? this.errorMessage,
      );
}
```

---

### 8.6 DownloaderState Entity

**File:** `lib/features/downloader/domain/entities/downloader_state.dart`

```dart
import 'package:flutter/foundation.dart';
import 'extraction_result.dart';
import 'download_task.dart';

enum ExtractionStatus { idle, loading, success, error }

@immutable
class DownloaderState {
  final ExtractionStatus      extractionStatus;
  final ExtractionResult?     extractionResult;
  final String?               extractionError;
  final List<DownloadTask>    activeTasks;
  final List<DownloadTask>    completedTasks;
  final String?               clipboardUrl;      // Detected link in clipboard
  final bool                  showClipboardSnack;

  const DownloaderState({
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

  DownloaderState copyWith({
    ExtractionStatus?    extractionStatus,
    ExtractionResult?    extractionResult,
    String?              extractionError,
    List<DownloadTask>?  activeTasks,
    List<DownloadTask>?  completedTasks,
    String?              clipboardUrl,
    bool?                showClipboardSnack,
  }) =>
      DownloaderState(
        extractionStatus:   extractionStatus   ?? this.extractionStatus,
        extractionResult:   extractionResult   ?? this.extractionResult,
        extractionError:    extractionError    ?? this.extractionError,
        activeTasks:        activeTasks        ?? this.activeTasks,
        completedTasks:     completedTasks     ?? this.completedTasks,
        clipboardUrl:       clipboardUrl       ?? this.clipboardUrl,
        showClipboardSnack: showClipboardSnack ?? this.showClipboardSnack,
      );
}
```

---

### 8.7 Repository Interfaces

**File:** `lib/features/downloader/domain/repositories/download_repository.dart`

```dart
import '../entities/download_task.dart';

abstract class DownloadRepository {
  Future<List<DownloadTask>> loadAll();
  Future<void>               save(DownloadTask task);
  Future<void>               update(DownloadTask task);
  Future<void>               delete(String taskId);
  Future<void>               clearCompleted();
}
```

**File:** `lib/features/downloader/domain/repositories/extraction_cache_repository.dart`

```dart
import '../entities/extraction_result.dart';

abstract class ExtractionCacheRepository {
  /// Returns cached result if it exists and is younger than 24 hours.
  Future<ExtractionResult?> getCached(String url);
  Future<void>              cache(String url, ExtractionResult result);
  Future<void>              clearExpired();
}
```

**File:** `lib/features/downloader/domain/services/storage_service.dart`

```dart
abstract class StorageService {
  /// Returns available storage in bytes.
  Future<int>    availableBytes();

  /// Resolves the output directory path for [subDir].
  Future<String> resolveOutputPath(String subDir, String filename);

  /// Resolves a temp path for intermediate DASH files.
  Future<String> resolveTempPath(String filename);

  /// Returns true if there is enough space for [requiredBytes].
  Future<bool>   hasEnoughSpace(int requiredBytes, {double multiplier = 2.5});

  /// Deletes a file at [path] safely (no exception if missing).
  Future<void>   deleteFile(String path);
}
```

**File:** `lib/features/downloader/domain/services/extraction_service.dart`

```dart
import '../entities/extraction_result.dart';

/// Contract for fetching video metadata from a URL.
abstract class ExtractionService {
  /// Fetches all available formats for [url].
  ///
  /// Throws [ExtractionException] on failure.
  Future<ExtractionResult> fetchMetadata(String url);
}

class ExtractionException implements Exception {
  final String message;
  final String? url;
  const ExtractionException(this.message, {this.url});

  @override
  String toString() => 'ExtractionException: $message (url: $url)';
}
```

**File:** `lib/features/downloader/domain/services/merge_service.dart`

```dart
abstract class MergeService {
  /// Merges [videoPath] and [audioPath] into [outputPath] using FFmpeg.
  /// Returns the final output path on success.
  Future<String> mergeVideoAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  });

  /// Converts [inputPath] (any format) to MP3 at [outputPath].
  Future<String> convertToMp3({
    required String inputPath,
    required String outputPath,
    int              bitrate = 320,
  });
}

class MergeException implements Exception {
  final String message;
  final int?   ffmpegReturnCode;
  const MergeException(this.message, {this.ffmpegReturnCode});
}
```

### Phase 2 Gate

```bash
flutter analyze lib/features/downloader/domain/
```

**Expected:** 0 errors.

---

## 9. Phase 3 — Extraction Engine (yt-dlp via Chaquopy)

### 9.1 yt-dlp Bridge (Python → Dart via Chaquopy)

Create the Python script that Chaquopy will execute:

**File:** `android/app/src/main/python/ytdlp_bridge.py`

```python
import yt_dlp
import json
import sys

def fetch_metadata(url):
    """
    Fetches video metadata using yt-dlp.
    Returns a JSON string with title, thumbnail, formats.
    """
    ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'skip_download': True,
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            formats = []
            for f in info.get('formats', []):
                fmt = {
                    'format_id': f.get('format_id', ''),
                    'ext':       f.get('ext', 'mp4'),
                    'width':     f.get('width'),
                    'height':    f.get('height'),
                    'note':      f.get('format_note', ''),
                    'filesize':  f.get('filesize') or f.get('filesize_approx'),
                    'url':       f.get('url'),
                    'vcodec':    f.get('vcodec', 'none'),
                    'acodec':    f.get('acodec', 'none'),
                    'abr':       f.get('abr'),
                    'tbr':       f.get('tbr'),
                }
                formats.append(fmt)
            
            result = {
                'title':     info.get('title', 'Unknown'),
                'thumbnail': info.get('thumbnail'),
                'duration':  info.get('duration'),
                'uploader':  info.get('uploader'),
                'formats':   formats,
            }
            return json.dumps(result)
    except Exception as e:
        return json.dumps({'error': str(e)})
```

---

### 9.2 yt-dlp Dart Service

**File:** `lib/features/downloader/data/services/ytdlp_extraction_service.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/services/extraction_service.dart';
import '../../core/downloader_constants.dart';
import '../../core/link_parser.dart';

/// Extraction service using yt-dlp via Chaquopy (Python on Android).
///
/// Runs in a separate Dart Isolate to avoid blocking the main thread.
class YtdlpExtractionService implements ExtractionService {
  static const _channel = MethodChannel('com.vidmaster/ytdlp');

  @override
  Future<ExtractionResult> fetchMetadata(String url) async {
    final cleanUrl = LinkParser.clean(url);

    try {
      // Run in Isolate to prevent main thread jank
      final jsonString = await _fetchInIsolate(cleanUrl);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        throw ExtractionException(
          data['error'] as String,
          url: cleanUrl,
        );
      }

      return _parseResult(cleanUrl, data);
    } on PlatformException catch (e) {
      throw ExtractionException(
        'yt-dlp platform error: ${e.message}',
        url: cleanUrl,
      );
    } on TimeoutException {
      throw ExtractionException(
        'Extraction timed out after ${DownloaderConstants.extractionTimeoutSeconds}s',
        url: cleanUrl,
      );
    }
  }

  Future<String> _fetchInIsolate(String url) async {
    final rootToken = RootIsolateToken.instance!;
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _isolateEntry, 
      _IsolatePayload(
        sendPort: receivePort.sendPort, 
        url: url, 
        token: rootToken,
      ),
    );
    
    final result = await receivePort.first;
    if (result is String) return result;
    throw Exception('Isolate returned invalid result type');
  }

  static Future<void> _isolateEntry(_IsolatePayload payload) async {
    // ✅ REQUIRED: Initialize binary messenger for MethodChannel in background isolate
    BackgroundIsolateBinaryMessenger.ensureInitialized(payload.token);

    try {
      const channel = MethodChannel('com.vidmaster/ytdlp');
      final result = await channel.invokeMethod<String>('fetchMetadata', payload.url);
      payload.sendPort.send(result ?? '{"error": "Empty response from engine"}');
    } catch (e) {
      payload.sendPort.send('{"error": "$e"}');
    }
  }

  ExtractionResult _parseResult(String url, Map<String, dynamic> data) {
    final rawFormats = (data['formats'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final videoFormats = <MediaFormat>[];
    final audioFormats = <MediaFormat>[];

    for (final f in rawFormats) {
      final vcodec = f['vcodec'] as String? ?? 'none';
      final acodec = f['acodec'] as String? ?? 'none';
      final height = f['height'] as int?;

      if (vcodec == 'none' && acodec != 'none') {
        // Audio-only format
        audioFormats.add(MediaFormat(
          formatId:     f['format_id'] as String,
          extension:    f['ext'] as String? ?? 'm4a',
          note:         f['note'] as String? ?? 'Audio',
          audioBitrate: (f['abr'] as num?)?.toInt(),
          fileSizeBytes: f['filesize'] as int?,
          url:          f['url'] as String?,
        ));
      } else if (height != null) {
        // Video format (may or may not have audio)
        final hasAudio = acodec != 'none';
        videoFormats.add(MediaFormat(
          formatId:     f['format_id'] as String,
          extension:    f['ext'] as String? ?? 'mp4',
          note:         f['note'] as String? ?? '${height}p',
          width:        f['width'] as int?,
          height:       height,
          fileSizeBytes: f['filesize'] as int?,
          url:          hasAudio ? f['url'] as String? : null,
          videoUrl:     hasAudio ? null : f['url'] as String?,
        ));
      }
    }

    // Sort video by height descending, audio by bitrate descending
    videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
    audioFormats.sort(
        (a, b) => (b.audioBitrate ?? 0).compareTo(a.audioBitrate ?? 0));

    // For DASH videos: pair video-only with best audio URL
    final bestAudio = audioFormats.isNotEmpty ? audioFormats.first : null;
    final pairedFormats = videoFormats.map((vf) {
      if (vf.videoUrl != null && bestAudio?.url != null) {
        return MediaFormat(
          formatId:     vf.formatId,
          extension:    vf.extension,
          note:         vf.note,
          width:        vf.width,
          height:       vf.height,
          fileSizeBytes: vf.fileSizeBytes,
          videoUrl:     vf.videoUrl,
          audioUrl:     bestAudio!.url,
        );
      }
      return vf;
    }).toList();

    final durationSec = data['duration'] as num?;

    return ExtractionResult(
      originalUrl:  url,
      title:        data['title'] as String? ?? 'Unknown',
      thumbnailUrl: data['thumbnail'] as String?,
      duration:     durationSec != null
          ? Duration(seconds: durationSec.toInt())
          : null,
      uploaderName: data['uploader'] as String?,
      videoFormats: pairedFormats,
      audioFormats: audioFormats,
      fetchedAt:    DateTime.now(),
    );
  }
}

/// Payload model for Isolate communication.
class _IsolatePayload {
  final SendPort sendPort;
  final String url;
  final RootIsolateToken token;

  _IsolatePayload({
    required this.sendPort,
    required this.url,
    required this.token,
  });
}
```

---

### 9.3 Android Native Method Channel

**File:** `android/app/src/main/kotlin/.../MainActivity.kt`

Add to your **existing** `MainActivity.kt` (do not replace the class):

```kotlin
// Add inside configureFlutterEngine(), alongside any existing channels:

MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.vidmaster/ytdlp")
    .setMethodCallHandler { call, result ->
        if (call.method == "fetchMetadata") {
            val url = call.arguments as String
            Thread {
                try {
                    // Call Python via Chaquopy
                    val python = Python.getInstance()
                    val module = python.getModule("ytdlp_bridge")
                    val jsonResult = module.callAttr("fetch_metadata", url).toString()
                    Handler(Looper.getMainLooper()).post {
                        result.success(jsonResult)
                    }
                } catch (e: Exception) {
                    Handler(Looper.getMainLooper()).post {
                        result.error("YTDLP_ERROR", e.message, null)
                    }
                }
            }.start()
        } else {
            result.notImplemented()
        }
    }
```

---

### 9.4 youtube_explode Fallback Service

**File:** `lib/features/downloader/data/services/youtube_explode_service.dart`

```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/services/extraction_service.dart';

/// Lightweight YouTube-only extraction using youtube_explode_dart.
/// Used as fallback when yt-dlp is unavailable or fails.
class YoutubeExplodeService implements ExtractionService {
  final YoutubeExplode _yt = YoutubeExplode();

  @override
  Future<ExtractionResult> fetchMetadata(String url) async {
    try {
      final videoId = VideoId(url);
      final video   = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      final videoFormats = <MediaFormat>[];
      final audioFormats = <MediaFormat>[];

      // Muxed streams (video + audio — usually up to 720p)
      for (final stream in manifest.muxed) {
        videoFormats.add(MediaFormat(
          formatId:      stream.tag.toString(),
          extension:     stream.container.name,
          note:          stream.qualityLabel,
          height:        stream.videoResolution.height,
          width:         stream.videoResolution.width,
          fileSizeBytes: stream.size.totalBytes,
          url:           stream.url.toString(),
        ));
      }

      // Video-only streams for DASH
      final bestAudio = manifest.audioOnly.withHighestBitrate();
      for (final stream in manifest.videoOnly) {
        videoFormats.add(MediaFormat(
          formatId:     stream.tag.toString(),
          extension:    stream.container.name,
          note:         stream.qualityLabel,
          height:       stream.videoResolution.height,
          width:        stream.videoResolution.width,
          fileSizeBytes: stream.size.totalBytes,
          videoUrl:     stream.url.toString(),
          audioUrl:     bestAudio.url.toString(),
        ));
      }

      // Audio-only streams
      for (final stream in manifest.audioOnly) {
        audioFormats.add(MediaFormat(
          formatId:      stream.tag.toString(),
          extension:     stream.container.name,
          note:          'Audio ${stream.bitrate.kiloBitsPerSecond.round()}kbps',
          audioBitrate:  stream.bitrate.kiloBitsPerSecond.round(),
          fileSizeBytes: stream.size.totalBytes,
          url:           stream.url.toString(),
        ));
      }

      videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
      audioFormats.sort(
          (a, b) => (b.audioBitrate ?? 0).compareTo(a.audioBitrate ?? 0));

      return ExtractionResult(
        originalUrl:  url,
        title:        video.title,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration:     video.duration,
        uploaderName: video.author,
        videoFormats: videoFormats,
        audioFormats: audioFormats,
        fetchedAt:    DateTime.now(),
      );
    } on VideoUnavailableException {
      throw ExtractionException('Video is unavailable or private', url: url);
    } catch (e) {
      throw ExtractionException('youtube_explode error: $e', url: url);
    }
  }

  void dispose() => _yt.close();
}
```

---

### 9.5 Composite Extraction Strategy

**File:** `lib/features/downloader/application/use_cases/extract_metadata_use_case.dart`

```dart
import '../../core/link_parser.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/extraction_cache_repository.dart';
import '../../domain/services/extraction_service.dart';

/// Orchestrates extraction with caching and automatic fallback.
///
/// Strategy:
/// 1. Check Isar cache (24h TTL)
/// 2. Try yt-dlp (all platforms)
/// 3. Fallback to youtube_explode (YouTube only)
class ExtractMetadataUseCase {
  final ExtractionService          _ytdlp;
  final ExtractionService          _ytExplode;
  final ExtractionCacheRepository  _cache;

  ExtractMetadataUseCase({
    required ExtractionService         ytdlp,
    required ExtractionService         ytExplode,
    required ExtractionCacheRepository cache,
  })  : _ytdlp     = ytdlp,
        _ytExplode = ytExplode,
        _cache     = cache;

  Future<ExtractionResult> call(String url) async {
    final cleanUrl = LinkParser.clean(url);
    final platform = LinkParser.identify(cleanUrl);

    // Step 1: Cache hit?
    final cached = await _cache.getCached(cleanUrl);
    if (cached != null) {
      debugPrint('[Extractor] Cache hit for $cleanUrl');
      return cached;
    }

    // Step 2: Try yt-dlp (primary)
    ExtractionResult? result;
    try {
      result = await _ytdlp.fetchMetadata(cleanUrl);
      debugPrint('[Extractor] yt-dlp success for $cleanUrl');
    } on ExtractionException catch (e) {
      debugPrint('[Extractor] yt-dlp failed: $e');
    }

    // Step 3: Fallback to youtube_explode (YouTube only)
    if (result == null && platform == VideoPlatform.youtube) {
      try {
        result = await _ytExplode.fetchMetadata(cleanUrl);
        debugPrint('[Extractor] youtube_explode fallback success');
      } on ExtractionException catch (e) {
        debugPrint('[Extractor] youtube_explode also failed: $e');
        rethrow;
      }
    }

    if (result == null) {
      throw ExtractionException(
        'All extraction engines failed for this URL',
        url: cleanUrl,
      );
    }

    // Cache the result
    await _cache.cache(cleanUrl, result);
    return result;
  }
}
```

### Phase 3 Gate

```bash
flutter analyze lib/features/downloader/
flutter build apk --debug   # Verify Chaquopy builds without error
```

---

## 10. Phase 4 — Merging Pipeline (FFmpeg)

### 10.1 FFmpeg Merge Service

**File:** `lib/features/downloader/data/services/ffmpeg_merge_service.dart`

```dart
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

import '../../domain/services/merge_service.dart';
import '../../core/downloader_constants.dart';

/// FFmpeg-based implementation of [MergeService].
///
/// All operations run in FFmpegKit's internal async queue.
/// Never call this from a UI callback directly — use a background task.
class FfmpegMergeService implements MergeService {
  @override
  Future<String> mergeVideoAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  }) async {
    // Command: copy video and audio streams without re-encoding
    // This is fast (no quality loss, no CPU-intensive transcoding)
    final command =
        '-i "$videoPath" -i "$audioPath" '
        '-c copy '
        '-map 0:v:0 -map 1:a:0 '
        '-movflags +faststart '
        '"$outputPath"';

    debugPrint('[FFmpeg] Merging: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getLogsAsString();
      throw MergeException(
        'Merge failed with code ${returnCode?.getValue()}',
        ffmpegReturnCode: returnCode?.getValue(),
      );
    }

    debugPrint('[FFmpeg] Merge complete → $outputPath');
    return outputPath;
  }

  @override
  Future<String> convertToMp3({
    required String inputPath,
    required String outputPath,
    int bitrate = 320,
  }) async {
    // Re-encode to MP3 with specified bitrate
    final command =
        '-i "$inputPath" '
        '-vn '                          // No video
        '-acodec libmp3lame '
        '-ab ${bitrate}k '
        '-ar 44100 '
        '"$outputPath"';

    debugPrint('[FFmpeg] Converting to MP3: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getLogsAsString();
      throw MergeException(
        'MP3 conversion failed',
        ffmpegReturnCode: returnCode?.getValue(),
      );
    }

    return outputPath;
  }
}
```

---

### 10.2 Merge Use Case

**File:** `lib/features/downloader/application/use_cases/merge_streams_use_case.dart`

```dart
import '../../domain/services/merge_service.dart';
import '../../domain/services/storage_service.dart';
import '../../domain/entities/download_task.dart';

/// Orchestrates the DASH merge pipeline after both streams complete.
class MergeStreamsUseCase {
  final MergeService   _merger;
  final StorageService _storage;

  MergeStreamsUseCase({
    required MergeService   merger,
    required StorageService storage,
  })  : _merger  = merger,
        _storage = storage;

  Future<String> call({
    required String videoTempPath,
    required String audioTempPath,
    required String title,
    required String extension,
  }) async {
    // Sanitize filename
    final safeTitle = title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .substring(0, title.length.clamp(0, 100));

    final outputPath = await _storage.resolveOutputPath(
      'VidMaster/Videos',
      '$safeTitle.$extension',
    );

    try {
      final result = await _merger.mergeVideoAudio(
        videoPath:  videoTempPath,
        audioPath:  audioTempPath,
        outputPath: outputPath,
      );

      // Cleanup temp files
      await _storage.deleteFile(videoTempPath);
      await _storage.deleteFile(audioTempPath);
      debugPrint('[MergeUseCase] Temp files deleted');

      return result;
    } on MergeException {
      // Do not delete temp files on failure — allow retry
      rethrow;
    }
  }
}
```

---

## 11. Phase 5 — Download Manager

### 11.1 Start Download Use Case

**File:** `lib/features/downloader/application/use_cases/start_download_use_case.dart`

```dart
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/download_task.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/services/storage_service.dart';
import '../../core/downloader_constants.dart';

class StartDownloadUseCase {
  final DownloadRepository _repo;
  final StorageService     _storage;

  StartDownloadUseCase({
    required DownloadRepository repo,
    required StorageService     storage,
  })  : _repo    = repo,
        _storage = storage;

  /// Starts a download for [format] from [result].
  /// Returns the created [DownloadTask].
  Future<DownloadTask> call({
    required ExtractionResult result,
    required MediaFormat      format,
  }) async {
    // Storage check
    final required = format.fileSizeBytes ?? 0;
    if (required > 0) {
      final multiplier = format.requiresMerge
          ? DownloaderConstants.storageBufferMultiplier
          : DownloaderConstants.storageBufferSingle;

      final hasSpace = await _storage.hasEnoughSpace(
        required, multiplier: multiplier,
      );
      if (!hasSpace) {
        throw InsufficientStorageException(required);
      }
    }

    final taskId = const Uuid().v4();
    final isAudio = format.isAudioOnly;
    final subDir  = isAudio
        ? DownloaderConstants.audioSubDir
        : DownloaderConstants.videoSubDir;

    final safeTitle = result.title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .substring(0, result.title.length.clamp(0, 100));

    final task = DownloadTask(
      id:           taskId,
      url:          result.originalUrl,
      title:        result.title,
      thumbnailUrl: result.thumbnailUrl,
      format:       format,
      createdAt:    DateTime.now(),
      status:       DownloadStatus.downloading,
    );

    await _repo.save(task);

    if (format.requiresMerge) {
      await _startDashDownload(taskId, task, result, format);
    } else {
      await _startDirectDownload(taskId, task, format, subDir, safeTitle);
    }

    return task;
  }

  Future<void> _startDirectDownload(
    String taskId,
    DownloadTask task,
    MediaFormat format,
    String subDir,
    String safeTitle,
  ) async {
    final outputPath = await _storage.resolveOutputPath(
      subDir, '$safeTitle.${format.extension}',
    );

    await FlutterDownloader.enqueue(
      url:        format.url!,
      savedDir:   outputPath.substring(0, outputPath.lastIndexOf('/')),
      fileName:   '$safeTitle.${format.extension}',
      showNotification: true,
      openFileFromNotification: false,
    );
  }

  Future<void> _startDashDownload(
    String taskId,
    DownloadTask task,
    ExtractionResult result,
    MediaFormat format,
  ) async {
    // For DASH: download video and audio to temp separately
    // The MergeStreamsUseCase handles merging when both complete
    final videoTemp = await _storage.resolveTempPath('${taskId}_video.${format.extension}');
    final audioTemp = await _storage.resolveTempPath('${taskId}_audio.m4a');

    await FlutterDownloader.enqueue(
      url:        format.videoUrl!,
      savedDir:   videoTemp.substring(0, videoTemp.lastIndexOf('/')),
      fileName:   '${taskId}_video.${format.extension}',
      showNotification: false,
      openFileFromNotification: false,
    );

    await FlutterDownloader.enqueue(
      url:        format.audioUrl!,
      savedDir:   audioTemp.substring(0, audioTemp.lastIndexOf('/')),
      fileName:   '${taskId}_audio.m4a',
      showNotification: false,
      openFileFromNotification: false,
    );
  }
}

class InsufficientStorageException implements Exception {
  final int requiredBytes;
  const InsufficientStorageException(this.requiredBytes);

  @override
  String toString() =>
      'InsufficientStorageException: Need at least '
      '${(requiredBytes / 1024 / 1024).ceil()} MB of free space';
}
```

---

## 12. Phase 6 — State Management

**File:** `lib/features/downloader/presentation/providers/downloader_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/link_parser.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/downloader_state.dart';
import '../../domain/entities/media_format.dart';
import '../../application/use_cases/extract_metadata_use_case.dart';
import '../../application/use_cases/start_download_use_case.dart';
import '../../domain/services/extraction_service.dart';
import '../../application/use_cases/start_download_use_case.dart';

/// Manages the entire downloader screen state.
class DownloaderNotifier extends StateNotifier<DownloaderState> {
  final ExtractMetadataUseCase _extractUseCase;
  final StartDownloadUseCase   _downloadUseCase;

  DownloaderNotifier({
    required ExtractMetadataUseCase extractUseCase,
    required StartDownloadUseCase   downloadUseCase,
  })  : _extractUseCase  = extractUseCase,
        _downloadUseCase = downloadUseCase,
        super(const DownloaderState());

  // ── Extraction ─────────────────────────────────────────────

  Future<void> extractUrl(String url) async {
    if (!LinkParser.isVideoUrl(url)) {
      state = state.copyWith(
        extractionStatus: ExtractionStatus.error,
        extractionError:  'This URL is not supported',
      );
      return;
    }

    state = state.copyWith(
      extractionStatus: ExtractionStatus.loading,
      extractionError:  null,
      extractionResult: null,
    );

    try {
      final result = await _extractUseCase(url);
      state = state.copyWith(
        extractionStatus: ExtractionStatus.success,
        extractionResult: result,
      );
    } on ExtractionException catch (e) {
      state = state.copyWith(
        extractionStatus: ExtractionStatus.error,
        extractionError:  e.message,
      );
    } catch (e) {
      state = state.copyWith(
        extractionStatus: ExtractionStatus.error,
        extractionError:  'Unexpected error: $e',
      );
    }
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
    } on InsufficientStorageException catch (e) {
      debugPrint('[Downloader] $e');
      // Surface to UI via a separate error field or snackbar
    } catch (e) {
      debugPrint('[Downloader] startDownload error: $e');
    }
  }

  void updateTaskProgress(String taskId, double progress, DownloadStatus status) {
    final updated = state.activeTasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(progress: progress, status: status);
    }).toList();

    state = state.copyWith(activeTasks: updated);

    // Move to completed list if done
    if (status == DownloadStatus.completed) {
      final task = updated.firstWhere((t) => t.id == taskId);
      state = state.copyWith(
        activeTasks:    state.activeTasks.where((t) => t.id != taskId).toList(),
        completedTasks: [...state.completedTasks, task],
      );
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
    if (url != null) extractUrl(url);
  }
}
```

**File:** `lib/features/downloader/presentation/providers/downloader_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/use_cases/extract_metadata_use_case.dart';
import '../../application/use_cases/start_download_use_case.dart';
import '../../data/services/ytdlp_extraction_service.dart';
import '../../data/services/youtube_explode_service.dart';
import '../../data/services/storage_service_impl.dart';
import '../../data/repositories/isar_download_repository.dart';
import '../../data/repositories/isar_extraction_cache_repository.dart';
import '../../domain/entities/downloader_state.dart';
import 'downloader_notifier.dart';

/// ⚠️ Replace IsarDownloadRepository(stub) with IsarDownloadRepository(isar)
/// after Phase 9 — Isar integration.

final downloaderProvider =
    StateNotifierProvider<DownloaderNotifier, DownloaderState>((ref) {
  final ytdlp      = YtdlpExtractionService();
  final ytExplode  = YoutubeExplodeService();
  final cache      = IsarExtractionCacheRepository.stub();   // stub until Phase 9
  final storage    = StorageServiceImpl();
  final repo       = IsarDownloadRepository.stub();          // stub until Phase 9

  final extractUseCase = ExtractMetadataUseCase(
    ytdlp:     ytdlp,
    ytExplode: ytExplode,
    cache:     cache,
  );

  final downloadUseCase = StartDownloadUseCase(
    repo:    repo,
    storage: storage,
  );

  return DownloaderNotifier(
    extractUseCase:  extractUseCase,
    downloadUseCase: downloadUseCase,
  );
});
```

### Phase 6 Gate

```bash
flutter analyze lib/features/downloader/
flutter build apk --debug
```

---

## 13. Phase 7 — UI Layer

### 13.1 Quality Selection Sheet

**File:** `lib/features/downloader/presentation/widgets/quality_selection_sheet.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../providers/downloader_provider.dart';

/// Bottom sheet that displays all available download qualities.
/// Appears after a successful metadata extraction.
class QualitySelectionSheet extends ConsumerWidget {
  final ExtractionResult result;

  const QualitySelectionSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(downloaderProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize:     0.95,
      minChildSize:     0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            // ── Handle ────────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Metadata Header ────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (result.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: result.thumbnailUrl!,
                    width:    80, height: 60,
                    fit:      BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (result.duration != null)
                      Text(_formatDuration(result.duration!),
                          style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Video Section ──────────────────────────────
            const Text('Video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: result.videoFormats.map((f) =>
                  _FormatChip(format: f, onTap: () {
                    Navigator.pop(context);
                    notifier.startDownload(f);
                  }),
              ).toList(),
            ),
            const SizedBox(height: 24),

            // ── Audio Section ──────────────────────────────
            const Text('Audio (MP3)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...result.audioFormats.map((f) => ListTile(
              leading: const Icon(Icons.music_note),
              title:   Text(f.note),
              trailing: Text(f.formattedSize,
                  style: const TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                notifier.startDownload(f);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _FormatChip extends StatelessWidget {
  final MediaFormat  format;
  final VoidCallback onTap;

  const _FormatChip({required this.format, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDash = format.requiresMerge;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:        Colors.amber.withOpacity(0.15),
          border:       Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(format.qualityLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(format.formattedSize,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            if (isDash)
              const Text('MERGE', style: TextStyle(
                  color: Colors.orange, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
```

---

### 13.2 Download Progress Card

**File:** `lib/features/downloader/presentation/widgets/download_progress_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/download_task.dart';

class DownloadProgressCard extends StatelessWidget {
  final DownloadTask task;

  const DownloadProgressCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _StatusBadge(status: task.status),
            ]),
            const SizedBox(height: 8),
            if (task.isDash) ...[
              // DASH shows two progress bars
              _ProgressRow(label: 'Video', value: task.videoProgress),
              const SizedBox(height: 4),
              _ProgressRow(label: 'Audio', value: task.audioProgress),
            ] else
              LinearProgressIndicator(
                value:           task.progress,
                backgroundColor: Colors.grey.shade800,
                color:           Colors.amber,
              ),
            const SizedBox(height: 4),
            Text(
              task.isDash
                  ? _mergeStatusText()
                  : '${(task.progress * 100).round()}%',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _mergeStatusText() {
    switch (task.status) {
      case DownloadStatus.downloading: return 'Downloading streams…';
      case DownloadStatus.merging:     return 'Merging…';
      default:                         return task.status.name;
    }
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;

  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 40, child: Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.grey))),
      const SizedBox(width: 8),
      Expanded(
        child: LinearProgressIndicator(
          value:           value,
          backgroundColor: Colors.grey.shade800,
          color:           Colors.amber,
        ),
      ),
      const SizedBox(width: 8),
      Text('${(value * 100).round()}%',
          style: const TextStyle(fontSize: 11)),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final DownloadStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case DownloadStatus.completed:  color = Colors.green;  label = 'Done';   break;
      case DownloadStatus.failed:     color = Colors.red;    label = 'Failed'; break;
      case DownloadStatus.merging:    color = Colors.orange; label = 'Merge';  break;
      case DownloadStatus.cancelled:  color = Colors.grey;   label = 'Cancelled'; break;
      default:                        color = Colors.amber;  label = 'Active'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        border:       Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
```

---

### 13.3 Downloader Screen

**File:** `lib/features/downloader/presentation/screens/downloader_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/downloader_state.dart';
import '../providers/downloader_provider.dart';
import '../widgets/quality_selection_sheet.dart';
import '../widgets/download_progress_card.dart';

class DownloaderScreen extends ConsumerWidget {
  const DownloaderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(downloaderProvider);
    final notifier = ref.read(downloaderProvider.notifier);

    // Show quality sheet when extraction succeeds
    ref.listen(downloaderProvider, (prev, next) {
      if (prev?.extractionStatus != ExtractionStatus.success &&
          next.extractionStatus == ExtractionStatus.success &&
          next.extractionResult != null) {
        showModalBottomSheet(
          context:          context,
          isScrollControlled: true,
          backgroundColor:  Colors.transparent,
          builder:          (_) => QualitySelectionSheet(
            result: next.extractionResult!,
          ),
        );
      }
    });

    // Show clipboard snackbar
    ref.listen(downloaderProvider, (prev, next) {
      if (next.showClipboardSnack && next.clipboardUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video link detected: ${next.clipboardUrl}'),
            action:  SnackBarAction(
              label:    'Download',
              onPressed: notifier.acceptClipboardLink,
            ),
            duration: const Duration(seconds: 6),
          ),
        );
        notifier.dismissClipboardSnack();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloader'),
        actions: [
          IconButton(
            icon:    const Icon(Icons.language),
            tooltip: 'Open Browser',
            onPressed: () => Navigator.pushNamed(context, '/browser'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Link Input ─────────────────────────────────
          _LinkInputSection(
            isLoading: state.isExtracting,
            onSubmit:  notifier.extractUrl,
          ),

          // ── Error ──────────────────────────────────────
          if (state.extractionStatus == ExtractionStatus.error &&
              state.extractionError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.red.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(state.extractionError!,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),

          // ── Active Downloads ───────────────────────────
          if (state.activeTasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child:   Text('Active Downloads',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...state.activeTasks.map((t) => DownloadProgressCard(task: t)),
          ],

          // ── Completed ─────────────────────────────────
          if (state.completedTasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child:   Text('Completed',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount:   state.completedTasks.length,
                itemBuilder: (_, i) => DownloadProgressCard(
                  task: state.completedTasks[i],
                ),
              ),
            ),
          ],

          if (state.activeTasks.isEmpty && state.completedTasks.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Paste a video link to start',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LinkInputSection extends StatefulWidget {
  final bool          isLoading;
  final Function(String) onSubmit;

  const _LinkInputSection({required this.isLoading, required this.onSubmit});

  @override
  State<_LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<_LinkInputSection> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText:    'Paste video link here...',
              prefixIcon:  const Icon(Icons.link),
              border:      OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon:    const Icon(Icons.clear),
                      onPressed: _controller.clear,
                    )
                  : null,
            ),
            onSubmitted: widget.onSubmit,
          ),
        ),
        const SizedBox(width: 8),
        widget.isLoading
            ? const SizedBox(
                width: 48, height: 48,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.amber),
              )
            : IconButton.filled(
                icon:    const Icon(Icons.search),
                onPressed: () => widget.onSubmit(_controller.text.trim()),
                style: IconButton.styleFrom(backgroundColor: Colors.amber),
              ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 14. Phase 8 — Clipboard & Browser

### 14.1 Clipboard Monitor Use Case

**File:** `lib/features/downloader/application/use_cases/clipboard_monitor_use_case.dart`

```dart
import 'dart:async';
import 'package:super_clipboard/super_clipboard.dart';

import '../../core/link_parser.dart';

/// Polls the clipboard and emits detected video URLs.
class ClipboardMonitorUseCase {
  StreamSubscription<String?>? _subscription;
  String? _lastSeen;

  /// Start monitoring. Calls [onLinkDetected] with each new video URL found.
  void start(void Function(String url) onLinkDetected) {
    final timer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) async {
        try {
          final clipboard = SystemClipboard.instance;
          if (clipboard == null) return;

          final reader = await clipboard.read();
          final text   = await reader.readValue(Formats.plainText);

          if (text != null &&
              text != _lastSeen &&
              LinkParser.isVideoUrl(text)) {
            _lastSeen = text;
            onLinkDetected(text);
          }
        } catch (_) {
          // Clipboard access may be denied — fail silently
        }
      },
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
```

---

### 14.2 In-App Browser Screen

**File:** `lib/features/downloader/presentation/screens/in_app_browser_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/link_parser.dart';
import '../providers/downloader_provider.dart';

/// In-app browser with automatic video link detection.
/// When the user navigates to a video page, a floating download button appears.
class InAppBrowserScreen extends ConsumerStatefulWidget {
  const InAppBrowserScreen({super.key});

  @override
  ConsumerState<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends ConsumerState<InAppBrowserScreen> {
  InAppWebViewController? _controller;
  bool   _showDownloadButton = false;
  String _currentUrl         = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUrl.isNotEmpty ? _currentUrl : 'Browser',
          maxLines:  1,
          overflow:  TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _AddressBar(onGo: _navigate),
        ),
      ),
      floatingActionButton: _showDownloadButton
          ? FloatingActionButton.extended(
              onPressed:  _triggerDownload,
              icon:       const Icon(Icons.download),
              label:      const Text('Download Video'),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            )
          : null,
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://www.youtube.com'),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled:       true,
          domStorageEnabled:       true,
          useShouldOverrideUrlLoading: true,
        ),
        onWebViewCreated: (c) => _controller = c,
        onLoadStop: (controller, url) {
          if (url == null) return;
          setState(() {
            _currentUrl         = url.toString();
            _showDownloadButton = LinkParser.isVideoUrl(url.toString());
          });
        },
      ),
    );
  }

  void _navigate(String url) {
    final uri = url.startsWith('http') ? url : 'https://$url';
    _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(uri)));
  }

  void _triggerDownload() {
    if (_currentUrl.isEmpty) return;
    Navigator.pop(context);
    ref.read(downloaderProvider.notifier).extractUrl(_currentUrl);
  }
}

class _AddressBar extends StatefulWidget {
  final Function(String) onGo;
  const _AddressBar({required this.onGo});

  @override
  State<_AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<_AddressBar> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          hintText:    'Search or enter URL',
          prefixIcon:  const Icon(Icons.search, size: 18),
          isDense:     true,
          border:      OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onSubmitted: widget.onGo,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
```

---

## 15. Phase 9 — Isar Persistence

### 15.1 Isar Collections

**File:** `lib/features/downloader/data/models/download_record_isar.dart`

```dart
import 'package:isar/isar.dart';

part 'download_record_isar.g.dart';

@collection
class DownloadRecordIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String taskId;

  late String url;
  late String title;
  String?     thumbnailUrl;
  late String formatId;
  late String extension;
  int?        height;
  int?        fileSizeBytes;
  late int    statusIndex;   // DownloadStatus.index
  late String outputPath;
  late DateTime createdAt;
  String?     errorMessage;
}
```

@collection
class ExtractionCacheIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String urlHash;   // md5(url)

  late String jsonData;  // Full ExtractionResult serialized to JSON
  late DateTime fetchedAt;
}

@collection
class SubtitleSettingsIsar {
  Id id = Isar.autoIncrement;
  
  late bool enabled;
  late String language;
  late double fontSize;
  late int colorValue;
}

@collection
class DownloadResumeIsar {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String taskId;
  
  late List<String> chunkPaths;
  late int totalChunks;
  late DateTime lastUpdatedAt;
}
```

**Run code generation:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Register in main.dart:**

```dart
// Append to existing Isar.open([...]) call:
DownloadRecordIsarSchema,
ExtractionCacheIsarSchema,
SubtitleSettingsIsarSchema,
DownloadResumeIsarSchema,
```

### 15.2 Gate — Full Integration

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/features/downloader/
flutter build apk --debug
flutter test test/features/downloader/
```

---

## 16. Integration with Existing Downloader Feature

> ⚠️ Read all existing files in `features/downloader/` before this phase.

### What Might Already Exist

The existing downloader likely handles:
- Direct URL downloads (no extraction)
- Basic download queue
- File listing

### Integration Points

| Existing Component | How to Extend |
|-------------------|---------------|
| Existing `DownloadRepository` | Add `ExtractionResult` support or create separate Isar collection |
| Existing providers | Add `downloaderProvider` as a separate provider — do NOT replace existing |
| Existing `DownloaderScreen` | Add a "From Social Media" tab or floating button |
| Existing Dio download logic | Keep for direct downloads; use `flutter_downloader` for social media |

### Recommended Integration Pattern

```
Existing tab: "Downloads"     → direct URL downloads (keep as-is)
New tab:      "Social Media"  → DownloaderScreen (new feature)
New screen:   "Browser"       → InAppBrowserScreen
```

Add to your router:

```dart
GoRoute(path: '/downloader/social',    builder: (_, __) => const DownloaderScreen()),
GoRoute(path: '/downloader/browser',   builder: (_, __) => const InAppBrowserScreen()),
```

---

## 17. Unit Test Suite

**File:** `test/features/downloader/link_parser_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/downloader/core/link_parser.dart';

void main() {
  group('LinkParser', () {
    group('isVideoUrl', () {
      test('recognises YouTube URLs', () {
        expect(LinkParser.isVideoUrl('https://www.youtube.com/watch?v=abc'), isTrue);
        expect(LinkParser.isVideoUrl('https://youtu.be/abc123'), isTrue);
      });

      test('recognises Instagram URLs', () {
        expect(LinkParser.isVideoUrl('https://www.instagram.com/p/abc/'), isTrue);
      });

      test('recognises TikTok URLs', () {
        expect(LinkParser.isVideoUrl('https://www.tiktok.com/@user/video/123'), isTrue);
      });

      test('rejects random URLs', () {
        expect(LinkParser.isVideoUrl('https://google.com'), isFalse);
        expect(LinkParser.isVideoUrl('not a url at all'), isFalse);
      });

      test('handles malformed URLs gracefully', () {
        expect(LinkParser.isVideoUrl('http://:malformed'), isFalse);
      });
    });

    group('identify', () {
      test('identifies YouTube', () {
        expect(LinkParser.identify('https://youtube.com/watch?v=x'),
            VideoPlatform.youtube);
      });

      test('identifies TikTok', () {
        expect(LinkParser.identify('https://tiktok.com/@user/video/1'),
            VideoPlatform.tiktok);
      });

      test('returns unknown for unsupported domains', () {
        expect(LinkParser.identify('https://unknownsite.com/video'),
            VideoPlatform.unknown);
      });
    });

    group('clean', () {
      test('removes tracking params from YouTube URLs', () {
        const url = 'https://www.youtube.com/watch?v=abc123&feature=share&si=xyz';
        expect(LinkParser.clean(url),
            'https://www.youtube.com/watch?v=abc123');
      });

      test('leaves non-YouTube URLs unchanged', () {
        const url = 'https://instagram.com/p/abc/?igshid=xyz';
        expect(LinkParser.clean(url), url);
      });
    });
  });

  group('MediaFormat', () {
    test('requiresMerge is true for DASH formats', () {
      const f = MediaFormat(
        formatId: '137+140',
        extension: 'mp4',
        note: '1080p',
        height: 1080,
        videoUrl: 'https://example.com/video',
        audioUrl: 'https://example.com/audio',
      );
      expect(f.requiresMerge, isTrue);
      expect(f.isAudioOnly,  isFalse);
    });

    test('isAudioOnly is true for audio formats', () {
      const f = MediaFormat(
        formatId: '140',
        extension: 'm4a',
        note: 'Audio 128kbps',
        audioBitrate: 128,
        url: 'https://example.com/audio',
      );
      expect(f.isAudioOnly,  isTrue);
      expect(f.requiresMerge, isFalse);
    });

    test('formattedSize handles null gracefully', () {
      const f = MediaFormat(formatId: '1', extension: 'mp4', note: '720p');
      expect(f.formattedSize, 'Unknown size');
    });

    test('formattedSize formats MB correctly', () {
      const f = MediaFormat(
          formatId: '1', extension: 'mp4', note: '720p',
          fileSizeBytes: 250 * 1024 * 1024);
      expect(f.formattedSize, '250 MB');
    });
  });
}

import 'package:vidmaster/features/downloader/domain/entities/media_format.dart';
```

---

## 18. Pre-Release Checklist

```
STATIC ANALYSIS
☐ flutter analyze lib/features/downloader/ → 0 issues
☐ No print() calls — only debugPrint('[Downloader] ...')

BUILD
☐ flutter build apk --debug → success
☐ flutter build apk --release → success
☐ APK size arm64-v8a: < 130MB (with ABI splits)
☐ APK installs on physical Android device

EXTRACTION
☐ Paste YouTube URL → quality sheet appears within 3 seconds
☐ Paste Instagram Reel URL → extraction succeeds
☐ Paste TikTok URL → extraction succeeds
☐ Paste unsupported URL → friendly error shown, no crash
☐ Same URL pasted twice → served from cache (no network call)
☐ yt-dlp failure → youtube_explode fallback fires for YouTube URLs

DOWNLOADS
☐ Select 720p muxed → single download starts, progress shown
☐ Select 1080p DASH → two streams download, merge runs, final file exists
☐ Select MP3 audio → FFmpeg converts, file saved to Music folder
☐ Storage check fires → "insufficient storage" snackbar for tiny devices
☐ Download survives app backgrounding
☐ Completed download appears in video library

CLIPBOARD
☐ Copy YouTube link → snackbar appears within 2 seconds
☐ Tap "Download" in snackbar → quality sheet opens
☐ Dismiss snackbar → no repeated prompt for same URL

BROWSER
☐ Browser opens to youtube.com
☐ Navigate to video page → floating download button appears
☐ Tap download button → browser closes, extraction starts
☐ Navigate to non-video page → no download button

PERFORMANCE
☐ Extraction runs in Isolate — no main thread jank during fetch
☐ FFmpeg merge runs without blocking UI
☐ Simultaneous downloads: up to 3 active at once

EDGE CASES
☐ Private video → clear error message, no crash
☐ Age-restricted video → clear error message
☐ No internet → error shown within timeout duration
☐ Very long video title → filename sanitized, no crash
☐ Video already downloaded → file is not overwritten (unique filename)
```

---

## 19. Known Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| yt-dlp breaks on platform updates | High | Engine update system: auto-download latest yt-dlp binary on launch |
| Chaquopy increases APK by 60-80MB | High | ABI splits configured first — reduces to ~40MB per arch |
| DASH merge failure on low-memory devices | High | Check `availableBytes()` before merge; abort with message if < 500MB |
| YouTube rate limiting / bot detection | Medium | Throttle extraction requests; cache aggressively (24h TTL) |
| FFmpeg crashes on malformed streams | Medium | Wrap all FFmpegKit calls in try/catch; keep temp files on failure |
| WebView cookie/session issues in browser | Medium | Use `flutter_inappwebview` cookie manager; enable DOM storage |
| Clipboard permission denied on Android 13+ | Low | Fail silently; only show prompt when user explicitly pastes |
| Temp files accumulate after failed merges | Medium | Run `CleanupService` on every app launch for files older than 24h |
| `youtube_explode_dart` rate limits | Medium | Implement exponential backoff; add delay between retries |
| Private video from Instagram (auth required) | High | Show clear error; do not attempt workarounds |

---

*VidMaster Engineering · Downloader Blueprint v1.0 — Snaptube/XPlayer Grade · 2026*