# VidMaster — Project Mapper

> **Purpose**: A precise, AI-agent-friendly map of the codebase. Every entry uses
> **paths relative to the Flutter project root** (`vidmaster/`).
>
> When you receive this file, read it before editing. If a task description
> mentions a UI element / feature, jump to the matching “**Common task → files**”
> recipe at the bottom.

- **Project root**: `vidmaster/`
- **Package name**: `vidmaster`
- **Flutter SDK**: `>=3.24.0` (Dart `>=3.4.0 <4.0.0`)
- **Architecture**: Clean Architecture (domain / data / presentation) + Riverpod
- **Native runtime split**: dual flavors → `stable` (production) + `experimental`
  (Chaquopy/yt‑dlp sandbox). Always default to **`stable`** unless explicitly told.

---

## 1. Top‑level layout

```
vidmaster/
├── android/                 # Native Android (Kotlin/Gradle)
├── assets/                  # Static assets (images, etc.)
├── docs/                    # Project documentation (this file lives here)
├── ios/ macos/ linux/ windows/ web/   # Other Flutter platforms (mostly default)
├── lib/                     # Dart source — the bulk of the app
├── test/                    # Unit + widget tests
├── analysis_options.yaml    # Lints
├── pubspec.yaml             # Dependencies (canonical)
├── pubspec.lock
├── BLUEPRINT.md             # High-level architectural blueprint
├── X.md                     # Technical PRD
└── README.md
```

---

## 2. Conventions

- **Layer rule**: `presentation` may import from `domain`; `data` implements
  `domain`; `domain` is pure Dart. Don’t cross layers in the wrong direction.
- **State**: `flutter_riverpod` `StateNotifierProvider` for feature state,
  plus standalone `Provider` for derived/memoized values.
- **DB**: `Isar (community)` for indexable data, `Hive` for vault metadata.
- **Routing**: `go_router` (single source of truth = `core/router/app_router.dart`).
- **Errors**: `Either<Failure, T>` from `dartz` flowing from data → presentation.
- **DI**: `lib/di.dart` is the central wiring (overrides happen in `main.dart`).
- **RTL/LTR**: app respects locale, but **media surfaces (video library, mini
  player, full-screen video player, bottom nav)** use `Directionality.ltr` where
  needed so grids, chrome, **seek bars**, and transport rows stay visually
  left-to-right (video titles still use normal `Text` for natural Arabic).

---

## 3. Entry points & cross-cutting

| Concern                | File                                                 | Notes |
|------------------------|------------------------------------------------------|-------|
| App entry              | `lib/main.dart`                                      | `MediaKit.ensureInitialized`, FlutterDownloader, AudioService, ProviderScope overrides. |
| Legacy entry (unused)  | `lib/main_screen.dart`                               | Kept for reference; do not edit unless asked. |
| Dependency injection   | `lib/di.dart`                                        | Centralized providers (Isar, Hive, Dio, Audio, repos, use cases). |
| Router                 | `lib/core/router/app_router.dart`                    | `AppRoutes` constants + `AppRouter.router`. |
| Theme                  | `lib/core/theme/app_theme.dart`                      | Light/Dark themes (Premium-XPlayer style). |
| Failures / Exceptions  | `lib/core/error/failures.dart`, `…/exceptions.dart`  | `Either` payloads. |
| UseCase contract       | `lib/core/usecase/usecase.dart`                      | `UseCase<T, P>` + `NoParams`. |
| Common widgets         | `lib/core/widgets/main_shell.dart`                   | Scaffold shell + bottom navigation (`_PremiumBottomBar`). |
|                        | `lib/core/widgets/icons/custom_sort_arrows_icon.dart`| Custom Painter sort icon. |
|                        | `lib/core/widgets/icons/custom_music_note_icon.dart` | Custom Painter music icon (theme-aware). |
|                        | `lib/core/widgets/states/states.dart`                | Re-exports for Empty/Error/Loading widgets. |
|                        | `lib/core/widgets/states/empty_state_widget.dart`    |  |
|                        | `lib/core/widgets/states/error_state_widget.dart`    |  |
|                        | `lib/core/widgets/states/loading_state_widget.dart`  | Includes `SkeletonList`. |
| Localization           | `lib/l10n/app_localizations.dart`                    | Generated from ARB; English + Arabic. |
|                        | `lib/l10n/app_localizations_en.dart`                 |  |
|                        | `lib/l10n/app_localizations_ar.dart`                 |  |

