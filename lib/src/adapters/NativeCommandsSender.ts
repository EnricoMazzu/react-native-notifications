import NativeRNBridgeModule, { Spec } from '../NativeRNBridgeModule';
import { Notification } from '../DTO/Notification';
import { NotificationCompletion } from '../interfaces/NotificationCompletion';
import { NotificationPermissions } from '../interfaces/NotificationPermissions';
import { NotificationCategory } from '../interfaces/NotificationCategory';
import { NotificationChannel } from '../interfaces/NotificationChannel';
import { NotificationPermissionOptions } from '../interfaces/NotificationPermissions';

export class NativeCommandsSender {
  private readonly nativeCommandsModule: Spec;
  constructor() {
    this.nativeCommandsModule = NativeRNBridgeModule;
  }

  postLocalNotification(notification: Notification, id: number) {
    return this.nativeCommandsModule.postLocalNotification(notification, id);
  }

  getInitialNotification(): Promise<Object> {
    return this.nativeCommandsModule.getInitialNotification();
  }

  requestPermissions(options?: NotificationPermissionOptions) {
    return this.nativeCommandsModule.requestPermissions(options || {});
  }

  abandonPermissions() {
    return this.nativeCommandsModule.abandonPermissions();
  }

  refreshToken() {
    this.nativeCommandsModule.refreshToken();
  }

  registerPushKit() {
    return this.nativeCommandsModule.registerPushKit();
  }

  setCategories(categories: [NotificationCategory?]) {
    this.nativeCommandsModule.setCategories(categories);
  }

  getBadgeCount(): Promise<number> {
    return this.nativeCommandsModule.getBadgeCount();
  }

  setBadgeCount(count: number) {
    this.nativeCommandsModule.setBadgeCount(count);
  }

  cancelLocalNotification(notificationId: number) {
    this.nativeCommandsModule.cancelLocalNotification(notificationId);
  }

  cancelAllLocalNotifications() {
    this.nativeCommandsModule.cancelAllLocalNotifications();
  }

  isRegisteredForRemoteNotifications(): Promise<any> {
    return this.nativeCommandsModule.isRegisteredForRemoteNotifications();
  }

  checkPermissions() {
    return this.nativeCommandsModule.checkPermissions();
  }

  removeAllDeliveredNotifications() {
    return this.nativeCommandsModule.removeAllDeliveredNotifications();
  }

  removeDeliveredNotifications(identifiers: Array<string>) {
    return this.nativeCommandsModule.removeDeliveredNotifications(identifiers);
  }

  public getDeliveredNotifications(): Promise<Notification[]> {
    return this.nativeCommandsModule.getDeliveredNotifications();
  }

  finishPresentingNotification(notificationId: string, notificationCompletion: NotificationCompletion): void {
    this.nativeCommandsModule.finishPresentingNotification(notificationId, notificationCompletion);
  }

  finishHandlingAction(notificationId: string): void {
    this.nativeCommandsModule.finishHandlingAction(notificationId);
  }

  setNotificationChannel(notificationChannel: NotificationChannel) {
    this.nativeCommandsModule.setNotificationChannel(notificationChannel);
  }

  deleteNotificationChannel(channelId: string): void {
    this.nativeCommandsModule.deleteNotificationChannel(channelId);
  }

  channelExists(channelId: string): Promise<boolean> {
    return this.nativeCommandsModule.channelExists(channelId);
  }
  
  channelBlocked(channelId: string): Promise<boolean> {
    return this.nativeCommandsModule.channelBlocked(channelId);
  }
  
  getChannels(): Promise<string[]> {
    return this.nativeCommandsModule.getChannels();
  }

  finishHandlingBackgroundAction(notificationId: string, backgroundFetchResult: string): void {
    this.nativeCommandsModule.finishHandlingBackgroundAction(notificationId, backgroundFetchResult);
  }
}
