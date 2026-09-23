#import <React/RCTEventEmitter.h>
#import <RNNotificationsSpec/RNNotificationsSpec.h>

static NSString* const RNRegistered                     = @"remoteNotificationsRegistered";
static NSString* const RNRegistrationDenied             = @"remoteNotificationsRegistrationDenied";
static NSString* const RNRegistrationFailed             = @"remoteNotificationsRegistrationFailed";
static NSString* const RNPushKitRegistered              = @"pushKitRegistered";
static NSString* const RNNotificationReceived           = @"notificationReceived";
static NSString* const RNNotificationReceivedBackground = @"notificationReceivedBackground";
static NSString* const RNNotificationOpened             = @"notificationOpened";
static NSString* const RNPushKitNotificationReceived    = @"pushKitNotificationReceived";
static NSString* const RNAppNotificationSettingsLinked  = @"appNotificationSettingsLinked";

@interface RNBridgeModule : RCTEventEmitter <NativeRNBridgeModuleSpec>

+ (void)sendEvent:(NSString *)event body:(NSDictionary *)body;

@end
