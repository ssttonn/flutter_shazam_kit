import 'package:flutter/material.dart';
import 'package:flutter_shazam_kit_macos/channel.dart';
import 'package:flutter_shazam_kit_platform_interface/flutter_shazam_kit_platform_interface_platform_interface.dart';

class FlutterShazamKitMacos extends FlutterShazamKitPlatform {
  @visibleForTesting
  FlutterShazamKitMacos();

  static void registerWith() {
    FlutterShazamKitPlatform.instance = FlutterShazamKitMacos();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
