#import "FlutterShazamKitPlugin.h"
#if __has_include(<flutter_shazam_kit/flutter_shazam_kit-Swift.h>)
#import <flutter_shazam_kit/flutter_shazam_kit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_shazam_kit-Swift.h"
#endif

@implementation FlutterShazamKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterShazamKitPlugin registerWithRegistrar:registrar];
}
@end
