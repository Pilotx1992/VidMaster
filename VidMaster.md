# VidMaster – Comprehensive Video & Music Player
## Product Requirements Document (PRD)
### Version 1.1 | March 2025 (Revised)

---

| Field | Value |
|---|---|
| **Product Name** | VidMaster – All-in-One Video & Music Player |
| **Version** | 1.1 (MVP — Revised) |
| **Platform** | Android 8.0+ (API 26+) |
| **Framework** | Flutter 3.24.0+ / Dart 3.4+ |
| **Architecture** | Clean Architecture + Riverpod 3.0 + Isar |
| **Document Status** | Revised v1.1 |
| **Last Updated** | March 2025 (technical review pass) |
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
   - 6.1 [Video Player](#61-video-player)
   - 6.2 [Music Player](#62-music-player)
   - 6.3 [Download Manager](#63-download-manager)
   - 6.4 [Security & Privacy](#64-security--privacy)
   - 6.5 [Cast / Chromecast](#65-cast--chromecast)
   - 6.6 [Picture-in-Picture (PiP)](#66-picture-in-picture-pip)
   - 6.7 [Video Sharing](#67-video-sharing)
   - 6.8 [File Browser & Library](#68-file-browser--library)
   - 6.9 [Settings & Preferences](#69-settings--preferences)
7. [Non-Functional Requirements](#7-non-functional-requirements)
8. [Technical Architecture](#8-technical-architecture)
   - 8.5 [Android 13 & 14 Background Execution Constraints](#85-android-13--14-background-execution-constraints)
   - 8.6 [ABI Splits & APK Size Strategy](#86-abi-splits--apk-size-strategy)
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

### 2.2 User Frustrations (Validated Assumptions)

- *"I have XPlayer for videos, Spotify for music, ADM for downloads — why can't one app do everything?"*
- *"XPlayer keeps showing full-screen ads between videos."*
- *"My private videos aren't safe without a proper locked vault."*
- *"Arabic language support in most players is broken or missing."*

### 2.3 Opportunity

The Android media player market is dominated by aging apps with poor UX and heavy monetization. A modern, Flutter-built player with Clean Architecture, full RTL support, and offline-first design represents a clear opportunity to capture a loyal user base in Arab markets.

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
| Day-7 retention | > 45% | Firebase Analytics |
| Day-30 retention | > 35% | Firebase Analytics |
| Crash-free sessions | > 99% | Firebase Crashlytics |
| App cold start time | < 2 seconds | Firebase Performance |
| Video start latency | < 1.5 seconds | In-App Logging |
| Download completion rate | > 90% | In-App Analytics |
| ANR rate | < 0.47% (Play Store threshold) | Play Console |
| APK size | < 50 MB | Build output |

### 3.3 User Success Criteria

- A user can open a video file and start playing within 3 taps from home screen
- A user can download a file from a direct URL in under 30 seconds
- A user can set up biometric lock in under 2 minutes
- A user can cast to Chromecast in under 5 taps

---

## 4. Competitive Analysis

### 4.1 Feature Comparison Matrix

| Feature | **VidMaster** | XPlayer | MX Player | VLC | GOM Player |
|---|:---:|:---:|:---:|:---:|:---:|
| All video formats (FFmpeg) | ✅ | ✅ | ⚠️ Limited | ✅ | ✅ |
| Integrated music player | ✅ | ❌ | ❌ | ✅ Partial | ❌ |
| Internet downloader | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cast / Chromecast | ✅ | ✅ | ✅ | ❌ | ❌ |
| Biometric lock (PIN + FP) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Hidden encrypted vault | ✅ | ❌ | ❌ | ❌ | ❌ |
| Picture-in-Picture | ✅ | ✅ | ✅ | ✅ | ❌ |
| Video sharing | ✅ | ✅ | ✅ | ✅ | ✅ |
| Subtitle auto-detection | ✅ | ✅ | ✅ | ✅ | ✅ |
| Background audio | ✅ | ✅ | ✅ | ✅ | ❌ |
| Arabic RTL UI | ✅ | ❌ | ❌ | ❌ | ❌ |
| 100% Ad-free | ✅ | ❌ (heavy ads) | ❌ (ads) | ✅ | ❌ |
| Offline-first | ✅ | ✅ | ✅ | ✅ | ✅ |
| Equalizer | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gesture controls | ✅ | ✅ | ✅ | ✅ | ✅ |
| Open Source | ❌ | ❌ | ❌ | ✅ | ❌ |

### 4.2 Competitive Positioning

```
                    HIGH FEATURES
                          │
          VidMaster ★     │      VLC
                          │
AD-FREE ──────────────────┼────────────────── AD-HEAVY
                          │
           MX Player      │    XPlayer
                          │
                    LOW FEATURES
```

**VidMaster's Unique Position:** Most feature-complete, ad-free, Arabic-native player.

### 4.3 Competitor Weaknesses to Exploit

| Competitor | Key Weakness | VidMaster Advantage |
|---|---|---|
| XPlayer | Heavy ads, no downloader | Ad-free + integrated downloader |
| MX Player | No downloader, no security | Full downloader + biometric vault |
| VLC | Outdated UI, no downloader | Modern Material 3 UI + downloader |
| GOM Player | Limited formats, no RTL | Full FFmpeg + Arabic RTL |

---

## 5. Target Users & Personas

### 5.1 Persona 1 — Ahmed, The Everyday User 🎬

| Attribute | Detail |
|---|---|
| **Age** | 22–35 |
| **Location** | Egypt, Saudi Arabia, UAE |
| **Education** | University graduate |
| **Device** | Mid-range Android (Samsung A-series, Redmi) |
| **Tech savvy** | Medium |

**Goals:**
- Watch downloaded movies and series without an internet connection
- Listen to music while commuting
- Download video clips from links shared on WhatsApp

**Frustrations:**
- XPlayer shows full-screen ads between episodes
- Needs 3 separate apps for video, music, and downloading
- Arabic UI in most apps is broken or incomplete

**VidMaster Solution:** Single app, no ads, Arabic RTL, offline-first

---

### 5.2 Persona 2 — Sara, The Working Mother 👩‍💼

| Attribute | Detail |
|---|---|
| **Age** | 28–42 |
| **Location** | Egypt, Jordan |
| **Education** | Post-graduate |
| **Device** | Mid-to-high-range Android |
| **Tech savvy** | Low–Medium |

**Goals:**
- Share children's video clips with family via WhatsApp
- Protect private videos from children accessing them
- Cast videos to the TV easily without cables

**Frustrations:**
- Can't password-protect specific videos
- Doesn't know how to use Chromecast reliably
- Complex apps with too many options overwhelm her

**VidMaster Solution:** Biometric vault + simple Chromecast one-tap + PiP while multitasking

---

### 5.3 Persona 3 — Mohamed, The Tech Enthusiast 🎧

| Attribute | Detail |
|---|---|
| **Age** | 18–28 |
| **Location** | Any Arabic country |
| **Education** | Tech-oriented student/professional |
| **Device** | High-end Android (Pixel, Samsung S-series) |
| **Tech savvy** | High |

**Goals:**
- Play rare video formats (MKV, AV1, HEVC, DTS audio)
- Download videos from direct URLs
- Use equalizer for best audio quality
- Modern, fast UI — not VLC's "Linux from 2005" look

**Frustrations:**
- VLC supports all formats but looks ancient
- XPlayer has good UI but no downloader and has ads
- No single app does everything he wants

**VidMaster Solution:** All formats (FFmpeg) + modern Material 3 UI + downloader + equalizer

---

## 6. Functional Requirements

> **Priority Scale:**
> - `P0 – Critical` → MVP blocker, must ship in v1.0
> - `P1 – High` → Important, ship in v1.0 if possible
> - `P2 – Medium` → Nice to have in v1.0, can defer to v1.1
> - `P3 – Low` → Future consideration

---

### 6.1 Video Player

#### 6.1.1 Core Playback Engine

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| VP-01 | Universal Format Support | Play all video formats via FFmpeg: MP4, MKV, AVI, MOV, FLV, WMV, 3GP, WebM, TS, VOB, MPG, HEVC (H.265), AV1, VP8, VP9, H.264, DivX, Xvid | P0 | `media_kit` + FFmpeg |
| VP-02 | Hardware Acceleration | Use GPU decoding when available, fallback to software | P0 | `media_kit` HW decoder |
| VP-03 | Video Resume | Remember last playback position per file, auto-resume on reopen | P0 | Isar DB |
| VP-04 | Playback Speed | Variable speed: 0.25x, 0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x, 3x, 4x | P0 | `media_kit` |
| VP-05 | Background Audio | Audio continues when app goes to background or screen locks | P1 | `audio_service` |
| VP-06 | Auto-Play Next | Automatically play next file in folder/playlist | P1 | Custom logic + Isar |
| VP-07 | Loop Modes | No loop / Loop one / Loop all | P1 | `media_kit` |
| VP-08 | Repeat A-B | Loop a specific segment between two user-defined timestamps | P2 | Custom timer logic |

#### 6.1.2 Playback Controls

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| VC-01 | Gesture: Brightness | Swipe up/down on LEFT half of screen to adjust brightness | P0 | GestureDetector |
| VC-02 | Gesture: Volume | Swipe up/down on RIGHT half of screen to adjust volume | P0 | GestureDetector + volume_controller |
| VC-03 | Gesture: Seek | Swipe left/right anywhere to seek forward/backward | P0 | GestureDetector |
| VC-04 | Double-tap Seek | Double tap left = -10s, double tap right = +10s (configurable) | P0 | GestureDetector |
| VC-05 | Seek Bar | Interactive seek bar with time tooltip showing thumbnail preview | P1 | video_thumbnail |
| VC-06 | Pinch to Zoom | Pinch gesture to zoom/fit video | P1 | Transform widget |
| VC-07 | Long-press Speed | Long press to temporarily play at 2x speed | P2 | GestureDetector |
| VC-08 | Screen Lock | Lock screen to prevent accidental touches during playback | P1 | Overlay widget |
| VC-09 | Volume Boost | Boost volume beyond system maximum (up to 200%) | P2 | media_kit audio processing |

#### 6.1.3 Aspect Ratio & Display

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| AR-01 | Auto Fit | Auto-detect and fit video dimensions | P0 | AspectRatio widget |
| AR-02 | 16:9 | Force 16:9 widescreen | P0 | BoxFit |
| AR-03 | 4:3 | Force 4:3 ratio | P0 | BoxFit |
| AR-04 | Fill Screen | Stretch to fill entire display | P0 | BoxFit.fill |
| AR-05 | Crop Mode | Crop edges to fill with correct ratio | P1 | BoxFit.cover |
| AR-06 | Rotation Lock | Lock/unlock screen rotation | P1 | SystemChrome |

#### 6.1.4 Subtitle Support

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| ST-01 | Auto-detect Subtitle | Auto-load .srt/.ass file with same name as video | P1 | File system matching |
| ST-02 | Manual Load | Browse and select subtitle file manually | P1 | File picker |
| ST-03 | Supported Formats | SRT, ASS, SSA, VTT, SUB, SMI, TTML | P1 | flutter_subtitle_wrapper |
| ST-04 | Text Customization | Font size, color, background opacity, position | P2 | Custom subtitle renderer |
| ST-05 | Embedded Subtitles | Extract and display embedded subtitles from MKV | P2 | media_kit subtitle track |
| ST-06 | Subtitle Delay | Adjust subtitle timing offset (±10 seconds) | P2 | Custom offset logic |
| ST-07 | Multi-track | Select between multiple subtitle tracks | P2 | media_kit track selection |

#### 6.1.5 Audio Tracks

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| AT-01 | Multi-track Audio | Select audio track from multi-language MKV files | P1 | media_kit track selection |
| AT-02 | Audio Delay | Adjust audio sync offset (±10 seconds) | P2 | media_kit |
| AT-03 | Equalizer (Video) | 7-band equalizer during video playback | P2 | just_audio_equalizer bridge |

---

### 6.2 Music Player

#### 6.2.1 Library Management

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| MP-01 | Auto-scan Library | Scan device storage on first launch and on demand | P0 | on_audio_query |
| MP-02 | Songs View | List all songs with title, artist, album, duration | P0 | on_audio_query |
| MP-03 | Albums View | Group songs by album with cover art | P0 | on_audio_query |
| MP-04 | Artists View | Group songs by artist | P0 | on_audio_query |
| MP-05 | Playlists | Create, edit, delete custom playlists | P0 | Isar DB |
| MP-06 | Favorites | Mark songs as favorite with quick-access tab | P1 | Isar DB |
| MP-07 | Recently Played | Track and display last 50 played tracks | P1 | Isar DB |
| MP-08 | Most Played | Sort by play count | P2 | Isar DB |
| MP-09 | Search | Search across songs, albums, artists | P1 | Isar query |
| MP-10 | Sort & Filter | Sort by title, artist, date added, duration | P1 | Isar query |

#### 6.2.2 Playback Features

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| MPB-01 | Background Playback | Audio continues when screen is off or app is minimized. **Requires a persistent Foreground Service with a visible notification** (Android 13+). The service must be declared with `foregroundServiceType="mediaPlayback"` in `AndroidManifest.xml`. | P0 | `audio_service` + Foreground Service |
| MPB-02 | Notification Controls | Play/Pause/Next/Prev/Seek from notification shade. **This notification is mandatory and non-dismissible while audio plays** — by design, not a limitation. Users must be informed of this in onboarding. | P0 | `audio_service` |
| MPB-03 | Lock Screen Controls | Media controls on lock screen | P0 | audio_service |
| MPB-04 | Shuffle Mode | Randomize playback order | P0 | just_audio |
| MPB-05 | Repeat Modes | Off / Repeat All / Repeat One | P0 | just_audio |
| MPB-06 | Crossfade | Smooth transition between tracks (0–10 seconds) | P2 | just_audio |
| MPB-07 | Gapless Playback | No silence between consecutive tracks | P1 | just_audio gapless |
| MPB-08 | Sleep Timer | Auto-stop after: 15, 30, 45, 60, 90 min or end of track | P1 | Timer API |
| MPB-09 | Speed Control | 0.5x – 2x playback speed for music/podcasts | P2 | just_audio |

#### 6.2.3 Now Playing Screen

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| NP-01 | Album Art | Display album artwork, fallback to generated gradient avatar | P0 | on_audio_query + ColorScheme |
| NP-02 | Lyrics Display | Show synced LRC lyrics if available locally | P2 | LRC file parser |
| NP-03 | Seek Bar | Interactive seek with current/total time display | P0 | SliderTheme |
| NP-04 | Mini Player | Persistent bottom bar visible across all screens | P0 | Persistent widget overlay |
| NP-05 | Equalizer Screen | Visual 7-band EQ with presets (Rock, Pop, Classical, etc.) | P2 | just_audio_equalizer |
| NP-06 | Visualizer | Audio waveform/bars animation on Now Playing | P2 | Custom paint |

#### 6.2.4 Supported Audio Formats

MP3, AAC, FLAC, WAV, OGG, WMA, M4A, APE, AIFF, Opus, AC3, DTS, AMR, M3U (playlists)

---

### 6.3 Download Manager

#### 6.3.1 Core Download Features

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| DL-01 | Direct URL Download | Download any direct video/audio URL (MP4, MP3, etc.) with progress bar | P0 | dio + flutter_downloader |
| DL-02 | Resume Downloads | Automatically resume interrupted downloads (supports HTTP Range) | P0 | flutter_downloader |
| DL-03 | Pause/Resume | Manually pause and resume individual downloads | P0 | flutter_downloader |
| DL-04 | Cancel Download | Cancel any active download with confirmation | P0 | flutter_downloader |
| DL-05 | Concurrent Downloads | Up to 3 simultaneous downloads (configurable 1–5) | P1 | WorkManager |
| DL-06 | Download Queue | Queue downloads and process sequentially or in parallel | P1 | flutter_downloader queue |
| DL-07 | File Naming | Auto-detect filename from URL/headers, allow rename before download | P1 | dio response headers |
| DL-08 | Format Detection | Auto-detect file type from Content-Type header | P1 | dio |
| DL-09 | Storage Selection | Choose download destination folder | P1 | path_provider + file_picker |

#### 6.3.2 Progress & Notifications

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| DN-01 | Progress Notification | Show individual download progress in notification shade | P0 | flutter_local_notifications |
| DN-02 | Completion Notification | Notify when download completes with quick-play action | P1 | flutter_local_notifications |
| DN-03 | Error Notification | Show error with retry option if download fails | P1 | flutter_local_notifications |
| DN-04 | Download Speed | Display real-time download speed (MB/s) | P2 | dio progress callback |
| DN-05 | ETA Display | Estimated time remaining for active downloads | P2 | Calculated from speed |

#### 6.3.3 Download History & Management

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| DH-01 | Download History | List all completed downloads with date, size, format | P0 | Isar DB |
| DH-02 | Delete Download | Delete file from storage and history | P0 | File API + Isar |
| DH-03 | Share Downloaded File | Share directly from downloads list | P1 | share_plus |
| DH-04 | Play Downloaded File | One-tap to play downloaded media | P0 | Navigator |
| DH-05 | Storage Stats | Show total storage used by downloaded files | P2 | File system API |

#### 6.3.4 Download Constraints

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| DC-01 | Wi-Fi Only Mode | Option to download only on Wi-Fi (save mobile data) | P1 | connectivity_plus |
| DC-02 | Background Downloads | Downloads continue when app is minimized. **Must run as a Foreground Service with `foregroundServiceType="dataSync"` in Android 14+.** A persistent notification showing download progress is mandatory — this is also a good UX signal to users. Do NOT request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` as it is a Play Store policy violation without strong justification. | P0 | `WorkManager` + Foreground Service |
| DC-03 | Boot Resume | Resume pending downloads after device restart | P1 | RECEIVE_BOOT_COMPLETED |

---

### 6.4 Security & Privacy

#### 6.4.1 App Lock

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| SEC-01 | Fingerprint Lock | Lock entire app with fingerprint on resume | P0 | local_auth |
| SEC-02 | Face ID Lock | Lock with face recognition (Android Face Unlock) | P0 | local_auth |
| SEC-03 | PIN Lock | 4–6 digit PIN as primary or fallback to biometric | P0 | flutter_secure_storage |
| SEC-04 | Pattern Lock | Android-style pattern unlock | P2 | pattern_lock package |
| SEC-05 | Auto-Lock Timeout | Configure lock trigger: immediately / 30s / 1min / 5min | P1 | Timer + WidgetsBindingObserver |
| SEC-06 | Failed Attempts | Lock for increasing duration after 5 failed PIN attempts | P1 | flutter_secure_storage counter |
| SEC-07 | Lock on Background | Lock when app moves to background | P1 | AppLifecycleState |

#### 6.4.2 Hidden Vault

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| HV-01 | Move to Vault | Move selected videos to encrypted vault. The original file is **encrypted in-place on storage** as a `.enc` file, then moved to a hidden `/vault/` directory. The original file is deleted from its source location. | P1 | File API + AES-256-GCM |
| HV-02 | Vault Encryption | **Do NOT store full video files inside Hive** — this would load GBs into RAM. Instead: encrypt each file as a standalone `.enc` file on disk using AES-256-GCM. Store only the encryption key (wrapped with user PIN), IV, and file metadata inside `Hive`. This supports files of any size with constant RAM usage. | P1 | `crypto` + `Hive` (metadata only) |
| HV-03 | Vault Unlock | Separate biometric/PIN for vault (can differ from app lock) | P1 | local_auth |
| HV-04 | Stealth Mode | Vault appears as a system utility (calculator disguise) | P2 | Custom disguise screen |
| HV-05 | Move Out of Vault | Restore files to original location | P1 | File API + Hive |
| HV-06 | Vault Snapshots | Warn if someone takes a screenshot while in vault | P2 | FLAG_SECURE |

#### 6.4.3 Privacy Features

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| PV-01 | No Analytics | Zero telemetry — no data sent to any server | P0 | Architecture decision |
| PV-02 | No Account Required | Fully functional without login or registration | P0 | Architecture decision |
| PV-03 | Screen Security | Prevent screenshots/screen recording (vault only) | P1 | FLAG_SECURE |
| PV-04 | Clear History | Clear watch history, download history, search history | P1 | Isar DB operations |
| PV-05 | Incognito Mode | Watch without saving to history | P2 | Session-only playback |

---

### 6.5 Cast / Chromecast

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| CC-01 | Device Discovery | Scan and list all available Chromecast devices on local network | P0 | flutter_cast_framework |
| CC-02 | Cast Video | Cast currently playing video to selected Chromecast device | P0 | flutter_cast_framework |
| CC-03 | Remote Control | Play, Pause, Seek, Volume from phone while casting | P0 | Cast SDK |
| CC-04 | Cast Queue | Queue multiple videos for casting | P1 | Cast SDK queue |
| CC-05 | Cast Status Badge | Show casting indicator in top bar and player | P0 | Custom widget |
| CC-06 | Disconnect | One-tap to stop casting and return to phone | P0 | Cast SDK |
| CC-07 | Volume Sync | Sync phone volume with TV during cast | P1 | Cast SDK |
| CC-08 | Subtitle on Cast | Send subtitle track to display on TV | P2 | Cast SDK + subtitle track |

---

### 6.6 Picture-in-Picture (PiP)

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| PIP-01 | Auto-trigger PiP | Enter PiP automatically when pressing back during video | P0 | Platform Channel (Android) |
| PIP-02 | Manual PiP Button | PiP button in player controls | P0 | PiP icon + Platform Channel |
| PIP-03 | PiP Controls | Play/Pause from within PiP window | P0 | Android PiP Actions |
| PIP-04 | Resizable Window | PiP window follows Android system resize behavior | P1 | Android PiP API |
| PIP-05 | Auto PiP on Home | Enter PiP when pressing Home button | P1 | onUserLeaveHint override |
| PIP-06 | PiP for Music | Show mini music controls in PiP while other apps are open | P2 | Android PiP |
| PIP-07 | Min Android Version | PiP requires Android 8.0 (API 26) minimum | P0 | Build config |

---

### 6.7 Video Sharing

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| SH-01 | Share File | Share video file directly via native Android share sheet | P0 | share_plus |
| SH-02 | Share via WhatsApp | Quick-share button for WhatsApp (most popular in target market) | P1 | share_plus with intent |
| SH-03 | Share via Telegram | Quick-share to Telegram | P1 | share_plus with intent |
| SH-04 | Copy File Path | Copy file path to clipboard | P2 | Clipboard API |
| SH-05 | Export Clip | Export a specific time range as a new video file | P3 | FFmpeg command |
| SH-06 | Share Screenshot | Capture and share a still frame from the video | P2 | media_kit frame capture |

---

### 6.8 File Browser & Library

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| FB-01 | File Browser | Browse device storage folders and subfolders | P0 | permission_handler + Directory API |
| FB-02 | Video Library | Show all videos grouped by folder | P0 | MediaStore query |
| FB-03 | Grid/List View | Toggle between thumbnail grid and list view | P0 | Custom toggle |
| FB-04 | Thumbnail Generation | Auto-generate video thumbnails | P0 | video_thumbnail |
| FB-05 | Search | Search all videos/audio by filename | P1 | Isar query |
| FB-06 | Sort Options | Sort by name, date, size, duration | P1 | Isar query |
| FB-07 | Recent Files | Show recently played files section | P1 | Isar DB |
| FB-08 | File Details | Long-press for: file size, format, resolution, bitrate, duration | P1 | media_info |
| FB-09 | Multi-select | Select multiple files for batch operations | P2 | Custom state |
| FB-10 | Batch Delete | Delete multiple files at once | P2 | File API |
| FB-11 | Folder Bookmarks | Pin favorite folders to home screen | P2 | Isar DB |

---

### 6.9 Settings & Preferences

| ID | Feature | Description | Priority | Implementation |
|---|---|---|---|---|
| ST-01 | Language | Arabic / English (auto-detect from system) | P0 | flutter_localizations |
| ST-02 | Theme | Dark (default) / Light / System | P0 | ThemeMode |
| ST-03 | Default Seek Duration | Configure double-tap seek seconds (5s / 10s / 15s / 30s) | P1 | SharedPreferences |
| ST-04 | Auto-rotate | Enable/disable auto screen rotation during video | P1 | SystemChrome |
| ST-05 | Subtitle Default Font Size | Set default subtitle size | P2 | SharedPreferences |
| ST-06 | Download Path | Configure default download folder | P1 | path_provider |
| ST-07 | Concurrent Downloads | Set max concurrent downloads (1–5) | P1 | SharedPreferences |
| ST-08 | Wi-Fi Only Downloads | Toggle mobile data restriction for downloads | P1 | connectivity_plus |
| ST-09 | Auto-lock Timeout | When to trigger app lock | P1 | SharedPreferences |
| ST-10 | Show Hidden Files | Toggle visibility of dot-files | P2 | File filter logic |
| ST-11 | Playback Resume | Enable/disable auto-resume from last position | P1 | SharedPreferences |
| ST-12 | PiP Behavior | Auto PiP on back / on home / manual only | P1 | SharedPreferences |

---

## 7. Non-Functional Requirements

### 7.1 Performance

| Requirement | Target | Rationale |
|---|---|---|
| Cold start time | < 2 seconds | User expectation for media apps |
| Video start latency | < 1.5 seconds from tap to playback | Core UX |
| RAM usage (idle) | < 80 MB | Background friendliness |
| RAM usage (1080p playback) | < 200 MB | Mid-range device support |
| RAM usage (4K playback) | < 350 MB | Flagship device support |
| Frame rate during playback | Stable 60fps UI overlay | No jank |
| APK size | < 50 MB | Install conversion rate |
| Battery drain (background music) | < 2% per hour | User retention |
| Thumbnail generation time | < 500ms per video | Smooth library loading |
| Search response time | < 200ms | Instant feel |

### 7.2 Reliability

| Requirement | Target |
|---|---|
| Crash-free rate | > 99.0% |
| ANR rate | < 0.47% (Play Store threshold) |
| Download completion rate | > 90% on stable connection |
| Data loss on crash | Zero (auto-save every 30 seconds) |
| Corrupt Isar recovery | Auto-rebuild database if schema corrupted |

### 7.3 Compatibility

| Requirement | Specification |
|---|---|
| Minimum Android version | Android 8.0 (API 26) — required for PiP and Biometric |
| Target Android version | Android 14 (API 34) |
| Compile SDK | API 34 |
| Screen sizes | 4.5" – 7" (phone), partial tablet support |
| Screen densities | mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi |
| Orientations | Portrait (UI), Landscape (video playback) |
| 64-bit | Required (Google Play requirement since 2019) |
| ABI Splits | arm64-v8a, armeabi-v7a, x86_64 |

### 7.4 Accessibility

| Requirement | Specification |
|---|---|
| Text scaling | Support system font scale up to 1.3x |
| Color contrast | WCAG AA compliant (4.5:1 ratio) |
| Touch targets | Minimum 48x48dp for all interactive elements |
| Screen reader | Basic TalkBack support for navigation |
| RTL mirroring | All icons and layouts flip correctly in Arabic |

### 7.5 Localization

| Requirement | Detail |
|---|---|
| Languages | Arabic (ar), English (en) |
| Locale detection | Auto-detect from device settings |
| RTL support | Full layout mirroring for Arabic |
| Date/time format | Locale-aware formatting |
| Number format | Locale-aware (Arabic-Indic numerals optional) |
| String management | ARB files per locale in `/lib/core/localization/` |

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

### 8.2 Folder Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   ├── localization/
│   │   ├── app_en.arb
│   │   ├── app_ar.arb
│   │   └── l10n.dart
│   ├── router/
│   │   └── app_router.dart          # go_router configuration
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── supported_formats.dart
│   └── utils/
│       ├── file_utils.dart
│       ├── duration_formatter.dart
│       └── size_formatter.dart
│
├── features/
│   ├── video_player/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── media_kit_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── video_model.dart
│   │   │   └── repositories/
│   │   │       └── video_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── video.dart
│   │   │   ├── repositories/
│   │   │   │   └── video_repository.dart
│   │   │   └── usecases/
│   │   │       ├── play_video.dart
│   │   │       ├── pause_video.dart
│   │   │       ├── seek_video.dart
│   │   │       └── get_video_thumbnail.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── video_player_provider.dart
│   │       │   └── video_library_provider.dart
│   │       ├── screens/
│   │       │   ├── video_library_screen.dart
│   │       │   └── video_player_screen.dart
│   │       └── widgets/
│   │           ├── player_controls.dart
│   │           ├── gesture_detector_overlay.dart
│   │           ├── brightness_indicator.dart
│   │           ├── volume_indicator.dart
│   │           └── subtitle_overlay.dart
│   │
│   ├── music_player/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── music_library_screen.dart
│   │       │   └── now_playing_screen.dart
│   │       └── widgets/
│   │           └── mini_player_bar.dart
│   │
│   ├── downloader/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── downloads_screen.dart
│   │       └── widgets/
│   │           └── download_item_tile.dart
│   │
│   ├── security/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── lock_screen.dart
│   │       │   └── vault_screen.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── cast/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       └── widgets/
│   │           └── cast_button.dart
│   │
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart
│
└── main.dart
```

### 8.3 Tech Stack

| Layer | Package | Version | Purpose |
|---|---|---|---|
| **Video Engine** | media_kit | ^1.1.11 | FFmpeg-based universal player |
| **Video UI** | media_kit_video | ^1.2.5 | Video widget + controls |
| **Music Playback** | just_audio | ^0.9.38 | High-quality audio engine |
| **Music BG Service** | audio_service | ^0.18.14 | Background + notification |
| **Music Library** | on_audio_query | ^2.9.0 | MediaStore query |
| **Downloader** | flutter_downloader | ^1.11.6 | WorkManager-based downloader |
| **HTTP Client** | dio | ^5.4.3+1 | Download + API calls |
| **State Management** | flutter_riverpod | ^2.5.1 | Clean state management |
| **Database** | isar | ^3.1.0+1 | Fast offline database |
| **Biometrics** | local_auth | ^2.2.0 | Fingerprint + Face ID |
| **Secure Storage** | flutter_secure_storage | ^9.0.0 | PIN + encrypted prefs |
| **Vault Encryption** | hive_flutter | ^1.1.0 | **Metadata + keys only** (never full video files) |
| **Navigation** | go_router | ^13.2.1 | Declarative routing |
| **Permissions** | permission_handler | ^11.3.1 | Runtime permissions |
| **Sharing** | share_plus | ^7.2.2 | Native share sheet |
| **Notifications** | flutter_local_notifications | ^17.1.2 | Download notifications |
| **Subtitle** | flutter_subtitle_wrapper | ^0.0.4 | Subtitle rendering |
| **Thumbnails** | video_thumbnail | ^0.5.3 | Thumbnail generation |
| **Connectivity** | connectivity_plus | ^5.0.2 | Network state detection |
| **Chromecast** | flutter_cast_framework | ^0.3.0 | Cast SDK bridge |

### 8.5 Android 13 & 14 Background Execution Constraints

> ⚠️ **This is one of the most critical implementation challenges in the entire project.** Android 13 and 14 have significantly tightened background execution policies via **Doze Mode**, **App Standby Buckets**, and **Foreground Service type enforcement**. Ignoring these will cause silent failures in production.

#### Background Audio (Music Player)

| Issue | Android Behavior | VidMaster Solution |
|---|---|---|
| Audio killed in background | Doze Mode kills background processes after ~1 min | Use `audio_service` which wraps a proper `MediaBrowserServiceCompat` Foreground Service |
| Notification required | Android 13+ requires `POST_NOTIFICATIONS` permission at runtime | Request permission on first launch with explanation dialog |
| Service type enforcement | Android 14 requires `foregroundServiceType` declared in manifest | Declare `android:foregroundServiceType="mediaPlayback"` |
| Battery optimization | System may stop the service anyway on aggressive OEMs (Xiaomi, Samsung) | Show a one-time prompt guiding users to exempt the app in battery settings — **do NOT request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` programmatically** |

**AndroidManifest.xml entry (audio):**
```xml
<service
    android:name="com.ryanheise.audioservice.AudioServiceFragmentActivity"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>
```

#### Background Downloads (Download Manager)

| Issue | Android Behavior | VidMaster Solution |
|---|---|---|
| Downloads killed | WorkManager jobs deferred/killed under Doze | Use `flutter_downloader` which runs a Foreground Service, not a bare WorkManager job |
| Service type enforcement | Android 14 requires `foregroundServiceType="dataSync"` | Declare it explicitly in manifest |
| Persistent notification | Required for any Foreground Service in Android 8+ | Show per-download progress notification — this is also **a good UX feature**, not a limitation |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Google Play **may reject the app** if this permission is requested without strong justification (e.g., VoIP, alarm apps) | **Do not request this permission.** Rely on Foreground Services instead. |

**AndroidManifest.xml entry (downloader):**
```xml
<service
    android:name="vn.hunghd.flutterdownloader.DownloadTaskService"
    android:foregroundServiceType="dataSync"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="false" />
```

#### OEM Battery Optimization (Samsung OneUI / Xiaomi MIUI)

Some OEMs (especially Xiaomi/MIUI) kill Foreground Services even with the proper declarations. The recommended approach:

1. **Detect OEM** at runtime using `Build.MANUFACTURER`
2. **Show a targeted prompt** directing users to the correct battery settings screen per OEM
3. Use the `battery_optimization_handler` package or a custom Platform Channel to deep-link to the correct settings page
4. **Do not make this mandatory** — show it once, respect the user's choice

---

### 8.6 ABI Splits & APK Size Strategy

> ⚠️ `media_kit` bundles FFmpeg native libraries for multiple CPU architectures. Without ABI splits, the APK includes ALL architectures simultaneously — pushing size to 150–200 MB.

**Strategy: Android App Bundle (.aab) + ABI Splits**

**`android/app/build.gradle` configuration:**
```groovy
android {
    ...
    splits {
        abi {
            enable true
            reset()
            include "arm64-v8a", "armeabi-v7a", "x86_64"
            universalApk false   // Do NOT generate a fat universal APK
        }
    }

    // Assign different version codes per ABI to satisfy Play Store
    ext.abiCodes = ["armeabi-v7a": 1, "arm64-v8a": 2, "x86_64": 3]

    android.applicationVariants.configureEach { variant ->
        variant.outputs.each { output ->
            def baseAbiVersionCode =
                project.ext.abiCodes.get(output.getFilter(OutputFile.ABI))
            if (baseAbiVersionCode != null) {
                output.versionCodeOverride =
                    baseAbiVersionCode * 1000 + variant.versionCode
            }
        }
    }
}
```

**Expected APK sizes per ABI:**

| ABI | Target Devices | Expected APK Size |
|---|---|---|
| `arm64-v8a` | All modern Android phones (2018+) | ~40–48 MB |
| `armeabi-v7a` | Older 32-bit devices (Android 8/9 era) | ~35–42 MB |
| `x86_64` | Emulators, some Chromebooks | ~45–52 MB |
| ~~Universal APK~~ | ~~All devices~~ | ~~150–200 MB~~ ❌ |

**Recommended upload:** Use `.aab` (Android App Bundle) for Play Store — Google Play generates and serves the correct split automatically per device. This also enables Play Feature Delivery if needed in the future.



```dart
// Feature-scoped providers
// video_player_provider.dart

@riverpod
class VideoPlayerNotifier extends _$VideoPlayerNotifier {
  @override
  VideoPlayerState build() => VideoPlayerState.initial();

  Future<void> playVideo(VideoEntity video) async {
    state = state.copyWith(status: PlaybackStatus.loading);
    final result = await ref.read(playVideoUseCaseProvider).call(video);
    result.fold(
      (failure) => state = state.copyWith(status: PlaybackStatus.error, failure: failure),
      (_) => state = state.copyWith(status: PlaybackStatus.playing, currentVideo: video),
    );
  }
}
```

---

## 9. UI/UX Requirements

### 9.1 Design System

| Token | Value |
|---|---|
| **Primary Color** | `#1565C0` (Deep Blue) |
| **Secondary Color** | `#F9A825` (Amber Gold) |
| **Background Dark** | `#0D1B2A` |
| **Surface Dark** | `#1C2B3A` |
| **Background Light** | `#F5F7FA` |
| **Typography** | Cairo (Arabic), Roboto (English) |
| **Design System** | Material 3 |
| **Border Radius** | 12dp (cards), 8dp (buttons), 16dp (bottom sheets) |
| **Elevation** | Material You dynamic shadows |

### 9.2 Navigation Structure

```
Bottom Navigation Bar (4 tabs):
├── 🎬 Videos          → VideoLibraryScreen
├── 🎵 Music           → MusicLibraryScreen
├── ⬇️ Downloads       → DownloadsScreen
└── ⚙️ Settings        → SettingsScreen

Modal Navigation:
├── VideoPlayerScreen  (full-screen, pushed over nav)
├── NowPlayingScreen   (music player, pushed over nav)
├── LockScreen         (over everything, no back)
└── VaultScreen        (locked section)

Persistent:
└── MiniPlayerBar      (bottom of screen, above nav bar)
```

### 9.3 Key Screen Specifications

#### Video Player Screen
- Full-screen immersive mode (hide status bar + nav bar)
- 3-layer overlay: Background (video), Controls (fade in/out), System (brightness/volume indicator)
- Controls auto-hide after 3 seconds of no interaction
- Top bar: Back, Title, Cast, PiP, More options
- Bottom bar: Seek bar, Time, Speed, Fullscreen toggle
- Center: Play/Pause, -10s, +10s

#### Music Now Playing Screen
- Large album art (60% of screen height)
- Blurred background derived from album art colors
- Animated progress ring around album art
- Controls: Shuffle, Previous, Play/Pause, Next, Repeat
- Bottom sheet expanders: Equalizer, Sleep Timer, Lyrics

#### Download Dialog
- URL input field (paste from clipboard auto-detected)
- File name (editable)
- Estimated size (fetched from Content-Length header)
- Download location selector
- Start Download button

### 9.4 Animation Specifications

| Animation | Duration | Curve |
|---|---|---|
| Screen transitions | 300ms | easeInOut |
| Player controls fade | 200ms | easeOut |
| Mini player slide up | 250ms | easeOut |
| Thumbnail load | Shimmer effect | Continuous |
| PiP transition | System-controlled | Android system |
| Tab switching | 200ms | easeIn |

### 9.5 RTL/LTR Behavior

| Element | LTR (English) | RTL (Arabic) |
|---|---|---|
| Navigation icons | Left-to-right | Mirrored |
| Seek bar | Left = start, Right = end | Right = start, Left = end |
| Brightness gesture | Left half = brightness | Right half = brightness |
| Volume gesture | Right half = volume | Left half = volume |
| Text alignment | Start (left) | Start (right) |
| Icons (forward/back) | → forward, ← back | ← forward, → back |

---

## 10. Data Models

### 10.1 Isar Schemas

```dart
@collection
class VideoEntity {
  Id id = Isar.autoIncrement;
  late String filePath;
  late String fileName;
  String? thumbnailPath;
  int? duration;          // in milliseconds
  int? lastPosition;      // resume position in ms
  int? fileSize;          // bytes
  String? resolution;     // e.g. "1920x1080"
  DateTime? lastPlayed;
  int playCount = 0;
  bool isFavorite = false;
  bool isInVault = false;
}

@collection
class DownloadTask {
  Id id = Isar.autoIncrement;
  late String taskId;     // flutter_downloader task ID
  late String url;
  late String fileName;
  late String savePath;
  late DownloadStatus status;
  int progress = 0;       // 0–100
  int? fileSize;
  DateTime? createdAt;
  DateTime? completedAt;
  String? errorMessage;
}

@collection
class AudioTrack {
  Id id = Isar.autoIncrement;
  late String filePath;
  String? title;
  String? artist;
  String? album;
  String? albumArtPath;
  int? duration;
  int? trackNumber;
  DateTime? lastPlayed;
  int playCount = 0;
  bool isFavorite = false;
}

@collection
class Playlist {
  Id id = Isar.autoIncrement;
  late String name;
  late DateTime createdAt;
  late List<int> trackIds;   // AudioTrack IDs
  String? coverPath;
}
```

---

## 11. API & Integrations

### 11.1 Download URL Validation

Before downloading, validate the URL:

1. Send `HEAD` request to URL
2. Check `Content-Type` header (video/*, audio/*)
3. Read `Content-Length` for size display
4. Read `Content-Disposition` for filename suggestion
5. Check `Accept-Ranges: bytes` for resume support

### 11.2 Chromecast Integration

```
App → flutter_cast_framework → Cast SDK → Chromecast Device
                                    ↓
                           Google Cast Protocol
                                    ↓
                          Video URL streamed to TV
```

The phone acts as a **remote control** — it sends the video URL directly to the Chromecast, which fetches and plays the video independently.

### 11.3 Android Platform Channels

| Channel | Purpose | Direction |
|---|---|---|
| `vidmaster/pip` | Enter/exit PiP mode | Flutter → Android |
| `vidmaster/brightness` | Set screen brightness | Flutter → Android |
| `vidmaster/volume_boost` | Boost beyond system max | Flutter → Android |
| `vidmaster/secure_flag` | Enable FLAG_SECURE | Flutter → Android |

---

## 12. Security Architecture

### 12.1 Authentication Flow

```
App Launch
    │
    ▼
Is Lock Enabled?
    │
   YES ──────────────────────────────► Show LockScreen
    │                                        │
    NO                                  Biometric available?
    │                                        │
    ▼                                   YES ─┤ NO
  Home Screen                          FP/Face  PIN Input
                                          │       │
                                       Success  Correct?
                                          │       │
                                          └───────┘
                                               │
                                           Home Screen
```

### 12.2 Vault Encryption

> ⚠️ **Critical Design Decision:** Never store full video files inside Hive or any in-memory DB. A 1 GB video encrypted into Hive would require loading 1 GB into RAM — causing an OOM crash on most Android devices.

**Correct approach — File-based encryption:**

```
User moves file to vault:
    │
    ▼
Generate unique 256-bit key per file (SecureRandom)
    │
    ▼
Generate unique 96-bit IV (GCM nonce) per file
    │
    ▼
Encrypt file with AES-256-GCM using streaming cipher
(reads source file in 4MB chunks → writes to .enc file)
    │
    ▼
Store encrypted .enc file in /data/user/0/<pkg>/vault/
(app-private, inaccessible without root)
    │
    ▼
Wrap file key with user's PIN via PBKDF2(PIN, salt, 200,000 iterations)
    │
    ▼
Store in Hive encrypted box:
  {
    encFileName: "abc123.enc",
    originalName: "my_video.mp4",
    wrappedKey: "<key encrypted with PIN-derived key>",
    iv: "<96-bit nonce>",
    salt: "<PBKDF2 salt>",
    fileSize: 1073741824,
    mimeType: "video/mp4"
  }

Source file is securely deleted (overwrite + delete)
```

**RAM impact:** Constant ~4 MB regardless of file size (streaming chunks).

### 12.3 PIN Storage

- PIN is hashed with `bcrypt` (cost factor 12) before storage
- Stored in `flutter_secure_storage` (Android Keystore backed)
- Never stored in plain text or SharedPreferences

---

## 13. Testing Strategy

### 13.1 Testing Pyramid

| Layer | Coverage Target | Tools |
|---|---|---|
| Unit Tests (Domain) | > 80% | `flutter_test` + `mocktail` |
| Unit Tests (Data) | > 70% | `flutter_test` + `mocktail` |
| Widget Tests | Key screens | `flutter_test` |
| Integration Tests | Critical flows | `integration_test` |
| Manual QA | All features | Physical devices |

### 13.2 Critical Test Cases

| Test Suite | Test Cases |
|---|---|
| Video Playback | Play MP4, MKV, AVI, HEVC; Resume from position; Subtitle load |
| Audio Engine | Play MP3, FLAC; Background continues; Notification controls |
| Downloader | Start download; Pause/Resume; Error handling; Wi-Fi only mode |
| Security | PIN setup; Biometric unlock; Failed attempts lockout; Vault encrypt/decrypt |
| Chromecast | Device discovery; Start casting; Stop casting |
| PiP | Trigger on back; Controls work; Dismiss PiP |
| RTL | All screens flip correctly; Seek bar direction; Gesture sides swap |

### 13.3 Devices for QA Testing

| Device | Reason |
|---|---|
| Samsung Galaxy A23 | Most popular mid-range in Egypt/Arab markets |
| Redmi Note 12 | Popular budget device |
| Samsung Galaxy S22 | High-end benchmark |
| Android Emulator (API 26) | Minimum SDK testing |
| Android Emulator (API 34) | Target SDK testing |

---

## 14. Development Roadmap

### Phase Overview

| Phase | Duration | Focus | Milestone |
|---|---|---|---|
| **Phase 1** | Weeks 1–2 | Project setup + Clean Architecture scaffolding | Foundation |
| **Phase 2** | Weeks 3–4 | Core Video Player (all formats, gestures, subtitles) | MVP Video |
| **Phase 3** | Weeks 5–6 | Music Player (library, background, equalizer) | MVP Audio |
| **Phase 4** | Weeks 7–8 | Download Manager (direct URLs, notifications, history) | MVP Download |
| **Phase 5** | Week 9 | Security (PIN lock, biometric, hidden vault) | MVP Security |
| **Phase 6** | Week 10 | Cast / Chromecast + Picture-in-Picture | MVP Cast |
| **Phase 7** | Week 11 | Video Sharing + File Browser polish + RTL refinement | Feature Complete |
| **Phase 8** | Week 12 | Testing + Bug fixes + Play Store submission | Release |

### Phase 1 — Foundation (Weeks 1–2)

- [x] Flutter project setup with Clean Architecture folder structure
- [x] Riverpod + Isar configuration
- [x] go_router navigation setup
- [x] Bottom Navigation Bar with 4 tabs
- [x] Dark/Light theme setup (Material 3)
- [x] Arabic/English localization (ARB files)
- [~] RTL/LTR switching logic *(ARB files exist with ar/en, but no runtime switch in Settings yet)*
- [~] Permissions handling (storage, notifications) *(permission_handler in pubspec, no runtime flow yet)*
- [ ] CI/CD pipeline (GitHub Actions)

### Phase 2 — Core Video Player (Weeks 3–4)

- [x] `media_kit` integration + FFmpeg build
- [x] VideoLibraryScreen with thumbnails grid
- [x] VideoPlayerScreen with full controls
- [x] Gesture controls (brightness, volume, seek)
- [x] Playback speed control
- [x] Subtitle loading (SRT, ASS, VTT)
- [~] Aspect ratio switching *(not found in player controls UI)*
- [x] Resume from last position (Isar)
- [x] Auto-play next in folder

### Phase 3 — Music Player (Weeks 5–6)

- [x] `just_audio` + `audio_service` integration
- [x] `on_audio_query` library scan
- [x] Songs, Albums, Artists tabs
- [x] Playlist creation and management
- [x] NowPlayingScreen with album art
- [x] MiniPlayerBar (persistent)
- [x] Consolidated MusicLibraryNotifier & State (Merged from PlayerProvider)
- [~] Notification + lock screen controls *(audio_service configured, not fully wired)*
- [x] Shuffle and repeat modes
- [x] Sleep timer
- [ ] Basic equalizer (7-band) *(just_audio_equalizer commented out in pubspec)*

### Phase 4 — Download Manager (Weeks 7–8)

- [x] `dio` + `flutter_downloader` integration
- [x] URL input dialog with validation
- [x] Active downloads list with progress
- [x] Pause/Resume/Cancel controls
- [x] Download history (Isar)
- [~] Notification per download *(flutter_local_notifications in pubspec, not wired in provider)*
- [~] Wi-Fi only mode *(field exists in entity, no UI toggle)*
- [ ] Boot resume via RECEIVE_BOOT_COMPLETED

### Phase 5 — Security (Week 9)

- [x] `local_auth` biometric integration
- [x] PIN setup screen
- [x] App lock on resume *(LockScreen + AppAuthNotifier implemented)*
- [~] Auto-lock timeout setting *(setting tile exists in UI, no logic wired)*
- [x] Failed attempts lockout *(AuthState tracks failedAttempts + lockoutUntil)*
- [x] Hidden Vault (Hive encrypted) *(vault_repository_impl + file_encryption_data_source)*
- [x] Move to/from vault flow *(EncryptAndMoveToVault + DecryptAndRestoreFromVault usecases)*
- [~] FLAG_SECURE for vault screen *(not implemented yet)*

### Phase 6 — Cast & PiP (Week 10)

- [ ] `flutter_cast_framework` setup *(commented out in pubspec, cast feature folder is empty)*
- [ ] Cast device discovery screen
- [~] Cast button in player *(icon exists in TopBar, no actual cast logic)*
- [ ] Remote controls during cast
- [x] PiP Platform Channel (Android) *(MethodChannel 'vidmaster/pip' used in player screen)*
- [~] Auto-PiP on back button *(channel call exists, no onUserLeaveHint native side verified)*
- [~] PiP play/pause controls *(depends on native Android PiP actions, not verified)*

### Phase 7 — Polish (Week 11)

- [~] Video sharing (share_plus) *(package in pubspec, no share button in library UI)*
- [~] File browser improvements *(folders tab exists with basic listing)*
- [~] Search across all content *(search field in VideoLibraryState, basic filter logic)*
- [x] Settings screen (all preferences) *(SettingsScreen with all sections, not wired to state)*
- [ ] RTL refinement pass
- [ ] Onboarding flow (first launch)
- [ ] Performance optimization pass
- [ ] Memory leak audit

### Phase 8 — Release (Week 12)

- [ ] Unit tests for all use cases
- [ ] Widget tests for key screens
- [ ] Integration test for critical flows
- [ ] QA on 3 physical devices
- [ ] ProGuard rules
- [ ] App signing configuration
- [ ] Play Store listing (screenshots, description AR/EN)
- [ ] Privacy policy page
- [ ] Google Play submission

---

## 15. Risk Register

| ID | Risk | Probability | Impact | Mitigation Strategy |
|---|---|---|---|---|
| R01 | FFmpeg license issues with Play Store | Low | Critical | Use `media_kit` which handles LGPL compliance; document license compliance in submission |
| R02 | Large APK size due to FFmpeg libs | **Certain without mitigation** | High | **Must** use `.aab` + ABI splits in `build.gradle`; never upload a universal APK. See §8.6. |
| R03 | Chromecast SDK complexity / outdated bridge | Medium | High | Prototype in Phase 1 spike; have fallback to basic local streaming |
| R04 | Background service killed on OEM devices (Xiaomi, Samsung) | **High** | **High** | Foreground Services with correct `foregroundServiceType`; guide users to OEM battery settings per-manufacturer. **Do NOT request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`** — Play Store may reject. See §8.5. |
| R05 | `flutter_downloader` WorkManager conflicts on Android 14 | Medium | High | Declare `foregroundServiceType="dataSync"` in manifest; test on Android 14 emulator early |
| R06 | Vault RAM crash when encrypting large files (1GB+) | **Certain if Hive stores files** | Critical | **Encrypt files as `.enc` on disk (streaming, 4MB chunks); store only keys + metadata in Hive.** See §12.2. |
| R07 | Biometric API inconsistencies across devices | Medium | Low | Always provide PIN fallback; test on 3+ device types |
| R08 | Android 14 media permission changes (`READ_MEDIA_VIDEO`) | Medium | High | Use `READ_MEDIA_VIDEO` + `READ_MEDIA_AUDIO` (API 33+) with `READ_EXTERNAL_STORAGE` legacy fallback for API ≤ 32 |
| R09 | PiP not working on all OEMs | Low | Medium | Test on Samsung (OneUI), Xiaomi (MIUI), stock Android; provide manual PiP only fallback |
| R10 | 12-week timeline overrun | Medium | Medium | Phase 6 (Cast+PiP) can defer to v1.1 without blocking Play Store launch |
| R11 | Isar migration issues | Low | Medium | Lock Isar version; write migration script between schema versions |

---

## 16. Out of Scope (v1.0)

The following features are **explicitly excluded** from v1.0 to maintain timeline and focus:

| Feature | Reason for Exclusion | Target Version |
|---|---|---|
| YouTube / social media downloading | Legal complexity (terms of service); yt-dlp integration requires extensive testing | v2.0 |
| Automatic subtitle translation | Requires external translation API, adds cost and privacy concerns | v2.0 |
| iOS version | Requires separate Chromecast, biometric, and PiP platform work | v2.0 |
| Cloud backup / sync | Goes against offline-first privacy philosophy; needs account system | v3.0 |
| Live streaming / IPTV (M3U) | Different product category; complex DRM handling | v2.0 |
| Video editor (trim, crop, merge) | FFmpeg command-line complexity; separate feature category | v2.0 |
| Built-in browser | Not core to media player; security implications | Not planned |
| Torrent download | Legal risks in target markets | Not planned |
| In-app purchases | App is fully free | Not planned |

---

## 17. Appendix

### 17.1 Supported Video Formats

| Category | Formats |
|---|---|
| **Container** | MP4, MKV, AVI, MOV, WMV, FLV, 3GP, WebM, TS, M2TS, VOB, MPG, MPEG, M4V, F4V, RM, RMVB |
| **Video Codecs** | H.264 (AVC), H.265 (HEVC), AV1, VP8, VP9, DivX, Xvid, MPEG-2, MPEG-4, Theora |
| **Audio Codecs** | AAC, MP3, AC3, DTS, E-AC3, TrueHD, FLAC, OGG, Opus |

### 17.2 Supported Audio Formats

MP3, AAC, FLAC, WAV, OGG, WMA, M4A, APE, AIFF, Opus, AC3, DTS, AMR, M3U, M3U8

### 17.3 Supported Subtitle Formats

SRT, ASS, SSA, VTT, SUB, IDX, SMI, TTML, LRC (music lyrics)

### 17.4 Required Android Permissions

```xml
<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29" />

<!-- Downloads & Background -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<!-- ✅ Android 14 REQUIRED: Declare specific foreground service types -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Biometric -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />

<!-- Notifications (runtime permission, Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Network State -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- ❌ DO NOT ADD — Play Store policy violation without VoIP/alarm justification -->
<!-- <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" /> -->
```

**Service declarations in `AndroidManifest.xml`:**

```xml
<!-- Audio playback foreground service (Android 14 requires foregroundServiceType) -->
<service
    android:name="com.ryanheise.audioservice.AudioServiceFragmentActivity"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>

<!-- Download foreground service -->
<service
    android:name="vn.hunghd.flutterdownloader.DownloadTaskService"
    android:foregroundServiceType="dataSync"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="false" />
```

### 17.5 Complete pubspec.yaml

```yaml
name: vidmaster
description: All-in-One Video & Music Player
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter

  # Video Engine
  media_kit: ^1.1.11
  media_kit_video: ^1.2.5
  media_kit_libs_video: ^1.0.5

  # Audio Engine
  just_audio: ^0.9.38
  audio_service: ^0.18.14
  on_audio_query: ^2.9.0
  just_audio_equalizer: ^0.0.4

  # Downloader
  flutter_downloader: ^1.11.6
  dio: ^5.4.3+1

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Security
  local_auth: ^2.2.0
  flutter_secure_storage: ^9.0.0
  hive_flutter: ^1.1.0
  crypto: ^3.0.3

  # Navigation
  go_router: ^13.2.1

  # Permissions & Files
  permission_handler: ^11.3.1
  path_provider: ^2.1.2
  file_picker: ^8.0.3

  # Sharing
  share_plus: ^7.2.2

  # Notifications
  flutter_local_notifications: ^17.1.2

  # Subtitle
  flutter_subtitle_wrapper: ^0.0.4

  # Thumbnails
  video_thumbnail: ^0.5.3

  # Connectivity
  connectivity_plus: ^5.0.2

  # Chromecast
  flutter_cast_framework: ^0.3.0

  # Utils
  intl: ^0.19.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mocktail: ^1.0.3
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  integration_test:
    sdk: flutter
```

### 17.6 Minimum Device Specifications

| Spec | Minimum | Recommended |
|---|---|---|
| Android Version | 8.0 (API 26) | 11.0 (API 30)+ |
| RAM | 2 GB | 4 GB+ |
| Storage (App) | 50 MB | 50 MB |
| CPU | Snapdragon 430 / Helio P10 | Snapdragon 665+ |
| Display | 720p | 1080p |

---

*End of Document — VidMaster PRD v1.1 (Revised)*
*© 2025 Nagi — All Rights Reserved*
