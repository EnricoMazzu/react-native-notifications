package com.wix.reactnativenotifications.core.notification;

import java.util.List;

public interface INotificationChannel {

    /**
     * Creates a new notification channel with the given parameters. This also updates an existing
     * notification channel.
     *
     */
    void setNotificationChannel();

    void deleteNotificationChannel(String channelId);

    boolean channelExists(String channelId);

    boolean channelBlocked(String channelId);

    List<String> listChannels();
    
    NotificationChannelProps asProps();
}