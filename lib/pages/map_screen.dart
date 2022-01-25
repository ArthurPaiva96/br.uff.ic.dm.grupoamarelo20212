import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int lat = 0;
  int long = 0;


  @override
  Widget build(BuildContext context) {
    var coordinates = (ModalRoute.of(context)!.settings.arguments as Map);
    this.lat = coordinates["lat"];
    this.long = coordinates["long"];

    print(this.lat);
    print(this.long);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
