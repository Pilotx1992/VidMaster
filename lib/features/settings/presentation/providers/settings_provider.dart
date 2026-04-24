import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../di.dart';

// ── State ──────────────────────────────────────────────────────────────────

class AppSettings {
  final ThemeMode themeMode;
  final String locale;           // 'en' or 'ar'
  final int seekDurationSeconds;
  final bool autoRotate;
  final bool resumePlayback;
  final String downloadPath;
  final bool wifiOnlyDownloads;
  final int maxConcurrentDownloads;
  final bool autoPipOnBack;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.locale = 'en',
    this.seekDurationSeconds = 10,
    this.autoRotate = true,
    this.resumePlayback = true,
    this.downloadPath = '/storage/emulated/0/VidMaster',
    this.wifiOnlyDownloads = false,
    this.maxConcurrentDownloads = 3,
    this.autoPipOnBack = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? locale,
    int? seekDurationSeconds,
    bool? autoRotate,
    bool? resumePlayback,
    String? downloadPath,
    bool? wifiOnlyDownloads,
    int? maxConcurrentDownloads,
    bool? autoPipOnBack,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        seekDurationSeconds: seekDurationSeconds ?? this.seekDurationSeconds,
        autoRotate: autoRotate ?? this.autoRotate,
        resumePlayback: resumePlayback ?? this.resumePlayback,
        downloadPath: downloadPath ?? this.downloadPath,
        wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
        maxConcurrentDownloads:
            maxConcurrentDownloads ?? this.maxConcurrentDownloads,
        autoPipOnBack: autoPipOnBack ?? this.autoPipOnBack,
      );
}

// ── Notifier ────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(_loadSettings(_prefs));

  static AppSettings _loadSettings(SharedPreferences prefs) {
    return AppSettings(
      themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.dark.index],
      locale: prefs.getString('locale') ?? 'en',
      seekDurationSeconds: prefs.getInt('seekDurationSeconds') ?? 10,
      autoRotate: prefs.getBool('autoRotate') ?? true,
      resumePlayback: prefs.getBool('resumePlayback') ?? true,
      downloadPath: prefs.getString('downloadPath') ?? '/storage/emulated/0/VidMaster',
      wifiOnlyDownloads: prefs.getBool('wifiOnlyDownloads') ?? false,
      maxConcurrentDownloads: prefs.getInt('maxConcurrentDownloads') ?? 3,
      autoPipOnBack: prefs.getBool('autoPipOnBack') ?? true,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt('themeMode', mode.index);
  }

  void setLocale(String locale) {
    state = state.copyWith(locale: locale);
    _prefs.setString('locale', locale);
  }

  void setSeekDuration(int seconds) {
    state = state.copyWith(seekDurationSeconds: seconds);
    _prefs.setInt('seekDurationSeconds', seconds);
  }

  void setAutoRotate(bool value) {
    state = state.copyWith(autoRotate: value);
    _prefs.setBool('autoRotate', value);
  }

  void setResumePlayback(bool value) {
    state = state.copyWith(resumePlayback: value);
    _prefs.setBool('resumePlayback', value);
  }

  void setDownloadPath(String path) {
    state = state.copyWith(downloadPath: path);
    _prefs.setString('downloadPath', path);
  }

  void setWifiOnlyDownloads(bool value) {
    state = state.copyWith(wifiOnlyDownloads: value);
    _prefs.setBool('wifiOnlyDownloads', value);
  }

  void setMaxConcurrentDownloads(int value) {
    state = state.copyWith(maxConcurrentDownloads: value);
    _prefs.setInt('maxConcurrentDownloads', value);
  }

  void setAutoPipOnBack(bool value) {
    state = state.copyWith(autoPipOnBack: value);
    _prefs.setBool('autoPipOnBack', value);
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
        (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)));
