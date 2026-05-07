# VidMaster — Execution Roadmap (Day-by-Day Checklist)
> **Document Type:** Delivery plan (checklist)
> **Source of truth:** `BLUEPRINT.md` ثم `X.md` — مواصفات تنفيذ الوكيل (6 مراحل): [`docs/VIDEO_AGENT.md`](VIDEO_AGENT.md)
> **Rule:** أي شيء Release = **`stable` فقط**. أي yt-dlp/Chaquopy = **`experimental` فقط**.
> **Last Updated:** 2026-05-07

---

## Day 1 — Project Identity + Build Configuration (`BLUEPRINT.md` §1 + §21)
- [x] تأكيد أوامر التشغيل والبناء:
  - [x] `flutter run -d "<device>" --flavor stable`
  - [x] `flutter build apk --release --flavor stable --split-per-abi`
  - [x] `flutter build appbundle --release --flavor stable`
  - [x] `flutter build apk --release --flavor experimental`
- [x] التأكد أن build artifacts بتطلع في المسارات المتوقعة (خصوصًا `flutter run` مع flavors).
  - [x] `flutter build apk --debug --flavor stable` أنتج: `build\app\outputs\flutter-apk\app-stable-debug.apk`
  - [x] `flutter build apk --release --flavor stable --split-per-abi` نجح (تم إنتاج Release APK تحت `android\app\build\outputs\apk\stable\release\app-stable-release.apk`)
- [x] تثبيت “قواعد التشغيل” للفريق: stable للمنتج، experimental للرمل.

## Day 2 — Dependency Map + Android Configuration (`BLUEPRINT.md` §4 + §5)
- [x] مراجعة `pubspec.yaml` مقابل Dependency Map (بدون اختلافات).
- [ ] Android permissions/services:
  - [ ] صلاحيات storage/network/notifications متوافقة مع Android 13/14.
  - [ ] التأكد إن `flutter_downloader` + boot receiver شغالين على stable.
- [ ] media_kit readiness:
  - [x] إضافة `media_kit_libs_video` وتأكيد أن `stable debug` APK يتضمن native deps (تم إعادة build بعد الإضافة).
  - [ ] توثيق/تشغيل prefetch عند ضعف الشبكة (علشان `libmpv` artifacts).

## Day 3 — DI + main initialization order (`BLUEPRINT.md` §11 + §17)
- [x] التحقق من تسلسل init في `main.dart`:
  - [x] `WidgetsFlutterBinding.ensureInitialized()`
  - [x] `MediaKit.ensureInitialized()` (مع التعامل الآمن لو فشل)
  - [x] `AudioService.init(...)`
  - [x] `FlutterDownloader.initialize(...)` + `registerCallback`
  - [x] `initIsar()` + `initHive()`
  - [x] `ProviderScope` overrides صحيحة
- [x] Smoke run: فتح التطبيق بدون crash على جهاز فعلي.

## Day 4 — Data Layer Models + Isar schemas (`BLUEPRINT.md` §9)
- [ ] تأكيد `Isar.open()` schemas كاملة (resume + subtitle prefs + downloads + extraction cache…).
- [ ] تشغيل app مرة، ثم:
  - [ ] دخول مكتبة الفيديو/الموسيقى
  - [ ] فتح شاشة الداونلودز
  - [ ] التأكد مفيش `Missing TypeSchema` ولا migrations مفاجئة

## Day 5 — Navigation Map + Runtime sanity (`BLUEPRINT.md` §15 + `X.md` Reality)
- [ ] مراجعة routes الأساسية:
  - [x] فتح Video Library → Video Player بدون `Invalid args` (تم إصلاح passing `VideoPlayerArgs`)
  - [x] التحقق من debug-only route `/dev/download-harness` (Debug فقط)
- [ ] توثيق “أوامر التشغيل اليومية” للفريق (stable debug/release).

## Day 5.1 — Runtime Crash Fixes (Hot)
- [x] إصلاح `UnimplementedError` الناتج عن stub `isarProvider` داخل `video_player_provider.dart` (تم ربطه بـ `di.dart`).
- [x] إزالة استدعاء MethodChannel من background isolate في `YtdlpExtractionService` لتجنب `_TypeError` من `BackgroundIsolateBinaryMessenger` على بعض الأجهزة.
- [x] إصلاح `Invalid video player arguments` بتوحيد `extra` المرسل للـ `/player` إلى `VideoPlayerArgs` من `VideoLibraryScreen`.

