import 'package:flutter/material.dart';

class MyNavigator {
  static void goToSignin(BuildContext context) {
    Navigator.pushNamed(context, "/Signin");
  }

  static void goToProf(BuildContext context) {
    Navigator.pushNamed(context, "/prof");
  }
  
  static void goToNot(BuildContext context) {
    Navigator.pushNamed(context, "/not");
  }
}
