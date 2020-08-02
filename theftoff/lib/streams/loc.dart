import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final databaseReferenceTest = FirebaseDatabase.instance.reference();

locUrl (BuildContext context) {
  databaseReferenceTest
      .child('User')
      .child('Tc9vFxMVQJZnHsK3vMRrAKFJag82')
      .child('VEHICLE')
      .child('Location')
      .child('Url')
      .onValue
      .listen((event) {
    var snapshot = event.snapshot;
    print(snapshot.value);
    String mapUrl = snapshot.value;
    print(mapUrl);
    
  });
}
