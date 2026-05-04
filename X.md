# VidMaster — Pro Video Player Engine
## Technical Blueprint & Product Requirements Document · v5.1 *(Agent-Verified)*

> **Classification:** Technical Blueprint + PRD
> **Status:** Ready for Implementation — Verified Against Actual Project
> **Target Platform:** Android (API 26+)
> **Framework:** Flutter 3.x · media_kit · Riverpod
> **Scope:** Core Playback · Gesture Engine · Subtitle Engine · Resume · PiP · Lock Mode · Performance Optimization
> **Authors:** Engineering Team · Last Updated: 2026
> **Database:** Isar (not Hive — confirmed by project scan)

---

## ⚡ Confirmed Project State (Agent-Verified)

هذا القسم يوثق الوضع الفعلي للمشروع كما تم التحقق منه بفحص الكود.

### المكتبات المثبتة (جاهزة — لا تعديل على pubspec.yaml)

| المكتبة | الإصدار | الحالة |
|--------|--------|--------|
| `media_kit` | ^1.1.11 | ✅ موجودة |
| `media_kit_video` | ^1.2.5 | ✅ موجودة |
| `flutter_riverpod` | ^2.5.1 | ✅ موجودة |
| `riverpod_annotation` | ^2.3.5 | ✅ موجودة |
| `isar` | ^3.1.0+1 | ✅ موجودة ← **يُستخدم بدل Hive** |
| `isar_flutter_libs` | ^3.1.0+1 | ✅ موجودة |
| `crypto` | ^3.0.3 | ✅ موجودة (للـ md5) |
| `file_picker` | ^8.0.3 | ✅ موجودة |
| `build_runner` | ^2.4.9 | ✅ موجودة (dev) |
| `flutter_secure_storage` | ^9.0.0 | ✅ موجودة |

### حالة الاختبارات
- ✅ تم إضافة اختبارات وحدة لطبقة الـ video player domain وتعمل بنجاح

### هيكل المشروع الحالي

```
lib/
├── core/              ✅ موجود (error, router, theme, usecase, widgets)
├── features/
│   ├── downloader/    ✅ كامل — لا تمسّه
│   ├── music_player/  ✅ كامل — لا تمسّه
│   ├── security/      ✅ جزئي — لا تمسّه
│   ├── settings/      ✅ جزئي — لا تمسّه
│   └── video_player/  🔧 موجود جزئياً — هنا نعمل
└── main_screen.dart · main.dart
```

### قرار الـ Database

> **Hive غير موجود في المشروع. Isar مثبت ومُهيأ بالفعل.**
> كل ما كان مكتوباً في هذا الـ PRD بـ "Hive" تم استبداله بـ "Isar".
> لا تضف Hive للمشروع.

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
│    ├── SubtitleMenuSheet    (tabbed bottom sheet)               │
│    └── _VideoSurface        (media_kit Video widget)            │
├─────────────────────────────────────────────────────────────────┤
│  STATE LAYER (Riverpod)                                         │
│  VideoPlayerState  ←→  VideoPlayerNotifier                     │
│    { status, position, duration, volume, brightness,           │
│      subtitleSettings, availableTracks, activeTrack,           │
│      isLocked, aspectRatioMode, playbackSpeed,                 │
│      showControls, currentVideo, error }                        │
├─────────────────────────────────────────────────────────────────┤
│  APPLICATION LAYER (Use Cases)                                  │
│  OpenVideoUseCase  SeekUseCase  SubtitleUseCase                │
│  ResumeUseCase     PiPUseCase   LockUseCase                    │
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
├─────────────────────────────────────────────────────────────────┤
│  DATA LAYER  (Isar — no Hive)                                  │
│  IsarResumeRepository  ·  IsarSubtitlePreferencesRepository    │
│  LocalVideoLibraryRepository                                    │
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
  SubtitleMenuSheet (3-tab BottomSheet)
    ├── Tab 1: setSubtitleTrack(track)
    ├── Tab 2: setSubtitleDelay(seconds) / nudgeSubtitleDelay(±0.5)
    └── Tab 3: updateSubtitleStyle(...)
         │
         ▼
  VideoPlayerNotifier
    ├── state = state.copyWith(subtitleSettings: ...)
    ├── VideoEngine.setProperty('sub-delay', value)   ← MPV native
    ├── VideoEngine.setSubtitleTrack(track)
    └── SubtitlePreferencesRepository.save(...)
         │
         ▼
  Isar DB (persisted — @collection, no typeId conflicts)
         │
  on openVideo():
    ├── load global style prefs  → state
    ├── load per-video delay     → state + setProperty
    └── load external track path → VideoEngine
         │
         ▼
  _VideoSurface: Video(subtitleViewConfiguration: SubtitleViewConfiguration(
    style: state.subtitleSettings.textStyle))
         │
         ▼
  User sees styled, synced subtitles
```

---

## 5. Folder Structure

> ⚠️ **المشروع ليس فارغاً.** الهيكل التالي يعكس المسارات الصحيحة داخل `features/video_player`.
> لا تنشئ مجلدات `lib/domain` أو `lib/data` على مستوى الـ root — المشروع يستخدم `lib/features/`.

```
lib/
├── main.dart                              # موجود — لا تعدّله إلا لإضافة Isar collections
├── main_screen.dart                       # موجود — لا تمسّه
│
├── core/                                  # موجود ✅ — لا تمسّه
│   ├── error/
│   ├── router/
│   ├── theme/
│   ├── usecase/
│   └── widgets/
│
└── features/
    ├── downloader/    ✅ لا تمسّه
    ├── music_player/  ✅ لا تمسّه
    ├── security/      ✅ لا تمسّه
    ├── settings/      ✅ لا تمسّه
    │
    └── video_player/                      # 🔧 هنا نعمل فقط
        ├── domain/
        │   ├── entities/
        │   │   ├── video_file.dart
        │   │   ├── subtitle_settings.dart      # Immutable + textStyle getter
        │   │   ├── gesture_result.dart
        │   │   ├── gesture_engine.dart          # Pure Dart — zero Flutter imports
        │   │   └── video_playback_state.dart    # @immutable + copyWith
        │   ├── repositories/
        │   │   ├── resume_repository.dart       # abstract interface
        │   │   └── subtitle_preferences_repository.dart
        │   └── services/
        │       └── platform_brightness_service.dart
        │
        ├── data/
        │   ├── models/
        │   │   ├── subtitle_settings_isar.dart  # @collection (Isar)
        │   │   └── video_resume_isar.dart       # @collection (Isar)
        │   ├── repositories/
        │   │   ├── isar_resume_repository.dart
        │   │   └── isar_subtitle_preferences_repository.dart
        │   ├── services/
        │   │   └── android_brightness_service.dart
        │   └── data_sources/
        │       └── video_engine.dart             # media_kit Player wrapper
        │
        └── presentation/
            ├── providers/
            │   ├── video_player_provider.dart    # Riverpod StateNotifierProvider
            │   └── video_player_notifier.dart    # StateNotifier<VideoPlayerState>
            ├── screens/
            │   └── video_player_screen.dart
            └── widgets/
                ├── controls_overlay.dart
                ├── pro_gesture_layer.dart
                ├── seek_preview_overlay.dart
                ├── subtitle_menu_sheet.dart
                └── subtitle_live_preview.dart
