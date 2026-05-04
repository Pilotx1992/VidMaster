abstract class PlatformBrightnessService {
  Future<double> getBrightness();
  Future<void> setBrightness(double value);
}