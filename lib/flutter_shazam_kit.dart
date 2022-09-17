import 'flutter_shazam_kit_platform_interface.dart';

class FlutterShazamKit {
  /// check if whether the shazamkit is available on this device
  /// [isShazamKitAvailable] return a boolean
  Future<bool> isShazamKitAvailable() {
    return FlutterShazamKitPlatform.instance.isShazamKitAvailable();
  }

  Future startRecording() {
    return FlutterShazamKitPlatform.instance.startRecording();
  }

  Future endRecording() {
    return FlutterShazamKitPlatform.instance.endRecording();
  }
}
