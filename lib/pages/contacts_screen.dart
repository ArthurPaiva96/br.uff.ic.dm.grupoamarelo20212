import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grupoamarelo20212/models/person.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Person user;

  Future<List<Person>> contactsList(Person user) async {
    List<String> likedIds = [];

    await FirebaseFirestore.instance
        .collection("liked")
        .where("user", isEqualTo: user.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        likedIds.add(doc["person"]);
      });
    });

    if (likedIds.isEmpty) return [];

    List<String> contactsIds = [];

    await FirebaseFirestore.instance
        .collection("liked")
        .where("user", whereIn: likedIds)
        .where("person", isEqualTo: user.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        contactsIds.add(doc["user"]);
      });
    });

    if (contactsIds.isEmpty) return [];

    List<Person> contacts = [];

    await FirebaseFirestore.instance
        .collection("person")
        .where(FieldPath.documentId, whereIn: contactsIds)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var person = Person(
            id: doc.id,
            name: doc["name"],
            birthday: doc["birthday"],
            login: doc["login"],
            password: doc["password"],
            isMan: doc["isMan"],
            seeWoman: doc["seeWoman"],
            seeMan: doc["seeMan"],
            bio: doc["bio"]);

        contacts.add(person);
      });
    });

    return contacts;
  }

  Widget contactTemplate(Person person) {
    return GestureDetector(
      onTap: () => {print("Abrir chat de ${user.name} com ${person.name}")},
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(person.name),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];

    contactsList(this.user);

    return FutureBuilder<List<Person>>(
        future: this.contactsList(this.user),
        builder: (context, AsyncSnapshot<List<Person>> snapshot) {
          if (snapshot.hasData) {
            var appBar = AppBar(
              title: Text("Lista de contatos"),
              centerTitle: true,
              backgroundColor: Colors.blue,
            );

            if (snapshot.data!.isEmpty || snapshot.data == null) {
              return Scaffold(
                  appBar: appBar, body: Text("Não há nenhum match"));
            }
            ;

            return Scaffold(
              appBar: appBar,
              body: Column(
                children: snapshot.data!
                    .map((person) => contactTemplate(person))
                    .toList(),
              ),
            );
          } else {
            return const Center(
              child: SpinKitRing(
                color: Colors.white,
                size: 50.0,
              ),
            );
          }
        });
  }
}