---

## 4. Routing → Screens

`AppRoutes` constants live in `lib/core/router/app_router.dart`.

| Route                       | Screen widget                                                                      | File |
|-----------------------------|------------------------------------------------------------------------------------|------|
| `/videos`                   | `VideoLibraryScreen`                                                               | `lib/features/video_player/presentation/screens/video_library_screen.dart` |
| `/music`                    | `MusicLibraryScreen`                                                               | `lib/features/music_player/presentation/screens/music_library_screen.dart` |
| `/playlists`                | `PlaylistsScreen`                                                                  | `lib/features/music_player/presentation/screens/playlists_screen.dart` |
| `/downloads`                | `DownloadsScreen`                                                                  | `lib/features/downloader/presentation/screens/downloads_screen.dart` |
| `/video-browser`            | `VideoBrowserScreen`                                                               | `lib/features/downloader/presentation/screens/video_browser_screen.dart` |
| `/settings`                 | `SettingsScreen`                                                                   | `lib/features/settings/presentation/screens/settings_screen.dart` |
| `/lock`                     | `LockScreen`                                                                       | `lib/features/security/presentation/screens/lock_screen.dart` |
| `/vault`                    | `VaultScreen`                                                                      | `lib/features/security/presentation/screens/vault_screen.dart` |
| `/now-playing`              | `NowPlayingScreen` (extra: `NowPlayingArgs`)                                       | `lib/features/music_player/presentation/screens/now_playing_screen.dart` |
| `/equalizer`                | `EqualizerScreen`                                                                  | `lib/features/music_player/presentation/screens/equalizer_screen.dart` |
| `/player`                   | `VideoPlayerScreen` (extra: `VideoPlayerArgs`)                                     | `lib/features/video_player/presentation/screens/video_player_screen.dart` |
| `/dev/download-harness`     | `DownloadHarnessScreen` (debug only)                                               | `lib/features/downloader/presentation/screens/download_harness_screen.dart` |

`MainShell` (`lib/core/widgets/main_shell.dart`) wraps the first 3 tabs. Bottom
nav order is **Video / Music / Playlist** — visually LTR even on Arabic locale.

---

## 5. Feature: Video Player

Path prefix: `lib/features/video_player/`

### Domain
| Concern                    | File |
|----------------------------|------|
| `VideoEntity`              | `domain/entities/video_entity.dart` |
| `VideoFile`                | `domain/entities/video_file.dart` |
| `VideoPlaybackState`       | `domain/entities/video_playback_state.dart` |
| `SubtitleSettings`         | `domain/entities/subtitle_settings.dart` |
| Gesture types              | `domain/entities/gesture_engine.dart`, `domain/entities/gesture_result.dart` |
| Repos contracts            | `domain/repositories/video_repository.dart`, `…/resume_repository.dart`, `…/subtitle_preferences_repository.dart` |
| Brightness service iface   | `domain/services/platform_brightness_service.dart` |
| Use cases                  | `domain/usecases/video_usecases.dart` |

