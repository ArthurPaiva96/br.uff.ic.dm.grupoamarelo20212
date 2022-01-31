import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/pages/contacts_screen.dart';
import 'package:grupoamarelo20212/pages/map_screen.dart';
import 'package:grupoamarelo20212/pages/menu_screen.dart';
import 'package:grupoamarelo20212/pages/personview.dart';
import 'package:grupoamarelo20212/pages/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grupoamarelo20212/pages/preferences_screen.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Pages
      routes: {
        //"/" : (context) => LoginScreen(),
        "/personview": (context) => PersonView(),
        "/menu": (context) => MenuScreen(),
        "/preferences": (context) => PreferencesScreen(),
        "/contacts": (context) => ContactsScreen(),
        "/map": (context) => MapScreen(),
      },
      home: FutureBuilder(
        future: _firebaseApp,
        builder: (context, snapshot){
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error.toString()}');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return LoginScreen();
          }

          return Container(
            color: Colors.white,
            child: const Center(
                child: CircularProgressIndicator()
            ),
          );
        },
      ),
    );
  }
}





