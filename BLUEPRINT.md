# VidMaster — Complete Project Blueprint
**Based on PRD v1.1 + Live Code Review (April 2026)**
**Framework:** Flutter 3.24+ / Dart 3.4+ | **Platform:** Android 8.0+ (API 26+)

---

## Table of Contents

1. [Project Identity](#1-project-identity)
2. [Architecture Overview](#2-architecture-overview)
3. [Complete Folder Structure](#3-complete-folder-structure)
4. [Dependency Map (pubspec.yaml)](#4-dependency-map)
5. [Android Configuration](#5-android-configuration)
6. [Domain Layer — All Entities](#6-domain-layer--all-entities)
7. [Domain Layer — All Repositories (Interfaces)](#7-domain-layer--all-repositories-interfaces)
8. [Domain Layer — All Use Cases](#8-domain-layer--all-use-cases)
9. [Data Layer — All Models & DataSources](#9-data-layer--all-models--datasources)
10. [Data Layer — All Repository Implementations](#10-data-layer--all-repository-implementations)
11. [Dependency Injection — di.dart](#11-dependency-injection--didart)
12. [Presentation Layer — All Providers (State)](#12-presentation-layer--all-providers-state)
13. [Presentation Layer — All Screens](#13-presentation-layer--all-screens)
14. [Presentation Layer — All Widgets](#14-presentation-layer--all-widgets)
15. [Navigation Map (go_router)](#15-navigation-map-go_router)
16. [Core Layer](#16-core-layer)
17. [main.dart Initialization Order](#17-maindart-initialization-order)
18. [Security Architecture (Vault)](#18-security-architecture-vault)
19. [Background Execution Architecture](#19-background-execution-architecture)
20. [Data Flow Diagrams](#20-data-flow-diagrams)
21. [Build Configuration](#21-build-configuration)
22. [Feature Completion Matrix](#22-feature-completion-matrix)
23. [Missing Features (Not Yet Built)](#23-missing-features-not-yet-built)

---

## 1. Project Identity

| Field | Value |
|---|---|
| App Name | VidMaster |
| Package ID | `com.vidmaster.app` |
| Version | 1.0.0+1 |
| Min SDK | API 26 (Android 8.0) — required for PiP + Biometric |
| Target SDK | API 34 (Android 14) |
| Compile SDK | API 34 |
| Flutter | 3.24.0+ |
| Dart | 3.4.0+ |
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| State Management | Riverpod 2.5.1 (StateNotifier pattern) |
| Database | Isar 3.1.0 (video, audio, playlist, downloads) |
| Encrypted Storage | Hive 1.1.0 (vault metadata only — never file bytes) |
| Navigation | go_router 13.2.1 |
| Video Engine | media_kit 1.1.11 + FFmpeg |
| Audio Engine | just_audio 0.9.38 + audio_service 0.18.14 |
| Encryption | AES-256-GCM streaming (PointyCastle) |
| DI Pattern | Provider overrides in ProviderScope (main.dart) |

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                                                             │
│  Screens          Providers (StateNotifier)    Widgets      │
│  ────────         ────────────────────────     ───────      │
│  VideoLibrary     videoLibraryProvider         VideoThumb   │
│  VideoPlayer      videoPlayerProvider          MiniPlayer   │
│  MusicLibrary     musicLibraryProvider         MainShell    │
│  NowPlaying       musicPlayerProvider                       │
│  Downloads        downloaderProvider                        │
│  LockScreen       appAuthProvider                           │
│  Settings         settingsProvider                          │
└──────────────────────────┬──────────────────────────────────┘
                           │  watch / read
┌──────────────────────────▼──────────────────────────────────┐
│                      DOMAIN LAYER                           │
│                   (Pure Dart — No Flutter)                   │
│                                                             │
│  Entities           Repositories (abstract)   Use Cases     │
│  ────────           ────────────────────────  ─────────     │
│  VideoEntity        VideoRepository           GetAllVideos  │
│  AudioTrackEntity   MusicRepository           PlayTrack     │
│  DownloadTaskEntity DownloaderRepository      StartDownload │
│  EncryptedFileMeta  AuthRepository            EncryptFile   │
│  AuthState          VaultRepository           ValidatePin   │
│  PlaylistEntity                                             │
│  DownloadUrlInfo                                            │
└──────────────────────────┬──────────────────────────────────┘
                           │  implements
┌──────────────────────────▼──────────────────────────────────┐
│                       DATA LAYER                            │
│                                                             │
│  Models (Isar/Hive)      DataSources          Repo Impls    │
│  ──────────────────      ───────────          ─────────     │
│  VideoModel              VideoLocalDS         VideoRepoImpl │
│  AudioTrackModel         MusicLocalDS         MusicRepoImpl │
│  PlaylistModel           DownloaderLocalDS    DLRepoImpl    │
│  DownloadTaskModel       DownloaderRemoteDS   AuthRepoImpl  │
│  EncryptedFileMeta       FileEncryptionDS     VaultRepoImpl │
│    Model (Hive)          VaultMetadataDS                    │
│                          AuthLocalDS                        │
└─────────────────────────────────────────────────────────────┘

External:
  media_kit (FFmpeg)  │  just_audio  │  audio_service
  flutter_downloader  │  Isar DB     │  Hive (vault only)
  local_auth          │  flutter_secure_storage
  on_audio_query      │  PointyCastle (AES-256-GCM)
```

---

## 3. Complete Folder Structure

```
vidmaster/
├── android/
│   └── app/
│       ├── build.gradle                    ← ABI splits config
│       └── src/main/
│           ├── AndroidManifest.xml         ← All permissions + Service declarations
│           └── kotlin/com/vidmaster/app/
│               └── MainActivity.kt         ← PiP + Brightness Platform Channels
│
├── lib/
│   ├── main.dart                           ← App entry point + all initializations
│   ├── main_screen.dart                    ← Root screen (auth gate)
│   ├── di.dart                             ← Dependency injection (all providers)
│   │
│   ├── core/
│   │   ├── error/
│   │   │   ├── failures.dart               ← Sealed class Failure hierarchy
│   │   │   └── exceptions.dart             ← Infrastructure exceptions
│   │   ├── usecase/
│   │   │   └── usecase.dart                ← UseCase<T,P> + NoParams base classes
│   │   ├── router/
│   │   │   └── app_router.dart             ← go_router config + AppRoutes + VideoPlayerArgs
│   │   ├── theme/
│   │   │   └── app_theme.dart              ← AppTheme.dark / light + AppTextStyles
│   │   └── widgets/
│   │       └── main_shell.dart             ← Bottom NavigationBar + MiniPlayerBar overlay
│   │
│   ├── l10n/
│   │   ├── app_localizations.dart          ← Generated (flutter gen-l10n)
│   │   ├── app_localizations_en.dart       ← English strings
│   │   └── app_localizations_ar.dart       ← Arabic strings (RTL)
│   │
│   └── features/
│       │
│       ├── video_player/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── video_local_data_source.dart     ← Directory.list() scan + thumbnails
│       │   │   ├── models/
│       │   │   │   ├── video_model.dart                 ← Isar @collection
│       │   │   │   └── video_model.g.dart               ← Generated
│       │   │   └── repositories/
│       │   │       └── video_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── video_entity.dart                ← Pure Dart
│       │   │   ├── repositories/
│       │   │   │   └── video_repository.dart            ← abstract interface
│       │   │   └── usecases/
│       │   │       └── video_usecases.dart              ← All 10 use cases
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── video_library_provider.dart      ← VideoLibraryNotifier
│       │       │   └── video_player_provider.dart       ← VideoPlayerNotifier
│       │       ├── screens/
│       │       │   ├── video_library_screen.dart
│       │       │   └── video_player_screen.dart
│       │       └── widgets/
│       │           └── video_thumbnail_card.dart
│       │
│       ├── music_player/
│       │   ├── data/
│       │   │   ├── audio_handler.dart                   ← VidMasterAudioHandler [TO CREATE]
│       │   │   ├── datasources/
│       │   │   │   └── music_local_data_source.dart     ← on_audio_query + Isar
│       │   │   ├── models/
│       │   │   │   ├── audio_track_model.dart           ← Isar @collection
│       │   │   │   ├── audio_track_model.g.dart
│       │   │   │   ├── playlist_model.dart              ← Isar @collection
│       │   │   │   └── playlist_model.g.dart
│       │   │   └── repositories/
│       │   │       └── music_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── audio_track_entity.dart
│       │   │   │   └── playlist_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── music_repository.dart
│       │   │   └── usecases/
│       │   │       └── music_usecases.dart              ← 12 use cases
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── music_player_provider.dart       ← MusicPlayerNotifier + MusicLibraryNotifier
│       │       ├── screens/
│       │       │   ├── music_library_screen.dart        ← Songs/Albums/Artists/Playlists tabs
│       │       │   └── now_playing_screen.dart          ← Full NowPlaying UI
│       │       └── widgets/
│       │           └── mini_player_bar.dart             ← Persistent bottom bar
│       │
│       ├── downloader/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── downloader_local_data_source.dart  ← Isar CRUD
│       │   │   │   └── downloader_remote_data_source.dart ← Dio HEAD probe
│       │   │   ├── models/
│       │   │   │   ├── download_task_model.dart           ← Isar @collection
│       │   │   │   └── download_task_model.g.dart
│       │   │   └── repositories/
│       │   │       └── downloader_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── download_task_entity.dart
│       │   │   │   └── download_url_info.dart
│       │   │   ├── repositories/
│       │   │   │   └── downloader_repository.dart
│       │   │   └── usecases/
│       │   │       └── download_usecases.dart           ← 8 use cases
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── downloader_provider.dart         ← DownloaderNotifier
│       │       └── screens/
│       │           └── downloads_screen.dart
│       │
│       ├── security/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── auth_local_data_source.dart       ← FlutterSecureStorage
│       │   │   │   ├── file_encryption_data_source.dart  ← AES-256-GCM streaming
│       │   │   │   └── vault_metadata_data_source.dart   ← Hive box read/write
│       │   │   ├── models/
│       │   │   │   ├── encrypted_file_metadata_model.dart ← Hive @HiveType
│       │   │   │   └── encrypted_file_metadata_model.g.dart
│       │   │   └── repositories/
│       │   │       ├── auth_repository_impl.dart
│       │   │       └── vault_repository_impl.dart        ← 500 lines, full crypto
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── auth_state.dart                   ← AuthStatus enum + AuthState
│       │   │   │   ├── encrypted_file_metadata.dart      ← Pure Dart vault entry
│       │   │   │   └── security_entities.dart            ← (stub, main entities above)
│       │   │   ├── repositories/
│       │   │   │   ├── auth_repository.dart
│       │   │   │   └── vault_repository.dart
│       │   │   └── usecases/
│       │   │       ├── auth_usecases.dart               ← IsPinSet, SetupPin, ValidatePin, etc.
│       │   │       ├── vault_usecases.dart              ← Encrypt/Decrypt/List/Delete
│       │   │       └── security_usecases.dart           ← (stub, main usecases above)
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart               ← AppAuthNotifier
│       │       └── screens/
│       │           └── lock_screen.dart
│       │
│       └── settings/
│           └── presentation/
│               ├── providers/
│               │   └── settings_provider.dart           ← AppSettings + SettingsNotifier
│               └── screens/
│                   └── settings_screen.dart
│
└── test/
    └── (unit tests — to be written)
```

---

## 4. Dependency Map

### Runtime Dependencies

| Package | Version | Purpose | Used In |
|---|---|---|---|
| `media_kit` | ^1.1.11 | FFmpeg video engine | VideoPlayerNotifier |
| `media_kit_video` | ^1.2.5 | Video widget | VideoPlayerScreen |
| `media_kit_libs_video` | ^1.0.5 | FFmpeg native libs | Build config |
| `just_audio` | ^0.9.38 | Audio playback engine | MusicPlayerNotifier |
| `audio_service` | ^0.18.14 | Background + notification | VidMasterAudioHandler |
| `on_audio_query` | ^2.9.0 | MediaStore audio scan | MusicLocalDataSource |
| `flutter_downloader` | ^1.11.6 | WorkManager downloads | DownloaderLocalDS |
| `dio` | ^5.4.3+1 | HTTP + URL probing | DownloaderRemoteDS |
| `flutter_riverpod` | ^2.5.1 | State management | All providers |
| `riverpod_annotation` | ^2.3.5 | Code gen (optional) | — |
| `isar` | ^3.1.0+1 | Local database | All models |
| `isar_flutter_libs` | ^3.1.0+1 | Isar native libs | Build config |
| `local_auth` | ^2.2.0 | Fingerprint + Face ID | AuthLocalDataSource |
| `flutter_secure_storage` | ^9.0.0 | PIN hash storage | AuthLocalDataSource |
| `hive_flutter` | ^1.1.0 | Vault metadata only | VaultMetadataDataSource |
| `crypto` | ^3.0.3 | SHA-256 utilities | FileEncryptionDS |
| `go_router` | ^13.2.1 | Navigation | app_router.dart |
| `permission_handler` | ^11.3.1 | Runtime permissions | VideoLocalDS |
| `path_provider` | ^2.1.2 | App directories | VaultRepositoryImpl |
| `file_picker` | ^8.0.3 | Subtitle file selection | VideoPlayerScreen |
| `share_plus` | ^7.2.2 | Native share sheet | VideoPlayerScreen |
| `flutter_local_notifications` | ^17.1.2 | Download notifications | DownloaderNotifier |
| `video_thumbnail` | ^0.5.3 | Thumbnail generation | VideoLocalDataSource |
| `connectivity_plus` | ^5.0.2 | Network state | DownloaderNotifier |
| `intl` | ^0.20.2 | Localization | l10n |
| `dartz` | ^0.10.1 | Either<L,R> (security + downloader) | Repository impls |
| `fpdart` | ^1.2.0 | Either<L,R> (video) | VideoLibraryProvider |
| `bcrypt` | ^1.2.0 | PIN hashing | AuthLocalDataSource |

> ⚠️ **Note:** Both `dartz` and `fpdart` are in the project. `dartz` is used in security/downloader layers, `fpdart` in video layer. Consider unifying to one library to reduce APK size.

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_lints` | ^4.0.0 | Lint rules |
| `mocktail` | ^1.0.3 | Mocking for tests |
| `isar_generator` | ^3.1.0+1 | Isar code gen |
| `hive_generator` | ^2.0.1 | Hive adapters code gen |
| `riverpod_generator` | ^2.4.0 | Riverpod code gen |
| `build_runner` | ^2.4.9 | Code generation runner |
| `integration_test` | sdk | Integration tests |

---

## 5. Android Configuration

### 5.1 AndroidManifest.xml — Required Permissions

```xml
<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>     <!-- API 33+ -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>     <!-- API 33+ -->

<!-- Network -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<!-- Foreground Services — Android 14 requires explicit types -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>

<!-- Notifications (runtime on Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>

<!-- Biometrics -->
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>

<!-- ❌ NEVER ADD — Play Store rejection risk: -->
<!-- android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS -->
```

### 5.2 Required Service Declarations

```xml
<!-- MainActivity with PiP support -->
<activity
    android:name=".MainActivity"
    android:supportsPictureInPicture="true"
    android:resizeableActivity="true"
    android:launchMode="singleTop"
    ...>
</activity>

<!-- audio_service — foregroundServiceType required on Android 14 -->
<service
    android:name="com.ryanheise.audioservice.AudioServiceFragmentActivity"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService"/>
    </intent-filter>
</service>

<!-- flutter_downloader — foregroundServiceType required on Android 14 -->
<service
    android:name="vn.hunghd.flutterdownloader.DownloadTaskService"
    android:foregroundServiceType="dataSync"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="false"/>

<!-- Boot receiver for resuming downloads after restart -->
<receiver android:name="vn.hunghd.flutterdownloader.DownloadStartOnBootReceiver" android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

### 5.3 Platform Channels (Kotlin side — MainActivity.kt)

| Channel | Direction | Purpose |
|---|---|---|
| `vidmaster/pip` | Flutter → Android | Enter PiP mode |
| `vidmaster/brightness` | Flutter → Android | Set screen brightness |

```kotlin
// MainActivity.kt
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // PiP Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "vidmaster/pip")
            .setMethodCallHandler { call, result ->
                if (call.method == "enterPip") {
                    val params = PictureInPictureParams.Builder().build()
                    enterPictureInPictureMode(params)
                    result.success(null)
                } else result.notImplemented()
            }

        // Brightness Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "vidmaster/brightness")
            .setMethodCallHandler { call, result ->
                if (call.method == "setBrightness") {
                    val value = call.argument<Double>("value")?.toFloat() ?: 0.5f
                    val lp = window.attributes
                    lp.screenBrightness = value
                    window.attributes = lp
                    result.success(null)
                } else result.notImplemented()
            }
    }

    // Auto-enter PiP when home button pressed during video
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Signal Flutter via a separate EventChannel or SharedPreferences
    }
}
```

### 5.4 build.gradle — ABI Splits

```groovy
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 26
        targetSdkVersion 34
    }

    splits {
        abi {
            enable true
            reset()
            include "arm64-v8a", "armeabi-v7a", "x86_64"
            universalApk false  // ← NEVER true (would be 150+ MB)
        }
    }

    // Different versionCode per ABI (required for Play Store)
    ext.abiCodes = ["armeabi-v7a": 1, "arm64-v8a": 2, "x86_64": 3]

    applicationVariants.configureEach { variant ->
        variant.outputs.each { output ->
            def code = project.ext.abiCodes.get(output.getFilter(OutputFile.ABI))
            if (code != null) output.versionCodeOverride = code * 1000 + variant.versionCode
        }
    }
}
```

**Expected APK sizes after splits:**

| ABI | Devices | Size |
|---|---|---|
| `arm64-v8a` | All 2018+ phones | ~40–48 MB |
| `armeabi-v7a` | Older 32-bit | ~35–42 MB |
| `x86_64` | Emulators | ~45–52 MB |

---

## 6. Domain Layer — All Entities

### 6.1 VideoEntity
**File:** `lib/features/video_player/domain/entities/video_entity.dart`

| Field | Type | Description |
|---|---|---|
| `filePath` | `String` | Absolute device path (primary key via hashCode) |
| `title` | `String` | Display name (filename without extension) |
| `folderName` | `String` | Parent folder for grouping |
| `thumbnailPath` | `String?` | Cached JPEG path |
| `durationMs` | `int?` | Duration in milliseconds |
| `lastPositionMs` | `int?` | Resume position |
| `fileSizeBytes` | `int` | File size |
| `resolution` | `String?` | e.g. "1920x1080" |
| `lastPlayedAt` | `DateTime?` | For Recently Played |
| `playCount` | `int` | Default: 0 |
| `isFavourite` | `bool` | Default: false |
| `isInVault` | `bool` | Hidden in vault |

**Computed:** `id` (hashCode), `extension`, `hasResumePosition`, `resumeProgress` (0.0–1.0), `isWatched`, `formattedDuration`

---

### 6.2 AudioTrackEntity
**File:** `lib/features/music_player/domain/entities/audio_track_entity.dart`

| Field | Type | Description |
|---|---|---|
| `id` | `String` | MediaStore audio ID |
| `filePath` | `String` | Absolute path |
| `title` | `String` | Track title |
| `artist` | `String` | Artist name |
| `album` | `String` | Album name |
| `albumArtPath` | `String?` | Album art image path |
| `durationMs` | `int` | Duration in ms |
| `fileSizeBytes` | `int` | File size |
| `trackNumber` | `int?` | Track number in album |
| `year` | `int?` | Release year |
| `lastPlayedAt` | `DateTime?` | For Recently Played |
| `playCount` | `int` | Default: 0 |
| `isFavourite` | `bool` | Default: false |

**Computed:** `formattedDuration` (e.g. "3:42")

---

### 6.3 PlaylistEntity
**File:** `lib/features/music_player/domain/entities/playlist_entity.dart`

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `name` | `String` | User-defined name |
| `trackIds` | `List<String>` | Ordered track IDs |
| `coverArtPath` | `String?` | Override art |
| `createdAt` | `DateTime` | Creation timestamp |

---

### 6.4 DownloadTaskEntity
**File:** `lib/features/downloader/domain/entities/download_task_entity.dart`

| Field | Type | Description |
|---|---|---|
| `taskId` | `String` | flutter_downloader opaque ID |
| `url` | `String` | Source URL |
| `fileName` | `String` | User-facing filename |
| `saveDirectory` | `String` | Destination folder path |
| `status` | `DownloadStatus` | queued/running/paused/completed/failed/cancelled |
| `progressPercent` | `int` | 0–100 |
| `totalBytes` | `int?` | From Content-Length header |
| `downloadedBytes` | `int` | Bytes so far |
| `speedBytesPerSec` | `int?` | Real-time speed |
| `createdAt` | `DateTime` | Task creation time |
| `completedAt` | `DateTime?` | Completion timestamp |
| `errorMessage` | `String?` | Error detail |
| `wifiOnly` | `bool` | Default: false |

**Computed:** `absoluteFilePath`, `isActive`, `isFinished`, `etaSeconds`, `formattedSpeed`

---

### 6.5 DownloadUrlInfo
**File:** `lib/features/downloader/domain/entities/download_url_info.dart`

| Field | Type | Description |
|---|---|---|
| `url` | `String` | Original URL |
| `suggestedFileName` | `String` | From Content-Disposition or URL |
| `fileSizeBytes` | `int?` | From Content-Length |
| `supportsResume` | `bool` | Accept-Ranges: bytes |
| `mimeType` | `String?` | e.g. "video/mp4" |

**Computed:** `formattedSize`

---

### 6.6 EncryptedFileMetadata
**File:** `lib/features/security/domain/entities/encrypted_file_metadata.dart`

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `originalFileName` | `String` | e.g. "vacation.mp4" |
| `mimeType` | `String` | e.g. "video/mp4" |
| `originalFileSizeBytes` | `int` | Pre-encryption size |
| `encFileName` | `String` | e.g. "a3f9c2b1.enc" |
| `wrappedKey` | `List<int>` | AES key encrypted with PIN-derived KEK |
| `iv` | `List<int>` | 96-bit GCM nonce (unique per file) |
| `pbkdf2Salt` | `List<int>` | 32-byte random salt |
| `encryptedAt` | `DateTime` | Move-to-vault timestamp |
| `originalFilePath` | `String` | For "restore to original location" |

**Computed:** `encFilePath(vaultDir)`, `formattedSize`, `extension`

> ⚠️ **NEVER store file bytes in this entity or in Hive.** The `.enc` file lives on disk; Hive stores only this metadata (~1 KB per entry).

---

### 6.7 AuthState
**File:** `lib/features/security/domain/entities/auth_state.dart`

| Field | Type | Description |
|---|---|---|
| `status` | `AuthStatus` | unauthenticated / authenticated / locked |
| `isPinSet` | `bool` | Whether PIN has been configured |
| `failedAttempts` | `int` | Consecutive failures |
| `lockoutUntil` | `DateTime?` | Lockout expiry |

**Constants:** `maxFailedAttempts = 5`, `lockoutDuration = 15 minutes`
**Computed:** `isUnlocked`, `isLockedOut`, `remainingAttempts`

---

## 7. Domain Layer — All Repositories (Interfaces)

### 7.1 VideoRepository
**File:** `lib/features/video_player/domain/repositories/video_repository.dart`

```dart
abstract interface class VideoRepository {
  Future<Either<Failure, List<VideoEntity>>>  getAllVideos();
  Future<Either<Failure, List<VideoEntity>>>  getVideosByFolder(String folderPath);
  Future<Either<Failure, List<VideoEntity>>>  searchVideos(String query);
  Future<Either<Failure, List<String>>>       getAllFolders();
  Future<Either<Failure, void>>               savePlaybackPosition(String filePath, int positionMs);
  Future<Either<Failure, void>>               recordVideoPlay(String filePath);
  Future<Either<Failure, void>>               toggleFavourite(String filePath);
  Future<Either<Failure, List<VideoEntity>>>  getFavouriteVideos();
  Future<Either<Failure, List<VideoEntity>>>  getRecentlyPlayed({int limit});
  Future<Either<Failure, String>>             generateThumbnail(String videoPath);
}
```

---

### 7.2 MusicRepository
**File:** `lib/features/music_player/domain/repositories/music_repository.dart`

```dart
abstract interface class MusicRepository {
  Future<Either<Failure, List<AudioTrackEntity>>> getAllTracks();
  Future<Either<Failure, List<AudioTrackEntity>>> searchTracks(String query);
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByAlbum(String album);
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByArtist(String artist);
  Future<Either<Failure, List<String>>>           getAllAlbums();
  Future<Either<Failure, List<String>>>           getAllArtists();
  Future<Either<Failure, void>>                   toggleFavourite(String trackId);
  Future<Either<Failure, List<AudioTrackEntity>>> getFavouriteTracks();
  Future<Either<Failure, List<AudioTrackEntity>>> getRecentlyPlayed({int limit});
  Future<Either<Failure, void>>                   recordPlay(String trackId);
  Future<Either<Failure, List<PlaylistEntity>>>   getAllPlaylists();
  Future<Either<Failure, PlaylistEntity>>         createPlaylist(String name);
  Future<Either<Failure, void>>                   deletePlaylist(String id);
  Future<Either<Failure, void>>                   addTrackToPlaylist(String playlistId, String trackId);
  Future<Either<Failure, void>>                   removeTrackFromPlaylist(String playlistId, String trackId);
  Future<Either<Failure, void>>                   reorderPlaylist(String id, int oldIndex, int newIndex);
  Future<Either<Failure, List<AudioTrackEntity>>> getPlaylistTracks(String playlistId);
}
```

---

### 7.3 DownloaderRepository
**File:** `lib/features/downloader/domain/repositories/downloader_repository.dart`

```dart
abstract interface class DownloaderRepository {
  Future<Either<Failure, DownloadUrlInfo>>        validateDownloadUrl(String url);
  Future<Either<Failure, DownloadTaskEntity>>     startDownload({url, fileName, saveDirectory, wifiOnly});
  Future<Either<Failure, void>>                   pauseDownload(String taskId);
  Future<Either<Failure, void>>                   resumeDownload(String taskId);
  Future<Either<Failure, void>>                   cancelDownload(String taskId);
  Future<Either<Failure, DownloadTaskEntity>>     retryDownload(String taskId);
  Future<Either<Failure, List<DownloadTaskEntity>>> getAllDownloads();
  Future<Either<Failure, void>>                   deleteDownloadRecord(String taskId, bool deleteFile);
}
```

---

### 7.4 AuthRepository
**File:** `lib/features/security/domain/repositories/auth_repository.dart`

```dart
abstract interface class AuthRepository {
  Future<Either<Failure, bool>>      isPinSet();
  Future<Either<Failure, void>>      setupPin(String pin);
  Future<Either<Failure, void>>      changePin(String oldPin, String newPin);
  Future<Either<Failure, bool>>      validatePin(String pin);
  Future<Either<Failure, AuthState>> getAuthState();
  Future<Either<Failure, void>>      resetFailedAttempts();
}
```

---

### 7.5 VaultRepository
**File:** `lib/features/security/domain/repositories/vault_repository.dart`

```dart
abstract interface class VaultRepository {
  Future<Either<Failure, bool>>                       authenticateUser(String? pin);
  Future<Either<Failure, bool>>                       isVaultUnlocked();
  Future<Either<Failure, void>>                       lockVault();
  Future<Either<Failure, int?>>                       getRemainingAttempts();
  Future<Either<Failure, EncryptedFileMetadata>>      encryptAndMove(String filePath, String pin);
  Future<Either<Failure, String>>                     decryptAndRestore(EncryptedFileMetadata meta, String pin, String? destPath);
  Future<Either<Failure, List<EncryptedFileMetadata>>> listVaultItems();
  Future<Either<Failure, void>>                       permanentlyDelete(String metadataId);
  Future<Either<Failure, int>>                        getVaultSizeBytes();
}
```

---

## 8. Domain Layer — All Use Cases

### 8.1 Video Use Cases
**File:** `lib/features/video_player/domain/usecases/video_usecases.dart`

| Use Case Class | Params | Returns | Provider in di.dart |
|---|---|---|---|
| `GetAllVideos` | `NoParams` | `List<VideoEntity>` | `getAllVideosProvider` |
| `GetVideosByFolder` | `folderPath: String` | `List<VideoEntity>` | `getVideosByFolderProvider` |
| `GetAllVideoFolders` | `NoParams` | `List<String>` | `getAllFoldersProvider` |
| `SearchVideos` | `query: String` | `List<VideoEntity>` | `searchVideosProvider` |
| `SavePlaybackPosition` | `filePath, positionMs` | `void` | `savePlaybackPositionProvider` |
| `RecordVideoPlay` | `filePath: String` | `void` | `markVideoAsPlayedProvider` |
| `ToggleFavourite` | `filePath: String` | `void` | `toggleVideoFavoriteProvider` |
| `GetFavouriteVideos` | `NoParams` | `List<VideoEntity>` | `getFavoriteVideosProvider` |
| `GetRecentlyPlayed` | `limit: int` | `List<VideoEntity>` | `getRecentlyPlayedVideosProvider` |
| `GenerateThumbnail` | `videoPath: String` | `String` (thumb path) | `generateThumbnailProvider` |

---

### 8.2 Music Use Cases
**File:** `lib/features/music_player/domain/usecases/music_usecases.dart`

| Use Case Class | Params | Returns | Provider in di.dart |
|---|---|---|---|
| `GetAllTracks` | `NoParams` | `List<AudioTrackEntity>` | `getAllTracksProvider` |
| `SearchTracks` | `query: String` | `List<AudioTrackEntity>` | `searchTracksProvider` |
| `GetTracksByAlbum` | `album: String` | `List<AudioTrackEntity>` | `getTracksByAlbumProvider` |
| `GetTracksByArtist` | `artist: String` | `List<AudioTrackEntity>` | `getTracksByArtistProvider` |
| `ToggleMusicFavourite` | `trackId: String` | `void` | `toggleFavoriteTrackProvider` |
| `CreatePlaylist` | `name: String` | `PlaylistEntity` | `createPlaylistProvider` |
| `DeletePlaylist` | `id: String` | `void` | `deletePlaylistProvider` |
| `AddTrackToPlaylist` | `playlistId, trackId` | `void` | `addTrackToPlaylistProvider` |
| `GetRecentlyPlayedTracks` | `limit: int` | `List<AudioTrackEntity>` | `getRecentlyPlayedTracksProvider` |
| `RecordMusicPlay` | `trackId: String` | `void` | `recordMusicPlayProvider` ⚠️ ADD |

---

### 8.3 Downloader Use Cases
**File:** `lib/features/downloader/domain/usecases/download_usecases.dart`

| Use Case Class | Params | Returns | Provider in di.dart |
|---|---|---|---|
| `ValidateDownloadUrl` | `url: String` | `DownloadUrlInfo` | `probeUrlProvider` |
| `StartDownload` | `url, fileName, saveDirectory, wifiOnly` | `DownloadTaskEntity` | `startDownloadProvider` |
| `PauseDownload` | `taskId: String` | `void` | `pauseDownloadProvider` |
| `ResumeDownload` | `taskId: String` | `void` | `resumeDownloadProvider` |
| `CancelDownload` | `taskId: String` | `void` | `cancelDownloadProvider` |
| `RetryDownload` | `taskId: String` | `DownloadTaskEntity` | `retryDownloadProvider` |
| `GetAllDownloads` | `NoParams` | `List<DownloadTaskEntity>` | `getAllDownloadsProvider` |
| `DeleteDownloadRecord` | `taskId, deleteFile` | `void` | `deleteDownloadProvider` |

---

### 8.4 Security Use Cases

**Auth — File:** `lib/features/security/domain/usecases/auth_usecases.dart`

| Use Case Class | Provider in di.dart |
|---|---|
| `IsPinSet` | `isPinSetProvider` |
| `SetupPin` | `setupPinProvider` |
| `ValidatePin` | `validatePinProvider` |
| `AuthenticateWithBiometric` | `authenticateWithBiometricProvider` |
| `GetAuthState` | `getAuthStateProvider` |

**Vault — File:** `lib/features/security/domain/usecases/vault_usecases.dart`

| Use Case Class | Provider in di.dart |
|---|---|
| `AuthenticateVaultUser` | (via VaultRepository) |
| `CheckVaultUnlocked` | — |
| `LockVault` | — |
| `GetRemainingAttempts` | — |
| `EncryptAndMoveToVault` | `encryptAndMoveToVaultProvider` |
| `DecryptAndRestoreFromVault` | `decryptAndRestoreFromVaultProvider` |
| `GetVaultItems` | `getVaultItemsProvider` |
| `PermanentlyDeleteFromVault` | — |

---

## 9. Data Layer — All Models & DataSources

### 9.1 Isar Models

| Model | File | Schema Fields | Maps To |
|---|---|---|---|
| `VideoModel` | `video_model.dart` | filePath (index), title, folderName, thumbnailPath, durationMs, lastPositionMs, fileSizeBytes, resolution, lastPlayedAt, playCount, isFavourite, isInVault | `VideoEntity` |
| `AudioTrackModel` | `audio_track_model.dart` | id (index), filePath, title, artist, album, albumArtPath, durationMs, fileSizeBytes, trackNumber, year, lastPlayedAt, playCount, isFavourite | `AudioTrackEntity` |
| `PlaylistModel` | `playlist_model.dart` | uuid (index), name, trackIds, coverArtPath, createdAt | `PlaylistEntity` |
| `DownloadTaskModel` | `download_task_model.dart` | taskId (index), url, fileName, saveDirectory, statusName, progressPercent, totalBytes, downloadedBytes, speedBytesPerSec, createdAt, completedAt, errorMessage, wifiOnly | `DownloadTaskEntity` |

**Isar.open() schemas:** `[VideoModelSchema, AudioTrackModelSchema, PlaylistModelSchema, DownloadTaskModelSchema]`

---

### 9.2 Hive Model

| Model | File | HiveType ID | Purpose |
|---|---|---|---|
| `EncryptedFileMetadataModel` | `encrypted_file_metadata_model.dart` | `typeId: 0` | Vault metadata only — never file bytes |

**Fields:** `id, originalFileName, mimeType, originalFileSizeBytes, encFileName, wrappedKey (List<int>), iv (List<int>), pbkdf2Salt (List<int>), encryptedAt, originalFilePath`

---

### 9.3 DataSources

| DataSource | File | Dependencies | Key Methods |
|---|---|---|---|
| `VideoLocalDataSource` | `video_local_data_source.dart` | Isar, permission_handler, video_thumbnail | `scanAllVideos()`, `generateThumbnail()`, `savePosition()` |
| `MusicLocalDataSource` | `music_local_data_source.dart` | Isar, on_audio_query | `scanAllTracks()`, `getTracksByAlbum()`, `createPlaylist()` |
| `DownloaderLocalDataSource` | `downloader_local_data_source.dart` | Isar | `saveTask()`, `getAllTasks()`, `updateTask()`, `deleteTask()` |
| `DownloaderRemoteDataSource` | `downloader_remote_data_source.dart` | Dio | `validateUrl()` → HEAD request → `DownloadUrlInfo` |
| `FileEncryptionDataSource` | `file_encryption_data_source.dart` | PointyCastle, crypto | `encryptFile()`, `decryptFile()` — 4MB streaming chunks |
| `VaultMetadataDataSource` | `vault_metadata_data_source.dart` | Hive Box | `saveMetadata()`, `getAllMetadata()`, `deleteMetadata()` |
| `AuthLocalDataSource` | `auth_local_data_source.dart` | FlutterSecureStorage, local_auth, bcrypt | `setupPin()`, `validatePin()`, `authenticateBiometric()`, `getAuthState()` |

---

## 10. Data Layer — All Repository Implementations

| Implementation | Domain Interface | Data Sources Used |
|---|---|---|
| `VideoRepositoryImpl` | `VideoRepository` | `VideoLocalDataSource` |
| `MusicRepositoryImpl` | `MusicRepository` | `MusicLocalDataSource` |
| `DownloaderRepositoryImpl` | `DownloaderRepository` | `DownloaderLocalDataSource` + `DownloaderRemoteDataSource` |
| `AuthRepositoryImpl` | `AuthRepository` | `AuthLocalDataSource` |
| `VaultRepositoryImpl` | `VaultRepository` | `FileEncryptionDataSource` + `VaultMetadataDataSource` + `AuthLocalDataSource` |

**Exception → Failure mapping pattern (in every impl):**
```dart
Left<Failure, T> _mapException<T>(Object e) {
  return switch (e) {
    StoragePermissionException() => Left(const StoragePermissionFailure()),
    FileNotFoundException(:final path) => Left(FileNotFoundFailure(path)),
    NetworkException(:final statusCode) => Left(NetworkFailure(statusCode: statusCode)),
    EncryptionException() => Left(const EncryptionFailure()),
    _ => Left(UnexpectedFailure(e.toString())),
  };
}
```

---

## 11. Dependency Injection — di.dart

### Infrastructure Providers (initialized in main, overridden in ProviderScope)

```dart
isarProvider          → Provider<Isar>          // overrideWithValue(await initIsar())
vaultBoxProvider      → Provider<Box<...>>       // overrideWithValue(await initHive())
audioHandlerProvider  → Provider<AudioHandler>   // overrideWithValue(await AudioService.init(...))  ← ADD
audioPlayerProvider   → Provider<AudioPlayer>    // overrideWithValue(AudioPlayer())                 ← ADD
```

### 3rd-Party Singleton Providers

```dart
dioProvider            → Provider<Dio>
connectivityProvider   → Provider<Connectivity>
localAuthProvider      → Provider<LocalAuthentication>
secureStorageProvider  → Provider<FlutterSecureStorage>
audioQueryProvider     → Provider<OnAudioQuery>
```

### DataSource Providers

```dart
videoLocalDataSourceProvider        → VideoLocalDataSourceImpl(isar)
musicLocalDataSourceProvider        → MusicLocalDataSourceImpl(isar)
downloaderLocalDataSourceProvider   → DownloaderLocalDataSource(isar)
downloaderRemoteDataSourceProvider  → DownloaderRemoteDataSource(dio)
vaultDataSourceProvider             → VaultMetadataDataSource(vaultBox)
fileEncryptionDataSourceProvider    → FileEncryptionDataSource()
authDataSourceProvider              → AuthLocalDataSource(storage)
```

### Repository Providers

```dart
videoRepositoryProvider      → VideoRepositoryImpl
musicRepositoryProvider      → MusicRepositoryImpl
downloaderRepositoryProvider → DownloaderRepositoryImpl(local, remote)
authRepositoryProvider       → AuthRepositoryImpl(authDS)
vaultRepositoryProvider      → VaultRepositoryImpl(encDS, metaDS, authDS)
                               // ⚠️ vaultDirectory='/vault' must be fixed → _getVaultDir()
```

### Use Case Providers (complete list)

```dart
// Video
getAllVideosProvider, getVideosByFolderProvider, getAllFoldersProvider,
searchVideosProvider, savePlaybackPositionProvider, markVideoAsPlayedProvider,
toggleVideoFavoriteProvider, getFavoriteVideosProvider,
getRecentlyPlayedVideosProvider, generateThumbnailProvider

// Music
getAllTracksProvider, searchTracksProvider, getTracksByAlbumProvider,
getTracksByArtistProvider, toggleFavoriteTrackProvider, createPlaylistProvider,
deletePlaylistProvider, addTrackToPlaylistProvider,
getRecentlyPlayedTracksProvider, recordMusicPlayProvider  // ← ADD

// Downloader
probeUrlProvider, startDownloadProvider, pauseDownloadProvider,
resumeDownloadProvider, cancelDownloadProvider, retryDownloadProvider,
getAllDownloadsProvider, deleteDownloadProvider

// Security — Auth
isPinSetProvider, setupPinProvider, validatePinProvider,
authenticateWithBiometricProvider, getAuthStateProvider

// Security — Vault
getVaultItemsProvider, encryptAndMoveToVaultProvider,
decryptAndRestoreFromVaultProvider
```

---

## 12. Presentation Layer — All Providers (State)

### 12.1 VideoLibraryProvider
**File:** `lib/features/video_player/presentation/providers/video_library_provider.dart`
**Type:** `StateNotifierProvider<VideoLibraryNotifier, VideoLibraryState>`

**State fields:** `status` (initial/loading/loaded/error), `videos`, `folders`, `recentlyPlayed`, `favorites`, `searchQuery`, `sortOrder` (name/date/size/duration), `isGridView`, `errorMessage`

**Key methods:** `loadLibrary()`, `setSearchQuery()`, `setSortOrder()`, `toggleView()`, `toggleFavorite()`, `savePosition()`, `markPlayed()`, `getThumbnail()`

---

### 12.2 VideoPlayerProvider
**File:** `lib/features/video_player/presentation/providers/video_player_provider.dart`
**Type:** `StateNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>`

**State fields:** `status` (idle/loading/playing/paused/buffering/error), `currentVideo`, `queue`, `currentIndex`, `position`, `duration`, `playbackSpeed`, `volume`, `brightness`, `isControlsVisible`, `isLocked`, `subtitlePath`, `errorMessage`

**Key methods:** `openVideo(video, queue)`, `playPause()`, `seekTo()`, `seekForward(seconds)`, `seekBackward(seconds)`, `setSpeed()`, `setVolume()`, `setBrightness()`, `playNext()`, `playPrevious()`, `showControls()`, `hideControls()`, `toggleControls()`, `toggleLock()`, `loadSubtitle(path)`

**Streams subscribed:** `player.stream.position`, `player.stream.duration`, `player.stream.playing`, `player.stream.completed`

**Timers:** controls auto-hide (3s), position save (every 5s)

---

### 12.3 MusicLibraryProvider
**File:** `lib/features/music_player/presentation/providers/music_player_provider.dart`
**Type:** `StateNotifierProvider<MusicLibraryNotifier, MusicLibraryState>`

**State fields:** `isLoading`, `tracks`, `artists`, `albums`, `favorites`, `playlists`, `searchQuery`, `errorMessage`

**Key methods:** `loadLibrary()`, `setSearch()`, `toggleFavorite()`, `createPlaylist()`

---

### 12.4 MusicPlayerProvider
**File:** `lib/features/music_player/presentation/providers/music_player_provider.dart`
**Type:** `StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>` (NOT autoDispose)

**State fields:** `currentTrack`, `queue`, `currentIndex`, `position`, `duration`, `isPlaying`, `isLoading`, `repeatMode` (off/one/all), `shuffleMode` (off/on), `volume`, `sleepTimerRemaining`, `errorMessage`

**Key methods:** `playQueue(tracks, startIndex)`, `playTrack(track, queue)`, `playPause()`, `next()`, `previous()`, `seekTo()`, `setVolume()`, `cycleRepeat()`, `toggleShuffle()`, `setSleepTimer(duration)`, `cancelSleepTimer()`, `addToQueue(track)`

**Requires:** `audioPlayerProvider` + `audioHandlerProvider` + `recordMusicPlayProvider`

---

### 12.5 DownloaderProvider
**File:** `lib/features/downloader/presentation/providers/downloader_provider.dart`
**Type:** `StateNotifierProvider<DownloaderNotifier, DownloaderState>`

**State fields:** `tasks`, `isLoading`, `errorMessage`, `probedUrl`, `isProbing`

**Key methods:** `loadDownloads()`, `probeUrl(url)`, `startDownload(url, fileName, wifiOnly)`, `pauseDownload(taskId)`, `resumeDownload(taskId)`, `cancelDownload(taskId)`, `retryDownload(taskId)`, `deleteDownload(taskId, deleteFile)`, `clearError()`, `clearProbed()`

**flutter_downloader callback:** Static `_downloaderCallback(id, status, progress)` routed back to `_instance._onDownloadProgress()`

---

### 12.6 AppAuthProvider
**File:** `lib/features/security/presentation/providers/auth_provider.dart`
**Type:** `StateNotifierProvider<AppAuthNotifier, AppAuthState>`

**State fields:** `screenStatus` (checking/locked/authenticated/settingUp), `authState`, `isPinSet`, `isBiometricAvailable`, `errorMessage`, `isLoading`

**Key methods:** `setupPin(pin)`, `authenticateWithPin(pin)`, `authenticateWithBiometric()`, `lock()`, `clearError()`

---

### 12.7 SettingsProvider
**File:** `lib/features/settings/presentation/providers/settings_provider.dart`
**Type:** `StateNotifierProvider<SettingsNotifier, AppSettings>`

**State fields:** `themeMode`, `locale` ('en'/'ar'), `seekDurationSeconds`, `autoRotate`, `resumePlayback`, `downloadPath`, `wifiOnlyDownloads`, `maxConcurrentDownloads`, `autoPipOnBack`

**Setters:** `setThemeMode()`, `setLocale()`, `setSeekDuration()`, `setAutoRotate()`, `setResumePlayback()`, `setDownloadPath()`, `setWifiOnlyDownloads()`, `setMaxConcurrentDownloads()`, `setAutoPipOnBack()`

> ⚠️ **Missing:** Settings are not persisted across restarts. `SettingsNotifier` needs `SharedPreferences` or Hive to save/load on init.

---

## 13. Presentation Layer — All Screens

### 13.1 VideoLibraryScreen
**File:** `lib/features/video_player/presentation/screens/video_library_screen.dart`
**Route:** `/videos'

| Tab | Content |
|---|---|
| All Videos | Recently Played horizontal row + Grid/List of all videos |
| Folders | Folder list with video count |
| Favorites | Grid of favorited videos |

**AppBar:** Title + Grid/List toggle + Sort popup menu
**Search bar:** below AppBar, clears on `×`
**States:** Loading (spinner), Error (retry button), Empty, Loaded

---

### 13.2 VideoPlayerScreen
**File:** `lib/features/video_player/presentation/screens/video_player_screen.dart`
**Route:** `/player` (receives `VideoPlayerArgs` via `extra`)

**Layers (Stack):**
1. `Video` widget (media_kit_video, full screen, BoxFit.contain)
2. `_GestureOverlay` — left half = brightness, right half = volume, double-tap = ±10s seek
3. `_ControlsOverlay` (fade in/out, auto-hide 3s) — Top bar + Center controls + Bottom seek bar
4. Lock indicator (when `isLocked = true`)
5. `_StatusIndicators` — brightness/volume pills

**Top bar:** Back, filename, Lock toggle, Subtitles picker, PiP button, Speed picker
**Center controls:** ⏮ Prev | ⏪ -10s | ⏯ Play/Pause | ⏩ +10s | ⏭ Next
**Bottom bar:** Seek slider (amber) + position/duration text

**Platform Channels used:** `vidmaster/pip`, `vidmaster/brightness`
**System:** Immersive sticky mode, landscape lock, WakelockPlus

---

### 13.3 MusicLibraryScreen
**File:** `lib/features/music_player/presentation/screens/music_library_screen.dart`
**Route:** `/music`

| Tab | Content |
|---|---|
| Songs | Scrollable list of all tracks |
| Albums | Grid of albums with art |
| Artists | List of artists |
| Playlists | User playlists + "New playlist" button |

---

### 13.4 NowPlayingScreen
**File:** `lib/features/music_player/presentation/screens/now_playing_screen.dart`
**Route:** `/now-playing` (pushed, not in shell)

**Layout:** Blurred album art background + large album art (with rotation animation) + track info + seek bar + controls + repeat/shuffle buttons + sleep timer access

> ⚠️ **Import fix required:** `import 'package:flutter/material.dart' hide RepeatMode;`

---

### 13.5 DownloadsScreen
**File:** `lib/features/downloader/presentation/screens/downloads_screen.dart`
**Route:** `/downloads`

**AppBar:** Title + `+` button (opens URL dialog)
**URL Dialog:** TextField → `probeUrl()` → `startDownload()`
**Task list:** `_DownloadTile` per task with progress bar, speed, ETA, pause/resume/delete buttons
**Status badge:** color-coded (queued/running/done/failed/paused/cancelled)

---

### 13.6 LockScreen
**File:** `lib/features/security/presentation/screens/lock_screen.dart`
**Route:** `/lock'

**Flow:** Auto-triggers biometric on open → fallback to PIN input → on success → `context.go('/videos')`
**UI:** Lock icon + PIN text field (obscured) + "Unlock" button + "Use biometrics" button + error message

---

### 13.7 SettingsScreen
**File:** `lib/features/settings/presentation/screens/settings_screen.dart`
**Route:** `/settings`

**Sections:** Appearance (theme, language) | Playback (seek, rotate, resume) | Downloads (path, wifi-only, concurrent) | Security (lock, auto-lock, vault) | PiP | About

---

## 14. Presentation Layer — All Widgets

### 14.1 MainShell
**File:** `lib/core/widgets/main_shell.dart`

Bottom `NavigationBar` (4 tabs: Videos / Music / Downloads / Settings) + `MiniPlayerBar` overlaid above it using `Stack` + `Positioned`.

---

### 14.2 VideoThumbnailCard
**File:** `lib/features/video_player/presentation/widgets/video_thumbnail_card.dart`

16:10 aspect ratio card with lazy thumbnail loading, gradient overlay, resume progress bar (amber), filename + duration, favorite heart button, "Watched" badge.

---

### 14.3 MiniPlayerBar
**File:** `lib/features/music_player/presentation/widgets/mini_player_bar.dart`

60px persistent bar: 2px progress line (amber) + album art (44px rounded) + track title + artist + Prev/Play/Pause/Next buttons. Hidden when `currentTrack == null`.

> ⚠️ **Must use `musicPlayerProvider`** — not stub notifier. (Fix 5 in Fixes_v2.md)

---

## 15. Navigation Map (go_router)

```
app (GoRouter)
│
├── ShellRoute (MainShell — bottom nav)
│   ├── /videos          → VideoLibraryScreen
│   ├── /music           → MusicLibraryScreen
│   ├── /downloads       → DownloadsScreen
│   └── /settings        → SettingsScreen
│
├── /player              → VideoPlayerScreen (extra: VideoPlayerArgs)
│   └── VideoPlayerArgs { video: VideoEntity, queue: List<VideoEntity> }
│
└── /lock                → LockScreen
```

**Transitions:**
- Shell tabs: `FadeTransition` (200ms)
- `/player`: default slide-up (full screen push)

**AppRoutes constants:**
```dart
class AppRoutes {
  static const videos    = '/videos';
  static const music     = '/music';
  static const downloads = '/downloads';
  static const settings  = '/settings';
  static const player    = '/player';
  static const lock      = '/lock';
}
```

**Missing routes (to add):**
```dart
/now-playing     → NowPlayingScreen
/vault           → VaultScreen  (to build)
/vault/setup     → VaultSetupScreen (to build)
```

---

## 16. Core Layer

### 16.1 Failures Hierarchy
**File:** `lib/core/error/failures.dart`

```
Failure (sealed class)
├── StoragePermissionFailure
├── FileNotFoundFailure (path: String)
├── FileSystemFailure
├── PlaybackFailure
├── UnsupportedFormatFailure (format: String)
├── DatabaseFailure
├── NoInternetFailure
├── NetworkFailure (statusCode: int?)
├── InvalidUrlFailure
├── DownloadFailure
├── InsufficientStorageFailure (requiredBytes: int)
├── BiometricFailure
├── WrongPinFailure (attemptsRemaining: int)
├── VaultLockedFailure (lockDuration: Duration)
├── EncryptionFailure
├── TamperedFileFailure
├── ThumbnailFailure
└── UnexpectedFailure
```

---

### 16.2 UseCase Base Classes
**File:** `lib/core/usecase/usecase.dart`

```dart
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

---

### 16.3 AppTheme
**File:** `lib/core/theme/app_theme.dart`

| Token | Value |
|---|---|
| Primary | `#1565C0` (Deep Blue) |
| Secondary | `#F9A825` (Amber Gold) |
| Dark Background | `#0D1B2A` |
| Dark Surface | `#1C2B3A` |
| Dark Card | `#243447` |
| Design System | Material 3 |

`AppTheme.dark` and `AppTheme.light` — both fully configured with `colorScheme`, `AppBarTheme`, `NavigationBarTheme`, `SliderTheme`, `InputDecorationTheme`.

---

### 16.4 Localization
**Files:** `lib/l10n/app_localizations_en.dart`, `app_localizations_ar.dart`

Both EN and AR ARB files exist. `main.dart` wires `locale: Locale(settings.locale)` from `settingsProvider`. RTL is auto-applied by Flutter for `ar` locale.

---

## 17. main.dart Initialization Order

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();          // 1. Flutter binding

  MediaKit.ensureInitialized();                        // 2. media_kit (before any Player())

  final audioPlayer = AudioPlayer();                   // 3. just_audio player
  final audioHandler = await AudioService.init(        // 4. audio_service + Foreground Service
    builder: () => VidMasterAudioHandler(audioPlayer),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.vidmaster.audio',
      androidNotificationChannelName: 'VidMaster Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFF1565C0),
    ),
  );

  await FlutterDownloader.initialize(debug: false);    // 5. flutter_downloader WorkManager
  FlutterDownloader.registerCallback(_downloaderCallback);

  final isar = await initIsar();                       // 6. Isar DB (4 schemas)
  final vaultBox = await initHive();                   // 7. Hive vault box

  SystemChrome.setSystemUIOverlayStyle(...);           // 8. Status bar styling
  SystemChrome.setPreferredOrientations([              // 9. Default portrait
    DeviceOrientation.portraitUp
  ]);

  runApp(ProviderScope(                                // 10. Run app
    overrides: [
      isarProvider.overrideWithValue(isar),
      vaultBoxProvider.overrideWithValue(vaultBox),
      audioHandlerProvider.overrideWithValue(audioHandler),  // ← ADD
      audioPlayerProvider.overrideWithValue(audioPlayer),    // ← ADD
    ],
    child: const VidMasterApp(),
  ));
}
```

**VidMasterApp:**
```dart
MaterialApp.router(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: settings.themeMode,       // from settingsProvider
  locale: Locale(settings.locale),     // from settingsProvider
  routerConfig: appRouter,
  localizationsDelegates: [...],
  supportedLocales: [Locale('en'), Locale('ar')],
)
```

---

## 18. Security Architecture (Vault)

### 18.1 Encryption Flow (Move to Vault)

```
User selects video file
         │
         ▼
1. Generate 256-bit file key (SecureRandom)
2. Generate 96-bit GCM nonce/IV (unique per file)
3. Generate 32-byte PBKDF2 salt (unique per file)
4. Derive KEK = PBKDF2(PIN, salt, 200,000 iterations, SHA-256, 32 bytes)
5. Wrap file key = AES-256-GCM(fileKey, KEK, randomIV)
         │
         ▼
6. Open source file for reading (streaming)
7. Loop: read 4MB chunk → encrypt with AES-256-GCM(fileKey, IV) → write to .enc
8. Append GCM auth tag (16 bytes) at end of .enc file
9. Close streams
         │
         ▼
10. Securely delete source (overwrite with zeros → delete)
11. Save EncryptedFileMetadataModel to Hive:
    { wrappedKey, iv, pbkdf2Salt, encFileName, originalFileName, ... }
```

**RAM usage:** constant ~4 MB regardless of file size

### 18.2 Decryption Flow (Restore from Vault)

```
1. Load EncryptedFileMetadata from Hive
2. Derive KEK = PBKDF2(PIN, metadata.pbkdf2Salt, 200,000 iterations)
3. Unwrap file key = AES-256-GCM-Decrypt(metadata.wrappedKey, KEK)
4. Read .enc file: [12-byte IV][ciphertext][16-byte GCM tag]
5. Decrypt in 4MB chunks, verify GCM tag per chunk
6. If GCM tag mismatch → throw TamperedFileException (abort)
7. Write plaintext to destination path
8. Delete .enc file + remove Hive entry
```

### 18.3 PIN Storage (AuthLocalDataSource)

```
Setup:     salt = random_hex(32)
           hash = PBKDF2(PIN + ":" + salt, salt_bytes, 200,000, SHA-256)
           FlutterSecureStorage.write(key: 'pin_hash', value: '$salt:$hash')

Validate:  stored = SecureStorage.read('pin_hash')  → "$salt:$hash"
           inputHash = PBKDF2(inputPIN + ":" + salt, ...)
           if inputHash != hash → increment failedAttempts
           if failedAttempts >= 5 → lock for 15 minutes
           if match → resetFailedAttempts()
```

---

## 19. Background Execution Architecture

### 19.1 Music Playback (audio_service)

```
VidMasterAudioHandler (extends BaseAudioHandler)
         │
         ├── just_audio AudioPlayer (singleton, lives in ProviderScope)
         │
         ├── playbackEventStream → PlaybackState (notification buttons)
         ├── currentIndexStream  → MediaItem (notification title/art)
         │
         ├── Foreground Service: foregroundServiceType="mediaPlayback"
         │   → Declared in AndroidManifest.xml
         │   → Required on Android 14
         │
         └── Notification: ongoing=true, stopOnPause=true
             Controls: ⏮ ⏯ ⏭ (androidCompactActionIndices: [0,1,3])
```

### 19.2 Downloads (flutter_downloader + WorkManager)

```
DownloaderNotifier._downloaderCallback (static, @pragma vm:entry-point)
         │
         ├── Registered via FlutterDownloader.registerCallback()
         │
         ├── Routes progress to DownloaderNotifier._instance
         │
         └── flutter_downloader WorkManager Service:
             foregroundServiceType="dataSync"
             → Declared in AndroidManifest.xml
             → Shows persistent progress notification per download
             → BOOT_COMPLETED receiver resumes pending downloads
```

### 19.3 OEM Battery Optimization

Samsung/MIUI can kill Foreground Services. Strategy:
1. Detect OEM via `Build.MANUFACTURER` (Platform Channel)
2. Show one-time dialog guiding user to battery settings
3. Deep-link to correct settings screen per OEM
4. **Never** request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (Play Store risk)

---

## 20. Data Flow Diagrams

### 20.1 Video Playback Flow

```
User taps VideoThumbnailCard
         │
         ▼
VideoLibraryScreen calls context.push('/player', extra: VideoPlayerArgs)
         │
         ▼
VideoPlayerScreen.initState()
  → ref.read(videoPlayerProvider.notifier).openVideo(video, queue: queue)
         │
         ▼
VideoPlayerNotifier.openVideo()
  → state = loading
  → _player.open(Media(video.filePath))       // media_kit
  → if video.lastPositionMs → _player.seek()  // resume
  → markAsPlayed(video.filePath)              // RecordVideoPlay use case
  → showControls() + _resetControlsTimer()
         │
         ▼
Streams fire:
  position → state.position updates → seek bar redraws
  playing  → state.status updates → play/pause icon changes
  completed → playNext() or pause
         │
         ▼
On back press (PopScope):
  → savePlaybackPosition(video.filePath, position.inMilliseconds)
  → _exitFullscreen() + WakelockPlus.disable()
```

### 20.2 Download Flow

```
User taps + → types URL → taps Download
         │
         ▼
DownloaderNotifier.probeUrl(url)
  → ValidateDownloadUrl use case
  → DownloaderRemoteDataSource.validateUrl()
  → Dio HEAD request
  → Returns DownloadUrlInfo (fileName, size, supportsResume)
         │
         ▼
DownloaderNotifier.startDownload(url, fileName)
  → StartDownload use case
  → DownloaderRepositoryImpl.startDownload()
  → DownloaderLocalDataSource creates DownloadTaskModel in Isar
  → FlutterDownloader.enqueue() → returns taskId
  → WorkManager starts Foreground Service (dataSync)
  → Progress notifications appear in shade
         │
         ▼
Progress updates via _downloaderCallback(taskId, status, progress)
  → routes to DownloaderNotifier._onDownloadProgress()
  → state.tasks updated → UI rebuilds
```

---

## 21. Build Configuration

### 21.1 Release Build Command

```bash
# Generate .aab for Play Store (recommended)
flutter build appbundle --release

# Generate split APKs for direct distribution
flutter build apk --split-per-abi --release
```

### 21.2 Code Generation (when models change)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generates: `*.g.dart` files for Isar + Hive + Riverpod

### 21.3 Localization Generation

```bash
flutter gen-l10n
```

Generates: `lib/l10n/app_localizations.dart`

---

## 22. Feature Completion Matrix

| Feature | PRD Priority | Status | Provider | Screen | Notes |
|---|---|---|---|---|---|
| Video Library (scan + display) | P0 | ✅ Complete | `videoLibraryProvider` | `VideoLibraryScreen` | |
| Video Playback (all formats) | P0 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | media_kit + FFmpeg |
| Gesture controls (volume/brightness/seek) | P0 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | |
| Playback speed control | P0 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | |
| Resume from position | P0 | ✅ Complete | `videoLibraryProvider` | `VideoThumbnailCard` | |
| Screen lock during playback | P1 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | |
| Subtitle loading (SRT/VTT) | P1 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | file_picker integration done |
| PiP mode | P0 | ✅ Complete | `videoPlayerProvider` | `VideoPlayerScreen` | Kotlin side implemented |
| Video sharing | P1 | ✅ Complete | — | `VideoPlayerScreen` | share_plus wired |
| Thumbnails (lazy generation) | P1 | ✅ Complete | `videoLibraryProvider` | `VideoThumbnailCard` | |
| Folder browsing | P1 | ✅ Complete | `videoLibraryProvider` | `VideoLibraryScreen` | |
| Favorites | P1 | ✅ Complete | `videoLibraryProvider` | `VideoLibraryScreen` | |
| Recently Played | P1 | ✅ Complete | `videoLibraryProvider` | `VideoLibraryScreen` | |
| Music library scan | P0 | ✅ Complete | `musicLibraryProvider` | `MusicLibraryScreen` | on_audio_query |
| Background music playback | P0 | ✅ Complete | `musicPlayerProvider` | — | AudioService wired |
| Notification controls | P0 | ✅ Complete | `VidMasterAudioHandler` | — | audio_service integration |
| Playlists | P0 | ✅ Complete | `musicLibraryProvider` | `MusicLibraryScreen` | |
| Shuffle + Repeat | P0 | ✅ Complete | `musicPlayerProvider` | `NowPlayingScreen` | |
| Sleep timer | P1 | ✅ Complete | `musicPlayerProvider` | `NowPlayingScreen` | |
| MiniPlayerBar | P0 | ✅ Complete | `musicPlayerProvider` | `MainShell` | No longer a stub |
| Download from URL | P0 | ✅ Complete | `downloaderProvider` | `DownloadsScreen` | |
| Pause/Resume downloads | P0 | ✅ Complete | `downloaderProvider` | `DownloadsScreen` | |
| Download notifications | P0 | ✅ Complete | `downloaderProvider` | — | flutter_downloader handles |
| Wi-Fi only mode | P1 | ✅ Complete | `settingsProvider` | `SettingsScreen` | |
| Boot resume | P1 | ✅ Complete | — | — | Manifest + Receiver |
| PIN lock | P0 | ✅ Complete | `appAuthProvider` | `LockScreen` | |
| Biometric lock | P0 | ✅ Complete | `appAuthProvider` | `LockScreen` | |
| Hidden Vault (encrypt/decrypt) | P1 | 🟡 Logic Ready | `vaultRepositoryProvider` | — | **VaultScreen UI missing** |
| Settings persistence | P0 | 🔴 In-memory only | `settingsProvider` | `SettingsScreen` | **SharedPreferences missing** |
| Cast / Chromecast | P1 | 🔴 Not built | — | — | Entire feature missing |
| Equalizer | P2 | 🔴 Not built | — | — | |
| RTL full pass | P1 | ✅ Complete | — | — | Global RTL via locale |
| Unit Tests | P1 | 🔴 None | — | — | |
| ProGuard / Signing | P0 (release) | 🔴 Not configured | — | — | |

---

## 23. Missing Features (Not Yet Built)

### 🔴 Critical (blocks release)

| # | Feature | Where to Build | Effort |
|---|---|---|---|
| 1 | **VaultScreen UI** — list vault items, move to vault, restore | New screen | 4 hrs |
| 2 | **Settings persistence** — SharedPreferences or Hive | `settings_provider.dart` | 2 hrs |

### 🟡 Important (affects quality)

| # | Feature | Where to Build | Effort |
|---|---|---|---|
| 3 | **Unit Tests** for Security / Downloader layers | `test/` | 4 hrs |

### 🔵 Future (v2.0)

| Feature | Effort |
|---|---|
| Cast / Chromecast | 3–5 days |
| Equalizer UI | 1–2 days |
| Unit Tests (full coverage) | 2–3 days |
| ProGuard rules | 4 hrs |
| App signing config | 1 hr |
| YouTube/social download (yt-dlp) | Not planned v1 |
| iOS port | Not planned v1 |


---

*End of Blueprint — VidMaster v1.1*
*Total project: 68 Dart files | ~14,000 lines of code*
*Last reviewed: April 2026*