### Data
| Concern                       | File |
|-------------------------------|------|
| Engine wrapper (media_kit)    | `data/data_sources/video_engine.dart` |
| Local datasource              | `data/datasources/video_local_data_source.dart` |
| Isar models (+ generated)     | `data/models/video_model.dart` (`+.g.dart`)<br>`data/models/video_resume_isar.dart` (`+.g.dart`)<br>`data/models/subtitle_settings_isar.dart` (`+.g.dart`) |
| Repo implementations          | `data/repositories/video_repository_impl.dart`<br>`data/repositories/isar_resume_repository.dart`<br>`data/repositories/isar_subtitle_preferences_repository.dart` (+ `.g.dart`) |
| Native brightness             | `data/services/android_brightness_service.dart` |

### Presentation
| Concern                              | File |
|--------------------------------------|------|
| Library screen (XPlayer-style list)  | `presentation/screens/video_library_screen.dart` |
| Player screen + `VideoPlayerArgs`    | `presentation/screens/video_player_screen.dart` |
| Library state                        | `presentation/providers/video_library_provider.dart` |
| Player state                         | `presentation/providers/video_player_notifier.dart`, `presentation/providers/video_player_provider.dart` |
| Mini player (video) state            | `presentation/providers/mini_player_provider.dart` |
| Subtitle engine state                | `presentation/providers/subtitle_engine_provider.dart` |
| Video surface widget                 | `presentation/widgets/video_surface.dart` |
| Mini player floating layer           | `presentation/widgets/mini_player_layer.dart` |
| Pro gesture overlay                  | `presentation/widgets/pro_gesture_layer.dart` |
| Gesture engine widget glue           | `presentation/widgets/gesture_engine.dart` |
| Subtitle styling sheet               | `presentation/widgets/subtitle_styling_sheet.dart` |
| Thumbnail card (grid)                | `presentation/widgets/video_thumbnail_card.dart` |
| Player chrome (Phase 2B)             | `presentation/widgets/player_top_bar.dart`<br>`presentation/widgets/player_seek_section.dart` (LTR `Slider`)<br>`presentation/widgets/player_transport_controls.dart` (±10s + play/pause)<br>`presentation/widgets/player_quick_actions_row.dart` (lock, mute, aspect, CC, speed, more)<br>`presentation/widgets/player_speed_menu_button.dart`<br>`presentation/widgets/player_subtitle_track_menu.dart`<br>`presentation/widgets/player_control_helpers.dart` (duration / speed / aspect labels)<br>`presentation/widgets/landscape_player_controls.dart`<br>`presentation/widgets/portrait_player_controls.dart` |
| Overlays (Phase 2B)                  | `presentation/widgets/player_locked_overlay.dart`<br>`presentation/widgets/player_loading_overlay.dart`<br>`presentation/widgets/player_error_overlay.dart` |

> `video_player_screen.dart`: layered **`Stack`** — black fill → centered
> **`VideoSurface`** → **`ProGestureLayer`** when controls hidden (not locked,
> not error) → **`LandscapePlayerControls`** / **`PortraitPlayerControls`** when
> controls visible (`MediaQuery.orientationOf`) → **`PlayerLoadingOverlay`** →
> **`PlayerLockedOverlay`** → **`PlayerErrorOverlay`**. Overlay gradient:
> `AppDecorations.playerOverlay` (`app_theme.dart`).

> `_XPlayerListRow`, `_TopRightControls`, derived `videoQueueFilesProvider`,
> and the sort dialog (`_showXPlayerSortDialog`) are all **inside**
> `presentation/screens/video_library_screen.dart`.

> **`VideoPlayerNotifier`**: playback speed via `setPlaybackSpeed` +
> `supportedPlaybackSpeeds`; after `open` / same-file reopen, engine rate is
> synced with `VideoEngine.setPlaybackSpeed`. Aspect mode remains
> `cycleAspectRatio()` only (no separate setter).

---

## 6. Feature: Music Player

Path prefix: `lib/features/music_player/`

### Domain
| Concern                    | File |
|----------------------------|------|
| Track entity               | `domain/entities/audio_track_entity.dart` |
| Playlist entity            | `domain/entities/playlist_entity.dart` |
| Repository contract        | `domain/repositories/music_repository.dart` |
| Use cases                  | `domain/usecases/music_usecases.dart` |

