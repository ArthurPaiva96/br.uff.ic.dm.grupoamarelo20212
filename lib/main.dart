import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/pages/personview.dart';
import 'package:grupoamarelo20212/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';


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
      //initialRoute: "/",
      routes: {
        //"/" : (context) => LoginScreen(),
        "/personview": (context) => PersonView(),
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





