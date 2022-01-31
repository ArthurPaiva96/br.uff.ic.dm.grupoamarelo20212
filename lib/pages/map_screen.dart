import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


// The map page mostly loads an map using the Flutter Map with MapBox and shows where the matched person last login was(location)
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  Widget build(BuildContext context) {
    var coordinates = (ModalRoute.of(context)!.settings.arguments as Map);
    // Recovers the location as a coordinates object
    LatLng latLng = LatLng(coordinates["lat"], coordinates["long"]);

    return Scaffold(
        appBar: AppBar(
          title: Text("Mapa"),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        // FlutterMap configuration
        body: FlutterMap(
          options: MapOptions(
            center: latLng,
            zoom: 13.0,
          ),
          layers: [
            // Map Box configuration
            TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/styles/v1/grupoamarelo/ckyuhls97000q14nt21g19zku/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ3J1cG9hbWFyZWxvIiwiYSI6ImNreXVndjU1bTBkOTIybm51dHVpdXJqenYifQ.4OaVjfPcPVC0hDpnCqeRKw",
              additionalOptions: {
                'acessToken': "pk.eyJ1IjoiZ3J1cG9hbWFyZWxvIiwiYSI6ImNreXVndjU1bTBkOTIybm51dHVpdXJqenYifQ.4OaVjfPcPVC0hDpnCqeRKw",
                'id': 'mapbox.mapbox-streets-v8'
              },
              attributionBuilder: (_) {
                return Text("© OpenStreetMap contributors");
              },
            ),
            // The marker which represents the person location
            MarkerLayerOptions(
              markers: [
                Marker(
                  height: 30.0,
                  width: 30.0,
                  point: latLng,
                  builder: (ctx) => Icon(Icons.location_on, color: Colors.red)
                )
              ]
            )
          ],
        ));
  }
}
