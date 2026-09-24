#import "RNBridgeModule.h"
#import "RNCommandsHandler.h"
#import "RCTConvert+RNNotifications.h"
#import "RNNotificationsStore.h"
#import <React/RCTBridgeDelegate.h>
#import <React/RCTBridge.h>
#import <ReactCommon/RCTTurboModule.h>

@implementation RNBridgeModule {
    RNCommandsHandler* _commandsHandler;
}

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    _commandsHandler = [[RNCommandsHandler alloc] init];
    for (NSString *event in [self supportedEvents]) {
        [self addListener:event];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (void)setBridge:(RCTBridge *)bridge {
    [super setBridge:bridge];
    if ([bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[RNNotificationsStore sharedInstance] setInitialNotification:[bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[RNRegistered, RNRegistrationDenied, RNRegistrationFailed,
             RNPushKitRegistered, RNNotificationReceived, RNNotificationReceivedBackground,
             RNNotificationOpened, RNPushKitNotificationReceived, RNAppNotificationSettingsLinked];
}

- (void)startObserving {
    for (NSString *event in [self supportedEvents]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:event
                                                   object:nil];
    }
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification {
    [self sendEventWithName:notification.name body:notification.userInfo];
}

+ (void)sendEvent:(NSString *)event body:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:event
                                                        object:self
                                                      userInfo:body];
}

#pragma mark - JS interface

- (NSDictionary *)requestPermissionsDictionary:(JS::NativeRNBridgeModule::NotificationPermissionOptions &)options {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (options.carPlay()) dictionary[@"carPlay"] = @(*options.carPlay());
    if (options.criticalAlert()) dictionary[@"criticalAlert"] = @(*options.criticalAlert());
    if (options.providesAppNotificationSettings()) dictionary[@"providesAppNotificationSettings"] = @(*options.providesAppNotificationSettings());
    if (options.provisional()) dictionary[@"provisional"] = @(*options.provisional());
    if (options.announcement()) dictionary[@"announcement"] = @(*options.announcement());
    return dictionary;
}

- (NSDictionary *)notificationCompletionDictionary:(JS::NativeRNBridgeModule::NotificationCompletion &)presentingOptions {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (presentingOptions.badge()) dictionary[@"badge"] = @(*presentingOptions.badge());
    if (presentingOptions.alert()) dictionary[@"alert"] = @(*presentingOptions.alert());
    if (presentingOptions.sound()) dictionary[@"sound"] = @(*presentingOptions.sound());
    return dictionary;
}

- (void)requestPermissions:(JS::NativeRNBridgeModule::NotificationPermissionOptions &)options {
    [_commandsHandler requestPermissions:[self requestPermissionsDictionary:options]];
}

- (void)setCategories:(NSArray *)categories {
    [_commandsHandler setCategories:categories];
}

- (void)getInitialNotification:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [_commandsHandler getInitialNotification:resolve reject:reject];
}

- (void)finishHandlingAction:(NSString *)completionKey {
    [_commandsHandler finishHandlingAction:completionKey];
}

- (void)finishPresentingNotification:(NSString *)completionKey presentingOptions:(JS::NativeRNBridgeModule::NotificationCompletion &)presentingOptions {
    [_commandsHandler finishPresentingNotification:completionKey presentingOptions:[self notificationCompletionDictionary:presentingOptions]];
}

- (void)finishHandlingBackgroundAction:(NSString *)completionKey backgroundFetchResult:(NSString *)backgroundFetchResult {
    [_commandsHandler finishHandlingBackgroundAction:completionKey backgroundFetchResult:backgroundFetchResult];
}

- (void)abandonPermissions {
    [_commandsHandler abandonPermissions];
}

- (void)registerPushKit {
    [_commandsHandler registerPushKit];
}

- (void)getBadgeCount:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [_commandsHandler getBadgeCount:resolve reject:reject];
}

- (void)setBadgeCount:(double)count {
    [_commandsHandler setBadgeCount:(int)count];
}

- (void)postLocalNotification:(NSDictionary *)notification id:(double)notificationId {
    [_commandsHandler postLocalNotification:notification withId:@(notificationId)];
}

- (void)cancelLocalNotification:(double)notificationId {
    [_commandsHandler cancelLocalNotification:@(notificationId)];
}

- (void)cancelAllLocalNotifications {
    [_commandsHandler cancelAllLocalNotifications];
}

- (void)isRegisteredForRemoteNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [_commandsHandler isRegisteredForRemoteNotifications:resolve reject:reject];
}

- (void)checkPermissions:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
    [_commandsHandler checkPermissions:resolve reject:reject];
}

#if !TARGET_OS_TV

- (void)removeAllDeliveredNotifications {
    [_commandsHandler removeAllDeliveredNotifications];
}

- (void)removeDeliveredNotifications:(NSArray<NSString *> *)identifiers {
    [_commandsHandler removeDeliveredNotifications:identifiers];
}

- (void)getDeliveredNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [_commandsHandler getDeliveredNotifications:resolve reject:reject];
}

#endif

// Android-only stubs required by the shared codegen spec
- (void)refreshToken {}
- (void)setNotificationChannel:(JS::NativeRNBridgeModule::NotificationChannel &)channel {}
- (void)deleteNotificationChannel:(NSString *)channelId {}
- (void)channelExists:(NSString *)channelId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject { resolve(@NO); }
- (void)channelBlocked:(NSString *)channelId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject { resolve(@NO); }
- (void)getChannels:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject { resolve(@[]); }

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeRNBridgeModuleSpecJSI>(params);
}

@end