### Data
| Concern                    | File |
|----------------------------|------|
| Audio handler (background) | `data/audio_handler.dart` (`VidMasterAudioHandler`) |
| Local datasource           | `data/datasources/music_local_data_source.dart` |
| Track Isar model           | `data/models/audio_track_model.dart` (+ `.g.dart`) |
| Playlist Isar model        | `data/models/playlist_model.dart` (+ `.g.dart`) |
| Repository impl            | `data/repositories/music_repository_impl.dart` |

### Presentation
| Concern                            | File |
|------------------------------------|------|
| Library screen (tabs)              | `presentation/screens/music_library_screen.dart` |
| Now Playing screen                 | `presentation/screens/now_playing_screen.dart` |
| Equalizer screen                   | `presentation/screens/equalizer_screen.dart` |
| Playlists screen (bottom-tab)      | `presentation/screens/playlists_screen.dart` |
| Library provider                   | `presentation/providers/music_library_provider.dart` |
| Player provider (queue, state)     | `presentation/providers/music_player_provider.dart` |
| Mini bar widget (above bottom nav) | `presentation/widgets/mini_player_bar.dart` |

> The music **mini bar** is rendered **inside `MainShell.bottomNavigationBar`**
> (above `_PremiumBottomBar`). To hide/show it, edit
> `lib/features/music_player/presentation/widgets/mini_player_bar.dart`
> (it auto-hides while on `/now-playing`).

---

## 7. Feature: Downloader

Path prefix: `lib/features/downloader/`

### Core / Application
| Concern                          | File |
|----------------------------------|------|
| Constants                        | `core/downloader_constants.dart` |
| URL parser                       | `core/link_parser.dart` |
| Cleanup service                  | `application/services/cleanup_service.dart` |
| Clipboard monitor                | `application/services/clipboard_monitor.dart` |
| Use cases (application)          | `application/use_cases/extract_metadata_use_case.dart`<br>`application/use_cases/start_download_use_case.dart`<br>`application/use_cases/merge_streams_use_case.dart` |

### Domain
| Concern                                  | File |
|------------------------------------------|------|
| Download task entity                     | `domain/entities/download_task_entity.dart` |
| URL info / metadata / formats            | `domain/entities/download_url_info.dart`<br>`domain/entities/extraction_result.dart`<br>`domain/entities/media_format.dart` |
| Social downloader state                  | `domain/entities/social_downloader_state.dart` |
| Repos (download / extraction cache)      | `domain/repositories/downloader_repository.dart`<br>`domain/repositories/download_repository.dart`<br>`domain/repositories/extraction_cache_repository.dart` |
| Service contracts                        | `domain/services/extraction_service.dart`<br>`domain/services/merge_service.dart`<br>`domain/services/storage_service.dart` |
| Aggregated use cases                     | `domain/usecases/download_usecases.dart` |

### Data
| Concern                                  | File |
|------------------------------------------|------|
| Local datasource                         | `data/datasources/downloader_local_data_source.dart` |
| Remote datasource (HEAD/GET probe)       | `data/datasources/downloader_remote_data_source.dart` |
| Task Isar model                          | `data/models/download_task_model.dart` (+ `.g.dart`) |
| Cache Isar model                         | `data/models/extraction_cache_model.dart` (+ `.g.dart`) |
| Repository impl                          | `data/repositories/downloader_repository_impl.dart` |
| Isar download repo                       | `data/repositories/isar_download_repository.dart` |
| Isar extraction cache repo               | `data/repositories/isar_extraction_cache_repository.dart` |
| FFmpeg merge service                     | `data/services/ffmpeg_merge_service.dart` |
| Storage service impl                     | `data/services/storage_service_impl.dart` |
| youtube_explode service                  | `data/services/youtube_explode_service.dart` |
| yt-dlp/Chaquopy bridge (experimental)    | `data/services/ytdlp_extraction_service.dart` |

