import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Test database page
class PersonInformation extends StatefulWidget {
  const PersonInformation({Key? key}) : super(key: key);

  @override
  _PersonInformationState createState() => _PersonInformationState();
}

class _PersonInformationState extends State<PersonInformation> {
  final Stream<QuerySnapshot> _personStream = FirebaseFirestore.instance.collection('person').snapshots();

  CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore.instance.collection("person");





  @override
  Widget build(BuildContext context) {
    var docRef = collection.doc();
    for(int i=1; i <= 50; i++){
      collection.add({
        "bio": "Bio fulana " + i.toString(),
        "birthday": "01/01/1996",
        "login": "fulana"+i.toString(),
        "name": "Fulana"+i.toString(),
        "password": "fulana"+i.toString(),
        "isMan": false,
        "seeMan": false,
        "seeWoman": false,
      }).then((value){
        print(value.id);
      });
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Persons"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _personStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                    "Name: ${data['name']} "
                        "Login: ${data['login']} "
                        "Password: ${data['password']} "
                        "Age: ${data['birthday']}"
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}