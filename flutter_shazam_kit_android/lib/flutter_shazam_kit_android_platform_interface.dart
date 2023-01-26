import 'package:flutter_shazam_kit_android/channel.dart';
import 'package:flutter_shazam_kit_platform_interface/flutter_shazam_kit_platform_interface_platform_interface.dart';

class FlutterShazamKitAndroid extends FlutterShazamKitPlatform {
  static void registerWith() {
    FlutterShazamKitPlatform.instance = FlutterShazamKitAndroid();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
