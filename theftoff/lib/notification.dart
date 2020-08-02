import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:firebase/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:json_annotation/json_annotation.dart';
import 'package:theftoff/splash.dart';
import 'package:url_launcher/url_launcher.dart';

 String _now;
  var _everySecond;
// String userId = "ub83XkABeaPm0VzEywCwAb4q7e22";

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  // final firestoreReference = Firestore.instance;S
  // StreamBuilder(
  //                 stream: Firestore.instance
  //                     .collection("messages").snapshots(),
  //                 builder: (context, snapshot) {
  //                   switch (snapshot.connectionState) {
  //                     case ConnectionState.none:
  //                     case ConnectionState.waiting:
  //                       return Center(
  //                         child: PlatformProgressIndicator(),
  //                       );
  //                     default:
  //                       return ListView.builder(
  //                         reverse: true,
  //                         itemCount: snapshot.data.documents.length,
  //                         itemBuilder: (context, index) {
  //                           List rev = snapshot.data.documents.reversed.toList();
  //                           ChatMessageModel message = ChatMessageModel.fromSnapshot(rev[index]);
  //                           return ChatMessage(message);
  //                         },
  //                       );
  //                   }
  //                 },
  //               )

final firestoreReference = Firestore.instance;
QuerySnapshot qn ;
@override
//   void init(){
//     super.initState();

// _now = DateTime.now().second.toString();

//     // defines a timer 
//     _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) async {
//       //Dataretrievalcode
//       var firestore = Firestore.instance;
//     QuerySnapshot qn =
//         await firestore.collection("location").getDocuments();
//       setState(() {
//         _now = DateTime.now().second.toString();
//       });
//     });
//   }

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
                    return Card(
                      child:ListTile(
                        title: Text(data["whatHappened"]),
                        subtitle: Text(data["whenHappened"]),
                        onTap:(){
                          launch(data["whereHappened"]);
                        } ,
                      )
                    );
                    // return ProductItem(
                    //   documentSnapshot: data,
                    //   id: data.documentID,
                    //   isFavourite: data['isFavourite'],
                    //   imageUrl: data['imageUrl'],
                    //   productName: data['productName'],
                    //   productPrice: data['productPrice'],
                    // );
                  },
                );
  }));
}}