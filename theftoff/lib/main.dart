import 'package:flutter/material.dart';
import 'package:theftoff/anotherpage.dart';
import 'package:theftoff/home.dart';
// import 'package:theftoff/LoginScreen.dart';
import 'package:theftoff/navigator.dart';
import 'package:theftoff/notification.dart';
import 'package:theftoff/profile.dart';
// import 'package:theftoff/map';

import 'package:theftoff/splash.dart';
import 'package:firebase_database/firebase_database.dart';


var routes = <String, WidgetBuilder>{
  // "/Signin": (BuildContext context) => GoogleSignApp(),
  //  "/prof": (BuildContext context) => Profile(),
  "/not":(BuildContext context) => NotificationScreen(),
};

void main() => runApp(new MaterialApp(
    theme:
    ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    // home: NotificationScreen(),
    // home: AnPage(),
    // home:MyApp(),
   routes: routes)
   );




