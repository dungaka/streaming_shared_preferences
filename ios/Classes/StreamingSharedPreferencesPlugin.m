#import "StreamingSharedPreferencesPlugin.h"
#if __has_include(<streaming_shared_preferences/streaming_shared_preferences-Swift.h>)
#import <streaming_shared_preferences/streaming_shared_preferences-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "streaming_shared_preferences-Swift.h"
#endif

@implementation StreamingSharedPreferencesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStreamingSharedPreferencesPlugin registerWithRegistrar:registrar];
}
@end
