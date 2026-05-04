# VidMaster — Pro Video Player Engine Implementation Guide
## Execution Blueprint · v5.1 (PRD-Aligned)
> **This document serves as the definitive implementation guide for VidMaster's video player engine per PRD v5.1.**
> **Read each section thoroughly before executing any step. Follow professional engineering practices.**

---

## 🚨 Non-Negotiable Rules (Engineering Standards)

```
1. Never delete existing files — only add or modify within lib/features/video_player/.
2. Do not alter pubspec.yaml without explicit approval.
3. Execute one phase → validate → proceed to next.
4. On any error: halt, document issue, do not attempt auto-fix.
5. Every new file passes flutter analyze before advancing.
6. Maintain Clean Architecture separation at all times.
7. Use Isar exclusively — no Hive integration.
8. Implement manual copyWith — no @freezed dependencies.
9. Ensure zero Flutter dependencies in domain layer.
10. Follow TDD principles: write tests alongside implementation.
```

---

## 📋 Pre-Implementation Assessment (Zero-Code Phase)

### Step 0.1: Verify Project Structure

Run this command first and report results to confirm lib/features/video_player/ exists:

```bash
find lib/features/video_player/ -type f -name "*.dart" | sort
```

### Step 0.2: Audit pubspec.yaml Dependencies

```bash
cat pubspec.yaml
```

Verify these libraries match PRD requirements:

| Library | Required Version | PRD Reference |
|---------|------------------|---------------|
| `media_kit` | ^1.1.11 | Core playback engine |
| `media_kit_video` | ^1.2.5 | UI components |
| `flutter_riverpod` | ^2.5.1 | State management |
| `riverpod_annotation` | ^2.3.5 | Code generation |
| `build_runner` | ^2.4.9 (dev) | Isar generation |
| `isar` | ^3.1.0+1 | Database (replaces Hive) |
| `isar_flutter_libs` | ^3.1.0+1 | Flutter integration |
| `crypto` | ^3.0.3 | MD5 hashing |

**Critical:** Confirm no Hive or @freezed dependencies exist.

### Step 0.3: Inventory Existing Riverpod Providers

```bash
grep -r "Provider\|StateNotifier\|riverpod" lib/features/video_player/ --include="*.dart" -l
```

---

## ✅ Readiness Confirmation

**Do not proceed beyond this point until you provide:**

- [ ] Current file structure (find command output)
- [ ] Dependency audit (pubspec.yaml contents)
- [ ] Existing provider count and locations

---

## 🏗️ Phase 1: File Structure Scaffolding

**Objective:** Create all directories and empty files within `lib/features/video_player/` without business logic. Preserve existing `core/` and other features.

### 1.1 Create Directory Hierarchy

```bash
mkdir -p lib/features/video_player/domain/entities
mkdir -p lib/features/video_player/domain/repositories
mkdir -p lib/features/video_player/domain/services
mkdir -p lib/features/video_player/data/models
mkdir -p lib/features/video_player/data/repositories
mkdir -p lib/features/video_player/data/services
mkdir -p lib/features/video_player/data/data_sources
mkdir -p lib/features/video_player/presentation/providers
mkdir -p lib/features/video_player/presentation/screens
mkdir -p lib/features/video_player/presentation/widgets
```

### 1.2 Generate Empty Files

Create each file with this exact content:
```dart
// TODO: implement
```

**File List:**
```
lib/features/video_player/domain/entities/video_file.dart
lib/features/video_player/domain/entities/subtitle_settings.dart
lib/features/video_player/domain/entities/gesture_engine.dart
lib/features/video_player/domain/entities/gesture_result.dart
lib/features/video_player/domain/entities/video_playback_state.dart

lib/features/video_player/domain/repositories/resume_repository.dart
lib/features/video_player/domain/repositories/subtitle_preferences_repository.dart

lib/features/video_player/domain/services/platform_brightness_service.dart

lib/features/video_player/data/models/subtitle_settings_isar.dart
lib/features/video_player/data/models/video_resume_isar.dart

lib/features/video_player/data/repositories/isar_resume_repository.dart
lib/features/video_player/data/repositories/isar_subtitle_preferences_repository.dart

lib/features/video_player/data/services/android_brightness_service.dart
lib/features/video_player/data/data_sources/video_engine.dart

lib/features/video_player/presentation/providers/video_player_notifier.dart
lib/features/video_player/presentation/providers/video_player_provider.dart

lib/features/video_player/presentation/screens/video_player_screen.dart

lib/features/video_player/presentation/widgets/controls_overlay.dart
lib/features/video_player/presentation/widgets/pro_gesture_layer.dart
lib/features/video_player/presentation/widgets/seek_preview_overlay.dart
lib/features/video_player/presentation/widgets/subtitle_menu_sheet.dart
lib/features/video_player/presentation/widgets/subtitle_live_preview.dart
```

