# VidMaster — Video Agent Guide

> [!WARNING]
> **This guide is archived.**
>
> The original implementation guide (1886 lines, 6 build-from-scratch phases) has been moved to
> [`docs/archive/VIDEO_AGENT.md`](./archive/VIDEO_AGENT.md).
>
> **Do not use it for current implementation.** All 6 phases described in that guide are already
> fully implemented in the codebase. Using it will cause duplicate widgets, conflicting state
> shapes, and regressions.

---

## Current References

| Need | Use this document |
|---|---|
| **Video player specs & architecture** | [`docs/X.md`](./X.md) — Technical blueprint + PRD for video player engine |
| **File paths & task recipes** | [`docs/mapper.md`](./mapper.md) — Precise codebase map with common task → files |
| **Architecture & DI** | [`docs/BLUEPRINT.md`](./BLUEPRINT.md) — Full architecture, folder structure, dependency map |
| **Feature status** | [`docs/BLUEPRINT.md §22`](./BLUEPRINT.md#22-feature-completion-matrix) — Feature completion matrix |
| **Release readiness** | [`docs/RELEASE_CHECKLIST.md`](./RELEASE_CHECKLIST.md) — Pre-release validation checklist |

---

## Quick File Reference (Video Player)

All video player code lives under `lib/features/video_player/`:

| Layer | Key files |
|---|---|
| **Domain** | `entities/` (6 files), `repositories/` (3 interfaces), `usecases/video_usecases.dart` (10 use cases), `services/platform_brightness_service.dart` |
| **Data** | `data_sources/video_engine.dart` (media_kit wrapper), `datasources/video_local_data_source.dart` (scan), `models/` (3 Isar models + .g.dart), `repositories/` (3 impls) |
| **Presentation** | `providers/` (5 providers), `screens/` (2 screens), `widgets/` (17 widget files) |

> For the full path listing, see [`mapper.md §5`](./mapper.md#5-feature-video-player).
