import { Commands } from './commands/Commands';
import { Platform } from 'react-native';
import { NotificationChannel } from './interfaces/NotificationChannel';

export class NotificationsAndroid {
  constructor(private readonly commands: Commands) {
    return new Proxy(this, {
      get(target, name) {
        if (Platform.OS === 'android') {
          return (target as any)[name];
        } else {
          return () => {};
        }
      }
    });
  }

  /**
  * Refresh FCM token
  */
  public registerRemoteNotifications() {
    this.commands.refreshToken();
  }

  /**
   * setNotificationChannel
   */
  public setNotificationChannel(notificationChannel: NotificationChannel) {
    return this.commands.setNotificationChannel(notificationChannel);
  }

  /**
  * deleteNotificationChannel
  */
  deleteNotificationChannel(channelId: string) {
    return this.commands.deleteNotificationChannel(channelId);
  }

  /**
   * channelExists
   */
  channelExists(channelId: string) {
    return this.commands.channelExists(channelId);
  }

  /**
   * channelBlocked
   */
  channelBlocked(channelId: string) {
    return this.commands.channelBlocked(channelId);
  }

  /**
   * getChannels
   */
  getChannels() {
    return this.commands.getChannels();
  }
}
