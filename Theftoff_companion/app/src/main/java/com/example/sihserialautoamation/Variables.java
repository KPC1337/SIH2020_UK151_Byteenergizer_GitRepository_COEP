package com.example.sihserialautoamation;

import android.app.Application;

public class Variables extends Application {
    private String alertNumber;

    public String getAlertNumber() {
        return alertNumber;
    }

    public void setAlertNumber(String alertNumber) {
        this.alertNumber = alertNumber;
    }
}
