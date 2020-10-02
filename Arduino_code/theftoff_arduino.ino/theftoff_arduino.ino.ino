#define ignitionPin 6 // connects to ground of ignition key switch
#define vibrationPin 7 // connects to digital output of vibration sensor attached to ignition harness
#define relayPin 2 // controls the relay connecting CDI and ignition coil
#define alarmPin 11 // controls the horn/alarm system of the vehicle
#define fuel A0

int lastfuel = 0;
int tolerance = 5;

int data = 0;

bool lockState = LOW;
bool alarmState = LOW;
bool lastIgnitionState = LOW;
bool lastVibrationSense = LOW;
bool lastFuelTheft = LOW;
bool fuelTheft = LOW;
bool ignitionTampering = LOW;
bool lastIgnitionTampering = LOW;

const int LOCK_DATA = 5;
const int UNLOCK_DATA = 6;
const int FUEL_THEFT_DATA = 2;
const int IGNITION_TAMPERING_DATA = 3;
const int ALARM_ON_DATA = 8;
const int ALARM_OFF_DATA = 9;

unsigned long nextFreqTime = 0;
unsigned long nextFreqTime2 = 0;
int delaytime = 1000;

void setup() {

  pinMode(ignitionPin, INPUT);
  pinMode(vibrationPin, INPUT_PULLUP);
  pinMode(relayPin, OUTPUT);
  pinMode(alarmPin, OUTPUT);



  Serial.begin(9600);
}

void loop() {
  bool ignitionState = digitalRead(ignitionPin);
  bool vibrationSense = digitalRead(vibrationPin);

  unsigned long now = millis();

  if (Serial.available() > 0) {
    data = Serial.read() - '0';
    Serial.println(data, DEC);
    dataHandler(data);
  }


  int currentfuel = analogRead(fuel);
  if (lockState) {

    if (!ignitionState){
      if (ignitionState != lastIgnitionState)
        nextFreqTime2 = now + delaytime;   
    }
    else if(!vibrationSense){
            if(vibrationSense != lastVibrationSense){
              nextFreqTime2 = now + delaytime;
            }
    }  
    
    else if (currentfuel < (lastfuel - tolerance)) {
      nextFreqTime = now + delaytime;
       /*
       Serial.println(FUEL_THEFT_DATA);
         Serial.print("Currentfuel: ");
         Serial.println(currentfuel);
         Serial.print("lastfuel: ");
         Serial.println(lastfuel);
        */
    }
    delay(10);
  }  lastfuel = currentfuel;

  /*
  Serial.print("now:");
  Serial.println(now);
  Serial.print("nextfrequency: ");
  Serial.println(nextFreqTime);
  Serial.print("nextfrequency2: ");
  Serial.println(nextFreqTime2);
  Serial.print("Currentfuel: ");
  Serial.println(currentfuel);
  Serial.print("vibrationsense: ");
  Serial.println(vibrationSense);
  */

  if (now < nextFreqTime)
  {
    digitalWrite(alarmPin, HIGH);
    fuelTheft = HIGH;
    if (lastFuelTheft != fuelTheft) {
      Serial.println(FUEL_THEFT_DATA);
    }
  }
  else {
    fuelTheft = LOW;
  }

  if (now < nextFreqTime2)
  {
    digitalWrite(alarmPin, HIGH);
    ignitionTampering = HIGH;
    if (lastIgnitionTampering != ignitionTampering) {
      Serial.println(IGNITION_TAMPERING_DATA);
    }
  }
  else {
    ignitionTampering = LOW;
  }

  if (!ignitionTampering && !fuelTheft) {
    digitalWrite(alarmPin, LOW);
  }



  lastIgnitionState = ignitionState;
  lastVibrationSense = vibrationSense;
  lastFuelTheft = fuelTheft;
  lastIgnitionTampering = ignitionTampering;

}


void dataHandler(int data) {
  switch (data) {
    case LOCK_DATA:
      lockState = HIGH;
      digitalWrite(relayPin, HIGH);
      lockSound();
      break;
    case UNLOCK_DATA:
      lockState = LOW;
      digitalWrite(relayPin, LOW);
      unlockSound();
      break;
    case ALARM_ON_DATA:
      digitalWrite(alarmPin, HIGH);
      delay(3000);
      break;
    case ALARM_OFF_DATA:
      digitalWrite(alarmPin, LOW);
      break;
  }
}

void lockSound() {
  digitalWrite(alarmPin, HIGH);
  delay(100);
  digitalWrite(alarmPin, LOW);
}


void unlockSound() {
  digitalWrite(alarmPin, HIGH);
  delay(100);
  digitalWrite(alarmPin, LOW);
  delay(200);
  digitalWrite(alarmPin, HIGH);
  delay(100);
  digitalWrite(alarmPin, LOW);
}
