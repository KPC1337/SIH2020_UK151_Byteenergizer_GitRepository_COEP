package com.example.sihserialautoamation;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

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
import com.hoho.android.usbserial.driver.UsbSerialDriver;
import com.hoho.android.usbserial.driver.UsbSerialProber;



public class MainActivity extends AppCompatActivity implements SensorEventListener {

    private static final int REQUEST_CODE_LOCATION_PERMISSION = 1;

    DatabaseReference reff;

    FirebaseAuth mAuth;

    private SensorManager sensorManager;
    Sensor accelerometer;
    TextView ready;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ready = findViewById(R.id.readyAlert);
        //serialRead = findViewById(R.id.serialValue);
        refresh();
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        sensorManager.registerListener(MainActivity.this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);

        Button sendButton = findViewById(R.id.sendButton);
        Button logoutbutton = findViewById(R.id.btn_logout);
        Button startLocationUpdates = findViewById(R.id.btn_startLocationUpdates);
        Button stopLocationUpdates = findViewById(R.id.btn_stopLocationUpdates);
        Button refreshButton = findViewById(R.id.btn_refresh);
        Button savePhoneNumber = findViewById(R.id.btn_savePhoneNumber);

        EditText phoneNumber = findViewById(R.id.editNumber);

        ActivityCompat.requestPermissions(MainActivity.this,new String[]{Manifest.permission.SEND_SMS},PackageManager.PERMISSION_GRANTED);
        ActivityCompat.requestPermissions(MainActivity.this,new String[]{Manifest.permission.CALL_PHONE},PackageManager.PERMISSION_GRANTED);

        SharedPreferences sharedPref = getSharedPreferences(Constants.SHARED_PREF_PHONE,MODE_PRIVATE);
        String savedNumber = sharedPref.getString(Constants.PHONE_NUMBER, "");
        phoneNumber.setText(savedNumber);
        ((Variables) this.getApplication()).setAlertNumber(savedNumber);