```

---

## 6. Modules Breakdown

### 6.1 Core Engine

| Class | File | Responsibility | Key API |
|-------|------|----------------|---------|
| `VideoEngine` | `features/video_player/data/data_sources/video_engine.dart` | Wraps media_kit Player; clean async API | `open()` `play()` `pause()` `seek()` `setVolume()` `setPlaybackSpeed()` `setSubtitleTrack()` `setSubtitleDelay()` `dispose()` |
| `GestureEngine` | `features/video_player/domain/entities/gesture_engine.dart` | Pure Dart State Machine; zero Flutter deps | `onStart()` `onUpdate()` `reset()` |

### 6.2 State Management

| Class | File | Responsibility |
|-------|------|----------------|
| `VideoPlayerState` | `features/video_player/domain/entities/video_playback_state.dart` | Immutable state snapshot; manual `copyWith` (no @freezed needed) |
| `VideoPlayerNotifier` | `features/video_player/presentation/providers/video_player_notifier.dart` | All business logic; `state.copyWith()` only |

### 6.3 Use Cases

| Class | Dependencies | Responsibility |
|-------|-------------|----------------|
| `OpenVideoUseCase` | `VideoEngine` · `ResumeRepository` · `SubtitlePreferencesRepository` | Open video + restore prefs |
| `SeekUseCase` | `VideoEngine` | Single-call seek with momentum |
| `SubtitleUseCase` | `VideoEngine` · `SubtitlePreferencesRepository` | Track selection, delay, style |
| `ResumeUseCase` | `ResumeRepository` | Save/restore playback position |
| `PiPUseCase` | `PiPService` | Enter/exit PiP |
| `LockUseCase` | — | Toggle gesture lock state |

### 6.4 Repositories & Services

| Interface | Implementation | Store |
|-----------|----------------|-------|
| `ResumeRepository` | `IsarResumeRepository` | Isar `@collection` |
| `SubtitlePreferencesRepository` | `IsarSubtitlePreferencesRepository` | Isar `@collection` |
| `VideoLibraryRepository` | `LocalVideoLibraryRepository` | Filesystem |
| `PlatformBrightnessService` | `AndroidBrightnessService` | Platform Channel |
| `PiPService` | `AndroidPiPService` | Platform Channel |

### 6.5 UI Components

| Widget | File | Key Responsibilities |
|--------|------|---------------------|
| `VideoPlayerScreen` | `video_player_screen.dart` | Assembles all layers; wires notifier |
| `ProGestureLayer` | `widgets/pro_gesture_layer.dart` | Gesture detection; seek overlay via local `setState` |
| `ControlsOverlay` | `widgets/controls_overlay.dart` | Play/Pause · Scrubber · Lock · CC · PiP buttons; `AnimatedOpacity` fade |
| `SeekPreviewOverlay` | `widgets/seek_preview_overlay.dart` | Absolute time · total duration · direction icon · relative delta |
| `SubtitleMenuSheet` | `widgets/subtitle_menu_sheet.dart` | 3-tab BottomSheet (Tracks / Sync / Style) |
| `SubtitleLivePreview` | `widgets/subtitle_live_preview.dart` | Real-time style preview; reacts to `SubtitleSettings` changes |
| `_VideoSurface` | `video_player_screen.dart` (internal) | `Video` widget + `SubtitleViewConfiguration` |

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
|------|-------|----|
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

## 9. Advanced State Management (Riverpod)

### 9.1 VideoPlayerState

`VideoPlayerState` هي `@immutable` class — single source of truth لكل الـ UI.
**لا نستخدم `@freezed`** — نكتب `copyWith` يدوياً لتجنب dependency إضافية.
كل mutations تمر عبر `state = state.copyWith(...)` فقط.

```dart
// lib/features/video_player/domain/entities/video_playback_state.dart
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'subtitle_settings.dart';
import 'video_file.dart';

enum PlayerStatus    { idle, loading, playing, paused, buffering, completed, error }
enum PlayerError     { unsupportedFormat, corruptedFile, networkError, unknown }
enum VideoAspectRatio {
  fit('auto'), fill('stretch'), crop('crop'), ar16x9('16:9'), ar4x3('4:3');
  final String mpvValue;
  const VideoAspectRatio(this.mpvValue);
}

@immutable
class VideoPlayerState {
  final PlayerStatus         status;
  final Duration             position;
  final Duration             duration;
  final double               volume;
  final double               brightness;
  final bool                 isLocked;
  final bool                 showControls;
  final VideoAspectRatio     aspectRatioMode;
  final double               playbackSpeed;
  final SubtitleSettings     subtitleSettings;
  final List<SubtitleTrack>  availableSubtitleTracks;
  final SubtitleTrack        activeSubtitleTrack;
  final bool                 isSubtitleSheetLoading;
  final VideoFile?           currentVideo;
  final PlayerError?         error;

  const VideoPlayerState({
    this.status                  = PlayerStatus.idle,
    this.position                = Duration.zero,
    this.duration                = Duration.zero,
    this.volume                  = 1.0,
    this.brightness              = 0.5,
    this.isLocked                = false,
    this.showControls            = false,
    this.aspectRatioMode         = VideoAspectRatio.fit,
    this.playbackSpeed           = 1.0,
    this.subtitleSettings        = SubtitleSettings.defaults,
    this.availableSubtitleTracks = const [],
    this.activeSubtitleTrack     = const SubtitleTrack.no(),
    this.isSubtitleSheetLoading  = false,
    this.currentVideo,
    this.error,
  });

  // ── Computed ───────────────────────────────────────────────
  bool get isPlaying    => status == PlayerStatus.playing;
  bool get isBuffering  => status == PlayerStatus.buffering;
  bool get hasError     => error != null;
  bool get isLiveStream => duration == Duration.zero;
  bool get canSeek      => !isLiveStream && duration > Duration.zero;

