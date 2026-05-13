import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/router/app_router.dart';
import '../providers/settings_provider.dart';

Widget _settingsIcon(BuildContext context, List<List<dynamic>> icon) {
  return HugeIcon(
    icon: icon,
    size: 24,
    color: Theme.of(context).iconTheme.color ?? Colors.white70,
    strokeWidth: 1.8,
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            // ── Appearance ──────────────────────────────────────────────────
            _buildSectionHeader(context, 'Appearance'),
            ListTile(
              leading: _settingsIcon(context, HugeIcons.strokeRoundedSun03),
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
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: _LtrDropdownItem(child: Text('System')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: _LtrDropdownItem(child: Text('Light')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: _LtrDropdownItem(child: Text('Dark')),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  _settingsIcon(context, HugeIcons.strokeRoundedTranslation),
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
                  DropdownMenuItem(
                    value: 'en',
                    child: _LtrDropdownItem(child: Text('English')),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: _LtrDropdownItem(child: Text('العربية')),
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── Playback ────────────────────────────────────────────────────
            _buildSectionHeader(context, 'Playback'),
            SwitchListTile(
              secondary:
                  _settingsIcon(context, HugeIcons.strokeRoundedScreenRotation),
              title: const Text('Auto Rotate'),
              subtitle: const Text(
                  'Automatically rotate screen based on video aspect ratio'),
              value: settings.autoRotate,
              onChanged: (bool value) => notifier.setAutoRotate(value),
            ),
            SwitchListTile(
              secondary:
                  _settingsIcon(context, HugeIcons.strokeRoundedPlayCircle),
              title: const Text('Resume Playback'),
              subtitle: const Text('Remember where you left off'),
              value: settings.resumePlayback,
              onChanged: (bool value) => notifier.setResumePlayback(value),
            ),
            SwitchListTile(
              secondary: _settingsIcon(
                  context, HugeIcons.strokeRoundedPictureInPictureOn),
              title: const Text('Auto PiP'),
              subtitle: const Text('Enter Picture-in-Picture when leaving app'),
              value: settings.autoPipOnBack,
              onChanged: (bool value) => notifier.setAutoPipOnBack(value),
            ),
            ListTile(
              leading: _settingsIcon(context, HugeIcons.strokeRoundedForward02),
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
                  DropdownMenuItem(
                    value: 5,
                    child: _LtrDropdownItem(child: Text('5 seconds')),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: _LtrDropdownItem(child: Text('10 seconds')),
                  ),
                  DropdownMenuItem(
                    value: 15,
                    child: _LtrDropdownItem(child: Text('15 seconds')),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: _LtrDropdownItem(child: Text('30 seconds')),
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── Downloads ───────────────────────────────────────────────────
            _buildSectionHeader(context, 'Downloads'),
            SwitchListTile(
              secondary: _settingsIcon(context, HugeIcons.strokeRoundedWifi01),
              title: const Text('Download over Wi-Fi only'),
              value: settings.wifiOnlyDownloads,
              onChanged: (bool value) => notifier.setWifiOnlyDownloads(value),
            ),
            ListTile(
              leading: _settingsIcon(context, HugeIcons.strokeRoundedLayers01),
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
                  DropdownMenuItem(
                    value: 1,
                    child: _LtrDropdownItem(child: Text('1')),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: _LtrDropdownItem(child: Text('2')),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: _LtrDropdownItem(child: Text('3')),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: _LtrDropdownItem(child: Text('4')),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: _LtrDropdownItem(child: Text('5')),
                  ),
                ],
              ),
            ),

            // Download Path - visual only, changing requires path provider
            ListTile(
              leading: _settingsIcon(context, HugeIcons.strokeRoundedFolder02),
              title: const Text('Download location'),
              subtitle: Text(settings.downloadPath),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Changing download location requires storage permission feature update.')),
                );
              },
            ),
            const Divider(),

            if (kDebugMode) ...[
              _buildSectionHeader(context, 'Developer'),
              ListTile(
                leading: _settingsIcon(context, HugeIcons.strokeRoundedCode),
                title: const Text('Download Harness'),
                subtitle: const Text('Stress-test downloader lifecycle'),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.devDownloadHarness),
              ),
              const Divider(),
            ],

            // ── Security (Phase 5) ──────────────────────────────────────────
            _buildSectionHeader(context, 'Security'),
            ListTile(
              leading:
                  _settingsIcon(context, HugeIcons.strokeRoundedSquareLock02),
              title: const Text('App Lock & Vault'),
              subtitle: const Text('Configure PIN and hidden files'),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: () => context.push('/vault'),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

class _LtrDropdownItem extends StatelessWidget {
  final Widget child;

  const _LtrDropdownItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}
