import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grupoamarelo20212/models/person.dart';

class PersonView extends StatefulWidget {
  PersonView({Key? key}) : super(key: key);

  @override
  State<PersonView> createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  CollectionReference<Map<String, dynamic>> liked_collection =
      FirebaseFirestore.instance.collection("liked");
  CollectionReference<Map<String, dynamic>> disliked_collection =
      FirebaseFirestore.instance.collection("disliked");
  late Person user;

  late List<Person> persons;
  int i = 0;

  Future<List<Person>> getPersons(Person user) async {
    List<String> alreadyLikedOrDisliked = [];

    await FirebaseFirestore.instance
        .collection("liked")
        .where("user", isEqualTo: user.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        alreadyLikedOrDisliked.add(doc["person"]);
      });
    });

    await FirebaseFirestore.instance
        .collection("disliked")
        .where("user", isEqualTo: user.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        alreadyLikedOrDisliked.add(doc["person"]);
      });
    });

    this.persons = [];

    await FirebaseFirestore.instance
        .collection("person")
        .where(FieldPath.documentId, whereNotIn: alreadyLikedOrDisliked)
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

        this.persons.add(person);
      });
    });

    this.persons = this
        .persons
        .where((person) =>
            (!user.seeWoman == person.isMan) | (user.seeMan == person.isMan))
        .toList();

    return this.persons;
  }

  @override
  Widget build(BuildContext context) {
    this.user =
        (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];

    return FutureBuilder<List<Person>>(
        future: this.getPersons(this.user),
        builder: (context, AsyncSnapshot<List<Person>> snapshot) {
          if (snapshot.hasData) {
            var appBar = AppBar(
              title: Text(persons[i].name),
              centerTitle: true,
              backgroundColor: Colors.blue,
            );

            return Scaffold(
              appBar: appBar,
              body: Column(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.height -
                            appBar.preferredSize.height) /
                        2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.lightBlueAccent,
                    child: Center(
                        child: Text(
                      "FOTO AQUI",
                      style: TextStyle(fontSize: 50.0),
                    )),
                  ),
                  Row(
                    children: [
                      Text(
                        persons[i].name,
                        style: TextStyle(fontSize: 30.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          persons[i].birthday.toString(),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(persons[i].bio),
                  ),
                ],
              ),
              floatingActionButton: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          await disliked_collection.add({
                            "user": this.user.id,
                            "person": this.persons[i].id
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Você rejeitou " + persons[i].name),
                            duration: Duration(seconds: 1),
                          ));
                          setState(() {
                            if (persons.length - 1 > i) i++;
                          });
                        },
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () async {
                        await liked_collection.add({
                          "user": this.user.id,
                          "person": this.persons[i].id
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Você curtiu " + persons[i].name),
                          duration: Duration(seconds: 1),
                        ));
                        setState(() {
                          if (persons.length - 1 > i) i++;
                        });
                      },
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check),
                    ),
                  ),
                ],
              ),
            );
            ;
          } else {
            return Center(
              child: SpinKitRing(
                color: Colors.white,
                size: 50.0,
              ),
            );
          }
        });
  }
}
