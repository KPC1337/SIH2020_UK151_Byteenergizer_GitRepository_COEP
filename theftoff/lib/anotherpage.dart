import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class AnPage extends StatefulWidget {
  @override
  _AnPageState createState() => _AnPageState();
}

class _AnPageState extends State<AnPage> {
  bool state;
  int data;
  String photoURL =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/80px-Apple_logo_black.svg.png";
  String displayName ;
  String email ;
  String uid = "ub83XkABeaPm0VzEywCwAb4q7e22";
  String mapUrl ;
  Future getGoogleUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    photoURL = user.photoUrl;
    displayName = user.displayName;
    email = user.email;
    uid = user.uid;

    setState(() {});
  }

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    getGoogleUserData();
    databaseReference
        .child('User')
        .child(uid)
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
          RaisedButton(onPressed: () {
            print("\n\n\n\n====================\n\n\n\n");
          }),
          Transform.scale(
            scale: 2.5,
            child: StreamBuilder(
                stream: databaseReference
                    .child("User")
                    .child(uid)
                    .child('VEHICLE')
                    .child('isLocked')
                    .onValue,
                builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                  databaseReference
                      .child("User")
                      .child(uid)
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
                                .child(uid)
                                .child('VEHICLE')
                                .update({'isLocked': 1})
                            : databaseReference
                                .child("User")
                                .child('ub83XkABeaPm0VzEywCwAb4q7e22')
                                .child('VEHICLE')
                                .update({'isLocked': 0});
                      });
                }),
          ),
        ])));
  }
}
