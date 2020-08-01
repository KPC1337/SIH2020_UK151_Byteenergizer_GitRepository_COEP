import 'package:flutter/material.dart';
import 'package:theftoff/anotherpage.dart';
import 'package:theftoff/home.dart';
// import 'package:theftoff/LoginScreen.dart';
import 'package:theftoff/navigator.dart';
import 'package:theftoff/profile.dart';
// import 'package:theftoff/map';

import 'package:theftoff/splash.dart';
import 'package:firebase_database/firebase_database.dart';


var routes = <String, WidgetBuilder>{
  // "/Signin": (BuildContext context) => GoogleSignApp(),
   "/prof": (BuildContext context) => Profile(),
  // "/map":(BuildContext context) => MapSample(),
};

void main() => runApp(new MaterialApp(
    theme:
    ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
    debugShowCheckedModeBanner: false,
    // home: SplashScreen(),
    home: AnPage(),
    // home:MyApp(),
   routes: routes)
   );




 DB(String path, String user) {
        final databaseReference = FirebaseDatabase.instance.reference().child(user);
        databaseReference.child(path).set("T");       
      }
