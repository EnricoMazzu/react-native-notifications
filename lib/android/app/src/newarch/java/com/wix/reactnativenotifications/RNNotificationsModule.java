package com.wix.reactnativenotifications;

import static com.wix.reactnativenotifications.Defs.LOGTAG;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.module.annotations.ReactModule;
import com.wix.reactnativenotifications.core.AppLifecycleFacadeHolder;
import com.wix.reactnativenotifications.core.InitialNotificationHolder;
import com.wix.reactnativenotifications.core.NotificationIntentAdapter;
import com.wix.reactnativenotifications.core.ReactAppLifecycleFacade;
import com.wix.reactnativenotifications.core.notification.INotificationChannel;
import com.wix.reactnativenotifications.core.notification.IPushNotification;
import com.wix.reactnativenotifications.core.notification.NotificationChannel;
import com.wix.reactnativenotifications.core.notification.PushNotification;
import com.wix.reactnativenotifications.core.notification.PushNotificationProps;
import com.wix.reactnativenotifications.core.notificationdrawer.IPushNotificationsDrawer;
import com.wix.reactnativenotifications.core.notificationdrawer.PushNotificationsDrawer;
import com.wix.reactnativenotifications.fcm.FcmInstanceIdRefreshHandlerService;

@ReactModule(name = RNNotificationsModule.NAME)
public class RNNotificationsModule extends NativeRNNotificationsSpec implements ActivityEventListener {
    public static final String NAME = "RNBridgeModule";

    public RNNotificationsModule(Application application, ReactApplicationContext reactContext) {
        super(reactContext);
        if (AppLifecycleFacadeHolder.get() instanceof ReactAppLifecycleFacade) {
            ((ReactAppLifecycleFacade) AppLifecycleFacadeHolder.get()).init(reactContext);
        }

        reactContext.addActivityEventListener(this);
    }

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    @Override
    public void initialize() {
        if(BuildConfig.DEBUG) Log.d(LOGTAG, "Native module init");
        startFcmIntentService(FcmInstanceIdRefreshHandlerService.EXTRA_IS_APP_INIT);

        final IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(getReactApplicationContext().getApplicationContext());
        notificationsDrawer.onAppInit();
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

    }

    @Override
    public void onNewIntent(Intent intent) {
        if (NotificationIntentAdapter.canHandleIntent(intent)) {
            Bundle notificationData = NotificationIntentAdapter.extractPendingNotificationDataFromIntent(intent);
            final IPushNotification notification = PushNotification.get(getReactApplicationContext().getApplicationContext(), notificationData);
            if (notification != null) {
                notification.onOpened();
            }
        }
    }

    @ReactMethod
    @Override
    public void refreshToken() {
        if(BuildConfig.DEBUG) Log.d(LOGTAG, "Native method invocation: refreshToken()");
        startFcmIntentService(FcmInstanceIdRefreshHandlerService.EXTRA_MANUAL_REFRESH);
    }

    @ReactMethod
    @Override
    public void getInitialNotification(final Promise promise) {
        if(BuildConfig.DEBUG) Log.d(LOGTAG, "Native method invocation: getInitialNotification");
        Object result = null;

        try {
            final PushNotificationProps notification = InitialNotificationHolder.getInstance().get();
            if (notification == null) {
                promise.resolve(null);
                return;
            }

            result = Arguments.fromBundle(notification.asBundle());
            InitialNotificationHolder.getInstance().clear();
        } catch (NullPointerException e) {
            Log.e(LOGTAG, "getInitialNotification: Null pointer exception");
        } finally {
            promise.resolve(result);
        }
    }

    @ReactMethod
    @Override
    public void postLocalNotification(ReadableMap notificationPropsMap, double notificationId) {
        if(BuildConfig.DEBUG) Log.d(LOGTAG, "Native method invocation: postLocalNotification");
        final Bundle notificationProps = Arguments.toBundle(notificationPropsMap);
        final IPushNotification pushNotification = PushNotification.get(getReactApplicationContext().getApplicationContext(), notificationProps);
        pushNotification.onPostRequest((int) notificationId);
    }

    @ReactMethod
    @Override
    public void cancelLocalNotification(double notificationId) {
        IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(getReactApplicationContext().getApplicationContext());
        notificationsDrawer.onNotificationClearRequest((int) notificationId);
    }

    @ReactMethod
    @Override
    public void setCategories(ReadableArray categories) {

    }

