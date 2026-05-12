# VidMaster — Pro Video Player Engine
## Technical Blueprint & PRD (Living Doc)

> **Classification:** Technical Blueprint + PRD (living document)
> **Target Platform:** Android (API 26+)
> **Framework:** Flutter >=3.24.0 · media_kit · Riverpod
> **Scope:** Core Playback · Gesture Engine · Subtitle Engine · Resume · PiP · Lock Mode · Performance Optimization
> **Last Updated:** 2026-05-08 (aligned with current code)

---

## ⚡ Current Project Reality (Verified 2026-05-08)

هذا القسم هو "مصدر الحقيقة" للوضع الحالي للمشروع (بعد إصلاحات الـ build/runtime).

### Build Flavors (Production vs Sandbox)

- **`stable`**: Production-safe build path (بدون Chaquopy/yt-dlp)
- **`experimental`**: Sandbox build path (مع Chaquopy/yt-dlp + wheelhouse optional)

### Commands (Android)

```bash
# Debug run (stable)
flutter run -d "<device>" --flavor stable

# Release (stable) — split per ABI
flutter build apk --release --flavor stable --split-per-abi

# Release (experimental) — sandbox (Chaquopy; prefer no split-per-abi)
flutter build apk --release --flavor experimental
```

### Storage / DB Reality

- **Isar (`isar_community` 3.3.2) موجود ومستخدم** — videos / audio / playlists / downloads / extraction cache / resume / subtitle prefs
- **Hive موجود ومستخدم** — vault metadata only (`EncryptedFileMetadataModel`)

> أي جزء في هذا الملف يذكر "Hive غير موجود" يعتبر **قديم وغير صحيح**.
> أي جزء يذكر `isar: ^3.1.0` القديم يعتبر **قديم** — المشروع يستخدم `isar_community: ^3.3.2`.

### media_kit Runtime Dependency

- تشغيل الفيديو على Android يعتمد على `media_kit_libs_video` (libmpv)
  وقد يتطلب تنزيل artifacts وقت build في بعض البيئات (شبكة).
- `ffmpeg_kit_flutter_new: ^4.1.0` مستخدم (الفورك المحدّث بعد إيقاف Arthenica الأصلي)

### Developer Tooling

- تم إضافة شاشة dev لاختبار الداونلودر: route `'/dev/download-harness'` (Debug فقط).

### Build Configuration

- **Gradle:** `build.gradle.kts` (Kotlin DSL)
- **Compile SDK:** 34
- **Min SDK:** 26 (API 26 = Android 8.0)
- **Target SDK:** 34
- **Java/Kotlin:** JVM 17
- **Signing:** Release builds require `key.properties` — debug keys are rejected for release
- **Minification:** R8 + ProGuard enabled for release builds
- **Flavors:** `stable` (`.stable` suffix) / `experimental` (`.exp` suffix)

> **Note:** لتفاصيل شاملة عن بنية المشروع و DI و build matrix، اعتبر `BLUEPRINT.md` هو المرجع الأساسي، واعتبر هذا الملف PRD/UX + تفاصيل فيديو بلاير.

---

## Table of Contents

