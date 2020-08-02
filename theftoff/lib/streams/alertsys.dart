import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:theftoff/splash.dart';

bool pressed = false ;
final databaseReferenceTest = FirebaseDatabase.instance.reference();

notifier(BuildContext context) {
  if (pressed == false){
    pressed = true;
  databaseReferenceTest
      .child('User')
      .child(userID)
      .child('VEHICLE')
      .child('alarm')
      .onValue
      .listen((event) {
    var snapshot = event.snapshot;
    int value = snapshot.value;
    print(value);
    if (value == 1) {
      FlutterRingtonePlayer.playAlarm(volume: 10.0);
      AwesomeDialog(
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.SCALE,
          body: Center(
            child: Text(
              "Your Alarm is On",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          btnOkOnPress: () {
            databaseReferenceTest
          .child("User")
      .child(userID)
          .child("VEHICLE")
          .update({"alarm": 0});
          },
          btnCancelOnPress: (){
            databaseReferenceTest
          .child("User")
      .child(userID)
          .child("VEHICLE")
          .update({"Alert": 0});
          }
          )..show();
    }
    if (value == 0) {
      FlutterRingtonePlayer.stop();
    }
  });
}else{
  print('Already done');
}
}