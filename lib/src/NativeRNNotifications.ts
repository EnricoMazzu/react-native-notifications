/* eslint-disable @typescript-eslint/ban-types */
import { TurboModule, TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  requestPermissions(options: Object): void;
  setCategories(categories: ReadonlyArray<Object>): void;
  getInitialNotification(): Promise<Object>;
  finishHandlingAction(notificationId: string): void;
  finishPresentingNotification(notificationId: string, notificationCompletion: Object): void;
  finishHandlingBackgroundAction(notificationId: string, backgroundFetchResult: string): void;
  abandonPermissions(): void;
  registerPushKit(): void;
  getBadgeCount(): Promise<number>;
  setBadgeCount(count: number): void;
  postLocalNotification(notification: Object, notificationId: number): void;
  cancelLocalNotification(notificationId: number): void;
  cancelAllLocalNotifications(): void;
  isRegisteredForRemoteNotifications(): Promise<boolean>;
  checkPermissions(): Promise<Object>;
  removeAllDeliveredNotifications(): void;
  removeDeliveredNotifications(identifiers: ReadonlyArray<string>): void;
  getDeliveredNotifications(): Promise<ReadonlyArray<Object>>;
  refreshToken(): void;
  setNotificationChannel(notificationChannel: Object): void;
  deleteChannel(channelId: string): void;
  channelExists(channelId: string): Promise<boolean>;
  channelBlocked(channelId: string): Promise<boolean>;
  getChannels(): Promise<ReadonlyArray<string>>;
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.get<Spec>('RNBridgeModule') as Spec | null;