### 1.3 Validation

```bash
find lib/features/video_player/ -type f -name "*.dart" | wc -l  # Should be 22
flutter analyze lib/features/video_player/  # Should pass
```

---

## 🧱 Phase 2: Domain Layer Implementation (Pure Business Logic)

**Principles:** Zero Flutter dependencies. Pure Dart. Testable without UI framework.

### 2.1 VideoFile Entity

**File:** `lib/features/video_player/domain/entities/video_file.dart`

```dart
class VideoFile {
  final String path;
  final String name;
  final Duration? duration;

  const VideoFile({
    required this.path,
    required this.name,
    this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFile &&
      runtimeType == other.runtimeType &&
      path == other.path;

  @override
  int get hashCode => path.hashCode;
}
```

### 2.2 SubtitleSettings Entity

**File:** `lib/features/video_player/domain/entities/subtitle_settings.dart`

```dart
import 'package:flutter/material.dart';

enum SubtitleFontSize {
  small(16.0),
  medium(20.0),
  large(24.0),
  xLarge(32.0),
  xxLarge(40.0);

  const SubtitleFontSize(this.value);
  final double value;
}

enum SubtitleFontStyle { normal, bold, boldShadow }

class SubtitleSettings {
  final SubtitleFontSize fontSize;
  final Color textColor;
  final Color backgroundColor;
  final double backgroundOpacity;
  final SubtitleFontStyle fontStyle;
  final double delaySeconds;

  const SubtitleSettings({
    this.fontSize = SubtitleFontSize.large,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.backgroundOpacity = 0.54,
    this.fontStyle = SubtitleFontStyle.boldShadow,
    this.delaySeconds = 0.0,
  });

  Color get effectiveBackground => backgroundColor.withValues(alpha: backgroundOpacity);

  TextStyle get textStyle => TextStyle(
    fontSize: fontSize.value,
    color: textColor,
    backgroundColor: effectiveBackground,
    fontWeight: fontStyle != SubtitleFontStyle.normal ? FontWeight.bold : FontWeight.normal,
    shadows: fontStyle == SubtitleFontStyle.boldShadow
        ? const [Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(1, 2))]
        : null,
  );

  SubtitleSettings copyWith({
    SubtitleFontSize? fontSize,
    Color? textColor,
    Color? backgroundColor,
    double? backgroundOpacity,
    SubtitleFontStyle? fontStyle,
    double? delaySeconds,
  }) => SubtitleSettings(
        fontSize: fontSize ?? this.fontSize,
        textColor: textColor ?? this.textColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
        fontStyle: fontStyle ?? this.fontStyle,
        delaySeconds: delaySeconds ?? this.delaySeconds,
      );

  static const defaults = SubtitleSettings();
}
```

### 2.3 Gesture Engine & Result

**Files:** `gesture_engine.dart` and `gesture_result.dart`

Implement per PRD Section 11.4. Ensure zero Flutter imports in gesture_engine.dart (except HapticFeedback for feedback).

### 2.4 Repository Contracts

**File:** `lib/features/video_player/domain/repositories/resume_repository.dart`

```dart
abstract class ResumeRepository {
  Future<Duration?> loadPosition(String videoPath);
  Future<void> savePosition(String videoPath, Duration position);
}
```

**File:** `lib/features/video_player/domain/repositories/subtitle_preferences_repository.dart`

