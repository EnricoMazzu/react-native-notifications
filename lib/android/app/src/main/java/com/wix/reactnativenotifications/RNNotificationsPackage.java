package com.wix.reactnativenotifications;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.react.TurboReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;
import com.google.firebase.FirebaseApp;
import com.wix.reactnativenotifications.core.AppLifecycleFacade;
import com.wix.reactnativenotifications.core.AppLifecycleFacadeHolder;
import com.wix.reactnativenotifications.core.InitialNotificationHolder;
import com.wix.reactnativenotifications.core.NotificationIntentAdapter;
import com.wix.reactnativenotifications.core.notification.IPushNotification;
import com.wix.reactnativenotifications.core.notification.PushNotification;
import com.wix.reactnativenotifications.core.notificationdrawer.IPushNotificationsDrawer;
import com.wix.reactnativenotifications.core.notificationdrawer.PushNotificationsDrawer;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNNotificationsPackage extends TurboReactPackage implements AppLifecycleFacade.AppVisibilityListener, Application.ActivityLifecycleCallbacks {

    private final Application mApplication;

    public RNNotificationsPackage(Application application) {
        mApplication = application;
        FirebaseApp.initializeApp(application.getApplicationContext());

        AppLifecycleFacadeHolder.get().addVisibilityListener(this);
        application.registerActivityLifecycleCallbacks(this);
    }

    @Override
    public NativeModule getModule(String name, ReactApplicationContext reactContext) {
        if (RNNotificationsModule.NAME.equals(name)) {
            return new RNNotificationsModule(mApplication, reactContext);
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
                    true
                )
            );
            return moduleInfos;
        };
    }

    @Override
    public void onAppVisible() {
        final IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(mApplication.getApplicationContext());
        notificationsDrawer.onAppVisible();
    }

    @Override
    public void onAppNotVisible() {
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        final IPushNotificationsDrawer notificationsDrawer = PushNotificationsDrawer.get(mApplication.getApplicationContext());
        notificationsDrawer.onNewActivity(activity);

        callOnOpenedIfNeed(activity);
    }

    @Override
    public void onActivityStarted(Activity activity) {
        if (InitialNotificationHolder.getInstance().get() == null) {
            callOnOpenedIfNeed(activity);
        }
    }

    @Override
    public void onActivityResumed(Activity activity) {
    }

    @Override
    public void onActivityPaused(Activity activity) {
    }

    @Override
    public void onActivityStopped(Activity activity) {
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
    }

    private void callOnOpenedIfNeed(Activity activity) {
        Intent intent = activity.getIntent();
        if (NotificationIntentAdapter.canHandleIntent(intent)) {
            Context appContext = mApplication.getApplicationContext();
            Bundle notificationData = NotificationIntentAdapter.extractPendingNotificationDataFromIntent(intent);
            final IPushNotification pushNotification = PushNotification.get(appContext, notificationData);
            if (pushNotification != null) {
                pushNotification.onOpened();
                // Erase notification intent after using it, to avoid looping with the same notification
                // in case the app is moved to background and opened again
                activity.setIntent(new Intent());
            }
        }
    }
}
