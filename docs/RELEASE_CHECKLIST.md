# VidMaster Release Checklist 🚀

This checklist must be completed before any production release.

## 1. Security & Compliance
- [ ] Set `ignoreSsl: false` in `FlutterDownloader.initialize` (main.dart).
- [ ] Set `debug: false` (or `kDebugMode`) in `FlutterDownloader.initialize`.
- [ ] Verify `FLAG_SECURE` is active for the Vault screen.
- [ ] Check `AndroidManifest.xml` for `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (Must NOT be present).
- [ ] Verify `foregroundServiceType` is correctly set for `audio_service` and `flutter_downloader`.

## 2. Technical Validation
- [ ] Run `flutter analyze` (Must have 0 issues).
- [ ] Run `flutter test` (All tests must pass).
- [ ] Verify Isar schemas are up to date and migrations (if any) are handled.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.

## 3. UI/UX & Localization
- [ ] Verify Dark/Light mode consistency across all screens.
- [ ] Test RTL (Arabic) layout mirroring on all features.
- [ ] Check for hardcoded `Colors.black`, `Colors.white`, etc. (Should be 0).
- [ ] Verify all strings are localized in `app_en.arb` and `app_ar.arb`.

## 4. Build & Distribution
- [ ] Increment `version` in `pubspec.yaml` (e.g., `1.0.1+2`).
- [ ] Run `flutter build apk --release --split-per-abi`.
- [ ] Run `flutter build appbundle`.
- [ ] Verify APK size is within target range (< 50MB per ABI).
- [ ] Check Proguard/R8 obfuscation rules in `proguard-rules.pro`.

## 5. Deployment
- [ ] Upload AAB to Google Play Console (Internal/Alpha/Beta track).
- [ ] Update "What's New" in store listing (EN/AR).
- [ ] Verify Firebase Crashlytics and Analytics are active.
