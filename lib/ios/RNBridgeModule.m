#import "RNBridgeModule.h"
#import "RNCommandsHandler.h"
#import "RCTConvert+RNNotifications.h"
#import "RNNotificationsStore.h"
#import <React/RCTBridge.h>

@implementation RNBridgeModule {
    RNCommandsHandler* _commandsHandler;
}

@synthesize bridge = _bridge;

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

RCT_EXPORT_METHOD(setBadgeCount:(int)count) {
    [_commandsHandler setBadgeCount:count];
}

RCT_EXPORT_METHOD(postLocalNotification:(NSDictionary *)notification notificationId:(nonnull NSNumber *)notificationId) {
    [_commandsHandler postLocalNotification:notification withId:notificationId];
}

RCT_EXPORT_METHOD(cancelLocalNotification:(nonnull NSNumber *)notificationId) {
    [_commandsHandler cancelLocalNotification:notificationId];
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
