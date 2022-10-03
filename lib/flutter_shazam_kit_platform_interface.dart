import 'dart:io';

import 'package:flutter_shazam_kit/models/detecting_state.dart';
import 'package:flutter_shazam_kit/models/error.dart';
import 'package:flutter_shazam_kit/models/result.dart';

import 'flutter_shazam_kit_method_channel.dart';

typedef OnMatchResultDiscovered = Function(MatchResult);
typedef OnError = Function(MainError error);
typedef OnDetectStateChanged = Function(DetectState state);

abstract class FlutterShazamKitPlatform {
  static FlutterShazamKitPlatform instance = MethodChannelFlutterShazamKit();

  OnMatchResultDiscovered? onMatchResultDiscoveredCallback;
  OnError? onErrorCallback;
  OnDetectStateChanged? onDetectStateChangedCallback;

  void onMatchResultDiscovered(
      OnMatchResultDiscovered onMatchResultDiscovered) {
    throw UnimplementedError(
        'onMatchResultDiscovered() has not been implemented.');
  }

  void onError(OnError onError) {
    throw UnimplementedError('onError() has not been implemented.');
  }

  void onDetectStateChanged(OnDetectStateChanged onDetectStateChanged) {
    throw UnimplementedError(
        'onDetectStateChanged() has not been implemented.');
  }

  Future configureShazamKitSession({String? developerToken}) {
    throw UnimplementedError(
        'configureShazamKitSession() has not been implemented.');
  }

  Future endSession() {
    throw UnimplementedError('endSession() has not been implemented.');
  }

  Future startDetectionWithMicrophone() {
    throw UnimplementedError(
        'startDetectionWithMicrophone() has not been implemented.');
  }

  Future startDetectionWithAudioFile(File file) {
    throw UnimplementedError(
        'startDetectionWithAudioFile() has not been implemented.');
  }

  Future endDetectionWithMicrophone() {
    throw UnimplementedError(
        'endDetectionWithMicrophone() has not been implemented.');
  }
}
