package com.wix.reactnativenotifications.fcm;

import static com.wix.reactnativenotifications.Defs.LOGTAG;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.wix.reactnativenotifications.BuildConfig;
import com.wix.reactnativenotifications.core.notification.IPushNotification;
import com.wix.reactnativenotifications.core.notification.PushNotification;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Instance-ID + token refreshing handling service. Contacts the FCM to fetch the updated token.
 *
 * @author amitd
 */
public class FcmInstanceIdListenerService extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(RemoteMessage message){
        Bundle bundle = message.toIntent().getExtras();
        if(BuildConfig.DEBUG) Log.d(LOGTAG, "New message from FCM: " + bundle);

        try {
            final IPushNotification notification = PushNotification.get(getApplicationContext(), bundle);
            notification.onReceived();
        } catch (IPushNotification.InvalidNotificationException e) {
            // An FCM message, yes - but not the kind we know how to work with.
            if(BuildConfig.DEBUG) Log.v(LOGTAG, "FCM message handling aborted", e);
        }
        
        try {
            if (bundle.containsKey("CA-Notification-ID")) {

                Context context = getApplicationContext();
                String appPackageName = context.getPackageName();
                String mfJobServiceClassName = "com.creditagricole.services.MFJobService";
                Class MFJobServiceClass = Class.forName(mfJobServiceClassName);

                Method enqueueWorkMethod = MFJobServiceClass.getMethod("enqueueWork", Context.class, Intent.class);

                Intent intent = new Intent(context, MFJobServiceClass);
                intent.putExtra("notificationId", bundle.getString("CA-Notification-ID"));

                enqueueWorkMethod.invoke(null, context, intent);
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }
}