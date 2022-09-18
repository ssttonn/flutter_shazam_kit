library flutter_shazam_kit;

import 'flutter_shazam_kit_platform_interface.dart';

export './models/detecting_state.dart';
export './models/error.dart';
export './models/media_item.dart';

class FlutterShazamKit {
  /// check if whether the shazamkit is available on this device
  /// [isShazamKitAvailable] return a boolean
  Future<bool> isShazamKitAvailable() {
    return FlutterShazamKitPlatform.instance.isShazamKitAvailable();
  }

  Future configureAudio() {
    return FlutterShazamKitPlatform.instance.configureAudio();
  }

  Future startDetectingByMicrophone(
      {required OnMediaItemsDiscovered onDiscovered,
      required OnDetectStateChanged onDetectStateChanged,
      required OnError onErrorCallback}) {
    return FlutterShazamKitPlatform.instance.startDetectingByMicrophone(
        onDiscovered: onDiscovered,
        onDetectStateChanged: onDetectStateChanged,
        onErrorCallback: onErrorCallback);
  }

  Future endDetecting() {
    return FlutterShazamKitPlatform.instance.endDetecting();
  }
}