    public void cancelDeliveredNotification(String tag, int notificationId) {
        IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(getReactApplicationContext().getApplicationContext());
        notificationsDrawer.onNotificationClearRequest(tag, notificationId);
    }

    @ReactMethod
    @Override
    public void isRegisteredForRemoteNotifications(Promise promise) {
        boolean hasPermission = NotificationManagerCompatFacade.from(getReactApplicationContext()).areNotificationsEnabled();
        promise.resolve(Boolean.valueOf(hasPermission));
    }

    @ReactMethod
    @Override
    public void removeAllDeliveredNotifications() {
        IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(getReactApplicationContext().getApplicationContext());
        notificationsDrawer.onAllNotificationsClearRequest();
    }

    @ReactMethod
    @Override
    public void setNotificationChannel(ReadableMap notificationChannelPropsMap) {
        final Bundle notificationChannelProps = Arguments.toBundle(notificationChannelPropsMap);
        INotificationChannel notificationsDrawer = NotificationChannel.get(
                getReactApplicationContext().getApplicationContext(),
                notificationChannelProps
        );
        notificationsDrawer.setNotificationChannel();
    }

    @ReactMethod
    @Override
    public void getChannels(final Promise promise) {
        INotificationChannel notificationsDrawer = NotificationChannel.get(
                getReactApplicationContext().getApplicationContext(),
                null
        );
        WritableArray array = Arguments.fromList(notificationsDrawer.listChannels());
        promise.resolve(array);
    }

    @ReactMethod
    @Override
    public void deleteChannel(String channelId) {
        INotificationChannel notificationsDrawer = NotificationChannel.get(
                getReactApplicationContext().getApplicationContext(),
                null
        );
        notificationsDrawer.deleteNotificationChannel(channelId);
    }

    @ReactMethod
    @Override
    public void channelExists(String channelId, Promise promise) {
        INotificationChannel notificationsDrawer = NotificationChannel.get(
                getReactApplicationContext().getApplicationContext(),
                null
        );

        boolean channelExists = notificationsDrawer.channelExists(channelId);
        promise.resolve(Boolean.valueOf(channelExists));
    }

    @ReactMethod
    @Override
    public void channelBlocked(String channelId, Promise promise) {
        INotificationChannel notificationsDrawer = NotificationChannel.get(
                getReactApplicationContext().getApplicationContext(),
                null
        );

        boolean channelBlocked = notificationsDrawer.channelBlocked(channelId);
        promise.resolve(Boolean.valueOf(channelBlocked));
    }

    @ReactMethod
    @Override
    public void requestPermissions(ReadableMap options) {
    }

    @ReactMethod
    @Override
    public void abandonPermissions() {
    }

    @ReactMethod
    @Override
    public void registerPushKit() {
    }

    @ReactMethod
    @Override
    public void getBadgeCount(Promise promise) {
        promise.resolve(null);
    }

    @ReactMethod
    @Override
    public void setBadgeCount(double count) {
    }

    @ReactMethod
    @Override
    public void cancelAllLocalNotifications() {
    }

    @ReactMethod
    @Override
    public void checkPermissions(Promise promise) {
        promise.resolve(null);
    }

    @ReactMethod
    @Override
    public void removeDeliveredNotifications(ReadableArray identifiers) {
    }

    @ReactMethod
    @Override
    public void getDeliveredNotifications(Promise promise) {
        promise.resolve(null);
    }

    @ReactMethod
    @Override
    public void finishPresentingNotification(String notificationId, ReadableMap notificationCompletion) {
    }

    @ReactMethod
    @Override
    public void finishHandlingAction(String notificationId) {
    }

    @ReactMethod
    @Override
    public void finishHandlingBackgroundAction(String notificationId, String backgroundFetchResult) {
    }

    @ReactMethod
    @Override
    public void addListener(String eventName) {
    }

    @ReactMethod
    @Override
    public void removeListeners(double count) {
    }

    protected void startFcmIntentService(String extraFlag) {
        final Context appContext = getReactApplicationContext().getApplicationContext();
        final Intent tokenFetchIntent = new Intent(appContext, FcmInstanceIdRefreshHandlerService.class);
        tokenFetchIntent.putExtra(extraFlag, true);
        FcmInstanceIdRefreshHandlerService.enqueueWork(appContext, tokenFetchIntent);
    }
}
