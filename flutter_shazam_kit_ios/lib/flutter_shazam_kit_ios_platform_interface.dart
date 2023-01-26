import 'package:flutter_shazam_kit_platform_interface/flutter_shazam_kit_platform_interface_platform_interface.dart';

import 'channel.dart';

class FlutterShazamKitIos extends FlutterShazamKitPlatform {
  static void registerWith() {
    FlutterShazamKitPlatform.instance = FlutterShazamKitIos();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
