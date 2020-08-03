import 'package:flutter/material.dart';
import 'package:theftoff/notification.dart';

import 'package:theftoff/splash.dart';


var routes = <String, WidgetBuilder>{
  "/not":(BuildContext context) => NotificationScreen(),
};

void main() => runApp(new MaterialApp(
    theme:
    ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
   routes: routes)
   );




