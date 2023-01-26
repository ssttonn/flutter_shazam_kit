import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterShazamKitPlatform extends PlatformInterface {
  /// Constructs a FlutterShazamKitPlatformInterfacePlatform.
  FlutterShazamKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static late FlutterShazamKitPlatform _instance;

  /// The default instance of [FlutterShazamKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterShazamKitPlatformInterface].
  static FlutterShazamKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterShazamKitPlatform] when
  /// they register themselves.
  static set instance(FlutterShazamKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
