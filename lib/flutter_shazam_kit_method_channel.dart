import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_shazam_kit/models/detecting_state.dart';
import 'package:flutter_shazam_kit/models/error.dart';
import 'package:flutter_shazam_kit/models/media_item.dart';
import 'package:flutter_shazam_kit/models/result.dart';

import 'flutter_shazam_kit_platform_interface.dart';

/// An implementation of [FlutterShazamKitPlatform] that uses method channels.
class MethodChannelFlutterShazamKit extends FlutterShazamKitPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('flutter_shazam_kit');

  final callbackMethodChannel =
      const MethodChannel("flutter_shazam_kit_callback");

  MethodChannelFlutterShazamKit() {
    callbackMethodChannel.setMethodCallHandler(_nativeMethodHandler);
  }

  Future _nativeMethodHandler(MethodCall call) async {
    switch (call.method) {
      case "matchFound":
        List<MediaItem> items =
            _parseMediaItemsFromJsonString(call.arguments as String? ?? "");
        onMatchResultDiscoveredCallback?.call(Matched(mediaItems: items));
        break;
      case "notFound":
        onMatchResultDiscoveredCallback?.call(NoMatch());
        break;
      case "didHasError":
        String errorMessage = call.arguments;
        onErrorCallback?.call(MainError(message: errorMessage));
        break;
      case "detectStateChanged":
        int stateIndex = call.arguments as int? ?? 0;
        onDetectStateChangedCallback?.call(DetectState.values[stateIndex]);
        break;
    }
  }

  List<MediaItem> _parseMediaItemsFromJsonString(String jsonString) {
    try {
      inspect(jsonDecode(jsonString) is Map<String, dynamic>);
      final rawMediaItems = jsonDecode(jsonString).cast<Map<String, dynamic>>();
      return rawMediaItems
          .map<MediaItem>((item) => MediaItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future configureShazamKitSession({String? developerToken}) {
    return methodChannel.invokeMethod(
        "configureShazamKitSession",
        developerToken != null && Platform.isAndroid
            ? {"developerToken": developerToken}
            : {});
  }

  @override
  Future endSession() {
    onMatchResultDiscoveredCallback = null;
    onDetectStateChangedCallback = null;
    onErrorCallback = null;
    return methodChannel.invokeMethod("endSession");
  }

  @override
  void onMatchResultDiscovered(
      OnMatchResultDiscovered onMatchResultDiscovered) {
    onMatchResultDiscoveredCallback = onMatchResultDiscovered;
  }

  @override
  void onDetectStateChanged(OnDetectStateChanged onDetectStateChanged) {
    onDetectStateChangedCallback = onDetectStateChanged;
  }

  @override
  void onError(OnError onError) {
    onErrorCallback = onError;
  }

  @override
  Future startDetectionWithMicrophone() {
    return methodChannel.invokeMethod(
      "startDetectionWithMicrophone",
    );
  }

  @override
  Future endDetectionWithMicrophone() {
    return methodChannel.invokeMethod("endDetectionWithMicrophone");
  }

  @override
  Future resumeDetection() {
    return methodChannel.invokeMethod("resumeDetection");
  }

  @override
  Future pauseDetection() {
    return methodChannel.invokeMethod("pauseDetection");
  }
}
