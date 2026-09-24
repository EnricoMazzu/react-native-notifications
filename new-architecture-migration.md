# New Architecture (TurboModules) migration

This document describes the completed migration of this fork to React Native New Architecture (TurboModules / JSI).

---

## Architecture overview

### Before migration — Old Architecture

| Layer | File | Pattern |
|---|---|---|
| JS commands | `NativeCommandsSender.ts` | `NativeModules.RNBridgeModule` |
| JS events | `NativeEventsReceiver.ts` | `NativeModules.RNEventEmitter` + `NativeEventEmitter` |
| Android module reg. | `RNNotificationsPackage.java` | `ReactPackage` → `createNativeModules()` |
| Android module | `RNNotificationsModule.java` | `ReactContextBaseJavaModule` |
| iOS commands module | `RNBridgeModule.h/.m` | `NSObject <RCTBridgeModule>` |
| iOS events module | `RNEventEmitter.h/.m` | `RCTEventEmitter <RCTBridgeModule>` (separate module) |

Two separate iOS native modules: `RNBridgeModule` for commands, `RNEventEmitter` for event emission.

### After migration — New Architecture

| Layer | File | Pattern |
|---|---|---|
| JS commands | `NativeCommandsSender.ts` | `NativeRNBridgeModule` (TurboModule) |
| JS events | `NativeEventsReceiver.ts` | `NativeEventEmitter(NativeRNBridgeModule)` on iOS, `DeviceEventEmitter` on Android |
| Codegen spec | `lib/codegen/NativeRNBridgeModule.js` | Flow TurboModule spec used by RN codegen |
| Android module reg. | `RNNotificationsPackage.java` | `TurboReactPackage` → `getModule()` + `getReactModuleInfoProvider()` |
| Android module | `RNNotificationsModule.java` | `NativeRNBridgeModuleSpec` + `addListener`/`removeListeners` stubs |
| iOS module | `RNBridgeModule.h/.mm` | Single `RCTEventEmitter <NativeRNBridgeModuleSpec>` — handles both commands and events |

`RNEventEmitter.h/.m` deleted. `RNBridgeModule` is now the single TurboModule for both commands and events.

---

## Data flow — New Architecture

**Incoming notification:**
```
Native OS → NSNotificationCenter → RNBridgeModule.handleNotification:
         → sendEventWithName:body: → JSI event bus → NativeEventEmitter (JS)
         → NativeEventsReceiver → user callback
```

**Outgoing command:**
```
User code → NotificationsRoot / Commands → NativeCommandsSender
         → NativeRNBridgeModule (TurboModule) → JSI → RNBridgeModule (iOS) / RNNotificationsModule (Android)
```

---

## Changes per file

### `lib/codegen/NativeRNBridgeModule.js` — codegen source

Flow/JS codegen spec that drives both iOS and Android TurboModule generation.

```ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // Notifications
  getInitialNotification(): Promise<Object>;
  postLocalNotification(notification: Object, id: number): void;
  cancelLocalNotification(notificationId: number): void;
  cancelAllLocalNotifications(): void;
  getDeliveredNotifications(): Promise<Object[]>;
  removeDeliveredNotifications(identifiers: string[]): void;
  removeAllDeliveredNotifications(): void;
  // Permissions
  requestPermissions(options: NotificationPermissionOptions): void;
  abandonPermissions(): void;
  isRegisteredForRemoteNotifications(): Promise<boolean>;
  checkPermissions(): Promise<NotificationPermissions>;
  // iOS-specific
  registerPushKit(): void;
  getBadgeCount(): Promise<number>;
  setBadgeCount(count: number): void;
  setCategories(categories: Object[]): void;
  finishPresentingNotification(notificationId: string, presentingOptions: NotificationCompletion): void;
  finishHandlingAction(notificationId: string): void;
  finishHandlingBackgroundAction(notificationId: string, backgroundFetchResult: string): void;
  // Android-specific
  refreshToken(): void;
  setNotificationChannel(notificationChannel: NotificationChannel): void;
  deleteNotificationChannel(channelId: string): void;
  channelExists(channelId: string): Promise<boolean>;
  channelBlocked(channelId: string): Promise<boolean>;
  getChannels(): Promise<string[]>;
  // Event emitter contract
  addListener(eventType: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNBridgeModule');
```

