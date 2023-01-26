library flutter_shazam_kit;

import 'flutter_shazam_kit_platform_interface.dart';
import 'models/detecting_state.dart';
import 'models/error.dart';
import 'models/result.dart';

export './models/detecting_state.dart';
export './models/error.dart';
export './models/media_item.dart';
export '/models/result.dart';

class FlutterShazamKit {
  Stream<MatchResult> get matchResultDiscoveredStream =>
      FlutterShazamKitPlatform.instance.matchResultDiscoveredStream;

  Stream<DetectState> get detectStateChangedStream =>
      FlutterShazamKitPlatform.instance.detectStateChangedStream;

  Stream<MainError> get errorStream => FlutterShazamKitPlatform.instance.errorStream;

  Future<void> configureShazamKitSession({String? developerToken}) {
    return FlutterShazamKitPlatform.instance
        .configureShazamKitSession(developerToken: developerToken);
  }

  Future<void> startDetectionWithMicrophone() {
    return FlutterShazamKitPlatform.instance.startDetectionWithMicrophone();
  }

  Future<void> endDetectionWithMicrophone() {
    return FlutterShazamKitPlatform.instance.endDetectionWithMicrophone();
  }

  Future<void> endSession() {
    return FlutterShazamKitPlatform.instance.endSession();
  }
}
