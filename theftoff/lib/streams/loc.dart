import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final databaseReferenceTest = FirebaseDatabase.instance.reference();
bool loc = false;
String mapUrl;

locUrl (BuildContext context,String uid) {
  if(loc == true){
  databaseReferenceTest
      .child('User')
      .child(uid)
      .child('VEHICLE')
      .child('Location')
      .child('Url')
      .onValue
      .listen((event) {
    var snapshot = event.snapshot;
    print(snapshot.value);
     mapUrl = snapshot.value;
     print("\n\n\n\n\n\n\n");
    print(mapUrl);
    databaseReferenceTest
          .child("User")
          .child(uid)
          .child("VEHICLE")
          .update({"locationRequest": 0});
    
  });
  }else{
    print("DONE");
  }
}





// databaseReference
//         .child('User')
//         .child('Tc9vFxMVQJZnHsK3vMRrAKFJag82')
//         .child('VEHICLE')
//         .child('Location')
//         .child('Url')
//         .onValue
//         .listen((event) {
//       print("===========================================");
//       var snapshot = event.snapshot;
//       // print(snapshot.value);
//       mapUrl = snapshot.value;
//       print(mapUrl);
      