### `package.json` — `codegenConfig`

Required for React Native 0.68 codegen discovery to generate native interfaces from the JS spec:

```json
"codegenConfig": {
  "libraries": [
    {
      "name": "RNNotificationsSpec",
      "type": "modules",
      "jsSrcsDir": "lib/codegen",
      "android": {
        "javaPackageName": "com.wix.reactnativenotifications"
      },
      "ios": {}
    }
  ]
}
```

### `lib/src/adapters/NativeCommandsSender.ts`

```ts
// Before
import { NativeModules } from 'react-native';
this.nativeCommandsModule = NativeModules.RNBridgeModule;

// After
import NativeRNBridgeModule from '../NativeRNBridgeModule';
this.nativeCommandsModule = NativeRNBridgeModule;
```

### `lib/src/adapters/NativeEventsReceiver.ts`

```ts
// Before
import { NativeModules, NativeEventEmitter, ... } from 'react-native';
this.emitter = Platform.OS === 'android'
  ? DeviceEventEmitter
  : new NativeEventEmitter(NativeModules.RNEventEmitter);  // NativeModules not populated in New Arch

// After
import { NativeEventEmitter, DeviceEventEmitter, ... } from 'react-native';
import NativeRNBridgeModule from '../NativeRNBridgeModule';
this.emitter = Platform.OS === 'android'
  ? DeviceEventEmitter                               // Android: RCTDeviceEventEmitter bus
  : new NativeEventEmitter(NativeRNBridgeModule);    // iOS: TurboModule for lifecycle, shared bus for events
```

`NativeEventEmitter` uses `NativeRNBridgeModule` only for `addListener`/`removeListeners` lifecycle calls. Events emitted by `RNBridgeModule.sendEventWithName:body:` flow through the shared JSI event bus to all `NativeEventEmitter` instances regardless of which module was passed to the constructor.

### `lib/ios/RNBridgeModule.h`

```objc
// Before
#import <Foundation/Foundation.h>
#import <RNNotificationsSpec/RNNotificationsSpec.h>
@interface RNBridgeModule : NSObject <NativeRNBridgeModuleSpec>
@end

// After
#import <React/RCTEventEmitter.h>
#import <RNNotificationsSpec/RNNotificationsSpec.h>

// Event name constants (moved from deleted RNEventEmitter.h)
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
```

### `lib/ios/RNBridgeModule.mm`

Key changes from the Old Architecture version:

- Removed `@synthesize bridge = _bridge` — `RCTEventEmitter` owns the bridge property.
- `setBridge:` now calls `[super setBridge:bridge]` before capturing launch options.
- Added `supportedEvents` — required abstract method of `RCTEventEmitter`.
- Added `startObserving` / `stopObserving` — subscribe/unsubscribe from `NSNotificationCenter` for all supported event names. Called automatically by `RCTEventEmitter` when JS listener count goes from 0→1 and 1→0.
- Added `handleNotification:` — forwards `NSNotification` payloads to JS via `sendEventWithName:body:`.
- Added `+ sendEvent:body:` class method — native callers (event handlers, PushKit, etc.) post to `NSNotificationCenter`; the instance receives it via `handleNotification:` and forwards to JS.
- Removed `RCT_EXPORT_METHOD(addListener:)` and `RCT_EXPORT_METHOD(removeListeners:)` stubs — `RCTEventEmitter` exports these automatically.
- Added `getTurboModule:` — returns `NativeRNBridgeModuleSpecJSI` for JSI/TurboModule wiring.

```objc
- (NSArray<NSString *> *)supportedEvents {
    return @[RNRegistered, RNRegistrationDenied, RNRegistrationFailed,
             RNPushKitRegistered, RNNotificationReceived, RNNotificationReceivedBackground,
             RNNotificationOpened, RNPushKitNotificationReceived, RNAppNotificationSettingsLinked];
}

- (void)startObserving {
    for (NSString *event in [self supportedEvents]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:event object:nil];
    }
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification {
    [self sendEventWithName:notification.name body:notification.userInfo];
}

+ (void)sendEvent:(NSString *)event body:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:event object:self userInfo:body];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeRNBridgeModuleSpecJSI>(params);
}
```

