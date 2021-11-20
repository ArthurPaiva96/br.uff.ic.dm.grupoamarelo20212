import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late Person user;
  late var userDB;

  @override
  Widget build(BuildContext context) {
    final bioController = TextEditingController();
    user = (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];
    userDB = FirebaseFirestore.instance.collection('person').doc(this.user.id);
    bioController.text = this.user.bio;

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      bioController.dispose();
      super.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Preferências"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SwitchListTile(
              title: Text("Ver mulheres"),
              onChanged: (bool value) {
                setState(() {
                  this.userDB.update({"seeWoman": !this.user.seeWoman});
                  this.user.seeWoman = !this.user.seeWoman;
                });
              },
              value: this.user.seeWoman,
            ),
            SwitchListTile(
              title: Text("Ver homens"),
              onChanged: (bool value) {
                setState(() {
                  this.userDB.update({"seeMan": !this.user.seeMan});
                  this.user.seeMan = !this.user.seeMan;
                });
              },
              value: this.user.seeMan,
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  //hintText: "Digite sua nova bio",
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  this.userDB.update({"bio": bioController.text});
                  this.user.bio = bioController.text;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Você alterou sua bio"),
                    duration: Duration(seconds: 1),
                  ));
                },
                child: Text("Salvar sua nova bio"))
          ],
        ),
      ),
    );
  }
}
