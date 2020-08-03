import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:theftoff/LoginScreen.dart';
import 'package:theftoff/home.dart';

import 'package:theftoff/profile.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 2), ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>CheckAuth())));
  }
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
        child: Image(image: AssetImage('lib/assets/pp.jpg'),)
    ),    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isLoggedIn;
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  @override
  void initState() {
    isLoggedIn = false;

    print("=====================================");
    FirebaseAuth.instance.currentUser().then((user) => user != null
        ? setState(() {
            isLoggedIn = true;
            userID = user.uid;
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
                    print("\n\n==================\n $state \n =================== ");
                  }
                });
          })
        : null);
    super.initState();
    // new Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? new MyHomePage() : new GoogleSignApp();
  }
}
String userID;
bool state =false;