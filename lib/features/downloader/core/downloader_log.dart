import 'package:flutter/foundation.dart';

final class DownloaderLog {
  DownloaderLog._();

  static void queue(String message) => _write('QUEUE', message);
  static void engine(String message) => _write('ENGINE', message);
  static void isar(String message) => _write('ISAR', message);
  static void merge(String message) => _write('MERGE', message);
  static void storage(String message) => _write('STORAGE', message);

  static void _write(String category, String message) {
    debugPrint('[Downloader][$category] $message');
  }
}
