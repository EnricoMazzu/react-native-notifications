#import "RNPushKitEventHandler.h"
#import "RNBridgeModule.h"

@implementation RNPushKitEventHandler {
  RNNotificationsStore* _store;
}

- (instancetype)initWithStore:(RNNotificationsStore *)store {
  self = [super init];
  _store = store;
  return self;
}

- (void)registeredWithToken:(NSString *)token {
    [RNBridgeModule sendEvent:RNPushKitRegistered body:@{@"pushKitToken": token}];
}

- (void)didReceiveIncomingPushWithPayload:(NSDictionary *)payload withCompletionHandler:(void (^)(void))completionHandler {
  NSString *identifier = [[NSUUID UUID] UUIDString];

  NSMutableDictionary *notification = [payload mutableCopy];
  notification[@"identifier"] = identifier;

  [_store setActionCompletionHandler:completionHandler withCompletionKey:identifier];
  [RNBridgeModule sendEvent:RNPushKitNotificationReceived body:payload];
}

@end
