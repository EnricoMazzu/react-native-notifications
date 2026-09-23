package com.wix.reactnativenotifications.core;

import android.os.Bundle;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class JsIOHelper {
    
    public boolean sendEventToJS(String eventName, Bundle data, ReactContext reactContext) {
        if (data == null) return false;
        // NOTE (finding #6): anticipare il check su reactContext evita di allocare WritableNativeMap
        // quando il contesto non è ancora pronto (eventi droppati durante l'avvio). Fix da abilitare:
        // if (reactContext == null || !reactContext.hasActiveReactInstance()) return false;
        return sendEventToJS(eventName, Arguments.fromBundle(data), reactContext);
    }

    public boolean sendEventToJS(String eventName, WritableMap data, ReactContext reactContext) {
        if (reactContext != null && reactContext.hasActiveReactInstance()) {
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
            return true;
        }
        return false;
    }
}
