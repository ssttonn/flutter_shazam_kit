import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shazam_kit/models/detecting_state.dart';
import 'package:flutter_shazam_kit/models/error.dart';
import 'package:flutter_shazam_kit/models/media_item.dart';

import 'flutter_shazam_kit_platform_interface.dart';

/// An implementation of [FlutterShazamKitPlatform] that uses method channels.
class MethodChannelFlutterShazamKit extends FlutterShazamKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_shazam_kit');

  final callbackMethodChannel =
      const MethodChannel("flutter_shazam_kit_callback");

  MethodChannelFlutterShazamKit() {
    callbackMethodChannel.setMethodCallHandler(_nativeMethodHandler);
  }

  Future _nativeMethodHandler(MethodCall call) async {
    switch (call.method) {
      case "mediaItemsFound":
        List<MediaItem> items =
            _parseMediaItemsFromJsonString(call.arguments as String? ?? "");
        onDiscovered?.call(items);
        break;
      case "didHasError":
        String errorMessage = call.arguments;
        onErrorCallback?.call(MainError(message: errorMessage));
        break;
      case "detectStateChanged":
        int stateIndex = call.arguments as int? ?? 0;
        onDetectStateChanged?.call(DetectState.values[stateIndex]);
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
  Future<bool> isShazamKitAvailable() async {
    final isShazamKitAvailable =
        (await methodChannel.invokeMethod<bool?>("isShazamKitAvailable")) ??
            false;
    return isShazamKitAvailable;
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
  Future startDetectingByMicrophone(
      {required OnMediaItemsDiscovered onDiscovered,
      required OnDetectStateChanged onDetectStateChanged,
      required OnError onErrorCallback}) {
    this.onDiscovered = onDiscovered;
    this.onDetectStateChanged = onDetectStateChanged;
    this.onErrorCallback = onErrorCallback;
    return methodChannel.invokeMethod(
      "startDetectingByMicrophone",
    );
  }

  @override
  Future endDetecting() {
    return methodChannel.invokeMethod("stopDetecting");
  }
}
