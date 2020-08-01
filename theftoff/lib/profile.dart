import 'package:backdrop/backdrop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:theftoff/navigator.dart';
// import 'package:theftoff/msg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:theftoff/streams/alertsys.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Profile extends StatefulWidget {
  // final UserDetails detailsUser=UserDetails(providerDetails, userName, photoUrl, userEmail, providerData);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool not;
  String photoURL =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/80px-Apple_logo_black.svg.png";
  String displayName = "";
  String email = "";
  String uid = "";
  Future getGoogleUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    photoURL = user.photoUrl;
    displayName = user.displayName;
    email = user.email;
    uid = user.uid;

    setState(() {});
  }

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  onTapMap() {
    // MyNavigator.goToMap(context);
  }

  onTapSwitch() {
    int isLock;
    databaseReference
        .child("User")
        .child("Tc9vFxMVQJZnHsK3vMRrAKFJag82")
        .child("VEHICLE")
        .once()
        .then((DataSnapshot snapshot) {
      isLock = snapshot.value['isLocked'];
      // long = snapshot.value['Longitude'];
      // print('Data : ${snapshot.value['Latitude']}');
      print(isLock);
      isLock = (isLock == 0) ? 1 : 0;
    }).then((val) {
      databaseReference
          .child("User")
          .child("Tc9vFxMVQJZnHsK3vMRrAKFJag82")
          .child("VEHICLE")
          .update({"isLocked": isLock});
    });
  }

  onTapAlarm() {int alert;
    databaseReference
        .child("User")
        .child("Tc9vFxMVQJZnHsK3vMRrAKFJag82")
        .child("VEHICLE")
        .once()
        .then((DataSnapshot snapshot) {
      alert = snapshot.value['Alert'];
      
      print(alert);
      alert = (alert == 0) ? 1 : 0;
    }).then((val) {
      databaseReference
          .child("User")
          .child("Tc9vFxMVQJZnHsK3vMRrAKFJag82")
          .child("VEHICLE")
          .update({"Alert": alert});
    });
  }

  onTapConnect() {
    print("Connect");
  }

  @override
  void initState() {
    super.initState();
    getGoogleUserData();
    notifier(not);
  }

  Material myItems(IconData icon, String heading, int color, Function onTapFn) {
    return Material(
      color: Colors.red[300],
      elevation: 6.0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      child: Center(
          child: InkWell(
        onTap: onTapFn,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //icon
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        icon,
                        color: Colors.red,
                        size: 23.0,
                      ),
                    ),
                  ),
                  //text
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      heading,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return BackdropScaffold(
        appBar: BackdropAppBar(
          title: Text(displayName),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                print("notifications");
              },
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                _gSignIn.signOut();
                print('Signed out');
                MyNavigator.goToSignin(context);
              },
            ),
          ],
        ),
        // Height of front layer when backlayer is shown.
        headerHeight: 40.0,
        frontLayer: StaggeredGridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 3.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            myItems(Icons.lock, "Switch", 0xffed622b, onTapSwitch),
            myItems(Icons.map, "Find my Ride", 0xffed622b, onTapMap),
            myItems(FontAwesomeIcons.bell, "Alarm", 0xffed622b, onTapAlarm),
            myItems(Icons.bluetooth, "Connect", 0xffed622b, onTapConnect),
          ],
          staggeredTiles: [
            StaggeredTile.extent(3, 100.0),
            StaggeredTile.extent(3, 100.0),
            StaggeredTile.extent(3, 100.0),
            StaggeredTile.extent(3, 100.0),
          ],
        ),
        backLayer: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(photoURL),
                radius: 50.0,
              ),
              SizedBox(height: 10.0),
              Text(
                "Name : " + displayName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
              Text(
                "Email : " + email,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ));
  }
}
