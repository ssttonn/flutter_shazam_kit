import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_shazam_kit_platform_interface.dart';

/// An implementation of [FlutterShazamKitPlatform] that uses method channels.
class MethodChannelFlutterShazamKit extends FlutterShazamKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_shazam_kit');

  MethodChannelFlutterShazamKit() {
    methodChannel.setMethodCallHandler(_nativeMethodHandler);
  }

  Future _nativeMethodHandler(MethodCall call) async {
    switch (call.method) {
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isShazamKitAvailable() async {
    final isShazamKitAvailable =
        (await methodChannel.invokeMethod<bool?>("isShazamKitAvailable")) ??
            false;
    return isShazamKitAvailable;
  }

  @override
  Future startRecording({int sampleRate = 48000, int bufferSize = 8192}) {
    return methodChannel.invokeMethod(
        "startRecording", {"sampleRate": sampleRate, "bufferSize": bufferSize});
  }

  @override
  Future endRecording() {
    return methodChannel.invokeMethod("stopRecording");
  }
}