### Presentation
| Concern                          | File |
|----------------------------------|------|
| Downloader provider              | `presentation/providers/downloader_provider.dart` |
| Social downloader notifier       | `presentation/providers/social_downloader_notifier.dart` |
| Social downloader provider       | `presentation/providers/social_downloader_provider.dart` |
| Downloads screen                 | `presentation/screens/downloads_screen.dart` |
| Video browser screen             | `presentation/screens/video_browser_screen.dart` |
| Dev harness (debug only)         | `presentation/screens/download_harness_screen.dart` |
| Item tile widget                 | `presentation/widgets/download_item_tile.dart` |
| Quality selection sheet          | `presentation/widgets/quality_selection_sheet.dart` |

---

## 8. Feature: Security (auth + vault)

Path prefix: `lib/features/security/`

| Layer        | File |
|--------------|------|
| Domain       | `domain/entities/auth_state.dart`, `domain/entities/encrypted_file_metadata.dart`, `domain/entities/security_entities.dart` |
|              | `domain/repositories/auth_repository.dart`, `domain/repositories/vault_repository.dart` |
|              | `domain/usecases/auth_usecases.dart`, `domain/usecases/vault_usecases.dart`, `domain/usecases/security_usecases.dart` |
| Data         | `data/datasources/auth_local_data_source.dart`, `data/datasources/vault_metadata_data_source.dart`, `data/datasources/file_encryption_data_source.dart` |
|              | `data/models/encrypted_file_metadata_model.dart` (+ `.g.dart`) |
|              | `data/repositories/auth_repository_impl.dart`, `data/repositories/vault_repository_impl.dart` |
| Presentation | `presentation/providers/auth_provider.dart`, `presentation/providers/vault_provider.dart` |
|              | `presentation/screens/lock_screen.dart`, `presentation/screens/vault_screen.dart` |

---

## 9. Feature: Settings

Path prefix: `lib/features/settings/`

| Concern  | File |
|----------|------|
| State    | `presentation/providers/settings_provider.dart` |
| Screen   | `presentation/screens/settings_screen.dart` |

`settingsProvider` controls `themeMode` + `locale`, consumed by `main.dart`.

---

## 10. Native Android

| Concern                            | File |
|------------------------------------|------|
| App-level Gradle (flavors / NDK)   | `android/app/build.gradle.kts` |
| Root Gradle (Kotlin / FFmpeg pins) | `android/build.gradle.kts` |
| Settings (plugins, repos)          | `android/settings.gradle.kts` |
| Wrapper                            | `android/gradle/wrapper/gradle-wrapper.properties` |
| Properties                         | `android/gradle.properties` |
| MainActivity                       | `android/app/src/main/kotlin/com/nagi/vidmaster/vidmaster/MainActivity.kt` |
| Manifests                          | `android/app/src/main/AndroidManifest.xml`<br>`android/app/src/debug/AndroidManifest.xml`<br>`android/app/src/profile/AndroidManifest.xml` |
| Splash / styles                    | `android/app/src/main/res/drawable/launch_background.xml`<br>`…/drawable-v21/…`<br>`…/values{,-night,-v31,-night-v31}/styles.xml` |
| Plugin generator                   | `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` |

> Use `--flavor stable` for production. Chaquopy plugin is applied **only**
> for `experimental`.

---

## 11. Tests

| File                                                  | Covers |
|-------------------------------------------------------|--------|
| `test/widget_test.dart`                               | Widget smoke test |
| `test/unit/settings_notifier_test.dart`               | Settings provider |
| `test/unit/subtitle_settings_test.dart`               | Subtitle settings entity |
| `test/unit/video_entity_test.dart`                    | `VideoEntity` |
| `test/unit/video_file_test.dart`                      | `VideoFile` |
| `test/unit/video_playback_state_test.dart`            | Playback state |
| `test/unit/video_player_notifier_test.dart`           | Player notifier |
| `test/unit/security/vault_repository_test.dart`       | Vault repo |

