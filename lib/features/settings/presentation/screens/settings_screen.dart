import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ── Appearance ──────────────────────────────────────────────────
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  notifier.setThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: settings.locale,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  notifier.setLocale(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
            ),
          ),
          const Divider(),

          // ── Playback ────────────────────────────────────────────────────
          _buildSectionHeader(context, 'Playback'),
          SwitchListTile(
            secondary: const Icon(Icons.screen_rotation),
            title: const Text('Auto Rotate'),
            subtitle: const Text('Automatically rotate screen based on video aspect ratio'),
            value: settings.autoRotate,
            onChanged: (bool value) => notifier.setAutoRotate(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.play_circle_filled),
            title: const Text('Resume Playback'),
            subtitle: const Text('Remember where you left off'),
            value: settings.resumePlayback,
            onChanged: (bool value) => notifier.setResumePlayback(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.picture_in_picture_alt),
            title: const Text('Auto PiP'),
            subtitle: const Text('Enter Picture-in-Picture when leaving app'),
            value: settings.autoPipOnBack,
            onChanged: (bool value) => notifier.setAutoPipOnBack(value),
          ),
          ListTile(
            leading: const Icon(Icons.fast_forward),
            title: const Text('Seek duration'),
            subtitle: const Text('Double tap to seek'),
            trailing: DropdownButton<int>(
              value: settings.seekDurationSeconds,
              underline: const SizedBox(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  notifier.setSeekDuration(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 seconds')),
                DropdownMenuItem(value: 10, child: Text('10 seconds')),
                DropdownMenuItem(value: 15, child: Text('15 seconds')),
                DropdownMenuItem(value: 30, child: Text('30 seconds')),
              ],
            ),
          ),
          const Divider(),

          // ── Downloads ───────────────────────────────────────────────────
          _buildSectionHeader(context, 'Downloads'),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('Download over Wi-Fi only'),
            value: settings.wifiOnlyDownloads,
            onChanged: (bool value) => notifier.setWifiOnlyDownloads(value),
          ),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Max concurrent downloads'),
            trailing: DropdownButton<int>(
              value: settings.maxConcurrentDownloads,
              underline: const SizedBox(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  notifier.setMaxConcurrentDownloads(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
                DropdownMenuItem(value: 4, child: Text('4')),
                DropdownMenuItem(value: 5, child: Text('5')),
              ],
            ),
          ),
          
          // Download Path - visual only, changing requires path provider
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Download location'),
            subtitle: Text(settings.downloadPath),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changing download location requires storage permission feature update.')),
              );
            },
          ),
          const Divider(),

          // ── Security (Phase 5) ──────────────────────────────────────────
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('App Lock & Vault'),
            subtitle: const Text('Configure PIN and hidden files'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/vault'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}