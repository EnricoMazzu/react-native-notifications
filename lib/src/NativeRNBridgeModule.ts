import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { NotificationCompletion } from './interfaces/NotificationCompletion';
import type { NotificationPermissions, NotificationPermissionOptions } from './interfaces/NotificationPermissions';
import type { NotificationChannel } from './interfaces/NotificationChannel';

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