  // ── copyWith ───────────────────────────────────────────────
  VideoPlayerState copyWith({
    PlayerStatus?         status,
    Duration?             position,
    Duration?             duration,
    double?               volume,
    double?               brightness,
    bool?                 isLocked,
    bool?                 showControls,
    VideoAspectRatio?     aspectRatioMode,
    double?               playbackSpeed,
    SubtitleSettings?     subtitleSettings,
    List<SubtitleTrack>?  availableSubtitleTracks,
    SubtitleTrack?        activeSubtitleTrack,
    bool?                 isSubtitleSheetLoading,
    VideoFile?            currentVideo,
    PlayerError?          error,
  }) =>
      VideoPlayerState(
        status:                  status                  ?? this.status,
        position:                position                ?? this.position,
        duration:                duration                ?? this.duration,
        volume:                  volume                  ?? this.volume,
        brightness:              brightness              ?? this.brightness,
        isLocked:                isLocked                ?? this.isLocked,
        showControls:            showControls            ?? this.showControls,
        aspectRatioMode:         aspectRatioMode         ?? this.aspectRatioMode,
        playbackSpeed:           playbackSpeed           ?? this.playbackSpeed,
        subtitleSettings:        subtitleSettings        ?? this.subtitleSettings,
        availableSubtitleTracks: availableSubtitleTracks ?? this.availableSubtitleTracks,
        activeSubtitleTrack:     activeSubtitleTrack     ?? this.activeSubtitleTrack,
        isSubtitleSheetLoading:  isSubtitleSheetLoading  ?? this.isSubtitleSheetLoading,
        currentVideo:            currentVideo            ?? this.currentVideo,
        error:                   error                   ?? this.error,
      );
}
```

### 9.2 VideoPlayerNotifier

```dart
// lib/features/video_player/presentation/providers/video_player_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../domain/entities/subtitle_settings.dart';
import '../../domain/entities/video_file.dart';
import '../../domain/entities/video_playback_state.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../domain/repositories/subtitle_preferences_repository.dart';
import '../../domain/services/platform_brightness_service.dart';
import '../../data/data_sources/video_engine.dart';

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final VideoEngine                   _engine;
  final ResumeRepository              _resumeRepo;
  final SubtitlePreferencesRepository _subtitlePrefsRepo;
  final PlatformBrightnessService     _brightnessService;

  VideoPlayerNotifier({
    required VideoEngine                   engine,
    required ResumeRepository              resumeRepo,
    required SubtitlePreferencesRepository subtitlePrefsRepo,
    required PlatformBrightnessService     brightnessService,
  })  : _engine            = engine,
        _resumeRepo        = resumeRepo,
        _subtitlePrefsRepo = subtitlePrefsRepo,
        _brightnessService = brightnessService,
        super(const VideoPlayerState()) {
    _initStreamListeners();
  }

  // ── Stream Listeners ───────────────────────────────────────
  void _initStreamListeners() {
    _engine.player.stream.duration.listen((d) {
      if (!mounted) return;
      state = state.copyWith(duration: d ?? Duration.zero);
    });
    _engine.player.stream.position.listen((p) {
      if (!mounted) return;
      state = state.copyWith(position: p);
    });
    _engine.player.stream.playing.listen((playing) {
      if (!mounted) return;
      state = state.copyWith(
        status: playing ? PlayerStatus.playing : PlayerStatus.paused);
    });
    _engine.player.stream.completed.listen((done) {
      if (!mounted || !done) return;
      state = state.copyWith(status: PlayerStatus.completed);
    });
    _engine.player.stream.buffering.listen((buffering) {
      if (!mounted || !buffering) return;
      state = state.copyWith(status: PlayerStatus.buffering);
    });
    _engine.player.stream.error.listen((_) {
      if (!mounted) return;
      state = state.copyWith(status: PlayerStatus.error, error: PlayerError.unknown);
    });
    _engine.player.stream.tracks.listen((tracks) {
      if (!mounted) return;
      state = state.copyWith(availableSubtitleTracks: tracks.subtitle);
    });
    _engine.player.stream.track.listen((track) {
      if (!mounted) return;
      state = state.copyWith(activeSubtitleTrack: track.subtitle);
    });
    _brightnessService.getScreenBrightness().then((b) {
      if (!mounted) return;
      state = state.copyWith(brightness: b);
    });
  }

  // ── Video Lifecycle ────────────────────────────────────────
  Future<void> openVideo(VideoFile video) async {
    state = state.copyWith(status: PlayerStatus.loading, currentVideo: video, error: null);
    try {
      await _engine.open(Media(video.path));

      // Restore subtitle global style
      final subtitleSettings = await _subtitlePrefsRepo.loadGlobalSettings();
      state = state.copyWith(subtitleSettings: subtitleSettings);
      await _engine.setSubtitleDelay(subtitleSettings.delaySeconds);

      // Restore per-video delay
      final savedDelay = await _subtitlePrefsRepo.loadDelayForVideo(video.path);
      if (savedDelay != 0.0) await setSubtitleDelay(savedDelay);

      // Restore external subtitle track
      final externalPath = await _subtitlePrefsRepo.loadExternalTrackPath(video.path);
      if (externalPath != null) await loadExternalSubtitleFile(externalPath);

      // Restore playback position
      final savedPosition = await _resumeRepo.loadPosition(video.path);
      if (savedPosition != null && savedPosition > const Duration(seconds: 10)) {
        await _engine.seek(savedPosition);
      }

      await _engine.play();
    } catch (e) {
      state = state.copyWith(status: PlayerStatus.error, error: PlayerError.unsupportedFormat);
    }
  }

  // ── Playback Controls ──────────────────────────────────────
  Future<void> play()    async => _engine.play();
  Future<void> pause()   async => _engine.pause();
  Future<void> retry()   async { if (state.currentVideo != null) await openVideo(state.currentVideo!); }

  Future<void> seekTo(Duration target) async {
    if (!state.canSeek) return;
    await _engine.seek(target);
    if (state.currentVideo != null)
      await _resumeRepo.savePosition(state.currentVideo!.path, target);
  }

  Future<void> seekRelative(Duration delta) async {
    if (!state.canSeek) return;
    final target = (state.position + delta).clamp(Duration.zero, state.duration);
    await seekTo(target);
  }

  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: v);
    await _engine.setVolume(v);
  }

  Future<void> setBrightness(double brightness) async {
    final b = brightness.clamp(0.0, 1.0);
    state = state.copyWith(brightness: b);
    await _brightnessService.setScreenBrightness(b);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    await _engine.setPlaybackSpeed(speed);
  }

  Future<void> setAspectRatio(VideoAspectRatio ratio) async {
    state = state.copyWith(aspectRatioMode: ratio);
    await _engine.setProperty('video-aspect-ratio', ratio.mpvValue);
  }

  // ── UI Controls ────────────────────────────────────────────
  void toggleControls() => state = state.copyWith(showControls: !state.showControls);

  void toggleLockMode() {
    state = state.copyWith(isLocked: !state.isLocked);
    HapticFeedback.mediumImpact();
  }

  // ── Subtitle — Track ──────────────────────────────────────
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await _engine.setSubtitleTrack(track);
    if (track.language != null)
      await _subtitlePrefsRepo.saveLastUsedLanguage(track.language);
  }

  Future<void> loadExternalSubtitleFile(String filePath) async {
    state = state.copyWith(isSubtitleSheetLoading: true);
    try {
      await _engine.setSubtitleTrack(SubtitleTrack.uri(filePath));
      if (state.currentVideo != null)
        await _subtitlePrefsRepo.saveExternalTrackPath(state.currentVideo!.path, filePath);
    } catch (e) {
      debugPrint('[SubtitleEngine] Failed to load: $e');
    } finally {
      state = state.copyWith(isSubtitleSheetLoading: false);
    }
  }

  // ── Subtitle — Delay ──────────────────────────────────────
  Future<void> setSubtitleDelay(double seconds) async {
    final clamped = seconds.clamp(-10.0, 10.0);
    state = state.copyWith(
      subtitleSettings: state.subtitleSettings.copyWith(delaySeconds: clamped));
    await _engine.setProperty('sub-delay', clamped.toStringAsFixed(2));
    if (state.currentVideo != null)
      await _subtitlePrefsRepo.saveDelayForVideo(state.currentVideo!.path, clamped);
  }

  void nudgeSubtitleDelay(double amount) =>
      setSubtitleDelay(state.subtitleSettings.delaySeconds + amount);

  void resetSubtitleDelay() => setSubtitleDelay(0.0);

  // ── Subtitle — Style ──────────────────────────────────────
  void updateSubtitleStyle({
    SubtitleFontSize?  fontSize,
    Color?             textColor,
    Color?             backgroundColor,
    double?            backgroundOpacity,
    SubtitleFontStyle? fontStyle,
  }) {
    final updated = state.subtitleSettings.copyWith(
      fontSize: fontSize, textColor: textColor,
      backgroundColor: backgroundColor, backgroundOpacity: backgroundOpacity,
      fontStyle: fontStyle,
    );
    state = state.copyWith(subtitleSettings: updated);
    _subtitlePrefsRepo.saveGlobalSettings(updated); // debounce in production
  }

  void resetSubtitleStyle() {
    state = state.copyWith(subtitleSettings: SubtitleSettings.defaults);
    _subtitlePrefsRepo.saveGlobalSettings(SubtitleSettings.defaults);
  }

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
```

---

## 10. Feature Specifications — Core

### 10.1 Core Playback (VideoEngine)

```dart
// lib/data/data_sources/video_engine.dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoEngine {
  final Player _player = Player();
  late final VideoController controller = VideoController(_player);

  Player get player => _player;

  Future<void> open(Media media)           async => _player.open(media);
  Future<void> play()                      async => _player.play();
  Future<void> pause()                     async => _player.pause();
  Future<void> seek(Duration position)     async => _player.seek(position);
  Future<void> setVolume(double v)         async => _player.setVolume(v * 100);
  Future<void> setPlaybackSpeed(double s)  async => _player.setRate(s);
  Future<void> setSubtitleTrack(SubtitleTrack t) async => _player.setSubtitleTrack(t);
  Future<void> setProperty(String key, String value) async =>
      _player.setProperty(key, value);
  Future<void> setSubtitleDelay(double d)  async =>
      _player.setProperty('sub-delay', d.toStringAsFixed(2));

  void dispose() => _player.dispose();
}
```

**Playback Speed Options:** 0.25× · 0.5× · 0.75× · 1.0× *(default)* · 1.25× · 1.5× · 2.0× · 3.0× · 4.0×

### 10.2 Display & Aspect Ratio

| Mode | `mpvValue` | Behavior |
|------|-----------|---------|
| `fit` | `'auto'` | Letterbox/pillarbox — no cropping (default) |
| `fill` | `'stretch'` | Stretch to fill screen |
| `crop` | `'crop'` | Center-crop — clips edges |
| `ar16x9` | `'16:9'` | Force 16:9 widescreen |
| `ar4x3` | `'4:3'` | Force 4:3 classic |

### 10.3 Lock Mode

When Lock Mode is active:
- All swipe gestures (seek, volume, brightness) are silently ignored
- `ControlsOverlay` does not appear on single tap
- Only the **unlock gesture** (long-press center ≥ 1.5s) is recognized
- `mediumImpact` haptic fires when lock is toggled on or off

### 10.4 Resume System

- Position is auto-saved every **5 seconds** during playback and on every `seekTo()` call
- Key: `md5(videoPath)` stored in Hive
- On `openVideo()`, if `savedPosition > 10s`, show resume dialog:
  ```
  ┌───────────────────────────────────┐
  │  Resume from 23:41?               │
  │  [Resume]          [Start over]   │
  └───────────────────────────────────┘
  ```
- Dialog auto-dismisses after **8s** and selects "Resume"
- Stored position is cleared when the video reaches `Completed` state

### 10.5 Picture-in-Picture (PiP)

| Detail | Spec |
|--------|------|
| Auto-entry trigger | App sent to background (`onPause`) while video is playing |
| Manual trigger | PiP button in `ControlsOverlay` |
| Android requirement | API 26+ · `android:supportsPictureInPicture="true"` in Manifest |
| Controls in PiP | Play / Pause only (Android system limitation) |
| On PiP exit | Full player restored; position synced |
| Fallback (API < 26) | PiP button is hidden; no crash |

---

## 11. Feature A — Gesture Engine

### 11.1 User Stories & Acceptance Criteria

#### US-G01 · Seek via Horizontal Swipe

> **As a** user watching a video,
> **I want to** swipe left/right to seek,
> **So that** I can navigate without touching the scrubber.

- [ ] AC-G01.1: Horizontal swipe shows seek preview overlay with time + total duration
- [ ] AC-G01.2: Overlay shows directional icon (⏩ / ⏪) matching seek direction
- [ ] AC-G01.3: Overlay shows relative delta: `[ +0:12 ]` or `[ −0:05 ]`
- [ ] AC-G01.4: Real `player.seek()` fires **only** on `onPanEnd` — never during drag
- [ ] AC-G01.5: Slow drag (velocity < 10 px/frame) → 400ms/px
- [ ] AC-G01.6: Fast drag (velocity ≥ 10 px/frame) → 1200ms/px
- [ ] AC-G01.7: Release with vx > 500px/s applies momentum: `extra = vx × 0.15ms`
- [ ] AC-G01.8: Result clamped to [0, `videoDuration`]

#### US-G02 · Volume & Brightness via Vertical Swipe

> **As a** user, **I want to** control volume and brightness without leaving fullscreen.

- [ ] AC-G02.1: Right-half vertical swipe → volume (0.0 → 1.0)
- [ ] AC-G02.2: Left-half vertical swipe → brightness (0.0 → 1.0)
- [ ] AC-G02.3: Swipe up = increase, swipe down = decrease
- [ ] AC-G02.4: Sensitivity: 1% per pixel
- [ ] AC-G02.5: Changes apply live during drag
- [ ] AC-G02.6: Value clamped to [0.0, 1.0]

#### US-G03 · Gesture Type Lock

> **As a** user, **I want** the gesture type to stay fixed once determined, preventing accidental seek while adjusting volume.

- [ ] AC-G03.1: Gesture type is undetermined until movement exceeds **8px** on any axis
- [ ] AC-G03.2: First axis to exceed 8px locks the type (horizontal = seek wins if both fire simultaneously)
- [ ] AC-G03.3: Lock cannot be changed until `onPanEnd` triggers `reset()`
- [ ] AC-G03.4: `lightImpact` haptic fires when seek is locked
- [ ] AC-G03.5: `heavyImpact` haptic fires when seek hits 0:00 or end boundary

#### US-G04 · Double-Tap Skip

> **As a** user, **I want to** double-tap left/right to skip ±10 seconds.

- [ ] AC-G04.1: Double-tap left → −10s
- [ ] AC-G04.2: Double-tap right → +10s
- [ ] AC-G04.3: `mediumImpact` haptic fires on every double-tap
- [ ] AC-G04.4: Does not conflict with single-tap (toggle controls)

---

### 11.2 UX & Physics Spec

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Gesture lock threshold | **8 px** | Prevents false triggers from hand tremor |
| Seek speed — slow drag | **400 ms/px** | Precise scrubbing |
| Seek speed — fast drag | **1200 ms/px** | Rapid large-jump navigation |
| Fast drag threshold | **10 px/frame** | Distinguishes deliberate fast swipe |
| Vertical sensitivity | **1% per pixel** | Matches system volume/brightness feel |
| Momentum multiplier | **vx × 0.15** | Applied when release vx > 500 px/s |
| Overlay fade-in | **150 ms** · `Curves.easeOutCubic` | Snappy appearance |
| Overlay fade-out | **200 ms** · `Curves.easeIn` | Smooth disappearance |
| Haptic — seek lock | `lightImpact` | Confirms gesture recognized |
| Haptic — boundary hit | `heavyImpact` | Signals 0:00 or end reached |
| Haptic — double-tap | `mediumImpact` | Confirms skip action |
| Haptic — lock toggle | `mediumImpact` | Confirms lock on/off |

---

### 11.3 Critical Bugs (Documented & Pre-Resolved)

> These bugs are **pre-resolved** in the spec below. Do NOT re-introduce them.

#### 🐛 Bug 1 — Video Stuttering (Seek on Every Pixel)

**Root Cause:** Calling `player.seek()` inside `onPanUpdate` sends 60+ seek commands/second to FFmpeg → catastrophic stuttering.

**Resolution:**
```
onPanUpdate → setState(_seekPreview)    ← local only, no player call
onPanEnd    → widget.onSeekEnd(target)  ← single player.seek() call
```

#### 🐛 Bug 2 — Exponential Seek (Accumulation Bug)

**Root Cause:** Computing `deltaX = localPosition.dx - _startX` and accumulating it causes exponential growth.

**Resolution:** Use `details.delta.dx` — movement since the **last frame only**.

```dart
// ❌ WRONG — grows exponentially with each frame
final deltaX = details.localPosition.dx - _startX;

