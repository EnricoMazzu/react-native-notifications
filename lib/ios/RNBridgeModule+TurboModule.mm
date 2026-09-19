#import "RNBridgeModule.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNNotificationsSpec.h"

@interface RNBridgeModule () <NativeRNNotificationsSpec>
@end

@implementation RNBridgeModule (TurboModule)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNNotificationsSpecJSI>(params);
}

@end
#endif