---

## 12. Documentation

| File                                  | What it is |
|---------------------------------------|------------|
| `BLUEPRINT.md`                        | Architecture blueprint (root copy). |
| `X.md`                                | Technical PRD. |
| `README.md`                           | Project README. |
| `docs/ROADMAP.md`                     | Day-by-day execution checklist. |
| `docs/VIDEO_AGENT.md`                 | Agent brief: video feature + player UX notes. |
| `docs/RELEASE_CHECKLIST.md`           | Pre-release verification. |
| `docs/downloader/BLUEPRINT.md`        | Downloader-specific blueprint. |
| `docs/downloader/PRD.md`              | Downloader PRD. |
| `docs/downloader/ROADMAP.md`          | Downloader roadmap. |
| `docs/mapper.md`                      | **This file**. Keep it in sync after major moves/renames. |

---

## 13. Common task → files (recipes)

> If a request matches one of these, start with the listed files.

- **Bottom navigation (tabs / icons / order)**
  → `lib/core/widgets/main_shell.dart`
  (uses `custom_music_note_icon.dart` from `core/widgets/icons/`).

- **Video library list/grid look (XPlayer style)**
  → `lib/features/video_player/presentation/screens/video_library_screen.dart`
    (contains `_XPlayerListRow`, `_TopRightControls`, sort dialog).
  → `lib/features/video_player/presentation/widgets/video_thumbnail_card.dart` (grid card).

- **Sort/filter behaviour & state**
  → `lib/features/video_player/presentation/providers/video_library_provider.dart`
    (`VideoLibraryState`, `displayVideos`, `updateSorting`, `enterSearch/exitSearch`).

- **Video playback engine / errors / open-by-path / speed / aspect cycle**
  → `lib/features/video_player/presentation/providers/video_player_notifier.dart`
  → `lib/features/video_player/data/data_sources/video_engine.dart`
  → `lib/features/video_player/presentation/screens/video_player_screen.dart`

- **Video player UI (portrait vs landscape controls, seek LTR, overlays)**
  → `lib/features/video_player/presentation/screens/video_player_screen.dart`
  → `lib/features/video_player/presentation/widgets/landscape_player_controls.dart`
  → `lib/features/video_player/presentation/widgets/portrait_player_controls.dart`
  → `lib/features/video_player/presentation/widgets/player_seek_section.dart`
  → `lib/features/video_player/presentation/widgets/player_transport_controls.dart`
  → `lib/features/video_player/presentation/widgets/player_top_bar.dart`
  → `lib/features/video_player/presentation/widgets/player_quick_actions_row.dart`
  → `lib/features/video_player/presentation/widgets/player_locked_overlay.dart`
  → `lib/features/video_player/presentation/widgets/player_loading_overlay.dart`
  → `lib/features/video_player/presentation/widgets/player_error_overlay.dart`

- **Gestures while playing (brightness/volume scrub, double-tap ±10) — physics**
  → `lib/features/video_player/presentation/widgets/pro_gesture_layer.dart`
  → `lib/features/video_player/domain/entities/gesture_engine.dart`

- **Music mini bar (close, play/pause, navigation, hide on Now Playing)**
  → `lib/features/music_player/presentation/widgets/mini_player_bar.dart`
  → `lib/features/music_player/presentation/providers/music_player_provider.dart`
    (`stopAndClear`, `clearCurrentTrack` flag in `copyWith`).

- **Now Playing screen (album art, controls)**
  → `lib/features/music_player/presentation/screens/now_playing_screen.dart`

- **Music library tabs (Songs / Folders / Albums / Artists)**
  → `lib/features/music_player/presentation/screens/music_library_screen.dart`

- **Routes / navigation arguments (`NowPlayingArgs`, `VideoPlayerArgs`)**
  → `lib/core/router/app_router.dart`

