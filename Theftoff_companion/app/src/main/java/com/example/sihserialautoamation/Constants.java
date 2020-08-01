package com.example.sihserialautoamation;

class Constants {
    static final int LOCATION_SERVICE_ID = 175;
    static final  String ACTION_START_LOCATION_SERVICE = "startLocationService";
    static final String ACTION_STOP_LOCATION_SERVICE = "stopLocationService";
    // values have to be globally unique
    static final String INTENT_ACTION_GRANT_USB = BuildConfig.APPLICATION_ID + ".GRANT_USB";
    static final String INTENT_ACTION_DISCONNECT = BuildConfig.APPLICATION_ID + ".Disconnect";
    static final String NOTIFICATION_CHANNEL = BuildConfig.APPLICATION_ID + ".Channel";
    static final String INTENT_CLASS_MAIN_ACTIVITY = BuildConfig.APPLICATION_ID + ".MainActivity";
    public static final String SHARED_PREF_PHONE = "sharedUserPhone";
    public static final String PHONE_NUMBER = "Number";

    // values have to be unique within each app
    static final int NOTIFY_MANAGER_START_FOREGROUND_SERVICE = 1001;
    private Constants() {}
}
