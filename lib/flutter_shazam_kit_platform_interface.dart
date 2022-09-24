import 'package:flutter_shazam_kit/models/detecting_state.dart';
import 'package:flutter_shazam_kit/models/error.dart';
import 'package:flutter_shazam_kit/models/media_item.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_shazam_kit_method_channel.dart';

typedef OnMediaItemsDiscovered = Function(List<MediaItem>);
typedef OnError = Function(MainError error);
typedef OnDetectStateChanged = Function(DetectState state);

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

  OnMediaItemsDiscovered? onDiscovered;
  OnError? onErrorCallback;
  OnDetectStateChanged? onDetectStateChanged;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isShazamKitAvailable() {
    throw UnimplementedError(
        'isShazamKitAvailable() has not been implemented.');
  }

  Future configureShazamKitSession({String? developerToken}) {
    throw UnimplementedError(
        'configureShazamKitSession() has not been implemented.');
  }

  Future startDetectingByMicrophone(
      {required OnMediaItemsDiscovered onDiscovered,
      required OnDetectStateChanged onDetectStateChanged,
      required OnError onErrorCallback}) {
    throw UnimplementedError(
        'startDetectingByMicrophone() has not been implemented.');
  }

  Future endDetecting() {
    throw UnimplementedError('endDetecting() has not been implemented.');
  }
}
