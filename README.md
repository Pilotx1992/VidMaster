# VidMaster — All-in-One Media Suite 🎬 🎵 📥

VidMaster is a high-performance, professional-grade media player and manager built with **Flutter**. It combines a powerful video engine, a background-capable music player, a high-speed downloader, and an AES-256 encrypted secure vault into a single, cohesive application.

---

## ✨ Key Features

### 📺 Advanced Video Player
- **Universal Format Support**: Powered by `media_kit` and `FFmpeg` for seamless 4K playback.
- **Gesture Controls**: Intuitive vertical swipes for Volume/Brightness and horizontal swipes for Seeking.
- **Picture-in-Picture (PiP)**: Continue watching while using other apps (Android 8.0+).
- **Subtitle Support**: Load external `.srt` or `.vtt` files.
- **Playback Management**: Speed control (0.5x – 2.0x), aspect ratio adjustments, and resume-from-last-position.

### 🎧 Background Music Player
- **System Integration**: Fully integrated with `audio_service` for lock-screen controls and notification management.
- **Library Management**: Automatic scanning of local storage with sorting by Artist, Album, and Genre.
- **Dynamic Playlists**: Create, edit, and manage custom playlists.
- **Audio Features**: Shuffle, Repeat modes, and a customizable Sleep Timer.

### 📥 High-Speed Downloader
- **Pause & Resume**: Reliable background downloading with full state persistence.
- **Foreground Service**: Compliant with Android 14 `dataSync` requirements for uninterrupted downloads.
- **Wi-Fi Optimization**: Optional Wi-Fi-only mode to save cellular data.

### 🛡️ Secure Hidden Vault
- **AES-256-GCM Encryption**: Military-grade streaming encryption for your private media.
- **Zero-Knowledge Metadata**: Metadata stored in encrypted Hive boxes; original files are "shredded" (overwritten) upon vaulting.
- **Biometric Lock**: Fast access via Fingerprint/Face ID with PIN fallback.

---

## 🛠️ Technology Stack

- **Framework**: Flutter 3.24+ / Dart 3.4+
- **Architecture**: **Clean Architecture** (Domain, Data, Presentation layers)
- **State Management**: `flutter_riverpod` (with code generation)
- **Navigation**: `go_router`
- **Databases**:
  - `Isar`: High-performance NoSQL for media library indexing.
  - `Hive`: Encrypted local storage for security metadata.
- **Engines**:
  - `media_kit`: Video playback core.
  - `just_audio`: Audio playback core.
  - `flutter_downloader`: Background task management.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.24.0 or higher)
- Android Studio / VS Code
- Android SDK (API 26+)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/vidmaster.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run build runner for code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 📱 Android Configuration (API 34+ Compliance)

VidMaster is fully optimized for Android 14. It utilizes the following Foreground Service types:
- `mediaPlayback`: For uninterrupted music streaming.
- `dataSync`: For background file downloads.

> [!IMPORTANT]
> To comply with Play Store policies, VidMaster **does not** request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. Background tasks are managed via WorkManager and AudioService.

---

## 📁 Project Structure

VidMaster follows a strict **Clean Architecture** pattern, organized by feature (Feature-First) to ensure high maintainability and scalability.

```text
lib/
├── core/                       # App-wide infrastructure
│   ├── error/                  # Custom Failures and Exceptions
│   ├── router/                 # GoRouter navigation config
│   ├── theme/                  # AppTheme, Colors, and Typography
│   ├── usecase/                # Base UseCase interface
│   └── utils/                  # Formatters, Validators, Constants
├── features/                   # Business modules
│   ├── downloader/             # Background downloading module
│   │   ├── data/               # Models, DataSources, RepoImpls
│   │   ├── domain/             # Entities, Repo Interfaces, UseCases
│   │   └── presentation/       # Screens, Notifiers, Widgets
│   ├── music_player/           # Audio library & background service
│   │   ├── data/               # (Clean Architecture sub-layers)
│   │   ├── domain/
│   │   └── presentation/
│   ├── security/               # Vault, Auth & Encryption
│   │   ├── data/               # (Clean Architecture sub-layers)
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/               # App configuration & Persistence
│   │   ├── domain/             # Settings state & Persistence logic
│   │   └── presentation/       # Settings screens & Notifiers
│   └── video_player/           # Video player & library engine
│       ├── data/               # (Clean Architecture sub-layers)
│       ├── domain/
│       └── presentation/
├── shared/                     # Cross-feature components
│   ├── models/                 # Common Data Transfer Objects
│   └── widgets/                # UI components used in multiple screens
├── di.dart                     # Dependency Injection container
├── main.dart                   # Entry point & App initialization
└── main_screen.dart            # Root Shell (Navigation Rail / Bottom Bar)
```

---

## 📜 License

Copyright © 2026 VidMaster Team. Distributed under the MIT License. See `LICENSE` for more information.

---

*For technical deep dives, refer to the [BLUEPRINT.md](./BLUEPRINT.md).*