### `lib/ios/RNEventEmitter.h` and `RNEventEmitter.m` — deleted

All functionality moved into `RNBridgeModule`. All callers updated:

| File | Change |
|---|---|
| `RNNotificationEventHandler.h` | `#import "RNEventEmitter.h"` → `#import "RNBridgeModule.h"` |
| `RNNotificationEventHandler.m` | Removed duplicate import; `[RNEventEmitter sendEvent:…]` → `[RNBridgeModule sendEvent:…]` (5 calls) |
| `RNNotificationCenter.m` | Import + 1 call updated |
| `RNPushKitEventHandler.m` | Import + 2 calls updated |
| `RNNotificationCenterMulticast.m` | Import + 1 call updated |
| `RNNotifications.m` | Removed unused `RNEventEmitter* _eventEmitter` ivar |

### `lib/android/app/src/main/java/…/RNNotificationsPackage.java`

```java
// Before: ReactPackage
public List<NativeModule> createNativeModules(ReactApplicationContext ctx) {
    return Arrays.asList(new RNNotificationsModule(mApplication, ctx));
}

// After: TurboReactPackage
public class RNNotificationsPackage extends TurboReactPackage implements ... {
    @Override
    public NativeModule getModule(String name, ReactApplicationContext ctx) {
        if (RNNotificationsModule.NAME.equals(name)) {
            return new RNNotificationsModule(mApplication, ctx);
        }
        return null;
    }

    @Override
    public ReactModuleInfoProvider getReactModuleInfoProvider() {
        return () -> {
            Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
            moduleInfos.put(
                RNNotificationsModule.NAME,
                new ReactModuleInfo(
                    RNNotificationsModule.NAME,
                    RNNotificationsModule.class.getName(),
                    false, false, false, false,
                    true  // isTurboModule
                )
            );
            return moduleInfos;
        };
    }
}
```

### `lib/android/app/src/main/java/…/RNNotificationsModule.java`

Added `addListener`/`removeListeners` stubs required by the `NativeEventEmitter` contract. Android events are emitted via `RCTDeviceEventEmitter` (in `JsIOHelper`) which maps to `DeviceEventEmitter` on the JS side — no separate event module needed.

```java
@ReactMethod
public void addListener(String eventName) {}

@ReactMethod
public void removeListeners(double count) {}
```

> **Note:** With the dedicated Flow codegen spec in `lib/codegen`, Android can extend the generated `NativeRNBridgeModuleSpec` directly and iOS can consume the generated `RNNotificationsSpec` headers through New Architecture codegen discovery.

---

## Known fix unrelated to New Architecture

**`FcmToken.java`** — replaced deprecated `hasActiveCatalystInstance()` with `hasActiveReactInstance()` to match `JsIOHelper.java`. This was a silent failure path when delivering the FCM token in New Architecture.

---

## What does NOT change

- Android channel logic (`NotificationChannel.java`, `INotificationChannel.java`) — pure Android API.
- `FcmInstanceIdListenerService` — `FirebaseMessagingService` + reflection on `MFJobService` are independent of the RN bridge architecture.
- `NotificationIntentAdapter`, `PushNotification`, `AppLifecycleFacade` — do not touch the JS bridge directly.
- Host app JS layer (AppHubFE) — no changes needed; the module's public API is identical.
- iOS `RNCommandsHandler`, `RNNotificationCenter`, `RNPushKit`, `RNNotificationsStore`, `RNNotificationParser` — command implementations, untouched.

---

## Interop layer note

RN 0.74+ ships a backward-compatible interop layer. This migration is fully compatible with both:
- **New Architecture + interop layer on** (default in RN 0.74–0.75): TurboModules coexist with legacy modules.
- **New Architecture + interop layer off** (opt-in from RN 0.76, default in future): all modules must be TurboModules. `RNBridgeModule` and `RNNotificationsModule` satisfy this requirement.
