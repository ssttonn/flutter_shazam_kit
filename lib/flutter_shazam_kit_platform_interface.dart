import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_shazam_kit_method_channel.dart';

abstract class FlutterShazamKitPlatform extends PlatformInterface {
  /// Constructs a FlutterShazamKitPlatform.
  FlutterShazamKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterShazamKitPlatform _instance = MethodChannelFlutterShazamKit();

  /// The default instance of [FlutterShazamKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterShazamKit].
  static FlutterShazamKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterShazamKitPlatform] when
  /// they register themselves.
  static set instance(FlutterShazamKitPlatform instance) {
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isShazamKitAvailable() {
    throw UnimplementedError(
        'isShazamKitAvailable() has not been implemented.');
  }

  Future startRecording() {
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  Future endRecording() {
    throw UnimplementedError('endRecording() has not been implemented.');
  }
}
