# VidMaster — All-in-One Media Suite 🎬 🎵 📥

VidMaster is a Flutter-based offline-first Android media application combining a video player, music player, download manager, and privacy vault. Built with Clean Architecture, Riverpod, and Isar.

> **Platform:** Android 8.0+ (API 26) · **Framework:** Flutter >=3.24.0 · **Architecture:** Feature-First Clean Architecture

---

## Current Status — May 2026

| Area | Status | Notes |
|---|---|---|
| Video Player | ✅ Complete | 47 files, gestures, subtitles, resume, PiP |
| Music Player | ✅ Complete | Background playback, playlists, equalizer, mini player |
| Downloader (direct URL) | ✅ Complete | Pause/resume/cancel, Isar state persistence |
| Social Extraction | 🧪 Experimental | yt-dlp via Chaquopy — experimental flavor only |
| Security (PIN + Biometric) | ✅ Complete | bcrypt PIN, local_auth biometrics, lockout |
| Vault (encrypt/decrypt) | ⚠️ Stabilizing | Auth guard works; crypto needs AEAD replacement; FLAG_SECURE pending |
| Settings | ✅ Complete | SharedPreferences fully wired (load + save verified) |
| Chromecast | 🟡 Partial | SDK initialized; no full casting flow |
| Build System | ✅ Stable | Kotlin DSL, stable/experimental flavors |
| ABI Splits | 🔴 Release Blocker | Not configured — APK is ~193 MB universal |
| Release Signing | 🔴 Release Blocker | `key.properties` required |
| Physical Device QA | 🔴 Release Blocker | Not yet performed |

---

## ✅ Implemented & Verified

### 📺 Video Player
- Universal format support via `media_kit` + `FFmpeg` (MP4, MKV, AVI, HEVC, AV1, VP9, etc.)
- Physics-aware gesture controls: seek with velocity/inertia, volume/brightness swipes, double-tap ±10s
- Picture-in-Picture (Android 8.0+)
- Subtitle engine: external `.srt`/`.vtt`/`.ass`/`.ssa`, delay adjustment, font/color customization, per-video persistence
- Playback speed (0.25x–4.0x), 5 aspect ratio modes, lock mode, resume-from-position
- 17 decomposed widget files (landscape/portrait controls, overlays, seek section, etc.)

### 🎧 Music Player
- `audio_service` + `just_audio` for background playback
- Library scanning via `on_audio_query` (Songs, Albums, Artists)
- Dynamic playlists (Isar-backed), shuffle, repeat, sleep timer
- 7-band equalizer via AndroidEqualizer
- Persistent MiniPlayerBar across all tabs

### 📥 Direct URL Downloader
- `flutter_downloader` with WorkManager integration
- Pause, resume, cancel with full Isar state persistence
- Clipboard auto-detection via LinkParser
- In-app browser with download detection
- Foreground service (`dataSync`) compliant with Android 14

### 🔐 Security (PIN + Biometrics)
- PIN hashed with bcrypt, stored in `flutter_secure_storage`
- Biometric unlock via `local_auth`
- Failed attempt lockout (5 attempts → 15 min)
- App lock on resume with `LockScreen` + `AppAuthNotifier`

### ⚙️ Settings
- Theme (light/dark), locale (EN/AR), seek duration, auto-rotate, Wi-Fi downloads, PiP on back
- SharedPreferences persistence: load on startup, save on every change

---

## 🟡 Partial / In Progress

| Feature | Status | Notes |
|---|---|---|
| Vault (encrypt/decrypt) | ⚠️ Stabilizing | VaultScreen + auth guard work; legacy crypto transform needs audited AEAD replacement; FLAG_SECURE not applied |
| Chromecast | 🟡 Partial | `flutter_chrome_cast` initialized in `main.dart`; no casting UI or device discovery flow |
| Music notifications | 🟡 Partial | `VidMasterAudioHandler` configured; lock-screen controls partially wired |
| Video sharing | 🟡 Partial | `share_plus` in pubspec; no share button in video library |
| Wi-Fi only downloads | 🟡 Partial | Field exists in settings entity; no UI toggle |
| RTL refinement | 🟡 Partial | Locale switching works; dedicated QA pass not done |
| Unit tests | 🟡 Partial | 8 test files exist (7 unit + 1 widget); coverage is low |

