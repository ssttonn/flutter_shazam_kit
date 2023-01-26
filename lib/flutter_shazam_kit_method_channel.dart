import 'dart:async';
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

  StreamController<MatchResult> matchResultDiscoveredController =
      StreamController.broadcast();
  StreamController<MainError> errorController = StreamController.broadcast();
  StreamController<DetectState> detectStateChangedController =
      StreamController.broadcast();

  MethodChannelFlutterShazamKit() {
    callbackMethodChannel.setMethodCallHandler(_nativeMethodHandler);
  }

  Future _nativeMethodHandler(MethodCall call) async {
    switch (call.method) {
      case "matchFound":
        List<MediaItem> items =
            _parseMediaItemsFromJsonString(call.arguments as String? ?? "");
        matchResultDiscoveredController.add(Matched(mediaItems: items));
        break;
      case "notFound":
        matchResultDiscoveredController.add(NoMatch());
        break;
      case "didHasError":
        String errorMessage = call.arguments;
        errorController.add(MainError(message: errorMessage));
        break;
      case "detectStateChanged":
        int stateIndex = call.arguments as int? ?? 0;
        detectStateChangedController.add(DetectState.values[stateIndex]);
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
  Future<void> configureShazamKitSession({String? developerToken}) {
    return methodChannel.invokeMethod(
        "configureShazamKitSession",
        developerToken != null && Platform.isAndroid
            ? {"developerToken": developerToken}
            : {});
  }

  @override
  Future<void> endSession() {
    return methodChannel.invokeMethod("endSession");
  }

  @override
  Stream<MatchResult> get matchResultDiscoveredStream =>
      matchResultDiscoveredController.stream;

  @override
  Stream<DetectState> get detectStateChangedStream =>
      detectStateChangedController.stream;

  @override
  Stream<MainError> get errorStream => errorController.stream;

  @override
  Future<void> startDetectionWithMicrophone() {
    return methodChannel.invokeMethod(
      "startDetectionWithMicrophone",
    );
  }

  @override
  Future<void> endDetectionWithMicrophone() {
    return methodChannel.invokeMethod("endDetectionWithMicrophone");
  }
}
