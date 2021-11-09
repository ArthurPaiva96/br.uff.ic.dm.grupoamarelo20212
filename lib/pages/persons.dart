import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonInformation extends StatefulWidget {
  const PersonInformation({Key? key}) : super(key: key);

  @override
  _PersonInformationState createState() => _PersonInformationState();
}

class _PersonInformationState extends State<PersonInformation> {
  final Stream<QuerySnapshot> _personStream = FirebaseFirestore.instance.collection('person').snapshots();

  @override
  Widget build(BuildContext context) {
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
                        "Age: ${data['age']}"
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}