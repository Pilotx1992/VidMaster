import 'package:flutter/services.dart';

import '../../domain/services/platform_brightness_service.dart';

class AndroidBrightnessService implements PlatformBrightnessService {
  static const MethodChannel _channel = MethodChannel('com.example.vidmaster/brightness');

  @override
  Future<double> getBrightness() async {
    try {
      final result = await _channel.invokeMethod<double>('getBrightness');
      return result ?? 0.5;
    } catch (e) {
      return 0.5; // Default
    }
  }

  @override
  Future<void> setBrightness(double value) async {
    try {
      await _channel.invokeMethod('setBrightness', {'value': value});
    } catch (e) {
      // Ignore
    }
  }
}