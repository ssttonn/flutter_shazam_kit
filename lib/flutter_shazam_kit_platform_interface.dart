import 'dart:async';

import 'package:flutter_shazam_kit/models/detecting_state.dart';
import 'package:flutter_shazam_kit/models/error.dart';
import 'package:flutter_shazam_kit/models/result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_shazam_kit_method_channel.dart';

abstract class FlutterShazamKitPlatform extends PlatformInterface {
  /// Constructs a FlutterShazamKitPlatform.
  FlutterShazamKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterShazamKitPlatform instance = MethodChannelFlutterShazamKit();

  Stream<MatchResult> get matchResultDiscoveredStream =>
      throw UnimplementedError(
          'matchResultDiscoveredStream() has not been implemented.');

  Stream<MainError> get errorStream =>
      throw UnimplementedError('errorStream() has not been implemented.');

  Stream<DetectState> get detectStateChangedStream => throw UnimplementedError(
      'detectStateChangedStream() has not been implemented.');

  Future<void> configureShazamKitSession({String? developerToken}) {
    throw UnimplementedError(
        'configureShazamKitSession() has not been implemented.');
  }

  Future<void> endSession() {
    throw UnimplementedError('endSession() has not been implemented.');
  }

  Future<void> startDetectionWithMicrophone() {
    throw UnimplementedError(
        'startDetectionWithMicrophone() has not been implemented.');
  }

  Future<void> endDetectionWithMicrophone() {
    throw UnimplementedError(
        'endDetectionWithMicrophone() has not been implemented.');
  }
}
