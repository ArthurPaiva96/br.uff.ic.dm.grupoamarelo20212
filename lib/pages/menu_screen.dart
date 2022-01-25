import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

    var serviceEnabled = await location.serviceEnabled();
    while (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    var permissionGranted = await location.hasPermission();
    while(permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    var userLocation = await location.getLocation();

    var userDB = FirebaseFirestore.instance.collection('person').doc(this.user.id);
    await userDB.update({
      "lat": userLocation.latitude,
      "long": userLocation.longitude,
    });

  }
}