```dart
import '../entities/subtitle_settings.dart';

abstract class SubtitlePreferencesRepository {
  Future<SubtitleSettings> loadGlobalSettings();
  Future<void> saveGlobalSettings(SubtitleSettings settings);
  Future<SubtitleSettings?> loadVideoSettings(String videoPath);
  Future<void> saveVideoSettings(String videoPath, SubtitleSettings settings);
  Future<String?> loadExternalTrackPath(String videoPath);
  Future<void> saveExternalTrackPath(String videoPath, String? path);
}
```

### 2.5 Platform Service Contract

**File:** `lib/features/video_player/domain/services/platform_brightness_service.dart`

```dart
abstract class PlatformBrightnessService {
  Future<double> getBrightness();
  Future<void> setBrightness(double value);
}
```

### 2.6 VideoPlaybackState Entity

**File:** `lib/features/video_player/domain/entities/video_playback_state.dart`

Implement manual immutable class with copyWith per PRD Section 9.1. Include all enums and computed properties.

---

## ⚙️ Phase 3: Data Layer (Isar Persistence)

### 3.1 VideoEngine Implementation

**File:** `lib/features/video_player/data/data_sources/video_engine.dart`

Implement media_kit wrapper per PRD Section 10.1. Handle API differences gracefully.

### 3.2 Isar Models

**File:** `lib/features/video_player/data/models/subtitle_settings_isar.dart`

```dart
import 'package:isar/isar.dart';

part 'subtitle_settings_isar.g.dart';

@collection
class SubtitleSettingsIsar {
  Id id = Isar.autoIncrement;

  late int fontSizeIndex;
  late int textColorValue;
  late int backgroundColorValue;
  late double backgroundOpacity;
  late int fontStyleIndex;
}
```

**File:** `lib/features/video_player/data/models/video_resume_isar.dart`

```dart
import 'package:isar/isar.dart';

part 'video_resume_isar.g.dart';

@collection
class VideoResumeIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String videoPathHash;

  late int positionMs;
}
```

**Generate Isar Code:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3.3 Repository Implementations

Implement Isar-based repositories with proper error handling and data conversion.

### 3.4 Platform Service Implementation

**File:** `lib/features/video_player/data/services/android_brightness_service.dart`

Implement platform channel communication per Android specifications.

---

## 🧠 Phase 4: Application Layer (Business Logic Orchestration)

### 4.1 VideoPlayerNotifier

**File:** `lib/features/video_player/presentation/providers/video_player_notifier.dart`

Implement state management per PRD Section 9.2. Ensure all business logic resides here.

### 4.2 Riverpod Provider

**File:** `lib/features/video_player/presentation/providers/video_player_provider.dart`

Wire dependencies and expose StateNotifierProvider.

---

## 🎨 Phase 5: Presentation Layer (UI Components)

### 5.1 ProGestureLayer

**File:** `lib/features/video_player/presentation/widgets/pro_gesture_layer.dart`

Implement gesture detection and overlay system per PRD Section 11.5.

### 5.2 Additional Widgets

Implement remaining UI components: ControlsOverlay, SubtitleMenuSheet, etc.

### 5.3 Screen Integration

**File:** `lib/features/video_player/presentation/screens/video_player_screen.dart`

Assemble all layers into cohesive screen.

---

## 🧪 Phase 6: Testing & Validation

### 6.1 Unit Tests

Write comprehensive unit tests for domain entities, especially GestureEngine.

### 6.2 Integration Tests

Validate end-to-end functionality.

### 6.3 Performance Validation

Ensure metrics meet PRD requirements.

---

## 📋 Final Validation Checklist

- [x] Phase 0: Project assessment complete
- [x] Phase 1: All 22 files created (verified with find)
- [x] Phase 2: Domain layer analyzes clean (0 errors)
- [x] Phase 3: Isar .g.dart files generated successfully
- [x] Phase 4: Notifier implements all PRD methods
- [x] Phase 5: Widgets integrate domain logic correctly
- [x] Phase 6: Domain unit tests added and passing
- [ ] Final: flutter build apk --debug succeeds (video player complete, security unrelated)

---

*VidMaster Engineering Team — Professional Implementation Standard v5.1*