---

## 🧪 Experimental (sandbox flavor only)

| Feature | Notes |
|---|---|
| Social media extraction | yt-dlp via Chaquopy — `experimental` flavor only |
| DASH stream merging | FFmpeg merge for video+audio streams — depends on extraction |
| YouTube extraction fallback | `youtube_explode_dart` available in stable flavor |
| ExtractionEngineCoordinator | Multi-engine fallback routing |

> **Build:** `flutter build apk --release --flavor experimental`
> These features are **not included** in the `stable` production build.

---

## 🔴 Release Blockers

| Issue | Severity | Details |
|---|---|---|
| **ABI splits not configured** | 🔴 Blocker | APK is ~193 MB universal; must add splits to `build.gradle.kts` |
| **Release signing** | 🔴 Blocker | `key.properties` with production keys required |
| **Physical device QA** | 🔴 Blocker | No manual QA on Android 8.0 or Android 14 devices |
| **Vault AEAD replacement** | ⚠️ Pre-release | Legacy authenticated transform must be replaced before vault is marketed as encrypted |
| **FLAG_SECURE** | ⚠️ Pre-release | Vault screen doesn't prevent screenshots |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.24.0+), Android SDK (API 26+, Compile SDK 34), JDK 17+

### Build Commands

```bash
# Debug (stable — production-safe)
flutter run --flavor stable

# Release APK (stable)
flutter build apk --release --flavor stable --split-per-abi

# Release APK (experimental — includes Chaquopy/yt-dlp)
flutter build apk --release --flavor experimental

# Code generation (after model changes)
dart run build_runner build --delete-conflicting-outputs
```

> **Note**: Release builds require `android/key.properties`. Debug signing is rejected for release.

---

## 📁 Project Structure

```text
lib/
├── core/                       # Router, theme, error handling, base use case, widgets
├── l10n/                       # Localization (EN/AR + generated)
├── features/
│   ├── video_player/           # 47 files — full Clean Architecture
│   ├── music_player/           # 17 files — audio library & background service
│   ├── downloader/             # 35+ files — 5-layer architecture
│   ├── security/               # 17 files — auth + vault
│   └── settings/               # 2 files — presentation only
├── di.dart                     # All Riverpod provider registrations
├── main.dart                   # Entry point + initialization
└── main_screen.dart            # Root Shell
```

> Full folder tree: [`BLUEPRINT.md §3`](./docs/BLUEPRINT.md#3-complete-folder-structure)
> File-level map: [`mapper.md`](./docs/mapper.md)

---

## 📜 License

Copyright © 2026 VidMaster Team. Distributed under the MIT License. See `LICENSE` for more information.

---

## 📚 Documentation

| Document | Purpose |
|---|---|
| [docs/BLUEPRINT.md](./docs/BLUEPRINT.md) | Canonical architecture reference — folder structure, dependencies, DI, feature matrix |
| [docs/mapper.md](./docs/mapper.md) | AI-agent codebase map — file paths, common task recipes |
| [docs/X.md](./docs/X.md) | Video player technical blueprint + PRD |
| [docs/VidMaster.md](./docs/VidMaster.md) | Product requirements document |
| [docs/ROADMAP.md](./docs/ROADMAP.md) | Execution checklist with day-by-day tasks |
| [docs/RELEASE_CHECKLIST.md](./docs/RELEASE_CHECKLIST.md) | Pre-release validation checklist |
| [docs/downloader/BLUEPRINT.md](./docs/downloader/BLUEPRINT.md) | Downloader engine implementation blueprint |
