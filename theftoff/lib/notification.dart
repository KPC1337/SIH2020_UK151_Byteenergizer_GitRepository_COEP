
import 'package:flutter/material.dart';
// import 'package:firebase/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:json_annotation/json_annotation.dart';
import 'package:theftoff/splash.dart';
import 'package:url_launcher/url_launcher.dart';


class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  

final firestoreReference = Firestore.instance;
QuerySnapshot qn ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title:Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(userID).snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.documents[index];
                    return 
                    Card(
                      child:ListTile(
                        title: Text(data["whatHappened"]),
                        subtitle: Text(data["whenHappened"]),
                        onTap:(){
                          launch(data["whereHappened"]);
                        } ,
                      )
                    );
                  },
                );
  }));
}}