// ✅ CORRECT — linear, per-frame delta
final deltaMs = details.delta.dx * seekSpeed;
_preview += Duration(milliseconds: deltaMs.toInt());
```

#### 🐛 Bug 3 — Gesture Type Switching (Missing Lock)

**Root Cause:** Without `_isLocked`, a vertical swipe drifting 1px horizontally flips Volume → Seek mid-gesture.

**Resolution:** `_isLocked = true` on first axis exceeding threshold. `_type` frozen until `reset()`.

---

### 11.4 Technical Architecture & Data Models

**Design Rule:** `GestureEngine` must have **zero Flutter imports** — testable without a widget tree.

#### GestureEngine (Pure Dart)

```dart
// lib/domain/entities/gesture_engine.dart
// ⚠️ NO Flutter imports allowed in this file

import 'package:flutter/services.dart'; // Only for HapticFeedback

enum GestureType { none, seek, volume, brightness }

class GestureEngine {
  GestureType _type     = GestureType.none;
  bool        _isLocked = false;
  Duration    _preview  = Duration.zero;
  double      _vol      = 0.0;
  double      _bright   = 0.0;

  // ── Configurable Parameters ────────────────────────────────
  final double threshold;       // default: 8.0 px
  final double fastThreshold;   // default: 10.0 px/frame
  final double seekSlowMs;      // default: 400.0 ms/px
  final double seekFastMs;      // default: 1200.0 ms/px
  final double vertSensitivity; // default: 0.01 (1% per pixel)

