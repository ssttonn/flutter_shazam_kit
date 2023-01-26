import 'package:flutter_shazam_kit_platform_interface/flutter_shazam_kit_platform_interface_platform_interface.dart';

class FlutterShazamKit {
  Future<String?> getPlatformVersion() {
    return FlutterShazamKitPlatform.instance.getPlatformVersion();
  }
}