        savePhoneNumber.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SharedPreferences.Editor editor = sharedPref.edit();
                editor.putString(Constants.PHONE_NUMBER, phoneNumber.getText().toString());
                editor.apply();
                ((Variables) MainActivity.this.getApplication()).setAlertNumber(phoneNumber.getText().toString());
                Toast.makeText(MainActivity.this, "Phone number saved", Toast.LENGTH_SHORT).show();
            }
        });

        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (ContextCompat.checkSelfPermission(
                        getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(
                            MainActivity.this,
                            new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                            REQUEST_CODE_LOCATION_PERMISSION
                    );
                } else {
                    getCurrentLocation();
                }

            }
        });


        startLocationUpdates.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (ContextCompat.checkSelfPermission(
                        getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(
                            MainActivity.this,
                            new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                            REQUEST_CODE_LOCATION_PERMISSION
                    );
                } else {
                    startLocationService();
                }

            }
        });


        stopLocationUpdates.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (ContextCompat.checkSelfPermission(
                        getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(
                            MainActivity.this,
                            new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                            REQUEST_CODE_LOCATION_PERMISSION
                    );
                } else {
                    stopLocationService();
                }

            }
        });

        logoutbutton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mAuth.signOut();
                FirebaseUser user = null;
                Intent intent = new Intent(MainActivity.this, LoginActivity.class);
                startActivity(intent);
            }
        });

        refreshButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                refresh();
            }
        });


    }



    void refresh() {
        UsbManager usbManager = (UsbManager) this.getSystemService(Context.USB_SERVICE);
        UsbSerialProber usbDefaultProber = UsbSerialProber.getDefaultProber();
        for (UsbDevice device : usbManager.getDeviceList().values()) {
            UsbSerialDriver driver = usbDefaultProber.probeDevice(device);
            if (driver != null) {
                for (int port = 0; port < driver.getPorts().size(); port++) {
                    Bundle args = new Bundle();
                    args.putInt("device", device.getDeviceId());
                    args.putInt("port", port);
                    int baudRate = 9600;
                    args.putInt("baud", baudRate);
                    TerminalFragment fragment = new TerminalFragment();
                    fragment.setArguments(args);
                    getFragmentManager().beginTransaction().replace(R.id.flFragment, fragment, "terminal").addToBackStack(null).commit();
                }
            }
        }

    }

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


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CODE_LOCATION_PERMISSION && grantResults.length > 0) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getCurrentLocation();
            } else {
                Toast.makeText(this, "Permission denied", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void getCurrentLocation() {
        final LocationRequest locationRequest = new LocationRequest();
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(3000);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        mAuth = FirebaseAuth.getInstance();
        final FirebaseUser currentFirebaseUser = mAuth.getCurrentUser();

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        LocationServices.getFusedLocationProviderClient(MainActivity.this)
                .requestLocationUpdates(locationRequest, new LocationCallback() {

                    public void onLocationResult(LocationResult locationResult) {
                        super.onLocationResult(locationResult);
                        LocationServices.getFusedLocationProviderClient(MainActivity.this)
                                .removeLocationUpdates(this);
                        if (locationResult != null && locationResult.getLocations().size() > 0) {
                            int latestLocationIndex = locationResult.getLocations().size() - 1;
                            double lat = locationResult.getLocations().get(latestLocationIndex).getLatitude();
                            double lon = locationResult.getLocations().get(latestLocationIndex).getLongitude();
                            TextView latitude = findViewById(R.id.latitude);
                            TextView longitude = findViewById(R.id.longitude);
                            reff = FirebaseDatabase.getInstance().getReference().child("User").child(currentFirebaseUser.getUid()).child("VEHICLE").child("Location");
                            reff.child("Url").setValue("https://maps.google.com/?q=" + lat + "," + lon);
                            reff.child("Latitude").setValue(lat);
                            reff.child("Longitude").setValue(lon);
                            latitude.setText("latitude: " + lat);
                            longitude.setText("longitude: " + lon);
                        }

                    }

                }, Looper.getMainLooper());


    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        double x,y,z,abs;
        x = sensorEvent.values[0];
        y = sensorEvent.values[1];
        z = sensorEvent.values[2];
        abs = Math.sqrt(x*x+y*y+z*z);
        ready.setText(String.valueOf(abs));
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {


    }
    /*
    @SuppressLint("SetTextI18n")
    public void updateSerial () throws IOException {
        if (uri!=null) {

                serial = this.readTextFromUri(uri);
                serialRead.setText(lastLine+lineCount);
        }
        reff= FirebaseDatabase.getInstance().getReference();
        reff.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                String fuel = Objects.requireNonNull(snapshot.child("fuel").getValue()).toString();
                ready.setText(fuel);

            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });


    }

     */
/*
    private void smsCreate(){
        if(lastLine.equals("shake")){

        }
    }

*/

/*
    private static final int PICK_TEXT_FILE = 2;

    private void openFile() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("text/plain");

        startActivityForResult(intent, PICK_TEXT_FILE);
    }


    private String readTextFromUri(Uri uri) throws IOException {
        StringBuilder stringBuilder = new StringBuilder();

        try (InputStream inputStream =
                     getContentResolver().openInputStream(uri);
             BufferedReader reader = new BufferedReader(
                     new InputStreamReader(Objects.requireNonNull(inputStream)))) {
            String line;

            while ((line = reader.readLine()) != null) {
                stringBuilder.append(line).append(" ");
                lastLine = line;
                lineCount = stringBuilder.toString().split(" ").length;
            }
            int previousLineCount = 0;
            if(lineCount> previousLineCount){

            }
        }
        return stringBuilder.toString();
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode,
                                 Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (requestCode == PICK_TEXT_FILE
                && resultCode == Activity.RESULT_OK) {
            // The result data contains a URI for the document or directory that
            // the user selected.

            if (resultData != null) {
                uri = resultData.getData();
                // Perform operations on the document using its URI.

                try {

                                serial = this.readTextFromUri(uri);
                                serialRead.setText(lastLine);
                                //lineCount = serial.split("\r\n|\r|\n").length;



                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
*/

}
