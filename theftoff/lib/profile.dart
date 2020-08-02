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
import 'package:theftoff/streams/loc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String mapUrl ;
  Future getGoogleUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    photoURL = user.photoUrl;
    displayName = user.displayName;
    email = user.email;
    uid = user.uid;
    print(
        "\n\n\n\n\n\n $photoURL\n\n $displayName \n\n$email\n\n $uid\n\n\n\n\n\n");
    setState(() {});
  }

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  
  onTaploc(){
    databaseReference
        .child("User")
        .child(uid)
        .child("VEHICLE")
        .update({"locationRequest": 0});
    databaseReference
        .child("User")
        .child(uid)
        .child("VEHICLE")
        .child("Location")
        .once()
        .then((DataSnapshot snapshot) {
      mapUrl = snapshot.value['Url'];

    });
  }
  onTapMap() async {
    if(mapUrl!=null){
    launch(mapUrl);}
    else{
      SnackBar(content: Text("Get Location First"),duration: Duration(seconds:2));
    }
  }

  onTapSwitch() async {
    notifier(context, uid);
    mapUrl = locUrl(context, uid);
    int isLock;
    getGoogleUserData();
    await databaseReference
        .child("User")
        .child(uid)
        .child("VEHICLE")
        .once()
        .then((DataSnapshot snapshot) {
      isLock = snapshot.value['isLocked'];
      print(isLock);
      isLock = (isLock == 0) ? 1 : 0;
    }).then((val) {
      databaseReference
          .child("User")
          .child(uid)
          .child("VEHICLE")
          .update({"isLocked": isLock});
    });
  }

  onTapConnect() {}

  onTapAlarm() {
    int alert;
    databaseReference
        .child("User")
        .child(uid)
        .child("VEHICLE")
        .once()
        .then((DataSnapshot snapshot) {
      alert = snapshot.value['alarm'];

      print(alert);
      alert = (alert == 0) ? 1 : 0;
    }).then((val) {
      databaseReference
          .child("User")
          .child(uid)
          .child("VEHICLE")
          .update({"alarm": alert});
    });
  }

  onTapAlarmOff() {
    int alert;
    databaseReference
        .child("User")
        .child(uid)
        .child("VEHICLE")
        .once()
        .then((DataSnapshot snapshot) {
      alert = snapshot.value['Alert'];

      print(alert);
      alert = (alert == 0) ? 1 : 0;
    }).then((val) {
      databaseReference
          .child("User")
          .child(uid)
          .child("VEHICLE")
          .update({"Alert": alert});
    });
  }

  @override
  void initState() {
    super.initState();
    getGoogleUserData();

    //Location
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
                      onTapAlarm();
                    })
                  ..show();
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
            myItems(Icons.map, "getloc", 0xffed622b, onTaploc),
            myItems(FontAwesomeIcons.bell, "Alarm", 0xffed622b, onTapAlarm),
            myItems(FontAwesomeIcons.bellSlash, "Alarm off", 0xffed622b,
                onTapAlarmOff),
            myItems(Icons.wifi, "Connect", 0xffed622b, onTapConnect),
          ],
          staggeredTiles: [
            StaggeredTile.extent(3, 100.0),
            StaggeredTile.extent(2, 100.0),
            StaggeredTile.extent(1, 100.0),
            StaggeredTile.extent(3, 100.0),
            StaggeredTile.extent(1, 100.0),
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
