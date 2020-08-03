import 'dart:async';

import 'package:backdrop/backdrop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:theftoff/msg.dart';
import 'package:theftoff/navigator.dart';
import 'package:theftoff/splash.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final firestoreReference = Firestore.instance;

  bool not;
  String photoURL =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/80px-Apple_logo_black.svg.png";
  String displayName = "";
  String email = "";
  String uid = "";
  String mapUrl = "";
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

  onTapMap() {
    databaseReference
        .child("User")
        .child(userID)
        .child("VEHICLE")
        .update({"locationRequest": 1});
    launch(mapUrl);
  }

  onTapSms() {
    sms();
  }

  onTapConnect() {}
  @override
  void initState() {
    super.initState();
    getGoogleUserData();
    databaseReference
        .child('User')
        .child(userID)
        .child('VEHICLE')
        .child('Location')
        .child('Url')
        .onValue
        .listen((event) {
      var snapshot = event.snapshot;
      mapUrl = snapshot.value;
      print(mapUrl);
      databaseReference
          .child("User")
          .child(userID)
          .child("VEHICLE")
          .update({"locationRequest": 0});
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return BackdropScaffold(
        appBar: BackdropAppBar(
          title: Text(displayName),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                MyNavigator.goToNot(context);
              },
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                _gSignIn.signOut();
                print('Signed out');
                MyNavigator.goToSignin(context);
              },
            ),
          ],
        ),
        headerHeight: 40.0,
        frontLayer: Center(
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
                  builder:
                      (BuildContext context, AsyncSnapshot<Event> snapshot) {
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
                        onChanged: (state) {
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              onTapMap();
                            },
                            icon: Icon(Icons.my_location),
                            label: Text("Locate My Ride")),
                      ),
                      Expanded(
                        child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              onTapMap();
                            },
                            icon: Icon(Icons.sms),
                            label: Text("Sms Connect")),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.scale(
                scale: 2.5,
                child: StreamBuilder(
                    stream: databaseReference
                        .child("User")
                        .child(userID)
                        .child('VEHICLE')
                        .child('isLocked')
                        .onValue,
                    builder:
                        (BuildContext context, AsyncSnapshot<Event> snapshot) {
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
            ])),
        backLayer: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(photoURL),
                radius: 50.0,
              ),
              SizedBox(height: 10.0),
              Text(
                "Name : " + displayName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              Text(
                "Email : " + email,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ));
  }
}
