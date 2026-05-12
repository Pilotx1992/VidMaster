# VidMaster – Comprehensive Video & Music Player
## Product Requirements Document (PRD)
### Version 1.2 | May 2026 (Revised — Aligned with Live Code)

---

| Field | Value |
|---|---|
| **Product Name** | VidMaster – All-in-One Video & Music Player |
| **Version** | 1.2 (MVP — Revised) |
| **Platform** | Android 8.0+ (API 26+) |
| **Framework** | Flutter >=3.24.0 / Dart >=3.4.0 |
| **Architecture** | Clean Architecture + Riverpod 2.6 + Isar Community 3.3.2 |
| **Document Status** | Revised v1.2 — aligned with live codebase |
| **Last Updated** | 2026-05-08 |
| **Author** | Nagi – Flutter Developer |
| **Document Language** | English |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Goals & Success Metrics](#3-goals--success-metrics)
4. [Competitive Analysis](#4-competitive-analysis)
5. [Target Users & Personas](#5-target-users--personas)
6. [Functional Requirements](#6-functional-requirements)
7. [Non-Functional Requirements](#7-non-functional-requirements)
8. [Technical Architecture](#8-technical-architecture)
9. [UI/UX Requirements](#9-uiux-requirements)
10. [Data Models](#10-data-models)
11. [API & Integrations](#11-api--integrations)
12. [Security Architecture](#12-security-architecture)
13. [Testing Strategy](#13-testing-strategy)
14. [Development Roadmap](#14-development-roadmap)
15. [Risk Register](#15-risk-register)
16. [Out of Scope](#16-out-of-scope)
17. [Appendix](#17-appendix)

---

## 1. Executive Summary

**VidMaster** is a feature-rich, offline-first Android media player built with Flutter that consolidates video playback, music streaming, internet downloading, Chromecast, biometric security, and Picture-in-Picture into a single, ad-free application.

Existing solutions like XPlayer, MX Player, and VLC each excel in specific areas but fail to provide a complete, unified experience — especially for Arabic-speaking users who require proper RTL interface support. VidMaster fills this gap by combining the best features of all competitors into one polished, privacy-focused application with full Arabic/English localization.

### Vision Statement
> *"One app to play everything — beautifully, securely, and privately."*

### Core Value Propositions
- **Universal Playback** — Every video and audio format via FFmpeg engine
- **All-in-One** — Video + Music + Downloader + Security in a single app
- **Privacy First** — Fully offline, zero data collection, biometric vault
- **Arabic Native** — First-class RTL support, not an afterthought
- **Ad-Free** — Clean experience with no interruptions

---

## 2. Problem Statement

### 2.1 Current Market Pain Points

| Pain Point | Impact | Affected Users |
|---|---|---|
| Users need 3–4 separate apps for video, music, and downloading | High friction, storage waste | All users |
| XPlayer, MX Player show aggressive ads | Degraded UX, privacy concerns | 80% of users |
| No free app combines biometric lock + downloading + casting | Security gap | Privacy-conscious users |
| Most players don't properly support Arabic RTL UI | Alienating experience | Arabic-speaking users |
| VLC has powerful features but outdated, complex UI | Abandonment | Casual users |
| Background playback breaks across many apps | Frustration | Music listeners |

---

## 3. Goals & Success Metrics

### 3.1 Business Goals

| # | Goal | Timeframe |
|---|---|---|
| G1 | Launch stable MVP on Google Play Store | Week 12 |
| G2 | Achieve 5,000+ installs in first month | Month 1 |
| G3 | Maintain 4.3+ star rating on Play Store | Ongoing |
| G4 | Establish VidMaster as top Arabic media player | Month 6 |
| G5 | Zero critical crashes in production | Ongoing |

### 3.2 Key Performance Indicators (KPIs)

| Metric | Target | Measurement Tool |
|---|---|---|
| First-month installs | > 5,000 | Google Play Console |
| Play Store rating | ≥ 4.3 ⭐ | Google Play Reviews |
| Crash-free sessions | > 99% | Firebase Crashlytics |
| App cold start time | < 2 seconds | Firebase Performance |
| Video start latency | < 1.5 seconds | In-App Logging |
| APK size | < 50 MB per ABI | Build output |

---

## 4. Competitive Analysis

| Feature | **VidMaster** | XPlayer | MX Player | VLC | GOM Player |
|---|:---:|:---:|:---:|:---:|:---:|
| All video formats (FFmpeg) | ✅ | ✅ | ⚠️ Limited | ✅ | ✅ |
| Integrated music player | ✅ | ❌ | ❌ | ✅ Partial | ❌ |
| Internet downloader | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cast / Chromecast | 🟡 SDK init only | ✅ | ✅ | ❌ | ❌ |
| Biometric lock (PIN + FP) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Hidden vault (security review pending) | ⚠️ | ❌ | ❌ | ❌ | ❌ |
| Picture-in-Picture | ✅ | ✅ | ✅ | ✅ | ❌ |
| Arabic RTL UI | ✅ | ❌ | ❌ | ❌ | ❌ |
| 100% Ad-free | ✅ | ❌ | ❌ | ✅ | ❌ |

---

## 5. Target Users & Personas

*(Unchanged from v1.1 — Ahmed, Sara, Mohamed personas remain valid)*

---

## 6. Functional Requirements

> **Priority Scale:** P0 = MVP blocker · P1 = Important · P2 = Nice to have · P3 = Future

*(Full requirement tables unchanged from v1.1 — all feature IDs VP-01 through ST-12 remain valid)*

---

## 7. Non-Functional Requirements

*(Unchanged from v1.1)*

---

## 8. Technical Architecture

### 8.1 Architecture Overview

VidMaster follows **Clean Architecture** with strict layer separation:

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  Flutter Widgets │ Riverpod Providers │ Screens  │
├─────────────────────────────────────────────────┤
│                Domain Layer                      │
│   Use Cases │ Entities │ Repository Interfaces   │
│              (Pure Dart — no Flutter)            │
├─────────────────────────────────────────────────┤
│                 Data Layer                       │
│  Repository Impl │ Isar DB │ Remote DataSources  │
│     media_kit │ just_audio │ flutter_downloader  │
└─────────────────────────────────────────────────┘
```

### 8.2 Folder Structure (Verified May 2026)

```
lib/
├── core/
│   ├── config/                 # BuildChannelConfig (stable/experimental)
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── theme/
│   │   └── app_theme.dart      # AppTheme.lightTheme / darkTheme
│   ├── router/
│   │   └── app_router.dart     # go_router + VideoPlayerArgs
│   ├── usecase/
│   │   └── usecase.dart        # UseCase<T,P> + NoParams
│   └── widgets/
│       └── main_shell.dart     # BottomNavigationBar shell
│
├── l10n/                       # app_en.arb, app_ar.arb + generated
│
├── features/
│   ├── video_player/           # Full Clean Architecture (27 files)
│   │   ├── data/               # Models (Isar), DataSources, RepoImpls
│   │   ├── domain/             # Entities, Repos, UseCases, Services
│   │   └── presentation/       # Providers, Screens, 17 Widgets
│   │
│   ├── music_player/           # Full Clean Architecture
│   │   ├── data/               # AudioHandler, Models, DataSources, RepoImpl
│   │   ├── domain/             # Entities, Repos, 12 UseCases
│   │   └── presentation/       # Providers, Screens (Library/NowPlaying/EQ/Playlists), MiniPlayerBar
│   │
│   ├── downloader/             # 5-layer Architecture (domain/data/application/core/presentation)
│   │   ├── core/               # LinkParser, DownloaderConstants
│   │   ├── domain/             # Entities, Repos, Services, UseCases
│   │   ├── data/               # Isar models, yt-dlp/YT Explode services, FFmpeg merge
│   │   ├── application/        # Use cases, ExtractionEngineCoordinator, CleanupService
│   │   └── presentation/       # Providers, Screens, Widgets
│   │
│   ├── security/               # Full Clean Architecture
│   │   ├── data/               # Auth DS, File Encryption DS, Vault Metadata DS, RepoImpls
│   │   ├── domain/             # Auth/Vault entities, repos, usecases
│   │   └── presentation/       # Auth/Vault providers, LockScreen, VaultScreen
│   │
│   └── settings/               # Presentation only
│       └── presentation/       # SettingsProvider, SettingsScreen
│
├── shared/                     # Cross-feature (models, widgets)
├── di.dart                     # All Riverpod provider registrations
├── main.dart                   # Entry point + initialization
└── main_screen.dart            # Root Shell
```

### 8.3 Tech Stack (Actual — from pubspec.yaml May 2026)

| Layer | Package | Version | Purpose |
|---|---|---|---|
| **Video Engine** | media_kit | ^1.2.0 | FFmpeg-based universal player |
| **Video UI** | media_kit_video | ^2.0.1 | Video widget + controls |
| **Video Libs** | media_kit_libs_video | ^1.0.7 | Native MPV/FFmpeg libs |
| **FFmpeg Kit** | ffmpeg_kit_flutter_new | ^4.1.0 | Maintained fork (merging/conversion) |
| **Music Playback** | just_audio | ^0.9.46 | High-quality audio engine |
| **Music BG Service** | audio_service | ^0.18.15 | Background + notification |
| **Music Library** | on_audio_query | ^2.9.0 | MediaStore query |
| **Chromecast** | flutter_chrome_cast | ^1.2.6 | Google Cast integration |
| **Downloader** | flutter_downloader | ^1.11.9 | WorkManager-based downloader |
| **HTTP Client** | dio | ^5.7.0 | Download + URL probing |
| **YT Extraction** | youtube_explode_dart | ^3.0.5 | YouTube metadata extraction |
| **State Management** | flutter_riverpod | ^2.6.1 | Clean state management |
| **FP (Security)** | dartz | ^0.10.1 | Either<L,R> for error handling |
| **FP (Video)** | fpdart | ^1.1.0 | Functional types |
| **Database** | isar_community | ^3.3.2 | Fast offline NoSQL database |
| **Database Libs** | isar_community_flutter_libs | ^3.3.2 | Isar native binaries |
| **Vault Metadata** | hive / hive_flutter | ^2.2.3 / ^1.1.0 | **Metadata + keys only** |
| **Biometrics** | local_auth | ^2.3.0 | Fingerprint + Face ID |
| **Secure Storage** | flutter_secure_storage | ^9.2.2 | PIN hash storage |
| **Encryption** | crypto | ^3.0.6 | SHA-256 utilities |
| **PIN Hashing** | bcrypt | ^1.1.3 | bcrypt for PINs |
| **Navigation** | go_router | ^17.2.3 | Declarative routing |
| **Permissions** | permission_handler | ^12.0.1 | Runtime permissions |
| **Sharing** | share_plus | ^10.1.4 | Native share sheet |
| **Notifications** | flutter_local_notifications | ^18.0.1 | Download notifications |
| **Thumbnails** | video_thumbnail | ^0.5.3 | Thumbnail generation |
| **Connectivity** | connectivity_plus | ^6.1.1 | Network state detection |
| **Wakelock** | wakelock_plus | ^1.2.8 | Keep screen awake |
| **WebView** | flutter_inappwebview | ^6.1.5 | In-app browser |
| **Photos** | photo_manager | ^3.9.0 | Media access |
| **Preferences** | shared_preferences | ^2.3.5 | Simple key-value store |
| **Localization** | intl | ^0.20.2 | l10n support |

### 8.5 Android 13 & 14 Background Execution Constraints

*(Unchanged from v1.1 — Foreground Service requirements and OEM battery optimization guidance remain valid)*

### 8.6 ABI Splits & APK Size Strategy

> ⚠️ **ABI splits are NOT YET CONFIGURED** in the current `build.gradle.kts`.
> Without splits, release APKs are ~193 MB (universal). This is a 🔴 **Release Blocker**.
> See `BLUEPRINT.md §5.4` for the planned Kotlin DSL config.

---

## 9–13. Sections Unchanged

> UI/UX Requirements (§9), Data Models (§10), API & Integrations (§11), Security Architecture (§12), and Testing Strategy (§13) remain valid from v1.1.

---

## 14. Development Roadmap

### Phase Overview (Updated May 2026)

| Phase | Focus | Status |
|---|---|---|
| **Phase 1** | Project setup + Clean Architecture scaffolding | ✅ Complete |
| **Phase 2** | Core Video Player (formats, gestures, subtitles) | ✅ Complete |
| **Phase 3** | Music Player (library, background, equalizer) | ✅ Complete |
| **Phase 4** | Download Manager (URLs, social extraction, DASH) | ✅ Core / 🧪 Social / 🟡 Polish |
| **Phase 5** | Security (PIN lock, biometric, hidden vault) | ⚠️ Stabilizing |
| **Phase 6** | Cast / Chromecast + Picture-in-Picture | 🟡 Partial |
| **Phase 7** | Polish (sharing, browser, RTL, performance) | 🟡 Partial |
| **Phase 8** | Testing + Bug fixes + Play Store submission | ⏳ Not Started |

### Phase 1 — Foundation ✅ Complete

- [x] Flutter project setup with Clean Architecture folder structure
- [x] Riverpod + Isar Community configuration
- [x] go_router navigation setup
- [x] Bottom Navigation Bar with 4 tabs
- [x] Dark/Light theme setup (Material 3)
- [x] Arabic/English localization (ARB files)
- [x] RTL/LTR switching logic via SettingsProvider
- [~] Permissions handling (permission_handler in pubspec, no full runtime flow)
- [ ] CI/CD pipeline

### Phase 2 — Core Video Player ✅ Complete

- [x] `media_kit` integration + FFmpeg build
- [x] VideoLibraryScreen with thumbnails grid
- [x] VideoPlayerScreen with full controls (17 widget files)
- [x] Gesture controls (brightness, volume, seek) — ProGestureLayer
- [x] Playback speed control
- [x] Subtitle loading (SRT, ASS, VTT) + styling sheet
- [x] Aspect ratio switching
- [x] Resume from last position (Isar)
- [x] Auto-play next in folder

### Phase 3 — Music Player ✅ Complete

- [x] `just_audio` + `audio_service` integration (VidMasterAudioHandler)
- [x] `on_audio_query` library scan
- [x] Songs, Albums, Artists tabs
- [x] Playlist creation and management
- [x] NowPlayingScreen with album art
- [x] MiniPlayerBar (persistent)
- [x] Consolidated MusicLibraryNotifier & State
- [x] Shuffle and repeat modes
- [x] Sleep timer
- [x] Equalizer screen (AndroidEqualizer)
- [~] Notification + lock screen controls (configured, partially wired)

### Phase 4 — Download Manager

**Stable Core: ✅ Complete**
- [x] `dio` + `flutter_downloader` integration
- [x] URL input dialog with validation
- [x] Active downloads list with progress
- [x] Pause/Resume/Cancel controls
- [x] Download history (Isar)
- [x] YouTube fallback via youtube_explode_dart
- [x] Clipboard monitoring
- [x] In-app browser
- [x] ExtractionEngineCoordinator with multi-engine fallback

**Social Extraction: 🧪 Experimental Only**
- [x] Social media extraction (yt-dlp via Chaquopy — 🧪 experimental flavor only)
- [x] DASH stream merging (FFmpeg)

**Polish Items: 🟡 Partial**
- [~] Notification per download (configured, partially wired)
- [~] Wi-Fi only mode (field exists in entity, no UI toggle)

### Phase 5 — Security ⚠️ Stabilizing

- [x] `local_auth` biometric integration
- [x] PIN setup screen (bcrypt hashing)
- [x] App lock on resume (LockScreen + AppAuthNotifier)
- [x] Failed attempts lockout (AuthState tracks failedAttempts + lockoutUntil)
- [ ] Hidden Vault release-grade encryption (legacy transform still needs AEAD replacement)
- [x] Move to/from vault flow (EncryptAndMoveToVault + DecryptAndRestoreFromVault)
- [~] Auto-lock timeout setting (UI exists, logic not wired)
- [ ] FLAG_SECURE for vault screen (not yet)

### Phase 6 — Cast & PiP 🟡 Partial

- [x] flutter_chrome_cast integration (initialized in main.dart)
- [~] Cast device discovery (basic setup)
- [x] PiP Platform Channel (vidmaster/pip)
- [~] PiP play/pause controls (depends on native Android PiP actions)

### Phase 7 — Polish 🟡 Partial

- [~] Video sharing (share_plus in pubspec, no share button in library)
- [~] File browser improvements (folders tab exists)
- [~] Search across all content (basic filter logic)
- [x] Settings screen (SettingsScreen with sections)
- [ ] RTL refinement pass
- [ ] Performance optimization pass
- [ ] Memory leak audit

### Phase 8 — Release ⏳ Not Started

- [ ] Unit tests for all use cases
- [ ] Widget tests for key screens
- [ ] QA on physical devices
- [ ] ProGuard rules (configured in build.gradle.kts)
- [ ] App signing configuration (key.properties required)
- [ ] Play Store submission

---

## 15. Risk Register

*(Unchanged from v1.1 — all risks remain valid. R02 APK size: NOT YET MITIGATED — ABI splits must be added to build.gradle.kts before release)*

---

## 16. Out of Scope (v1.0)

*(Unchanged from v1.1)*

---

## 17. Appendix

### 17.5 Dependency Reference

> Full dependency listing with versions and purpose: see [`BLUEPRINT.md §4 — Dependency Map`](./BLUEPRINT.md#4-dependency-map)
>
> Canonical source: `pubspec.yaml` in project root.

*(Remaining appendix sections 17.1–17.4, 17.6 unchanged from v1.1)*

---

*End of Document — VidMaster PRD v1.2 (Revised — May 2026)*
*© 2026 Nagi — All Rights Reserved*
