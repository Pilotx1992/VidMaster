import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

import '../providers/video_cast_provider.dart';

class VideoCastDevicePicker extends ConsumerStatefulWidget {
  final VideoFile video;
  final Duration position;
  final Duration duration;
  final FutureOr<void> Function() onCastStarted;

  const VideoCastDevicePicker({
    super.key,
    required this.video,
    required this.position,
    required this.duration,
    required this.onCastStarted,
  });

  @override
  ConsumerState<VideoCastDevicePicker> createState() =>
      _VideoCastDevicePickerState();
}

class _VideoCastDevicePickerState extends ConsumerState<VideoCastDevicePicker> {
  String? _busyDeviceId;
  bool _disconnecting = false;

  bool get _isBusy => _busyDeviceId != null || _disconnecting;

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(videoCastDevicesProvider);
    final isConnected = ref.watch(videoCastConnectedProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Cast to device',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isConnected)
                  TextButton(
                    onPressed: _isBusy ? null : _disconnect,
                    child: _disconnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            devices.when(
              data: _buildDeviceList,
              loading: () => const _SearchingDevices(),
              error: (error, _) => _PickerMessage(
                icon: Symbols.error_outline,
                message: 'Unable to search for Cast devices.',
                detail: '$error',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<GoogleCastDevice> devices) {
    if (devices.isEmpty) {
      return const _PickerMessage(
        icon: Symbols.cast_connected,
        message: 'No Cast devices found.',
        detail: 'Make sure your Chromecast is powered on and on this network.',
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final isBusy = _busyDeviceId == device.deviceID;
          return ListTile(
            enabled: !_isBusy,
            leading: const Icon(Symbols.cast, color: Colors.white70),
            title: Text(
              device.friendlyName,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              device.modelName ?? 'Cast Device',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: isBusy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _isBusy ? null : () => _castToDevice(device),
          );
        },
      ),
    );
  }

  Future<void> _castToDevice(GoogleCastDevice device) async {
    if (_isBusy) return;

    setState(() {
      _busyDeviceId = device.deviceID;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final castSession = ref.read(videoCastSessionProvider);
    final sessionResult = await castSession.startSessionWithDevice(device);
    if (!mounted) return;
    if (sessionResult.isFailure) {
      _showSnackBar(messenger, sessionResult.message);
      _clearBusy();
      return;
    }

    final loadResult = await castSession.castVideo(
      widget.video,
      startPosition: widget.position,
      duration: widget.duration,
      autoPlay: true,
    );
    if (!mounted) return;
    if (loadResult.isFailure) {
      _showSnackBar(messenger, loadResult.message);
      _clearBusy();
      return;
    }

    navigator.pop();
    _showSnackBar(messenger, 'Casting started');
    _notifyCastStarted();
  }

  void _notifyCastStarted() {
    try {
      final result = widget.onCastStarted();
      if (result is Future<void>) {
        unawaited(result.catchError((_) {}));
      }
    } catch (_) {
      // Casting succeeded; local playback pause is best-effort.
    }
  }

  Future<void> _disconnect() async {
    if (_isBusy) return;

    setState(() {
      _disconnecting = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await ref.read(videoCastSessionProvider).disconnect();
    if (!mounted) return;

    if (result.isSuccess) {
      navigator.pop();
    } else {
      setState(() {
        _disconnecting = false;
      });
    }
    _showSnackBar(messenger, result.message);
  }

  void _clearBusy() {
    if (!mounted) return;
    setState(() {
      _busyDeviceId = null;
    });
  }

  void _showSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

class _SearchingDevices extends StatelessWidget {
  const _SearchingDevices();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFF9A825)),
          SizedBox(height: 16),
          Text(
            'Searching for devices...',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _PickerMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? detail;

  const _PickerMessage({
    required this.icon,
    required this.message,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
