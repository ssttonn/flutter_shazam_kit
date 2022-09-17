import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit_method_channel.dart';

void main() {
  MethodChannelFlutterShazamKit platform = MethodChannelFlutterShazamKit();
  const MethodChannel channel = MethodChannel('flutter_shazam_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
