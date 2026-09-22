# How to customize push notification handling in the host app

This library exposes an extension point that lets the host app control how each incoming FCM message is processed, without modifying the library itself.

## Background

`PushNotification.get()` checks at runtime whether the `Application` class implements `INotificationsApplication`. If it does, the app is responsible for instantiating the `IPushNotification` object for every incoming message — allowing full override of `onReceived()`, `onOpened()`, and `onPostRequest()`.

## Steps

### 1. Create a `PushNotification` subclass in the app

Override only the methods you need. `mContext` and `mNotificationProps` are `protected` fields inherited from `PushNotification`.

```java
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.wix.reactnativenotifications.core.AppLaunchHelper;
import com.wix.reactnativenotifications.core.AppLifecycleFacade;
import com.wix.reactnativenotifications.core.JsIOHelper;
import com.wix.reactnativenotifications.core.notification.PushNotification;

import com.creditagricole.services.MFJobService;

public class CAPushNotification extends PushNotification {

    public CAPushNotification(Context context, Bundle bundle,
            AppLifecycleFacade facade, AppLaunchHelper launchHelper, JsIOHelper jsIOHelper) {
        super(context, bundle, facade, launchHelper, jsIOHelper);
    }

    @Override
    public void onReceived() throws InvalidNotificationException {
        super.onReceived(); // preserves default JS event dispatch

        Bundle bundle = mNotificationProps.asBundle();
        if (bundle.containsKey("CA-Notification-ID")) {
            Intent intent = new Intent(mContext, MFJobService.class);
            intent.putExtra("notificationId", bundle.getString("CA-Notification-ID"));
            MFJobService.enqueueWork(mContext, intent);
        }
    }
}
```

### 2. Implement `INotificationsApplication` in the app's `Application` class

```java
import android.content.Context;
import android.os.Bundle;

import com.wix.reactnativenotifications.core.AppLaunchHelper;
import com.wix.reactnativenotifications.core.AppLifecycleFacade;
import com.wix.reactnativenotifications.core.JsIOHelper;
import com.wix.reactnativenotifications.core.notification.INotificationsApplication;
import com.wix.reactnativenotifications.core.notification.IPushNotification;

public class MyApplication extends Application implements INotificationsApplication {

    @Override
    public IPushNotification getPushNotification(Context context, Bundle bundle,
            AppLifecycleFacade facade, AppLaunchHelper launchHelper) {
        return new CAPushNotification(context, bundle, facade, launchHelper, new JsIOHelper());
    }
}
```

### 3. Clean up the library once the app-side implementation is verified

Remove the commented block in [FcmInstanceIdListenerService.java](lib/android/app/src/main/java/com/wix/reactnativenotifications/fcm/FcmInstanceIdListenerService.java) and the now-unused imports (`Intent`, `InvocationTargetException`, `Method`).
