#import "RNBridgeModule.h"
#import "RNCommandsHandler.h"
#import "RCTConvert+RNNotifications.h"
#import "RNNotificationsStore.h"
#import <React/RCTBridge.h>
#import <React/RCTLog.h>
#import <math.h>

static NSNumber *RNNotificationIdNumber(double notificationId) {
    if (floor(notificationId) == notificationId) {
        return @((long long)notificationId);
    }

    return @(notificationId);
}

@implementation RNBridgeModule {
    RNCommandsHandler* _commandsHandler;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    _commandsHandler = [[RNCommandsHandler alloc] init];
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[RNRegistered,
             RNRegistrationDenied,
             RNRegistrationFailed,
             RNPushKitRegistered,
             RNNotificationReceived,
             RNNotificationReceivedBackground,
             RNNotificationOpened,
             RNPushKitNotificationReceived,
             RNAppNotificationSettingsLinked];
}

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
    if ([_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[RNNotificationsStore sharedInstance] setInitialNotification:[_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (void)sendEvent:(NSString *)event body:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:event
                                                        object:self
                                                      userInfo:body];
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

#pragma mark - JS interface

RCT_EXPORT_METHOD(requestPermissions:(NSDictionary *)options) {
    [_commandsHandler requestPermissions:options];
}

RCT_EXPORT_METHOD(setCategories:(NSArray *)categories) {
    [_commandsHandler setCategories:categories];
}

RCT_EXPORT_METHOD(getInitialNotification:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [_commandsHandler getInitialNotification:resolve reject:reject];
}

RCT_EXPORT_METHOD(finishHandlingAction:(NSString *)completionKey) {
    [_commandsHandler finishHandlingAction:completionKey];
}

RCT_EXPORT_METHOD(finishPresentingNotification:(NSString *)notificationId notificationCompletion:(NSDictionary *)notificationCompletion) {
    [_commandsHandler finishPresentingNotification:notificationId presentingOptions:notificationCompletion];
}

RCT_EXPORT_METHOD(finishHandlingBackgroundAction:(NSString *)notificationId backgroundFetchResult:(NSString *)backgroundFetchResult) {
    [_commandsHandler finishHandlingBackgroundAction:notificationId backgroundFetchResult:backgroundFetchResult];
}

RCT_EXPORT_METHOD(abandonPermissions) {
    [_commandsHandler abandonPermissions];
}

RCT_EXPORT_METHOD(registerPushKit) {
    [_commandsHandler registerPushKit];
}

RCT_EXPORT_METHOD(getBadgeCount:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [_commandsHandler getBadgeCount:resolve reject:reject];
}

RCT_EXPORT_METHOD(setBadgeCount:(double)count) {
    if (floor(count) != count) {
        RCTLogWarn(@"setBadgeCount expects an integer value, received %f", count);
        return;
    }

    [_commandsHandler setBadgeCount:(int)count];
}

RCT_EXPORT_METHOD(postLocalNotification:(NSDictionary *)notification notificationId:(double)notificationId) {
    [_commandsHandler postLocalNotification:notification withId:RNNotificationIdNumber(notificationId)];
}

RCT_EXPORT_METHOD(cancelLocalNotification:(double)notificationId) {
    [_commandsHandler cancelLocalNotification:RNNotificationIdNumber(notificationId)];
}

RCT_EXPORT_METHOD(cancelAllLocalNotifications) {
    [_commandsHandler cancelAllLocalNotifications];
}

RCT_EXPORT_METHOD(isRegisteredForRemoteNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [_commandsHandler isRegisteredForRemoteNotifications:resolve reject:reject];
}

RCT_EXPORT_METHOD(checkPermissions:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [_commandsHandler checkPermissions:resolve reject:reject];
}

RCT_EXPORT_METHOD(refreshToken) {
}

RCT_EXPORT_METHOD(setNotificationChannel:(NSDictionary *)notificationChannel) {
}

RCT_EXPORT_METHOD(deleteChannel:(NSString *)channelId) {
}

RCT_EXPORT_METHOD(channelExists:(NSString *)channelId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve(@(NO));
}

RCT_EXPORT_METHOD(channelBlocked:(NSString *)channelId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve(@(NO));
}

RCT_EXPORT_METHOD(getChannels:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve(@[]);
}

#if !TARGET_OS_TV

RCT_EXPORT_METHOD(removeAllDeliveredNotifications) {
    [_commandsHandler removeAllDeliveredNotifications];
}

RCT_EXPORT_METHOD(removeDeliveredNotifications:(NSArray<NSString *> *)identifiers) {
    [_commandsHandler removeDeliveredNotifications:identifiers];
}

RCT_EXPORT_METHOD(getDeliveredNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [_commandsHandler getDeliveredNotifications:resolve reject:reject];
}

#endif

@end
