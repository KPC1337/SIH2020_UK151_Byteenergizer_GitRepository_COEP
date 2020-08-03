import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:theftoff/splash.dart';

class AnPage extends StatefulWidget {
  @override
  _AnPageState createState() => _AnPageState();
}

class _AnPageState extends State<AnPage> {
  
  int data;
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    databaseReference
        .child('User')
        .child(userID)
        .child('VEHICLE')
        .child('isLocked')
        .onValue
        .listen((event) {
      var snapshot = event.snapshot;
      print(snapshot.value);
      data = snapshot.value;
      if (data == 1) {
        state = true;
      } else {
        state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
          StreamBuilder(
              stream: databaseReference
                  .child("User")
                  .child(userID)
                  .child('VEHICLE')
                  .child('Alarm')
                  .onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                databaseReference
                    .child("User")
                    .child(userID)
                    .child('VEHICLE')
                    .once()
                    .then((DataSnapshot snapshot) {
                  int value = snapshot.value['Alarm'];
                  if (value == 1) {
                    state = true;
                  } else {
                    state = false;
                  }
                });
                return LiteRollingSwitch(
                    value: state,
                    textOn: 'active',
                    textOff: 'inactive',
                    colorOn: Colors.deepOrange,
                    colorOff: Colors.blueGrey,
                    iconOn: Icons.alarm_on,
                    iconOff: Icons.alarm_off,
                    onChanged: (bool state) {
                      state
                          ? databaseReference
                              .child("User")
                              .child(userID)
                              .child('VEHICLE')
                              .update({'Alarm': 1})
                          : databaseReference
                              .child("User")
                              .child(userID)
                              .child('VEHICLE')
                              .update({'Alarm': 0});
                    });
              }),
              FlatButton(onPressed: (){}, child: Text("HOHO")),
          Transform.scale(
          scale: 2.5,
          child:
          StreamBuilder(
              stream: databaseReference
                  .child("User")
                  .child(userID)
                  .child('VEHICLE')
        .child('isLocked')
                  .onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                databaseReference
                    .child("User")
                    .child(userID)
                    .child('VEHICLE')
                    .once()
                    .then((DataSnapshot snapshot) {
                  int value = snapshot.value['isLocked'];
                  if (value == 1) {
                    state = true;
                  } else {
                    state = false;
                  }
                });
                return LiteRollingSwitch(
                    value: state,
                    textOn: 'active',
                    textOff: 'inactive',
                    colorOn: Colors.deepOrange,
                    colorOff: Colors.blueGrey,
                    iconOn: Icons.lightbulb_outline,
                    iconOff: Icons.power_settings_new,
                    onChanged: (bool state) {
                      state
                          ? databaseReference
                              .child("User")
                              .child(userID)
                              .child('VEHICLE')
                              .update({'isLocked': 1})
                          : databaseReference
                              .child("User")
                              .child(userID)
                              .child('VEHICLE')
                              .update({'isLocked': 0});
                    });
              }),
          ),
          
        ])));
  }
}
