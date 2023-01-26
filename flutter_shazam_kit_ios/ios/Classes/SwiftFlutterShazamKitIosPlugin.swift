import Flutter
import UIKit

public class SwiftFlutterShazamKitIosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sstonn/flutter_shazam_kit_ios", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterShazamKitIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
