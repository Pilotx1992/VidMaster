# Product Requirements Document (PRD) — VidMaster Downloader (v2.0)

**Project:** VidMaster Downloader (Snaptube/XPlayer Grade)  
**Version:** 2.0  
**Status:** In Development  
**Author:** Antigravity (AI Assistant)

---

## 1. Executive Summary
VidMaster Downloader v2.0 is an advanced media acquisition tool that replicates the functionality of top-tier apps like **Snaptube** and **XPlayer**. It moves beyond direct URL downloads to support **Social Media Video Extraction** from platforms like YouTube, Facebook, Instagram, and TikTok, featuring multi-format support, quality selection, and automated media merging.

---

## 2. User Stories

| ID | User Role | Requirement | Goal/Benefit |
| :--- | :--- | :--- | :--- |
| **US.1** | Basic User | I want to paste a direct URL. | To download standard files (MP4, MKV). |
| **US.6** | Social User | I want to paste a YouTube link. | To see a list of available qualities (360p to 4K) and formats. |
| **US.7** | Music Lover | I want to download only the audio from a video. | To save storage and listen to music offline in MP3 format. |
| **US.8** | Content Curator | I want to download videos from Instagram/TikTok. | To archive content without watermarks (where possible). |
| **US.9** | Power User | I want to choose between high-speed or data-saving. | To manage mobile data effectively. |

---

## 3. Key Features

### 3.1 Media Extraction Engine (The "Snaptube" Core)
- **Universal Link Parsing:** Identify and parse links from YouTube, FB, IG, TikTok, etc.
- **Metadata Fetching:** Retrieve title, thumbnail, duration, and stream formats before downloading.
- **Quality Selection Dialog:** UI overlay allowing choice of resolution (144p to 4K) and audio bitrate (128k to 320k).

### 3.2 Advanced Downloading & Routing
- **Hybrid Engine Router:** Automatically route to `flutter_downloader` for files or `FFmpeg` for streams (M3U8).
- **DASH Stream Handling:** For 1080p+ YouTube videos, download video and audio separately and merge via **FFmpeg**.
- **Queue System:** Concurrent download management (Max 2 active) with background persistence.
- **Smart Retry:** Automatic recovery with exponential backoff and 800ms UI throttling.

### 3.3 Media Synergy & UX
- **In-App Browser:** Webview with auto-detect scripts and a floating download button.
- **Clipboard Auto-Detect:** Prompt for download when a valid media link is copied.
- **Auto-Library Sync:** Instant addition of completed files to Video/Music libraries.

---

## 4. Technical Requirements
- **Extraction Engine:** `yt-dlp` (via Chaquopy/Python bridge) + `youtube_explode_dart` (fallback).
- **Processing Engine:** `FFmpeg Kit` (Full GPL) for merging, conversion, and metadata embedding.
- **Persistence:** Isar Database as the **Source of Truth** for queue and task state.
- **Native Android:** Foreground Service for background stability and notification control.

---

## 5. Success Metrics
- **Platform Support:** Top 10+ social platforms.
- **Extraction Speed:** Metadata retrieval in < 3 seconds.
- **Reliability:** >95% success rate for DASH merging (1080p+).
- **Performance:** Maintain 60 FPS during high-speed downloads via UI Throttling.
