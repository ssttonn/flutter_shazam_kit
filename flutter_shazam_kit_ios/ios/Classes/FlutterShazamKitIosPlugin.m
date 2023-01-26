#import "FlutterShazamKitIosPlugin.h"
#if __has_include(<flutter_shazam_kit_ios/flutter_shazam_kit_ios-Swift.h>)
#import <flutter_shazam_kit_ios/flutter_shazam_kit_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_shazam_kit_ios-Swift.h"
#endif

@implementation FlutterShazamKitIosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterShazamKitIosPlugin registerWithRegistrar:registrar];
}
@end
