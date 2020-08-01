package com.example.sihserialautoamation;

import android.Manifest;
import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.telephony.SmsManager;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedList;
import java.util.Queue;


/**
 * create notification and queue serial data while activity is not in the foreground
 * use listener chain: SerialSocket -> SerialService -> UI fragment
 */
public class SerialService extends Service implements SerialListener,SensorEventListener {

    FirebaseAuth mAuth;
    DatabaseReference locationDataReference,locationCallbackReference,fuelTheftReference,tamperingReference,alarmReference,
            alertReference;
    private String newline = "\r\n";
    private SensorManager sensorManager;
    boolean lastLift = false;
    boolean sendMessage = true;
    boolean locked = false;


    class SerialBinder extends Binder {
        SerialService getService() {
            return SerialService.this;
        }
    }

    private enum QueueType {Connect, ConnectError, Read, IoError}

    private class QueueItem {
        QueueType type;
        byte[] data;
        Exception e;

        QueueItem(QueueType type, byte[] data, Exception e) {
            this.type = type;
            this.data = data;
            this.e = e;
        }
    }

    private final Handler mainLooper;
    private final IBinder binder;
    private final Queue<QueueItem> queue1, queue2;

    private SerialSocket socket;
    private SerialListener listener;
    private boolean connected;

    /**
     * Lifecylce
     */
    public SerialService() {
        mainLooper = new Handler(Looper.getMainLooper());
        binder = new SerialBinder();
        queue1 = new LinkedList<>();
        queue2 = new LinkedList<>();
        mAuth = FirebaseAuth.getInstance();
        final FirebaseUser currentFirebaseUser = mAuth.getCurrentUser();
        assert currentFirebaseUser != null;
        locationDataReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("isLocked");
        locationCallbackReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("locationRequest");
        alarmReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("alarm");


        locationDataReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                String isLocked = snapshot.getValue().toString();
                if (isLocked.equals("1")) {
                    byte[] data = ("5" + newline).getBytes();
                    try {
                        write(data);
                        locked = true;
                    } catch (IOException e) {
                        onSerialIoError(e);
                    }
                }
                if (isLocked.equals("0")) {
                    byte[] data = ("6" + newline).getBytes();
                    try {
                        write(data);
                        locked = false;
                    } catch (IOException e) {
                        onSerialIoError(e);
                    }
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
        locationCallbackReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                String isLocked = snapshot.getValue().toString();
                if (isLocked.equals("1")) {
                    byte[] data = ("5" + newline).getBytes();
                    startLocationService();
                }
                if (isLocked.equals("0")) {
                    stopLocationService();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
        alarmReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                String isLocked = snapshot.getValue().toString();
                if (isLocked.equals("1")) {
                    byte[] data = ("8" + newline).getBytes();
                    try {
                        write(data);
                    } catch (IOException e) {
                        onSerialIoError(e);
                    }
                }
                if (isLocked.equals("0")) {
                    byte[] data = ("9" + newline).getBytes();
                    try {
                        write(data);
                    } catch (IOException e) {
                        onSerialIoError(e);
                    }
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });


    }

    @Override
    public void onDestroy() {
        cancelNotification();
        disconnect();
        super.onDestroy();
    }
    @Override
    public void onCreate() {
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    /**
     * Api
     */
    public void connect(SerialSocket socket) throws IOException {
        socket.connect(this);
        this.socket = socket;
        connected = true;
    }

    public void disconnect() {
        connected = false; // ignore data,errors while disconnecting
        cancelNotification();
        if (socket != null) {
            socket.disconnect();
            socket = null;
        }
    }

    public void write(byte[] data) throws IOException {
        if (!connected)
            throw new IOException("not connected");
        socket.write(data);
    }

    public void attach(SerialListener listener) {
        if (Looper.getMainLooper().getThread() != Thread.currentThread())
            throw new IllegalArgumentException("not in main thread");
        cancelNotification();
        // use synchronized() to prevent new items in queue2
        // new items will not be added to queue1 because mainLooper.post and attach() run in main thread
        synchronized (this) {
            this.listener = listener;
        }
        for (QueueItem item : queue1) {
            switch (item.type) {
                case Connect:
                    listener.onSerialConnect();
                    break;
                case ConnectError:
                    listener.onSerialConnectError(item.e);
                    break;
                case Read:
                    listener.onSerialRead(item.data);
                    break;
                case IoError:
                    listener.onSerialIoError(item.e);
                    break;
            }
        }
        for (QueueItem item : queue2) {
            switch (item.type) {
                case Connect:
                    listener.onSerialConnect();
                    break;
                case ConnectError:
                    listener.onSerialConnectError(item.e);
                    break;
                case Read:
                    listener.onSerialRead(item.data);
                    break;
                case IoError:
                    listener.onSerialIoError(item.e);
                    break;
            }
        }
        queue1.clear();
        queue2.clear();
    }

    public void detach() {
        if (connected)
            createNotification();
        // items already in event queue (posted before detach() to mainLooper) will end up in queue1
        // items occurring later, will be moved directly to queue2
        // detach() and mainLooper.post run in the main thread, so all items are caught
        listener = null;
    }

    private void createNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel nc = new NotificationChannel(Constants.NOTIFICATION_CHANNEL, "Background service", NotificationManager.IMPORTANCE_HIGH);
            nc.setShowBadge(false);
            NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            nm.createNotificationChannel(nc);
        }
        Intent disconnectIntent = new Intent()
                .setAction(Constants.INTENT_ACTION_DISCONNECT);
        Intent restartIntent = new Intent()
                .setClassName(this, Constants.INTENT_CLASS_MAIN_ACTIVITY)
                .setAction(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_LAUNCHER);
        PendingIntent disconnectPendingIntent = PendingIntent.getBroadcast(this, 1, disconnectIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        PendingIntent restartPendingIntent = PendingIntent.getActivity(this, 1, restartIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, Constants.NOTIFICATION_CHANNEL)
                .setSmallIcon(R.drawable.applogo)
                .setColor(getResources().getColor(R.color.colorPrimary))
                .setContentTitle(getResources().getString(R.string.app_name))
                .setContentText(socket != null ? "Connected to " + socket.getName() : "Background Service")
                .setContentIntent(restartPendingIntent)
                .setOngoing(true)
                .addAction(new NotificationCompat.Action(R.drawable.ic_clear_white_24dp, "Disconnect", disconnectPendingIntent));
        // @drawable/ic_notification created with Android Studio -> New -> Image Asset using @color/colorPrimaryDark as background color
        // Android < API 21 does not support vectorDrawables in notifications, so both drawables used here, are created as .png instead of .xml
        Notification notification = builder.build();
        startForeground(Constants.NOTIFY_MANAGER_START_FOREGROUND_SERVICE, notification);
    }

    private void cancelNotification() {
        stopForeground(true);
    }

    /**
     * SerialListener
     */
    public void onSerialConnect() {
        if (connected) {
            synchronized (this) {
                if (listener != null) {
                    mainLooper.post(() -> {
                        if (listener != null) {
                            listener.onSerialConnect();
                        } else {
                            queue1.add(new QueueItem(QueueType.Connect, null, null));
                        }
                    });
                } else {
                    queue2.add(new QueueItem(QueueType.Connect, null, null));
                }
            }
        }
    }

    public void onSerialConnectError(Exception e) {
        if (connected) {
            synchronized (this) {
                if (listener != null) {
                    mainLooper.post(() -> {
                        if (listener != null) {
                            listener.onSerialConnectError(e);
                        } else {
                            queue1.add(new QueueItem(QueueType.ConnectError, null, e));
                            cancelNotification();
                            disconnect();
                        }
                    });
                } else {
                    queue2.add(new QueueItem(QueueType.ConnectError, null, e));
                    cancelNotification();
                    disconnect();
                }
            }
        }
    }

    public void generateMessage(String messageCode) {
        SmsManager mySmsManager = SmsManager.getDefault();
        String number = ((Variables) this.getApplication()).getAlertNumber();
        mAuth = FirebaseAuth.getInstance();
        final FirebaseUser currentFirebaseUser = mAuth.getCurrentUser();
        assert currentFirebaseUser != null;
        fuelTheftReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("fuelTheft");
        tamperingReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("tampering");
        alertReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid())
                .child("VEHICLE").child("Alert");

        if (messageCode.contains("3" + "\r\n")) {
            Date currentTime = Calendar.getInstance().getTime();
            tamperingReference.push().child("Time").setValue(currentTime);
            alertReference.setValue(1);
            //Intent callIntent = new Intent(Intent.ACTION_CALL);
            //callIntent.setData(Uri.parse("tel:"+number));
            //callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            //startActivity(callIntent);
            mySmsManager.sendTextMessage(number, null, "Vehicle is being tampered", null, null);
        } else if (messageCode.contains("2" + "\r\n")) {
            fuelTheftReference.push();
            Date currentTime = Calendar.getInstance().getTime();
            fuelTheftReference.push().child("Time").setValue(currentTime);
            alertReference.setValue(1);
            mySmsManager.sendTextMessage(number, null, "Fuel is being stolen", null, null);
        }else if(messageCode.equals("lift")){
            mySmsManager.sendTextMessage(number, null, "Vehicle being lifted", null, null);
        }

    }

