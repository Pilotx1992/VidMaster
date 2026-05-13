import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/link_parser.dart';

/// A service that monitors the clipboard for video URLs.
class ClipboardMonitor with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _timer;
  String? _lastClipboardContent;
  bool _isStarted = false;
  bool _isCheckingClipboard = false;

  ClipboardMonitor(this._ref);

  void start() {
    if (_isStarted) {
      _syncWithLifecycle(WidgetsBinding.instance.lifecycleState);
      return;
    }

    _isStarted = true;
    WidgetsBinding.instance.addObserver(this);
    _syncWithLifecycle(WidgetsBinding.instance.lifecycleState);
  }

  void stop() {
    if (!_isStarted) {
      _timer?.cancel();
      return;
    }

    _isStarted = false;
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncWithLifecycle(state);
  }

  void _syncWithLifecycle(AppLifecycleState? state) {
    final shouldPoll = state == null || state == AppLifecycleState.resumed;

    if (!_isStarted || !shouldPoll) {
      _stopPolling();
      return;
    }

    if (_timer?.isActive ?? false) {
      return;
    }

    unawaited(_checkClipboard());
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_checkClipboard()),
    );
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkClipboard() async {
    if (_isCheckingClipboard) {
      return;
    }

    _isCheckingClipboard = true;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;

      if (text != null && text != _lastClipboardContent) {
        _lastClipboardContent = text;

        if (LinkParser.isVideoUrl(text)) {
          // Notify the listener (e.g., show a toast or a bottom sheet)
          _ref.read(detectedLinkProvider.notifier).state = text;
        }
      }
    } catch (_) {
      // Handle permission issues or other errors silently
    } finally {
      _isCheckingClipboard = false;
    }
  }
}

final clipboardMonitorProvider = Provider<ClipboardMonitor>((ref) {
  final monitor = ClipboardMonitor(ref);
  ref.onDispose(() => monitor.stop());
  return monitor;
});

/// The currently detected link from clipboard.
final detectedLinkProvider = StateProvider<String?>((ref) => null);