- **Theme (colors, typography, AppBar, navigation, list density)**
  → `lib/core/theme/app_theme.dart`

- **Custom icons (sort arrows, music note)**
  → `lib/core/widgets/icons/custom_sort_arrows_icon.dart`
  → `lib/core/widgets/icons/custom_music_note_icon.dart`

- **Empty / Error / Loading / Skeleton states**
  → `lib/core/widgets/states/states.dart` (re-exports the three widgets)

- **Downloader UI (list, item tile, quality sheet)**
  → `lib/features/downloader/presentation/screens/downloads_screen.dart`
  → `lib/features/downloader/presentation/widgets/download_item_tile.dart`
  → `lib/features/downloader/presentation/widgets/quality_selection_sheet.dart`

- **Downloader queue / start / cancel logic**
  → `lib/features/downloader/data/repositories/downloader_repository_impl.dart`
  → `lib/features/downloader/data/repositories/isar_download_repository.dart`
  → `lib/features/downloader/application/use_cases/start_download_use_case.dart`

- **URL probing (HEAD/GET 405 fallback)**
  → `lib/features/downloader/data/datasources/downloader_remote_data_source.dart`

- **Extraction (youtube_explode / yt-dlp)**
  → `lib/features/downloader/data/services/youtube_explode_service.dart`
  → `lib/features/downloader/data/services/ytdlp_extraction_service.dart` (experimental)

- **Isar schemas registered at startup**
  → `lib/di.dart` (`initIsar()` — keep this list in sync with all `*_model.dart` / `*_isar.dart`).

- **App entry / runtime init order**
  → `lib/main.dart`

- **Localization (English / Arabic strings)**
  → `lib/l10n/app_localizations_en.dart`, `…_ar.dart`
  → Generated wrapper: `lib/l10n/app_localizations.dart`

- **Android flavors / Chaquopy / FFmpeg pinning**
  → `android/app/build.gradle.kts`, `android/build.gradle.kts`

- **Splash / launcher styles**
  → `android/app/src/main/res/drawable*/launch_background.xml`
  → `android/app/src/main/res/values*/styles.xml`

- **MainActivity (no Chaquopy in stable)**
  → `android/app/src/main/kotlin/com/nagi/vidmaster/vidmaster/MainActivity.kt`

---

## 14. Things that look duplicated but aren’t

- `lib/features/video_player/data/data_sources/video_engine.dart`
  vs `…/data/datasources/video_local_data_source.dart`
  → Different folders (`data_sources` vs `datasources`). The first wraps
  `media_kit`; the second is the device-scan source. **Don’t merge them.**

- `lib/features/video_player/domain/entities/gesture_engine.dart`
  vs `lib/features/video_player/presentation/widgets/gesture_engine.dart`
  → One is the pure Dart engine; the other is the widget glue.

- `…/domain/repositories/download_repository.dart`
  vs `…/domain/repositories/downloader_repository.dart`
  → Two contracts (queue vs URL extraction). They’re both used.

---

## 15. Generated files (do **not** edit by hand)

Anything ending in `.g.dart` is generated by `build_runner`:

- `…/video_player/data/models/*.g.dart`
- `…/music_player/data/models/*.g.dart`
- `…/downloader/data/models/*.g.dart`
- `…/security/data/models/*.g.dart`
- `…/video_player/data/repositories/isar_subtitle_preferences_repository.g.dart`

Regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 16. When to touch `mapper.md`

Update this file whenever you:

1. Add / move / rename a feature folder.
2. Add a new top-level concern under `lib/core/`.
3. Add or remove a route in `AppRoutes`.
4. Add a new Isar schema (also update `lib/di.dart`).
5. Add native Android files that affect builds (Gradle, Manifest, plugins).

Keep the **Routing** table and the **Common task → files** recipes accurate;
they are what AI agents rely on most.