    public void onSerialRead(byte[] data) {
        if (connected) {
            generateMessage(new String(data));
            synchronized (this) {
                if (listener != null) {
                    mainLooper.post(() -> {
                        if (listener != null) {
                            listener.onSerialRead(data);
                        } else {
                            queue1.add(new QueueItem(QueueType.Read, data, null));
                        }
                    });
                } else {
                    queue2.add(new QueueItem(QueueType.Read, data, null));
                }
            }
        }
    }

    public void onSerialIoError(Exception e) {
        if (connected) {
            synchronized (this) {
                if (listener != null) {
                    mainLooper.post(() -> {
                        if (listener != null) {
                            listener.onSerialIoError(e);
                        } else {
                            queue1.add(new QueueItem(QueueType.IoError, null, e));
                            cancelNotification();
                            disconnect();
                        }
                    });
                } else {
                    queue2.add(new QueueItem(QueueType.IoError, null, e));
                    cancelNotification();
                    disconnect();
                }
            }
        }
    }
    private void getCurrentLocation() {
        final LocationRequest locationRequest = new LocationRequest();
        locationRequest.setInterval(3000);
        locationRequest.setFastestInterval(2000);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        if (ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(this,
                        Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }


        LocationServices.getFusedLocationProviderClient(this)
                .requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper());

    }
    private LocationCallback locationCallback = new LocationCallback() {
        @Override
        public void onLocationResult(LocationResult locationResult) {
            super.onLocationResult(locationResult);
            if (locationResult != null && locationResult.getLastLocation() != null) {
                //stopLocationService();
                double latitude = locationResult.getLastLocation().getLatitude();
                double longitude = locationResult.getLastLocation().getLongitude();
                Log.d("Location_Update", latitude + "," + longitude);
                mAuth = FirebaseAuth.getInstance();
                final FirebaseUser currentFirebaseUser  = mAuth.getCurrentUser();
                assert currentFirebaseUser != null;
                locationDataReference = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid()).child("VEHICLE").child("Location");
                locationDataReference.child("Url").setValue("https://maps.google.com/?q=" + latitude + "," + longitude);
                locationDataReference.child("Latitude").setValue(latitude);
                locationDataReference.child("Longitude").setValue(longitude);
                stopLocationService();
            }
        }
    };

    private Boolean IsLocationServiceRunning() {
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);

        if (activityManager != null) {
            for (ActivityManager.RunningServiceInfo service :
                    activityManager.getRunningServices(Integer.MAX_VALUE)) {
                if (LocationService.class.getName().equals(service.service.getClassName())) {
                    if (service.foreground) {
                        return true;
                    }
                }
            }
            return false;
        }
        return false;
    }

    private void startLocationService() {
        if (!IsLocationServiceRunning()) {
            Intent intent = new Intent(getApplicationContext(), LocationService.class);
            intent.setAction(Constants.ACTION_START_LOCATION_SERVICE);
            startService(intent);
            Toast.makeText(this, "Location service started", Toast.LENGTH_SHORT).show();
        }
    }

    private void stopLocationService() {
        if (IsLocationServiceRunning()) {
            Intent intent = new Intent(getApplicationContext(), LocationService.class);
            intent.setAction(Constants.ACTION_STOP_LOCATION_SERVICE);
            startService(intent);
            Toast.makeText(this, "Location service stopped", Toast.LENGTH_SHORT).show();
        }
    }

    @Override//
    public int onStartCommand(Intent intent, int flags, int startId) {
        Toast.makeText(this, "Service Started", Toast.LENGTH_LONG).show();
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        //registering Sensor
        Sensor sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        sensorManager.registerListener(this,
                sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
                500000);

        //then you should return sticky
        return Service.START_STICKY;
    }


    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        if(connected) {
            double x, y, z, abs;
            boolean lift;

            x = sensorEvent.values[0];
            y = sensorEvent.values[1];
            z = sensorEvent.values[2];
            abs = Math.sqrt(x * x + y * y + z * z);
            if (abs > 11) {
                lift = true;
            } else {
                lift = false;
            }
            if (lastLift != lift) {
                if (sendMessage && locked) {
                    generateMessage("lift");
                    Toast.makeText(getApplicationContext(), "Detected", Toast.LENGTH_SHORT).show();
                }
                sendMessage = false;
                Handler mHandler = new Handler(Looper.getMainLooper());
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        sendMessage = true;
                    }
                };
                mHandler.postDelayed(runnable, 5000);

            }

            lastLift = lift;
        }

    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }







}