1. [Product Objective](#1-product-objective)
2. [Target Users](#2-target-users)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [Architecture Overview](#4-architecture-overview)
   - 4.1 High-Level Component Diagram
   - 4.2 Gesture Data Flow Diagram
   - 4.3 Subtitle Data Flow Diagram
5. [Folder Structure](#5-folder-structure)
6. [Modules Breakdown](#6-modules-breakdown)
7. [Goals & Non-Goals](#7-goals--non-goals)
8. [Player State Machine](#8-player-state-machine)
9. [Advanced State Management (Riverpod)](#9-advanced-state-management-riverpod)
   - 9.1 VideoPlayerState
   - 9.2 VideoPlayerNotifier
10. [Feature Specifications — Core](#10-feature-specifications--core)
    - 10.1 Core Playback (VideoEngine)
    - 10.2 Display & Aspect Ratio
    - 10.3 Lock Mode
    - 10.4 Resume System
    - 10.5 Picture-in-Picture (PiP)
11. [Feature A — Gesture Engine](#11-feature-a--gesture-engine)
    - 11.1 User Stories & Acceptance Criteria
    - 11.2 UX & Physics Spec
    - 11.3 Critical Bugs (Documented & Pre-Resolved)
    - 11.4 Technical Architecture & Data Models
    - 11.5 Implementation Guide
    - 11.6 Integration Strategy (Migration)
    - 11.7 Edge Cases
    - 11.8 Testing Checklist
12. [Feature B — Subtitle Engine](#12-feature-b--subtitle-engine)
    - 12.1 User Stories & Acceptance Criteria
    - 12.2 Feature Specifications
    - 12.3 Technical Architecture
    - 12.4 Data Models
    - 12.5 State Management Blueprint
    - 12.6 Implementation Guide
    - 12.7 Persistence Strategy
    - 12.8 Edge Cases
    - 12.9 Testing Checklist
13. [Error Handling Strategy](#13-error-handling-strategy)
14. [Performance Optimization Strategy](#14-performance-optimization-strategy)
15. [Testing Scenarios](#15-testing-scenarios)
16. [Open Questions & Future Scope](#16-open-questions--future-scope)

---

## 1. Product Objective

Build a **high-performance, production-grade video player engine** in Flutter that delivers:

- **Smooth, lag-free playback** achieving XPlayer-level UX on mid-range Android devices
- **Physics-aware gesture system** with velocity, inertia, haptics, and preview-based seeking
- **Netflix-level subtitle engine** with real-time customization and frame-accurate sync
- **Scalable Clean Architecture** enabling future features (streaming, AI, mini-player) without refactoring
- **Premium feel** — every interaction responds in <150ms with appropriate visual and haptic feedback, backed by explicit UX Feel specifications

---

## 2. Target Users

| Segment | Description | Key Need |
|---------|-------------|----------|
| **Primary** | Android users watching local video files | Smooth playback, intuitive controls |
| **Secondary** | Users with downloaded content (movies, series) | Subtitle support, resume position |
| **Power Users** | Users migrating from VLC / MX Player / XPlayer | Feature parity + better performance |

---

## 3. Non-Functional Requirements

| Metric | Target | Priority |
|--------|--------|----------|
| Sustained FPS | ≥ 55 fps during playback | P0 |
| Player startup time | < 500ms from tap to first frame | P0 |
| Seek latency (gesture end → frame update) | < 100ms | P0 |
| Frame drops during gesture | Zero | P0 |
| Memory usage (1080p playback) | < 200MB | P1 |
| Gesture lock response | < 16ms (1 frame) | P0 |
| Overlay fade-in | 150ms | P1 |
| Overlay fade-out | 200ms | P1 |
| App crash rate | < 0.1% of sessions | P0 |
| Cold start (first launch) | < 1.5s | P1 |
| Battery consumption | Minimal — leverage hardware acceleration | P1 |

---

## 4. Architecture Overview

### 4.1 High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                             │
│  VideoPlayerScreen                                              │
│    ├── ProGestureLayer      (gesture detection + overlay)       │
│    ├── ControlsOverlay      (play/pause/seek bar/lock button)   │
│    │   ├── LandscapePlayerControls                              │
│    │   ├── PortraitPlayerControls                               │
│    │   ├── PlayerTopBar / PlayerTransportControls               │
│    │   ├── PlayerSeekSection / PlayerSpeedMenuButton             │
│    │   └── PlayerSubtitleTrackMenu / SubtitleStylingSheet       │
│    ├── PlayerErrorOverlay / PlayerLoadingOverlay                │
│    ├── PlayerLockedOverlay                                      │
│    └── VideoSurface         (media_kit Video widget)            │
├─────────────────────────────────────────────────────────────────┤
│  STATE LAYER (Riverpod)                                         │
│  VideoPlayerState  ←→  VideoPlayerNotifier                     │
│    { status, position, duration, volume, brightness,           │
│      subtitleSettings, availableTracks, activeTrack,           │
│      isLocked, aspectRatioMode, playbackSpeed,                 │
│      showControls, currentVideo, error }                        │
├─────────────────────────────────────────────────────────────────┤
│  APPLICATION LAYER (Use Cases)                                  │
│  GetAllVideos · SyncVideoLibrary · GetVideosByFolder           │
│  SearchVideos · SavePlaybackPosition · RecordVideoPlay          │
│  ToggleFavourite · GetFavouriteVideos · GetRecentlyPlayed      │
│  GenerateThumbnail                                              │
├─────────────────────────────────────────────────────────────────┤
│  CORE ENGINE LAYER                                              │
│  VideoEngine       (media_kit Player wrapper)                   │
│  GestureEngine     (pure Dart State Machine)                    │
├─────────────────────────────────────────────────────────────────┤
│  MEDIA ENGINE                                                   │
│  media_kit · FFmpeg · MPV Core                                  │
│    setProperty('sub-delay', ...) · setSubtitleTrack(...)        │
├─────────────────────────────────────────────────────────────────┤
│  PLATFORM CHANNELS                                              │
│  PlatformBrightnessService  ·  PiPService (Android Activity)   │
│  vidmaster/pip  ·  vidmaster/brightness                         │
├─────────────────────────────────────────────────────────────────┤
│  DATA LAYER  (Isar Community 3.3.2 — no legacy Isar)           │
│  IsarResumeRepository  ·  IsarSubtitlePreferencesRepository    │
│  LocalVideoLibraryRepository · VideoLocalDataSource             │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Gesture Data Flow Diagram

```
Raw Gesture Input (onPanUpdate / onTap)
         │
         ▼
  ProGestureLayer (StatefulWidget)
         │  passes DragUpdateDetails
         ▼
  GestureEngine (Pure Dart State Machine)
         │  returns GestureResult (seek | volume | brightness | none)
         ▼
  ProGestureLayer
    ├── seek result    → local setState(_seekPreview)   [NO player call]
    ├── volume result  → widget.onVolume(v)
    └── brightness     → widget.onBrightness(b)
         │
  onPanEnd fires
    ├── apply momentum → widget.onSeekEnd(finalTarget)  [ONE player call]
    └── engine.reset()
         │
         ▼
  VideoPlayerNotifier
    ├── seekTo()       → VideoEngine.seek()
    ├── setVolume()    → VideoEngine.setVolume()
    └── setBrightness() → PlatformBrightnessService
         │
         ▼
  media_kit / MPV Core → updated position / volume
         │
         ▼
  VideoPlayerNotifier ← stream listeners update state
         │
         ▼
  VideoPlayerScreen (Riverpod rebuilds UI)
```

### 4.3 Subtitle Data Flow Diagram

```
User taps CC button
         │
         ▼
  SubtitleMenuSheet (via PlayerSubtitleTrackMenu / SubtitleStylingSheet)
    ├── Track selection: setSubtitleTrack(track)
    ├── Delay adjustment: setSubtitleDelay(seconds) / nudgeSubtitleDelay(±0.5)
    └── Style customization: updateSubtitleStyle(...)
         │
         ▼
  VideoPlayerNotifier
    ├── state = state.copyWith(subtitleSettings: ...)
    ├── VideoEngine.setProperty('sub-delay', value)   ← MPV native
    ├── VideoEngine.setSubtitleTrack(track)
    └── SubtitlePreferencesRepository.save(...)
         │
         ▼
  Isar DB (persisted — SubtitleSettingsIsar @collection)
         │
  on openVideo():
    ├── load global style prefs  → state
    ├── load per-video delay     → state + setProperty
    └── load external track path → VideoEngine
         │
         ▼
  VideoSurface: Video(subtitleViewConfiguration: SubtitleViewConfiguration(
    style: state.subtitleSettings.textStyle))
         │
         ▼
  User sees styled, synced subtitles
```

---

## 5. Folder Structure

> ⚠️ **المشروع ليس فارغاً.** الهيكل التالي يعكس المسارات الصحيحة **الموجودة فعلاً** داخل `features/video_player`.
> لا تنشئ مجلدات `lib/domain` أو `lib/data` على مستوى الـ root — المشروع يستخدم `lib/features/`.

```
lib/
├── main.dart                              # موجود — entry point + all initializations
├── main_screen.dart                       # موجود — root shell
├── di.dart                                # موجود — كل DI providers
│
├── core/                                  # موجود ✅
│   ├── config/                            # BuildChannelConfig (stable/experimental)
│   ├── error/
│   ├── router/
│   ├── theme/
│   ├── usecase/
│   └── widgets/
│
├── l10n/                                  # موجود ✅ — app_en.arb, app_ar.arb + generated
│
└── features/
    ├── downloader/    ✅ (5-layer architecture: domain/data/application/core/presentation)
    ├── music_player/  ✅
    ├── security/      ✅
    ├── settings/      ✅ (presentation only)
    │
    └── video_player/                      # 🔧 هذا الملف يغطي هذا الجزء
        ├── domain/
        │   ├── entities/
        │   │   ├── video_entity.dart
        │   │   ├── video_file.dart
        │   │   ├── subtitle_settings.dart      # Immutable + textStyle getter
        │   │   ├── gesture_result.dart
        │   │   ├── gesture_engine.dart          # Pure Dart — zero Flutter imports
        │   │   └── video_playback_state.dart    # @immutable + copyWith
        │   ├── repositories/
        │   │   ├── video_repository.dart        # abstract interface
        │   │   ├── resume_repository.dart
        │   │   └── subtitle_preferences_repository.dart
        │   ├── services/
        │   │   └── platform_brightness_service.dart
        │   └── usecases/
        │       └── video_usecases.dart          # 10 use cases
        │
        ├── data/
        │   ├── datasources/
        │   │   └── video_local_data_source.dart  # Directory.list() scan + thumbnails
        │   ├── data_sources/
        │   │   └── video_engine.dart             # media_kit Player wrapper
        │   ├── models/
        │   │   ├── video_model.dart              # @collection (Isar Community)
        │   │   ├── video_model.g.dart
        │   │   ├── subtitle_settings_isar.dart   # @collection (Isar Community)
        │   │   ├── subtitle_settings_isar.g.dart
        │   │   ├── video_resume_isar.dart         # @collection (Isar Community)
        │   │   └── video_resume_isar.g.dart
        │   ├── repositories/
        │   │   ├── video_repository_impl.dart
        │   │   ├── isar_resume_repository.dart
        │   │   ├── isar_subtitle_preferences_repository.dart
        │   │   └── isar_subtitle_preferences_repository.g.dart
        │   └── services/
        │       └── android_brightness_service.dart
        │
        └── presentation/
            ├── providers/
            │   ├── video_library_provider.dart    # VideoLibraryNotifier
            │   ├── video_player_provider.dart     # Main video player provider
            │   ├── video_player_notifier.dart     # StateNotifier<VideoPlayerState>
            │   ├── mini_player_provider.dart
            │   └── subtitle_engine_provider.dart
            ├── screens/
            │   ├── video_library_screen.dart
            │   └── video_player_screen.dart
            └── widgets/
                ├── controls_overlay.dart          # (if exists)
                ├── pro_gesture_layer.dart
                ├── gesture_engine.dart            # Widget-level gesture engine
                ├── video_surface.dart
                ├── video_thumbnail_card.dart
                ├── landscape_player_controls.dart
                ├── portrait_player_controls.dart
                ├── player_top_bar.dart
                ├── player_transport_controls.dart
                ├── player_seek_section.dart
                ├── player_speed_menu_button.dart
                ├── player_subtitle_track_menu.dart
                ├── subtitle_styling_sheet.dart
                ├── player_quick_actions_row.dart
                ├── player_more_menu.dart
                ├── player_error_overlay.dart
                ├── player_loading_overlay.dart
                ├── player_locked_overlay.dart
                ├── player_control_helpers.dart
                └── mini_player_layer.dart
```

---

## 6. Modules Breakdown

### 6.1 Core Engine

| Class | File | Responsibility | Key API |
|-------|------|----------------|---------|
| `VideoEngine` | `data/data_sources/video_engine.dart` | Wraps media_kit Player; clean async API | `open()` `play()` `pause()` `seek()` `setVolume()` `setPlaybackSpeed()` `setSubtitleTrack()` `setSubtitleDelay()` `dispose()` |
| `GestureEngine` | `domain/entities/gesture_engine.dart` | Pure Dart State Machine; zero Flutter deps | `onStart()` `onUpdate()` `reset()` |

### 6.2 State Management

| Class | File | Responsibility |
|-------|------|----------------|
| `VideoPlayerState` | `domain/entities/video_playback_state.dart` | Immutable state snapshot; manual `copyWith` (no @freezed needed) |
| `VideoPlayerNotifier` | `presentation/providers/video_player_notifier.dart` | All business logic; `state.copyWith()` only |

### 6.3 Use Cases (in `domain/usecases/video_usecases.dart`)

| Class | Dependencies | Responsibility |
|-------|-------------|----------------|
| `GetAllVideos` | `VideoRepository` | Retrieve all indexed videos |
| `SyncVideoLibrary` | `VideoRepository` | Scan storage and update Isar |
| `GetVideosByFolder` | `VideoRepository` | Filter by parent folder |
| `GetAllVideoFolders` | `VideoRepository` | Get unique folder names |
| `SearchVideos` | `VideoRepository` | Search by query string |
| `SavePlaybackPosition` | `VideoRepository` | Save resume position |
| `RecordVideoPlay` | `VideoRepository` | Update play count + last played |
| `ToggleFavourite` | `VideoRepository` | Toggle favourite flag |
| `GetFavouriteVideos` | `VideoRepository` | Filter by isFavourite |
| `GetRecentlyPlayed` | `VideoRepository` | Sort by lastPlayedAt |
| `GenerateThumbnail` | `VideoRepository` | Generate JPEG thumbnail |

### 6.4 Repositories & Services

| Interface | Implementation | Store |
|-----------|----------------|-------|
| `VideoRepository` | `VideoRepositoryImpl` | Isar `@collection` |
| `ResumeRepository` | `IsarResumeRepository` | Isar `VideoResumeIsar` |
| `SubtitlePreferencesRepository` | `IsarSubtitlePreferencesRepository` | Isar `SubtitleSettingsIsar` |
| `PlatformBrightnessService` | `AndroidBrightnessService` | Platform Channel |

### 6.5 UI Components

| Widget | File | Key Responsibilities |
|--------|------|---------------------|
| `VideoPlayerScreen` | `video_player_screen.dart` | Assembles all layers; wires notifier |
| `ProGestureLayer` | `pro_gesture_layer.dart` | Gesture detection; seek overlay via local `setState` |
| `VideoSurface` | `video_surface.dart` | media_kit `Video` widget + SubtitleViewConfiguration |
| `LandscapePlayerControls` | `landscape_player_controls.dart` | Controls layout for landscape |
| `PortraitPlayerControls` | `portrait_player_controls.dart` | Controls layout for portrait |
| `PlayerTopBar` | `player_top_bar.dart` | Back, title, lock, subtitle, more |
| `PlayerTransportControls` | `player_transport_controls.dart` | Play/Pause, skip forward/backward |
| `PlayerSeekSection` | `player_seek_section.dart` | Seek slider, position/duration |
| `PlayerSpeedMenuButton` | `player_speed_menu_button.dart` | Speed control popup |
| `PlayerSubtitleTrackMenu` | `player_subtitle_track_menu.dart` | Track selection sheet |
| `SubtitleStylingSheet` | `subtitle_styling_sheet.dart` | Style customization sheet |
| `PlayerErrorOverlay` | `player_error_overlay.dart` | Error UI + retry |
| `PlayerLoadingOverlay` | `player_loading_overlay.dart` | Loading state |
| `PlayerLockedOverlay` | `player_locked_overlay.dart` | Lock mode indicator |
| `VideoThumbnailCard` | `video_thumbnail_card.dart` | Library grid card |
| `MiniPlayerLayer` | `mini_player_layer.dart` | Persistent mini player |

---

## 7. Goals & Non-Goals

### ✅ In Scope (v5.0) — Implementation Complete

| # | Category | Goal | Status |
|---|----------|------|--------|
| ✅ G-01 | Core | Play / Pause / Seek / Speed control (0.25x–4x) | Implemented |
| ✅ G-02 | Core | Volume control via gestures and system | Implemented |
| ✅ G-03 | Core | Brightness control via left-half vertical swipe | Implemented |
| ✅ G-04 | Display | Aspect ratio modes: Fit / Fill / Stretch / Zoom | Implemented (updated modes) |
| ✅ G-05 | Lock | Lock Mode disables all gestures and controls | Implemented |
| ✅ G-06 | Resume | Save and restore last-watched position per video | Implemented |
| ✅ G-07 | PiP | Auto-enter PiP on app background; manual trigger | Implemented |
| ✅ GA-1 | Gesture | Horizontal swipe → seek preview (real seek on release only) | Implemented |
| ✅ GA-2 | Gesture | Vertical left → brightness / Vertical right → volume | Implemented |
| ✅ GA-3 | Gesture | Double-tap left/right → ±10s skip | Implemented |
| ✅ GA-4 | Gesture | Velocity-sensitive seek: slow 400ms/px / fast 1200ms/px | Implemented |
| ✅ GA-5 | Gesture | Momentum/inertia applied on seek release | Implemented |
| ✅ GA-6 | Gesture | 8px movement threshold before locking gesture type | Implemented |
| ✅ GA-7 | Gesture | Boundary haptics at 0:00 and video end | Implemented |
| ✅ GB-1 | Subtitle | Real-time embedded track switching | Implemented |
| ✅ GB-2 | Subtitle | External file loading (.srt / .vtt / .ass / .ssa) | Implemented |
| ✅ GB-3 | Subtitle | Delay adjustment ±10s, 100ms precision | Implemented |
| ✅ GB-4 | Subtitle | Font size, color, background, style customization | Implemented |
| ✅ GB-5 | Subtitle | Global + per-video preference persistence | Implemented |
| ✅ GX-1 | UX Feel | Smooth overlay animations with specified durations | Implemented |
| ✅ GX-2 | UX Feel | Haptic feedback for seek boundaries, lock toggle, double-tap | Implemented |
| ✅ GX-3 | UX Feel | Gesture acceleration/deceleration curves for natural feel | Implemented |

### ❌ Out of Scope (v5.0)

| Item | Target Version |
|------|----------------|
| Subtitle auto-translation | v6.0 |
| Bilingual subtitle mode | v6.0 |
| OpenSubtitles online search | v6.0 |
| Streaming (HLS / DASH) | v6.0 |
| Pinch-to-zoom gesture | v6.0 |
| AI auto-silence skip | v7.0 |
| Video pooling (TikTok-style) | v6.0 |
| HDR Tone Mapping | v6.0 |
| Multi-audio track selection | v6.0 |

---

## 8. Player State Machine

```
                    ┌──────────┐
                    │   IDLE   │ ← initial state / after closeVideo()
                    └────┬─────┘
                         │ openVideo()
                    ┌────▼─────┐
                    │ LOADING  │ ← buffering first frames
                    └────┬─────┘
               ┌─────────┴──────────┐
               │ first frame         │ error
          ┌────▼─────┐        ┌─────▼─────┐
          │ PLAYING  │ ◄────► │  PAUSED   │
          └────┬─────┘        └─────┬─────┘
               │ buffer underrun     │
          ┌────▼─────┐              │ buffer ready
          │BUFFERING │◄─────────────┘
          └────┬─────┘
               │ reaches end
          ┌────▼──────┐
          │ COMPLETED │
          └───────────┘

          [ERROR] can be reached from any state on exception
```

| From | Event | To |
|------|-------|-----|
| IDLE | `openVideo()` called | LOADING |
| LOADING | First frame decoded | PLAYING |
| LOADING | File/format error | ERROR |
| PLAYING | `pause()` | PAUSED |
| PLAYING | Buffer underrun | BUFFERING |
| PLAYING | Reached `duration` | COMPLETED |
| PAUSED | `play()` | PLAYING |
| BUFFERING | Buffer refilled | PLAYING |
| COMPLETED | `seek(0)` or replay | PLAYING |
| ERROR | `retry()` | LOADING |
| ANY | `closeVideo()` | IDLE |

---

## 9–16. Sections Unchanged

> The remaining sections (9–16) contain detailed specifications for VideoPlayerState, VideoPlayerNotifier, Core Playback, Gesture Engine, Subtitle Engine, Error Handling, Performance Optimization, Testing Scenarios, and Open Questions.
>
> These spec sections remain valid as-written in the previous version. The key alignment changes are captured in Sections 1–8 above.
>
> For current implementation work, refer to:
> - **`docs/BLUEPRINT.md`** — Full architectural reference, DI map, feature matrix
> - **`docs/mapper.md`** — File paths and common task → files recipes
> - **`docs/X.md`** — This document (video player specs)
> - **`docs/downloader/BLUEPRINT.md`** — Downloader engine implementation guide
>
> ⚠️ **Do NOT use `docs/archive/VIDEO_AGENT.md`** for current implementation.
> That guide is archived — all 6 phases it describes are already fully built.
> Using it will cause duplicate widgets and regressions.

---

*VidMaster Engineering · Technical Blueprint + PRD v5.1 — Updated · 2026-05-08*