---

## Day 6 — Downloader Hardening 1 (Lifecycle)
- [ ] من Dev harness:
  - [ ] enqueue 1 download
  - [ ] pause/resume/cancel/remove
  - [ ] التأكد إن Isar state = native engine state
- [ ] Queue integrity:
  - [ ] منع duplicate (url + quality + platform) لو ده شرطك الحالي

## Day 7 — Downloader Hardening 2 (Process death + reboot)
- [ ] Force stop أثناء download ثم reopen:
  - [ ] الحالة تُسترجع بشكل صحيح
  - [ ] مفيش duplicate tasks
  - [ ] مفيش orphan temp files
- [ ] Reboot test (أو محاكاة قدر الإمكان):
  - [ ] tasks تظهر بنفس الحالة
  - [ ] notifications behavior منطقي (لو مفعلة)

## Day 8 — Downloader Hardening 3 (Network interruption + storage)
- [ ] قطع الإنترنت أثناء download:
  - [ ] failure/retry بدون loop وبدون freeze
- [ ] Android 10–14 storage:
  - [ ] مسار حفظ الملفات لا يعمل crash
  - [ ] الملفات تظهر للمستخدم بالطريقة المناسبة (حسب التصميم الحالي)

---

## Day 9 — Video Player Engine (Core playback + gesture + overlays) (`X.md`)
- [ ] تشغيل فيديوهات متعددة (صغير/كبير/صيغ مختلفة إن أمكن).
- [ ] Sanity UX:
  - [ ] play/pause/seek
  - [ ] تغيير speed
  - [ ] lock mode
  - [ ] PiP (لو مفعّل في build الحالي)
- [ ] لو `media_kit` فشل init في جهاز معيّن:
  - [ ] التطبيق لا ينهار (graceful degradation)
  - [ ] توثيق سبب الفشل (artifacts/abi/network)

## Day 9.1 — Video Playback Hotfixes
- [x] فتح الفيديو باستخدام `file://` URI بدل path خام داخل `VideoPlayerNotifier` + معالجة `fileNotFound`/error state.

## Day 10 — Subtitle Engine + Resume (`X.md`)
- [ ] تحميل SRT/VTT من file picker.
- [ ] subtitle settings persistence (Isar records).
- [ ] resume position:
  - [ ] إعادة فتح نفس الفيديو يرجّع position
  - [ ] لا corruption عند غلق/فتح سريع

---

## Day 11 — Settings Persistence (`BLUEPRINT.md` matrix notes)
- [ ] تنفيذ persistence لـ `settingsProvider` (SharedPreferences أو Hive—حسب التصميم الحالي).
- [ ] تأكيد:
  - [ ] wifi-only mode يثبت بعد restart
  - [ ] أي toggles/values ترجع كما هي

## Day 12 — Vault UI (لو داخل v1)
- [ ] شاشة Vault:
  - [ ] list items
  - [ ] restore
  - [ ] delete
  - [ ] move-to-vault flow
- [ ] تأكيد إن Hive هنا metadata فقط (بدون تخزين bytes).

---

## Day 13 — Tests
- [ ] Unit tests للأجزاء الحرجة:
  - [ ] Downloader repo/usecases (state mapping)
  - [ ] Security auth/vault usecases (happy + failure paths)
- [ ] Integration smoke (اختياري لكن مفيد):
  - [ ] open app → start download → open video

## Day 14 — Release Packaging
- [ ] Signing:
  - [ ] `key.properties` جاهز محليًا + secrets خارج git
- [ ] Release build:
  - [ ] `stable` appbundle/apk يطلع بدون network surprises قدر الإمكان
- [ ] QA checklist سريع:
  - [ ] install
  - [ ] open app
  - [ ] play video
  - [ ] start/pause/resume download

---

## Ongoing — Experimental Sandbox (بعد استقرار stable)
- [ ] تجهيز wheelhouse للـ yt-dlp (offline قدر الإمكان).
- [ ] أي تطوير extractor يبقى داخل `experimental` بدون لمس استقرار `stable`.