  GestureEngine({
    this.threshold      = 8.0,
    this.fastThreshold  = 10.0,
    this.seekSlowMs     = 400.0,
    this.seekFastMs     = 1200.0,
    this.vertSensitivity= 0.01,
  });

  void onStart({
    required double   dx,
    required double   screenWidth,
    required Duration currentPosition,
    required double   volume,
    required double   brightness,
  }) {
    _preview  = currentPosition;
    _vol      = volume;
    _bright   = brightness;
    // Tentative vertical type based on screen half
    _type     = dx < screenWidth / 2 ? GestureType.brightness : GestureType.volume;
    _isLocked = false;
  }

  GestureResult onUpdate(DragUpdateDetails d, Duration totalDuration) {
    // Phase 1: lock determination — horizontal beats vertical if simultaneous
    if (!_isLocked) {
      if (d.delta.dx.abs() > threshold) {
        _type = GestureType.seek;
        _isLocked = true;
        HapticFeedback.lightImpact();
      } else if (d.delta.dy.abs() > threshold) {
        _isLocked = true; // _type already set by onStart (volume or brightness)
      }
    }

    if (!_isLocked) return const GestureResult.none();

    // Phase 2: execute on locked type
    switch (_type) {
      case GestureType.seek:
        final speed = d.delta.dx.abs() > fastThreshold ? seekFastMs : seekSlowMs;
        _preview += Duration(milliseconds: (d.delta.dx * speed).toInt());
        if (_preview <= Duration.zero) {
          _preview = Duration.zero;
          HapticFeedback.heavyImpact();
        } else if (_preview >= totalDuration) {
          _preview = totalDuration;
          HapticFeedback.heavyImpact();
        }
        return GestureResult.seek(_preview);

      case GestureType.volume:
        _vol = (_vol - d.delta.dy * vertSensitivity).clamp(0.0, 1.0);
        return GestureResult.volume(_vol);

      case GestureType.brightness:
        _bright = (_bright - d.delta.dy * vertSensitivity).clamp(0.0, 1.0);
        return GestureResult.brightness(_bright);

      default:
        return const GestureResult.none();
    }
  }

  void reset() {
    _type     = GestureType.none;
    _isLocked = false;
  }
}
```

#### GestureResult (Sealed Output)

```dart
// lib/domain/entities/gesture_result.dart

class GestureResult {
  final GestureType type;
  final Duration?   seek;
  final double?     value;

  const GestureResult._(this.type, {this.seek, this.value});
  const GestureResult.none()            : this._(GestureType.none);
  factory GestureResult.seek(Duration d)   => GestureResult._(GestureType.seek,       seek: d);
  factory GestureResult.volume(double v)   => GestureResult._(GestureType.volume,      value: v);
  factory GestureResult.brightness(double b) => GestureResult._(GestureType.brightness, value: b);
}
```

---

### 11.5 Implementation Guide

#### Step G1 — Create Engine Files
Create `gesture_engine.dart` and `gesture_result.dart` per Section 11.4.

**Verify:** `flutter analyze` → 0 errors. `dart:ui` or `package:flutter/widgets.dart` must NOT be imported in `gesture_engine.dart`.

#### Step G2 — Create ProGestureLayer

```dart
// lib/presentation/video_player/widgets/pro_gesture_layer.dart
class ProGestureLayer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration position;
  final double volume;
  final double brightness;
  final VoidCallback         onTap;
  final Function(Duration)   onSeekEnd;      // real seek — called ONCE on release
  final Function(double)     onVolume;        // called live during drag
  final Function(double)     onBrightness;    // called live during drag
  final VoidCallback         onDoubleTapLeft;
  final VoidCallback         onDoubleTapRight;
  // ...
}

class _ProGestureLayerState extends State<ProGestureLayer> {
  late final GestureEngine _engine = GestureEngine(); // configurable defaults

