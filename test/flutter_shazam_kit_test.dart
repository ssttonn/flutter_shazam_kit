import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit_platform_interface.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterShazamKitPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterShazamKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterShazamKitPlatform initialPlatform = FlutterShazamKitPlatform.instance;

  test('$MethodChannelFlutterShazamKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterShazamKit>());
  });

  test('getPlatformVersion', () async {
    FlutterShazamKit flutterShazamKitPlugin = FlutterShazamKit();
    MockFlutterShazamKitPlatform fakePlatform = MockFlutterShazamKitPlatform();
    FlutterShazamKitPlatform.instance = fakePlatform;
  
    expect(await flutterShazamKitPlugin.getPlatformVersion(), '42');
  });
}
