import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// The menu page with options to navigate to other screen such as PersonView, Contacts and Preferences
// It also gets and updates the user location as he or she logs in
class MenuScreen extends StatefulWidget {
  MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Person user;

  @override
  Widget build(BuildContext context) {
    updateUserLocation();
    setOneId();

    user = (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];

    return Scaffold(
      backgroundColor: Color(0xFF527DAA),
      appBar: AppBar(
        title: Text("Menu"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Pessoas"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                minimumSize: Size(300, 36),
              ),
              onPressed: () {
                // Calls the PersonView screen
                Navigator.pushNamed(context, "/personview", arguments: {
                  "personLogged": this.user,
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                child: Text("Chat"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(300, 36),
                ),
                onPressed: () {
                  // Calls the Contacts screen
                  Navigator.pushNamed(context, "/contacts", arguments: {
                    "personLogged": this.user,
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                child: Text("Preferências"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(300, 36),
                ),
                onPressed: () {
                  // Calls the Preferences screen
                  Navigator.pushNamed(context, "/preferences", arguments: {
                    "personLogged": this.user,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateUserLocation() async {

    var location = new Location();

    // Verifies if the location is enabled on the cellphone
    var serviceEnabled = await location.serviceEnabled();
    while (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    // Asks the user permission to use the cellphone location
    var permissionGranted = await location.hasPermission();
    while(permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    var userLocation = await location.getLocation();

    // updates the database with the user location
    var userDB = FirebaseFirestore.instance.collection('person').doc(this.user.id);
    await userDB.update({
      "lat": userLocation.latitude,
      "long": userLocation.longitude,
    });

  }

  setOneId() async{

    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;

    var userDB = FirebaseFirestore.instance.collection('person').doc(this.user.id);

    userDB.update({"oneId": osUserID});
  }
}
