#import "MlkitTranslatePlugin.h"
#if __has_include(<mlkit_translate/mlkit_translate-Swift.h>)
#import <mlkit_translate/mlkit_translate-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mlkit_translate-Swift.h"
#endif

@implementation MlkitTranslatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMlkitTranslatePlugin registerWithRegistrar:registrar];
}
@end
