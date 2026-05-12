# VidMaster — Execution Roadmap v2.1
## Stabilize → Harden → Ship

> **Document Type:** Daily Execution Checklist
> **Companion To:** BLUEPRINT.md · X.md · VidMaster.md
> **Last Updated:** 2026-05-08 (aligned with live codebase)

---

## Current Status — May 2026

| Area | Status | Notes |
|---|---|---|
| **Build System** | ✅ Stable | Kotlin DSL `build.gradle.kts`, both flavors verified |
| **Video Player** | ✅ Complete | 47 files, fully functional with gestures + subtitles |
| **Music Player** | ✅ Complete | 17 files, background playback via audio_service |
| **Downloader** | ✅ Core Complete | 35+ files; Wi-Fi toggle UI not wired; social extraction 🧪 experimental only |
| **Security** | ⚠️ Stabilizing | Vault auth/session guard in progress; crypto replacement still required |
| **Settings** | ✅ Complete | Theme, locale, preferences |
| **Chromecast** | 🟡 Partial | SDK initialized, basic casting |
| **Release Build** | ⏳ Pending | Signing config required |

---

## Day 1–2: Foundation Verification ✅ DONE

- [x] `flutter clean && flutter pub get`
- [x] `dart run build_runner build --delete-conflicting-outputs`
- [x] `flutter analyze` → verify 0 errors
- [x] Verify Isar Community 3.3.2 schemas generate correctly
- [x] Verify stable flavor builds: `flutter build apk --debug --flavor stable`
- [x] Verify experimental flavor builds (Chaquopy check)
- [x] Verify DI graph resolves (all providers in `di.dart`)

---

## Day 3–5: Build Configuration ✅ DONE

- [x] Migrate `build.gradle` → `build.gradle.kts` (Kotlin DSL)
- [x] Configure product flavors: `stable` (`.stable`), `experimental` (`.exp`)
- [x] Set up conditional Chaquopy loading (experimental only)
- [x] Configure R8 + ProGuard for release builds
- [x] Release signing guard (rejects debug keys for release)
- [x] APK output copy task (afterEvaluate → flutter-apk directory)
- [x] Verify `ffmpeg_kit_flutter_new` fork resolves correctly

---

## Day 6–8: Downloader Hardening ✅ DONE

- [x] Verify all 3 Isar collections (DownloadTaskModel, ExtractionCacheModel)
- [x] `flutter_downloader` WorkManager integration
- [x] yt-dlp extraction service (🧪 experimental flavor only)
- [x] YouTube Explode fallback (stable flavor)
- [x] ExtractionEngineCoordinator multi-engine routing
- [x] DASH merge via FFmpegMergeService — Implemented / Needs QA on device
- [x] Storage service (disk space checks)
- [x] CleanupService for temp files
- [x] Clipboard monitoring (LinkParser + auto-detect) — Implemented / Needs QA
- [x] In-app browser integration — Implemented / Needs QA

---

## Day 9–10: Subtitle Engine ✅ DONE

- [x] SubtitleSettingsIsar model + generated code
- [x] IsarSubtitlePreferencesRepository (persistence)
- [x] SubtitleStylingSheet (font, color, background, opacity)
- [x] PlayerSubtitleTrackMenu (embedded + external tracks)
- [x] Delay adjustment (±10s, 100ms precision)
- [x] Per-video subtitle delay persistence
- [x] External file loading (.srt, .vtt, .ass, .ssa)

---

## Day 11–12: RTL & UI Polish ⏳ PENDING

- [ ] Full RTL pass on all screens (Arabic locale)
- [ ] EdgeInsetsDirectional audit
- [ ] TextDirection propagation check
- [ ] Right-to-left gesture inversion (seek direction)
- [ ] Arabic ARB string completion
- [ ] Overflow/clipping in RTL mode

---

## Day 13–14: Performance Optimization ⏳ PENDING

- [ ] Memory leak audit (video player lifecycle)
- [ ] `RepaintBoundary` placement on key overlays
- [ ] `const` widget audit
- [ ] Riverpod `select()` optimization for player state
- [ ] FPS profiling during gesture seeking
- [ ] Battery consumption baseline test

---

## Day 15–16: Testing ⏳ PENDING

- [ ] Unit tests for all 10 video use cases
- [ ] Unit tests for GestureEngine (pure Dart)
- [ ] Unit tests for SubtitleSettings (copyWith, textStyle)
- [ ] Widget tests for key player controls
- [ ] Integration test: video open → play → seek → close
- [ ] Integration test: download → complete → library sync

---

## Day 17–18: Release Preparation ⏳ PENDING

- [ ] Create `android/key.properties` with production signing keys
- [ ] Build stable release APK (split per ABI)
- [ ] Verify APK sizes (target: < 50MB per ABI)
- [ ] Test on physical device (Android 8.0 minimum)
- [ ] Test on physical device (Android 14)
- [ ] Play Store listing preparation
- [ ] Final `flutter analyze` → 0 issues
- [ ] RELEASE_CHECKLIST.md validation

---

## Risk Mitigation Notes

| Risk | Impact | Mitigation |
|---|---|---|
| `media_kit_libs_video` download fails in CI | Build blocker | Cache native artifacts in CI pipeline |
| `ffmpeg_kit_flutter_new` fork becomes stale | Medium | Pin version, monitor for upstream fixes |
| Chaquopy increases APK size by ~50MB | User acquisition | Only in experimental flavor; stable is lean |
| `isar_community` schema migration breaks | Data loss | Isar migration strategy (version bump) |
| Android 15+ permission changes | Runtime crash | Monitor Android beta; adapt early |

---

## Alignment Check

This roadmap is aligned with:
- `BLUEPRINT.md` — Architectural reference
- `X.md` — Video player technical blueprint
- `VidMaster.md` — Product requirements document
- `docs/RELEASE_CHECKLIST.md` — Pre-release validation
- `docs/downloader/BLUEPRINT.md` — Downloader implementation guide
