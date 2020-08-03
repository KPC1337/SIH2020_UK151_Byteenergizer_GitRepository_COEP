// import 'dart:async';

// import 'package:backdrop/backdrop.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:theftoff/navigator.dart';
// // import 'package:theftoff/msg.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:theftoff/notification.dart';
// import 'package:theftoff/splash.dart';
// import 'package:theftoff/streams/alertsys.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:url_launcher/url_launcher.dart';


//  String _now;
//   var _everySecond;
// class Profile extends StatefulWidget {
//   // final UserDetails detailsUser=UserDetails(providerDetails, userName, photoUrl, userEmail, providerData);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {

//   final firestoreReference = Firestore.instance;

//   bool not;
//   String photoURL =
//       "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/80px-Apple_logo_black.svg.png";
//   String displayName = "";
//   String email = "";
//   String uid = "";
//   String mapUrl="";
//   Future getGoogleUserData() async {
//     FirebaseUser user = await FirebaseAuth.instance.currentUser();

//     photoURL = user.photoUrl;
//     displayName = user.displayName;
//     email = user.email;
//     uid = user.uid;

//     setState(() {});
//   }

//   final DatabaseReference databaseReference =
//       FirebaseDatabase.instance.reference();

//   onTapMap() {
//     // print("\n\n\n\n\n\n\n\nONTAP\n\n\n\n\n\n\n\n\n\n");
//     // print(mapUrl);
//     databaseReference
//           .child("User")
//       .child(userID)
//           .child("VEHICLE")
//           .update({"locationRequest":1});
//     launch(mapUrl);
//     // MyNavigator.goToMap(context);

//   }

//   onTapConnect(){}


//   @override
//   void initState() {
//     super.initState();
//     getGoogleUserData();
//     notifier(context);

//     //Location
//   //   databaseReference
//   //     .child('User')
//   //     .child(userID)
//   //     .child('VEHICLE')
//   //     .child('Location')
//   //     .child('Url')
//   //     .onValue
//   //     .listen((event) {
//   //   var snapshot = event.snapshot;
//   //   // print(snapshot.value);
//   //   mapUrl = snapshot.value;
//   //   print(mapUrl);
//   //   databaseReference
//   //         .child("User")
//   //     .child(userID)
//   //         .child("VEHICLE")
//   //         .update({"locationRequest":0});
//   // });




//   }

//   // Material myItems(IconData icon, String heading, int color, Function onTapFn) {
//   //   return Material(
//   //     color: Colors.red[300],
//   //     elevation: 6.0,
//   //     shadowColor: Colors.transparent,
//   //     borderRadius: BorderRadius.circular(24.0),
//   //     child: Center(
//   //         child: InkWell(
//   //       onTap: onTapFn,
//   //       child: Padding(
//   //         padding: const EdgeInsets.all(8.0),
//   //         child: Row(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: <Widget>[
//   //             Column(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: <Widget>[
//   //                 //icon
//   //                 Material(
//   //                   color: Colors.white,
//   //                   borderRadius: BorderRadius.circular(24.0),
//   //                   child: Padding(
//   //                     padding: const EdgeInsets.all(6.0),
//   //                     child: Icon(
//   //                       icon,
//   //                       color: Colors.red,
//   //                       size: 23.0,
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 //text
//   //                 Padding(
//   //                   padding: const EdgeInsets.all(2.0),
//   //                   child: Text(
//   //                     heading,
//   //                     style: TextStyle(
//   //                       color: Colors.white,
//   //                       fontSize: 10.0,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     )),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final GoogleSignIn _gSignIn = GoogleSignIn();

//     return BackdropScaffold(
        
//         appBar: BackdropAppBar(
//           title: Text(displayName),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(
//                 Icons.notifications,
//                 size: 20.0,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 MyNavigator.goToNot(context);
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 FontAwesomeIcons.signOutAlt,
//                 size: 20.0,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 _gSignIn.signOut();
//                 print('Signed out');
//                 MyNavigator.goToSignin(context);
//               },
//             ),
//           ],
//         ),
//         // Height of front layer when backlayer is shown.
//         headerHeight: 40.0,
//         // frontLayer: StaggeredGridView.count(
//           // crossAxisCount: 3,
//           // crossAxisSpacing: 4.0,
//           // mainAxisSpacing: 3.0,
//           // padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           // children: <Widget>[
//           //   myItems(Icons.map, "Find my Ride", 0xffed622b, onTapMap),
//           //   myItems(Icons.map, "SMS Connect", 0xffed622b, onTapMap),
//           //   myItems(Icons.map, "Bluetooth Pairing", 0xffed622b, onTapMap),
//           //   myItems(Icons.map, "", 0xffed622b, onTapMap),
//           // ],
//           // staggeredTiles: [
//           //   StaggeredTile.extent(3, 80.0),
//           //   StaggeredTile.extent(3, 80.0),
//           //   StaggeredTile.extent(3, 200.0),
//           //   // StaggeredTile.extent(1, 100.0),
//           //   StaggeredTile.extent(3, 100.0),
//           // ],
          
//         ),
//         backLayer: 
//         Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               CircleAvatar(
//                 backgroundImage: NetworkImage(photoURL),
//                 radius: 50.0,
//               ),
//               SizedBox(height: 10.0),
//               Text(
//                 "Name : " + displayName,
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     fontSize: 20.0),
//               ),
//               SizedBox(height: 10.0),
//               Text(
//                 "Email : " + email,
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     fontSize: 20.0),
//               ),
//               SizedBox(height: 10.0),
//             ],
//           ),
//         ));
//   }
// }
