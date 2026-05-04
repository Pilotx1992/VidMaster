import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/services/storage_service.dart';

class StorageServiceImpl implements StorageService {
  static const _channel = MethodChannel('vidmaster/storage');

  @override
  Future<int> availableBytes() async {
    try {
      final int? bytes = await _channel.invokeMethod<int>('getAvailableBytes');
      return bytes ?? 0;
    } catch (e) {
      debugPrint('[Storage] Error getting free space: $e');
      // Fallback to a safe estimate if platform call fails
      return 500 * 1024 * 1024; // 500 MB
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> hasEnoughSpace(int requiredBytes, {double multiplier = 2.5}) async {
    final available = await availableBytes();
    return available >= (requiredBytes * multiplier);
  }

  @override
  Future<String> resolveOutputPath(String subDir, String filename) async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/$subDir';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '$path/$filename';
  }

  @override
  Future<String> resolveTempPath(String filename) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/VidMaster/temp';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '$path/$filename';
  }
}
