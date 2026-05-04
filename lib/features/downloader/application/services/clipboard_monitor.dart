import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/link_parser.dart';

/// A service that monitors the clipboard for video URLs.
class ClipboardMonitor {
  final Ref _ref;
  Timer? _timer;
  String? _lastClipboardContent;

  ClipboardMonitor(this._ref);

  void start() {
    _timer?.cancel();
    // Check every 2 seconds when app is active
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _checkClipboard());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _checkClipboard() async {
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
