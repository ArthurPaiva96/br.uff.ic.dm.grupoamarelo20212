import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/pages/personview.dart';
import 'package:grupoamarelo20212/pages/login.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/" : (context) => LoginScreen(),
      "/personview": (context) => PersonView(),
    },
  ));
}




