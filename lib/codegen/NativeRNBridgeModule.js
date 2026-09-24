/**
 * @format
 * @flow
 */

import type {TurboModule} from 'react-native/Libraries/TurboModule/RCTExport';
import * as TurboModuleRegistry from 'react-native/Libraries/TurboModule/TurboModuleRegistry';

export type NotificationPermissionOptions = {|
  +carPlay?: ?boolean,
  +criticalAlert?: ?boolean,
  +providesAppNotificationSettings?: ?boolean,
  +provisional?: ?boolean,
  +announcement?: ?boolean,
|};

export type NotificationPermissions = {|
  +badge: boolean,
  +alert: boolean,
  +sound: boolean,
  +carPlay?: ?boolean,
  +criticalAlert?: ?boolean,
  +providesAppNotificationSettings?: ?boolean,
  +provisional?: ?boolean,
  +announcement?: ?boolean,
  +notificationCenter: boolean,
  +lockScreen: boolean,
|};

export type NotificationCompletion = {|
  +badge?: ?boolean,
  +alert?: ?boolean,
  +sound?: ?boolean,
|};

export type NotificationAction = {|
  +identifier: string,
  +activationMode: string,
  +title: string,
  +authenticationRequired: boolean,
  +textInput?: ?{|
    +buttonTitle: string,
    +placeholder: string,
  |},
|};

export type NotificationCategory = {|
  +identifier: string,
  +actions?: ?Array<NotificationAction>,
|};

export type NotificationChannel = {|
  +channelId: string,
  +name: string,
  +importance: number,
  +description?: ?string,
  +enableLights?: ?boolean,
  +enableVibration?: ?boolean,
  +groupId?: ?string,
  +groupName?: ?string,
  +lightColor?: ?string,
  +showBadge?: ?boolean,
  +soundFile?: ?string,
  +vibrationPattern?: ?Array<number>,
|};

export interface Spec extends TurboModule {
  +getInitialNotification: () => Promise<?Object>;
  +postLocalNotification: (notification: Object, id: number) => void;
  +cancelLocalNotification: (notificationId: number) => void;
  +cancelAllLocalNotifications: () => void;
  +getDeliveredNotifications: () => Promise<Array<Object>>;
  +removeDeliveredNotifications: (identifiers: Array<string>) => void;
  +removeAllDeliveredNotifications: () => void;

  +requestPermissions: (options: NotificationPermissionOptions) => void;
  +abandonPermissions: () => void;
  +isRegisteredForRemoteNotifications: () => Promise<boolean>;
  +checkPermissions: () => Promise<NotificationPermissions>;

  +registerPushKit: () => void;
  +getBadgeCount: () => Promise<number>;
  +setBadgeCount: (count: number) => void;
  +setCategories: (categories: Array<NotificationCategory>) => void;
  +finishPresentingNotification: (
    notificationId: string,
    presentingOptions: NotificationCompletion,
  ) => void;
  +finishHandlingAction: (notificationId: string) => void;
  +finishHandlingBackgroundAction: (
    notificationId: string,
    backgroundFetchResult: string,
  ) => void;

  +refreshToken: () => void;
  +setNotificationChannel: (notificationChannel: NotificationChannel) => void;
  +deleteNotificationChannel: (channelId: string) => void;
  +channelExists: (channelId: string) => Promise<boolean>;
  +channelBlocked: (channelId: string) => Promise<boolean>;
  +getChannels: () => Promise<Array<string>>;

  +addListener: (eventType: string) => void;
  +removeListeners: (count: number) => void;
}

export default (TurboModuleRegistry.getEnforcing<Spec>('RNBridgeModule'): Spec);
