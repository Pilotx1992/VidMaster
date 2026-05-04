# VidMaster — Downloader Roadmap v2.0

> **Document Type:** Integration Roadmap
> **Companion To:** Downloader PRD v2.0 · Implementation Blueprint v1.0 · Technical Blueprint v2.0
> **Project Stack:** Flutter 3.x · yt-dlp (Chaquopy) · FFmpeg · Riverpod · Isar
> **Scope:** Social Media Extraction · DASH Merging · In-App Browser · Clipboard Detection
> **Last Updated:** 2026

---

## Overview

This roadmap describes the planned execution path for the downloader feature and aligns directly with the implementation blueprint. It is not a separate technical spec; it is the delivery plan for the same feature set defined in `BLUEPRINT.md`.

## Current Status

- **Current phase:** Phase 6 — Maintenance & Future Features
- **Status:** Active 🟢

---

## Phase 1: MVP & Advanced Engineering (Completed ✅)
- [x] Establish `flutter_downloader` integration with Riverpod state management.
- [x] Persist active and completed tasks using Isar.
- [x] Display real-time speed and ETA with UI throttling.
- [x] Implement concurrent queue management.

## Phase 2: Native Config & Extraction (Completed ✅)
- [x] Configure Android ABI splits before adding Chaquopy.
- [x] Add Chaquopy / yt-dlp bridge for extraction.
- [x] Create clean architecture skeleton under `lib/features/downloader/`.
- [x] Build extraction workflow with yt-dlp and fallback engines.
- [x] Implement the quality selection sheet with DASH-aware options.

## Phase 3: Processing & DASH Merging (Completed ✅)
- [x] Implement DASH download orchestration for separate video/audio streams.
- [x] Add FFmpeg merge pipeline and temporary file cleanup.
- [x] Persist DASH download state in Isar for recovery across app restarts.
- [ ] Add HQ audio conversion and metadata embedding.

## Phase 4: Smart Synergy & Browser (Completed ✅)
- [x] Add clipboard monitoring for link detection.
- [x] Integrate an in-app browser with detection/floating action support.
- [x] Sync downloaded files with the app’s library views.
- [ ] Create remote update mechanism for extraction binaries.

## Phase 5: Optimization & Final Release (Completed ✅)
- [x] Optimize FFmpeg usage for lower-end devices (Stream Copying).
- [x] Add storage sanity checks using the 2.5× buffer rule (Native Storage Channel).
- [x] Validate ABI split builds and finalize APK size strategy.
- [x] Prepare production-ready release with Proguard/obfuscation.

---

## Milestone Summary
| Milestone | Deliverable | Status |
| :--- | :--- | :--- |
| **M1: Extraction Ready** | Metadata fetch for YT/FB in background using Chaquopy/yt-dlp. | ✅ DONE |
| **M2: DASH & HD** | Parallel video/audio downloads and FFmpeg merging. | ✅ DONE |
| **M3: Smart Browser** | Clipboard auto-detection and browser integration. | ✅ DONE |
| **M4: Production v2** | Stable release with optimized APK and storage policy. | ✅ DONE |

---

## Alignment Check
- `ROADMAP.md` now matches the phase structure and feature scope from `BLUEPRINT.md`.
- There is no direct conflict between the two documents; `ROADMAP.md` is a higher-level delivery plan while `BLUEPRINT.md` is the detailed technical execution guide.
