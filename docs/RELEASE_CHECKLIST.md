# VidMaster — Pre-Release Checklist v2.0

> **Last Updated:** 2026-05-08

---

## 🔒 Security & Privacy

- [ ] `flutter_secure_storage` uses `encryptedSharedPreferences: true` ✅ (verified in di.dart)
- [ ] PIN hashed with bcrypt (never stored in plain text) ✅ (verified in AuthLocalDataSource)
- [ ] Replace legacy vault transform with audited AEAD before marketing Vault as encrypted ⚠️ NOT YET
- [ ] Vault metadata in Hive box — **never** file bytes ✅ (verified in vault_metadata_data_source.dart)
- [ ] `FLAG_SECURE` on vault screen (prevent screenshots) ⚠️ NOT YET
- [ ] PBKDF2 salt per encryption operation ✅ (verified in VaultRepositoryImpl)
- [ ] Encryption key wrapped with PIN-derived KEK ✅
- [ ] Failed attempt lockout (5 attempts → 15 min lock) ✅ (AuthState constants)

---

## 📱 Android 14 Compliance

- [ ] `compileSdk = 34` ✅
- [ ] `targetSdk = 34` ✅
- [ ] `minSdk = 26` ✅
- [ ] Foreground Service types declared:
  - [ ] `mediaPlayback` for audio_service ✅ (AndroidManifest.xml)
  - [ ] `dataSync` for flutter_downloader ✅ (AndroidManifest.xml)
- [ ] `POST_NOTIFICATIONS` permission declared ✅
- [ ] **No** `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` ✅ (verified absent)
- [ ] PiP `supportsPictureInPicture="true"` on MainActivity ✅
- [ ] Granular media permissions (`READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`) ✅

---

## 📦 Build & Distribution

- [ ] ABI splits configured (arm64-v8a, armeabi-v7a, x86_64) ⚠️ Not in current build.gradle.kts
- [ ] Universal APK disabled (`universalApk false`) ⚠️ See above
- [ ] APK size per ABI < 50 MB ⏳ Not yet verified
- [ ] Release signing via `key.properties` ✅ (guard in build.gradle.kts)
- [ ] R8 minification enabled for release ✅ (`isMinifyEnabled = true`)
- [ ] Resource shrinking enabled for release ✅ (`isShrinkResources = true`)
- [ ] ProGuard rules file exists ⚠️ Verify `proguard-rules.pro`
- [ ] No debug logging in release builds (kDebugMode guard) ✅

---

## 🧪 Testing

- [ ] `flutter analyze` → 0 errors ⏳
- [ ] All unit tests passing ⏳
- [ ] Widget tests for critical flows ⏳
- [ ] Physical device test (Android 8.0 / API 26) ⏳
- [ ] Physical device test (Android 14 / API 34) ⏳
- [ ] RTL layout test (Arabic locale) ⏳
- [ ] Dark mode test (all screens visible) ⏳
- [ ] Memory leak check (video player lifecycle) ⏳

---

## 🎨 UI/UX

- [ ] All screens support light + dark theme ⚠️ Some hardcoded colors may exist
- [ ] RTL layout verified for all screens ⏳
- [ ] No text overflow/clipping in Arabic ⏳
- [ ] Bottom navigation works in both orientations ✅
- [ ] MiniPlayerBar visible across all tabs ✅

---

## 📋 Play Store Readiness

- [ ] App icon generated (flutter_launcher_icons) ⏳
- [ ] Splash screen configured (flutter_native_splash) ⏳
- [ ] App bundle generated (`flutter build appbundle`) ⏳
- [ ] Privacy policy URL ready ⏳
- [ ] Content rating questionnaire completed ⏳
- [ ] Store listing (title, description, screenshots) ⏳

---

## Notes

- **Build Flavors**: `stable` (production) and `experimental` (sandbox with Chaquopy/yt-dlp)
- **Experimental Build Python Requirements**: Experimental flavor requires Python 3.8–3.12 for Chaquopy/yt-dlp builds. Python 3.13 is not supported because the current Chaquopy/pip path may fail due to removed `cgi`. Build command: `./gradlew -PvidmasterPython="<path-to-python-3.12-or-lower>" :app:assembleExperimentalDebug --console=plain`
- **Signing**: Release builds enforce `key.properties` — debug signing is rejected
- **Kotlin DSL**: Build configuration uses `build.gradle.kts` (not Groovy)
- **ABI Splits**: Currently not enabled in `build.gradle.kts` — should be added before production release to reduce APK size from ~193MB to ~50MB per ABI