  // ── Local state only — Riverpod is NOT called here ──────
  bool     _isSeeking   = false;
  Duration _seekPreview = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onDoubleTapDown: (d) {
          final isLeft = d.localPosition.dx < MediaQuery.of(context).size.width / 2;
          isLeft ? widget.onDoubleTapLeft() : widget.onDoubleTapRight();
          HapticFeedback.mediumImpact();
        },
        onPanStart: (d) => _engine.onStart(
          dx:              d.localPosition.dx,
          screenWidth:     MediaQuery.of(context).size.width,
          currentPosition: widget.position,
          volume:          widget.volume,
          brightness:      widget.brightness,
        ),
        onPanUpdate: (d) {
          final result = _engine.onUpdate(d, widget.duration);
          switch (result.type) {
            case GestureType.seek:
              setState(() { _isSeeking = true; _seekPreview = result.seek!; });
              break;
            case GestureType.volume:
              widget.onVolume(result.value!);
              break;
            case GestureType.brightness:
              widget.onBrightness(result.value!);
              break;
            default: break;
          }
        },
        onPanEnd: (details) {
          if (_isSeeking) {
            // ── Momentum / Inertia ─────────────────────────
            Duration target = _seekPreview;
            final vx = details.velocity.pixelsPerSecond.dx;
            if (vx.abs() > 500) {
              target = Duration(
                milliseconds: (target.inMilliseconds + (vx * 0.15).toInt())
                    .clamp(0, widget.duration.inMilliseconds),
              );
            }
            widget.onSeekEnd(target);       // ← single real seek
            setState(() => _isSeeking = false);
          }
          _engine.reset();
        },
        child: widget.child,
      ),

      // ── Seek Preview Overlay (local state, no Riverpod) ──
      if (_isSeeking)
        Center(
          child: AnimatedOpacity(
            opacity: _isSeeking ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  _seekPreview > widget.position
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white, size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_fmt(_seekPreview)} / ${_fmt(widget.duration)}',
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '[ ${_seekPreview > widget.position ? '+' : '−'}'
                  '${_fmt((_seekPreview - widget.position).abs())} ]',
                  style: const TextStyle(color: Colors.amber, fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
```

#### Step G3 — Wire in VideoPlayerScreen

```dart
ProGestureLayer(
  duration:         state.duration,
  position:         state.position,
  volume:           state.volume,
  brightness:       state.brightness,
  onTap:            notifier.toggleControls,
  onSeekEnd:        notifier.seekTo,
  onVolume:         notifier.setVolume,
  onBrightness:     notifier.setBrightness,
  onDoubleTapLeft:  () => notifier.seekRelative(const Duration(seconds: -10)),
  onDoubleTapRight: () => notifier.seekRelative(const Duration(seconds: 10)),
  child: _VideoSurface(
    controller:       notifier.engine.controller,
    subtitleSettings: state.subtitleSettings,
    mode:             state.aspectRatioMode,
  ),
)
```

---

### 11.6 Integration Strategy (Migration)

| Step | Action |
|------|--------|
| 1 | Remove existing `GestureDetector` or `_GestureOverlay` wrapping the video surface |
| 2 | Insert `ProGestureLayer` between `_VideoSurface` and `ControlsOverlay` |
| 3 | Verify `notifier.seekTo()` calls `_engine.seek()` exactly once (no accumulation) |
| 4 | Confirm zero seek-related logic remains inside any `onPanUpdate` handler |
| 5 | Run `flutter analyze` → 0 issues |

---

### 11.7 Edge Cases

| Scenario | Expected Behavior |
|----------|------------------|
| Drag starts at screen center | Treated as right half → volume |
| Both axes exceed 8px simultaneously | Horizontal wins (seek takes priority) |
| Momentum target exceeds `duration` | Clamped to `duration` |
| Double-tap then immediate pan | Double-tap completes; pan starts fresh from `onPanStart` |
| `onPanEnd` fires without `onPanStart` | `_isSeeking = false`; `engine.reset()` — no-op |
| Volume / brightness hits 0.0 or 1.0 | Clamped silently; no haptic (avoids spam) |
| Live stream (`duration == Duration.zero`) | `canSeek = false`; horizontal seek disabled |
| Device has no vibrator | `HapticFeedback` swallowed by Flutter; no crash |
| Lock Mode active | All pan and tap events blocked before reaching `ProGestureLayer` |
| Low disk space on position save | Catch `FileSystemException`; Snackbar: *"Low disk space"* |
| Very short video (< 5s) | Boundary haptics still fire; double-tap skip clamped |

---

### 11.8 Testing Checklist

**Unit Tests (GestureEngine — no widget tree):**
- [ ] `delta.dx = 9` → `_type = seek`, `_isLocked = true`, `lightImpact` fired
- [ ] `delta.dy = 9`, right half → `_type = volume`, `_isLocked = true`
- [ ] Seek accumulates linearly via delta, not absolute position
- [ ] `delta.dx.abs() > 10` → uses `seekFastMs = 1200`
- [ ] `delta.dx.abs() ≤ 10` → uses `seekSlowMs = 400`
- [ ] Seek clamped to [0, totalDuration] at both boundaries
- [ ] `reset()` sets `_isLocked = false`, `_type = none`
- [ ] Volume/brightness clamped to [0.0, 1.0]
- [ ] Configurable constructor: custom `threshold = 12.0` is respected

**Widget Tests (ProGestureLayer):**
- [ ] Seek overlay appears on horizontal pan; disappears on `onPanEnd`
- [ ] Overlay shows correct directional icon (⏩ / ⏪)
- [ ] Overlay shows relative delta string (`[ +0:12 ]`)
- [ ] `onSeekEnd` called exactly once per pan gesture
- [ ] `onVolume` called live during vertical pan on right half
- [ ] `onDoubleTapLeft` fires on left-half double-tap
- [ ] Momentum: vx = 1000 px/s adds 150ms to final target
- [ ] Overlay fade-in animation uses 150ms duration

---

## 12. Feature B — Subtitle Engine

### 12.1 User Stories & Acceptance Criteria

#### US-S01 · Track Selection

- [ ] AC-S01.1: All embedded tracks listed with language name (fallback: `"Track N"`)
- [ ] AC-S01.2: Active track highlighted — checkmark + amber
- [ ] AC-S01.3: "Off" always at the top of the list
- [ ] AC-S01.4: Track change takes effect within 1 frame
- [ ] AC-S01.5: Track list updates automatically when video changes

#### US-S02 · External File Loading

- [ ] AC-S02.1: File picker filters to `.srt`, `.vtt`, `.ass`, `.ssa`
- [ ] AC-S02.2: External track appears as `"External: filename.srt"`
- [ ] AC-S02.3: Previously loaded external track auto-restored on reopen
- [ ] AC-S02.4: Loading a second file replaces the first (no stacking)
- [ ] AC-S02.5: Error toast on unreadable file or unsupported encoding

#### US-S03 · Sync / Delay Adjustment

- [ ] AC-S03.1: Range: −10.0s to +10.0s
- [ ] AC-S03.2: Precision: 100ms steps (200 slider divisions)
- [ ] AC-S03.3: Display: `+1.5s` / `−1.5s` / `0.0s`
- [ ] AC-S03.4: Applied natively via MPV `setProperty('sub-delay', value)`
- [ ] AC-S03.5: "Reset" returns to `0.0` instantly
- [ ] AC-S03.6: Delay persists per-video across app restarts
- [ ] AC-S03.7: Quick nudge buttons: `◀ −0.5s` and `+0.5s ▶`

#### US-S04 · Visual Style

- [ ] AC-S04.1: Font size: 16 / 20 / 24 *(default)* / 32 / 40 px
- [ ] AC-S04.2: Text color: White / Yellow / Green / Cyan / Orange / Red + custom picker
- [ ] AC-S04.3: Background: Black / Dark Gray / Transparent
- [ ] AC-S04.4: Background opacity: 0%–80% slider
- [ ] AC-S04.5: Live preview renders in Style tab
- [ ] AC-S04.6: Font style: Normal / Bold / Bold+Shadow
- [ ] AC-S04.7: All changes apply instantly; no video stutter

#### US-S05 · Preferences Persistence

- [ ] AC-S05.1: Global style defaults persisted in Hive
- [ ] AC-S05.2: Per-video overrides keyed by `md5(videoPath)`
- [ ] AC-S05.3: "Reset to defaults" clears all overrides

---

### 12.2 Feature Specifications

#### Subtitle Source Priority (on `openVideo`)

```
1. Per-video stored track  (Hive restore)
   ↓ not found
2. Match device locale language
   ↓ no match
3. First available embedded track
   ↓ no embedded tracks
4. SubtitleTrack.no() — subtitles off
```

#### BottomSheet Tab Layout

```
┌──────────────────────────────────────────────────────────┐
│  ● Tracks          ⟳ Sync          Aa Style              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Tab 1 — Tracks          Tab 2 — Sync                   │
│  ─────────────────        ─────────────────────          │
│  [📂 Storage][🌐 Online]  Subtitle Timing                │
│  ──────────────────       −1.5 s                         │
│  ✗  Off                   ────●───────────────           │
│  ✓  English (emb.) ✔      −10s              +10s        │
│     Arabic (emb.)         [◀−0.5s][Reset][+0.5s▶]       │
│     External: Film.srt    Negative=Earlier                │
│                           Positive=Later                  │
│                                                          │
│  Tab 3 — Style                                           │
│  ─────────────────────────────────────────────────────   │
│  Font Size:  [S]  [M]  [L ✔]  [XL]  [XXL]              │
│  Text Color: ⬤White  ⬤Yellow✔  ⬤Green  ⬤Cyan  ⬤+       │
│  Background Opacity:  ████░░░░  45%                      │
│  Style: [Normal]  [Bold]  [Bold+Shadow ✔]                │
│  Preview:  [  Hello, World!  ]                           │
│                  [ Reset to Defaults ]                   │
└──────────────────────────────────────────────────────────┘
```

---

### 12.3 Technical Architecture

**New Files to Create:**

| File | Purpose |
|------|---------|
| `domain/entities/subtitle_settings.dart` | Immutable entity; computed `textStyle` + `effectiveBackground` |
| `domain/repositories/subtitle_preferences_repository.dart` | Abstract persistence interface |
| `data/models/subtitle_settings_hive_model.dart` | `@HiveType(typeId: 10)` |
| `data/repositories/hive_subtitle_preferences_repository.dart` | Hive implementation |
| `presentation/video_player/widgets/subtitle_menu_sheet.dart` | 3-tab BottomSheet |
| `presentation/video_player/widgets/subtitle_live_preview.dart` | Real-time style preview |

**Files to Modify:**

| File | Change |
|------|--------|
| `application/notifiers/video_player_notifier.dart` | Subtitle methods (already in Section 9.2) |
| `presentation/video_player/video_player_screen.dart` | Pass `subtitleSettings` to `_VideoSurface`; wire CC button |
| `di/injection_container.dart` | Register `SubtitlePreferencesRepository` |

---

### 12.4 Data Models

#### SubtitleSettings (Domain Entity — Single Definition)

```dart
// lib/domain/entities/subtitle_settings.dart
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────
enum SubtitleFontSize {
  small(16.0), medium(20.0), large(24.0), xLarge(32.0), xxLarge(40.0);
  final double value;
  const SubtitleFontSize(this.value);
}

enum SubtitleFontStyle { normal, bold, boldShadow }

// ── Entity ───────────────────────────────────────────────────
class SubtitleSettings {
  final SubtitleFontSize  fontSize;
  final Color             textColor;
  final Color             backgroundColor;
  final double            backgroundOpacity; // 0.0 → 1.0
  final SubtitleFontStyle fontStyle;
  final double            delaySeconds;      // negative=earlier, positive=later

  const SubtitleSettings({
    this.fontSize          = SubtitleFontSize.large,
    this.textColor         = Colors.white,
    this.backgroundColor   = Colors.black,
    this.backgroundOpacity = 0.54,
    this.fontStyle         = SubtitleFontStyle.boldShadow,
    this.delaySeconds      = 0.0,
  });

  // ── Computed Getters ──────────────────────────────────────
  Color get effectiveBackground => backgroundColor.withOpacity(backgroundOpacity);

  TextStyle get textStyle => TextStyle(
    fontSize:        fontSize.value,
    color:           textColor,
    backgroundColor: effectiveBackground,
    fontWeight: fontStyle != SubtitleFontStyle.normal
        ? FontWeight.bold : FontWeight.normal,
    shadows: fontStyle == SubtitleFontStyle.boldShadow
        ? const [Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(1, 2))]
        : null,
  );

  // ── copyWith ──────────────────────────────────────────────
  SubtitleSettings copyWith({
    SubtitleFontSize?  fontSize,
    Color?             textColor,
    Color?             backgroundColor,
    double?            backgroundOpacity,
    SubtitleFontStyle? fontStyle,
    double?            delaySeconds,
  }) => SubtitleSettings(
    fontSize:          fontSize          ?? this.fontSize,
    textColor:         textColor         ?? this.textColor,
    backgroundColor:   backgroundColor   ?? this.backgroundColor,
    backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    fontStyle:         fontStyle         ?? this.fontStyle,
    delaySeconds:      delaySeconds      ?? this.delaySeconds,
  );

  static const defaults = SubtitleSettings();
}
```

#### SubtitlePreferencesRepository (Interface)

```dart
// lib/domain/repositories/subtitle_preferences_repository.dart
import '../entities/subtitle_settings.dart';

abstract class SubtitlePreferencesRepository {
  Future<SubtitleSettings> loadGlobalSettings();
  Future<void>             saveGlobalSettings(SubtitleSettings s);
  Future<double>           loadDelayForVideo(String videoPath);
  Future<void>             saveDelayForVideo(String videoPath, double delay);
  Future<String?>          loadLastUsedLanguage();
  Future<void>             saveLastUsedLanguage(String? lang);
  Future<String?>          loadExternalTrackPath(String videoPath);
  Future<void>             saveExternalTrackPath(String videoPath, String? path);
}
```

#### Hive Model

```dart
// lib/data/models/subtitle_settings_hive_model.dart
import 'package:hive/hive.dart';
part 'subtitle_settings_hive_model.g.dart';

@HiveType(typeId: 10)
class SubtitleSettingsHiveModel extends HiveObject {
  @HiveField(0) int    fontSizeIndex;         // SubtitleFontSize.index
  @HiveField(1) int    textColorValue;        // Color.value
  @HiveField(2) int    backgroundColorValue;
  @HiveField(3) double backgroundOpacity;
  @HiveField(4) int    fontStyleIndex;        // SubtitleFontStyle.index
  // Note: delaySeconds is NOT stored globally — it's per-video only

  SubtitleSettingsHiveModel({
    required this.fontSizeIndex,
    required this.textColorValue,
    required this.backgroundColorValue,
    required this.backgroundOpacity,
    required this.fontStyleIndex,
  });
}
// Run: flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 12.5 State Management Blueprint

All subtitle state lives inside `VideoPlayerState` (Section 9.1) and is managed by `VideoPlayerNotifier` (Section 9.2). No additional state layer is required.

**`_VideoSurface` wiring:**

```dart
Video(
  controller: controller,
  fit: boxFit,
  fill: Colors.black,
  subtitleViewConfiguration: SubtitleViewConfiguration(
    style:   subtitleSettings.textStyle,         // ← computed getter
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
  ),
)
```

**CC Button wiring:**

```dart
IconButton(
  icon: const Icon(Icons.closed_caption_outlined, color: Colors.white),
  tooltip: 'Subtitles',
  onPressed: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SubtitleMenuSheet(),
  ),
)
```

---

### 12.6 Implementation Guide

| # | Step | File |
|---|------|------|
| S1 | Create `SubtitleSettings` entity + enums | `domain/entities/subtitle_settings.dart` |
| S2 | Create `SubtitlePreferencesRepository` interface | `domain/repositories/` |
| S3 | Create Hive model → run `build_runner` | `data/models/subtitle_settings_hive_model.dart` |
| S4 | Create `HiveSubtitlePreferencesRepository` | `data/repositories/` |
| S5 | Subtitle fields already in `VideoPlayerState` (Section 9.1) | — verify only |
| S6 | Subtitle methods already in `VideoPlayerNotifier` (Section 9.2) | — verify only |
| S7 | Pass `state.subtitleSettings` to `_VideoSurface` | `video_player_screen.dart` |
| S8 | Create `SubtitleMenuSheet` (3 tabs) | `presentation/widgets/` |
| S9 | Wire CC `IconButton` | `video_player_screen.dart` |
| S10 | Register `SubtitlePreferencesRepository` in DI | `di/injection_container.dart` |

---

### 12.7 Persistence Strategy

| Key Pattern | Store | Type | Purpose |
|-------------|-------|------|---------|
| `subtitle_global_settings` | Hive `settings` box | `SubtitleSettingsHiveModel` | Global style |
| `subtitle_delay_{md5(path)}` | Hive `video_prefs` box | `double` | Per-video delay |
| `subtitle_external_{md5(path)}` | Hive `video_prefs` box | `String?` | Per-video external file |
| `subtitle_last_language` | SharedPreferences | `String?` | Auto-restore language |

> Use `md5(videoPath)` as the key suffix — safely handles long paths and special characters.

**Load sequence on `openVideo(video)`** — see Section 9.2 `openVideo()` implementation.

---

### 12.8 Edge Cases

| Scenario | Expected Behavior |
|----------|------------------|
| Video has no subtitle tracks | Track tab shows "Off" only; CC button still accessible |
| External `.srt` is UTF-16 | Error snackbar: *"Subtitle encoding not supported"* |
| External file path no longer exists | Skip restore silently; clear stored path |
| `setProperty('sub-delay')` throws (MPV not ready) | Catch + log; no crash; retry on next call |
| User loads second external file | Replaces first; never stacks |
| Track list arrives while sheet is open | Sheet rebuilds reactively via Riverpod |
| Video changes while sheet is open | Sheet auto-closes via state change listener |
| Delay slider dragged rapidly | Throttle `setProperty` to max 10 calls/sec |
| Background opacity = 0% | Fully transparent — valid state, not an error |
| `copyWith` with all-null args | Returns identical object; no unnecessary rebuild |

---

### 12.9 Testing Checklist

**Unit Tests:**
- [ ] `SubtitleSettings.copyWith()` — correct partial updates
- [ ] `SubtitleSettings.textStyle` — correct `TextStyle` per `fontStyle` variant
- [ ] `SubtitleSettings.effectiveBackground` — opacity applied correctly
- [ ] `setSubtitleDelay()` clamps to [−10.0, 10.0]
- [ ] `nudgeSubtitleDelay()` at boundaries doesn't overflow
- [ ] Repository: delay round-trips via `saveDelayForVideo` / `loadDelayForVideo`
- [ ] `resetSubtitleStyle()` restores `SubtitleSettings.defaults`

**Widget Tests:**
- [ ] `SubtitleMenuSheet` renders all 3 tabs
- [ ] Active track shows checkmark in amber
- [ ] Delay tab displays `+1.5s` / `−0.5s` correctly
- [ ] Color chips call `updateSubtitleStyle(textColor: ...)` on tap
- [ ] `SubtitleLivePreview` updates live during slider drag

**Integration Tests:**
- [ ] Open video → subtitle tracks appear in list within 500ms
- [ ] Select track → change reflected within 1 frame
- [ ] Set delay −2.0s → MPV `sub-delay = "-2.00"`
- [ ] Load external `.srt` → appears as active track
- [ ] Restart app → style and delay restored from Hive

---

## 13. Error Handling Strategy

| Scenario | Handling | User Feedback |
|----------|----------|---------------|
| Unsupported video format | Set `status = error`; catch `PlatformException` | Error screen + "Try Another File" button |
| Corrupted video file | Catch media_kit decode error | Snackbar: *"File may be corrupted"* + Retry |
| Subtitle file parse failure | Catch + log; skip loading | Snackbar: *"Could not load subtitle file"* |
| Subtitle unsupported encoding | Catch `IOException` | Snackbar: *"Subtitle encoding not supported"* |
| Player native crash | Catch `PlatformException`; reinitialize `VideoEngine` | Brief loading indicator; transparent recovery |
| PiP on API < 26 | Check API level before invoking | PiP button hidden; no crash |
| File not found at resume restore | Clear stored position | Open from start silently |
| `setProperty` throws (MPV not ready) | Catch + queue retry | No user feedback |
| Brightness permission denied | Graceful degradation | Brightness swipe falls back to system overlay |
| Low disk space on save | Catch `FileSystemException` | Snackbar: *"Low disk space, cannot save preferences"* |
| Network error (future streaming) | Catch `SocketException` | Error screen with retry option |

---

## 14. Performance Optimization Strategy

| Strategy | Description | Implementation |
|----------|-------------|----------------|
| **Debounce Seek** | Preview updates continuously; `player.seek()` fires only on `onPanEnd` | Enforced by `ProGestureLayer` contract |
| **Riverpod `select()`** | Widgets subscribe only to the state fields they use | `ref.watch(provider.select((s) => s.position))` |
| **`RepaintBoundary`** | Wrap `SeekPreviewOverlay` and `ControlsOverlay` | Prevents video surface repaint on control changes |
| **`const` Widgets** | Static UI elements declared `const` | Eliminates rebuild of fixed UI during position ticks |
| **Hardware Acceleration** | MPV uses MediaCodec on Android by default | Verify via `media_kit` platform config |
| **Lazy Sheet Loading** | `SubtitleMenuSheet` built only on `showModalBottomSheet` | Never in persistent widget tree |
| **Avoid Rebuilding `Video`** | `VideoController` is created once; never re-instantiated | Managed in `VideoEngine`; passed down via `notifier` |
| **Position Stream Throttle** | UI scrubber can throttle to 4 updates/sec | Use `stream.throttleTime(250ms)` if needed |
| **Player Pooling** | Pre-warm player instances for playlist switching | v6.0 — `PlayerPool` class |

### Animation Polish (YouTube Feel)

| Interaction | Spec |
|-------------|------|
| Controls fade-in | `AnimatedOpacity` 150ms · `Curves.easeOutCubic` |
| Controls fade-out | `AnimatedOpacity` 200ms · `Curves.easeIn` |
| Seek overlay appear | Scale + fade in 150ms |
| Seek overlay dismiss | Scale down + fade out 200ms |
| Double-tap skip icon | Directional icon radiates outward · 250ms · `Curves.decelerate` |
| Lock/unlock confirmation | Small icon flashes center · 300ms fade · auto-hides |
| Inertial seek overlay | Preview time continues updating post-release until `player.seek()` resolves |

---

## 15. Testing Scenarios

### Performance
- [ ] Fast seek dragging (5s continuous swipe) → FPS stays ≥ 55
- [ ] Long video (3+ hours) → scrubber precision remains accurate
- [ ] Low-end device (2GB RAM) → no OOM crash
- [ ] Rapid video switching (10 videos in 30s) → startup delay stays < 500ms per video

### Gestures
- [ ] Vertical swipe drifting horizontal → stays locked as volume; no accidental seek
- [ ] Double-tap then immediate pan → handled independently; no state conflict
- [ ] Swipe to 0:00 boundary → `heavyImpact` fires; position never goes negative
- [ ] Gesture lock verified: once type is locked, axis drift doesn't change it

### Lifecycle
- [ ] App backgrounded → PiP auto-enters
- [ ] Return from PiP → position synced; no playback gap
- [ ] Device rotation during playback → position preserved; no restart

### Subtitles
- [ ] Video with 5 embedded tracks → all listed; switching works instantly
- [ ] Load `.ass` file → styled text renders correctly
- [ ] Rapid delay slider drag → no MPV flooding; no crash
- [ ] All styling options (size, color, background, opacity, style) apply instantly
- [ ] Delay adjustment persists across app restarts for same video

### Edge Cases
- [ ] Invalid video file → error UI shown; app doesn't freeze
- [ ] Very short video (< 5s) → boundary haptics work; no negative duration
- [ ] Open same video twice → resume position restored once (no duplication)
- [ ] Low disk space → appropriate snackbar displayed; no crash

---

## 16. Open Questions & Future Scope

| # | Question | Owner | Decision By |
|---|----------|-------|-------------|
| OQ-1 | Disable horizontal seek for live streams? | UX | Sprint review |
| OQ-2 | Make double-tap skip distance (10s) user-configurable? | PM | v6.0 |
| OQ-3 | Reset subtitle delay when switching tracks? | UX | Sprint review |
| OQ-4 | Cap per-video subtitle prefs at 500 entries? | Eng | Launch |
| OQ-5 | Show CC button when no subtitle tracks exist? | UX | Sprint review |
| OQ-6 | Resume dialog 8s auto-dismiss — correct duration? | UX | Sprint review |
| OQ-7 | Gesture sensitivity — expose user-configurable slider in Settings? | PM | v6.0 |

### Future Scope (v6.0+)

| Feature | Description | Version |
|---------|-------------|---------|
| Subtitle auto-translation | On-device ML or DeepL API | v6.0 |
| Bilingual subtitle mode | Two tracks simultaneously | v6.0 |
| OpenSubtitles integration | Hash-based automatic subtitle matching | v6.0 |
| Subtitle inline editor | Timing correction directly for `.srt` files | v6.0 |
| Pinch-to-zoom | Free-scale video in fullscreen | v6.0 |
| HLS / DASH streaming | Network video support | v6.0 |
| Video pooling | Pre-warm players for instant switching | v6.0 |
| AI silence skip | Auto-detect and skip silent scenes | v7.0 |
| HDR Tone Mapping | Accurate HDR color representation | v6.0 |
| Multi-audio track selection | Switch embedded audio tracks | v6.0 |
| Gesture sensitivity settings | User-configurable seek/scroll speed | v6.0 |

---

*VidMaster Engineering · Technical Blueprint + PRD v5.0 — Final · 2026*