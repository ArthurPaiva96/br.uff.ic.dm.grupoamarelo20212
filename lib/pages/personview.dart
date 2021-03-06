import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:grupoamarelo20212/models/person.dart';

// This page shows the persons which the user can like or disliked based on the user's preferences and who he/she already liked or disliked
// The user can also swipe left or right instead of touching the like or dislike button
class PersonView extends StatefulWidget {
  PersonView({Key? key}) : super(key: key);

  @override
  State<PersonView> createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {

  // swipe cards stuff
  late MatchEngine _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late List<SwipeItem> _swipePersons = <SwipeItem>[];
  bool matchEngineInitialized = false;

  bool gotList = false;
  CollectionReference<Map<String, dynamic>> liked_collection =
      FirebaseFirestore.instance.collection("liked");
  CollectionReference<Map<String, dynamic>> disliked_collection =
      FirebaseFirestore.instance.collection("disliked");

  late Person user;
  late List<Person> persons;

  int personIndex = 0;

  Future<List<Person>> getPersons(Person user) async {
    // Gets the person who the user can like or dislike
    if(gotList) return [];

    if (!user.seeWoman && !user.seeMan) {
      this.persons = [];
      return [];
    }

    List<String> alreadyLikedOrDisliked = [];
    // First it gets who the user already like or disliked
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
    if(alreadyLikedOrDisliked.isEmpty) alreadyLikedOrDisliked.add("a"); // Work around

    // Then it gets each person who the user haven't liked or disliked yet
    await FirebaseFirestore.instance
        .collection("person")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {

        if(!alreadyLikedOrDisliked.contains(doc.id)){

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
        }

      });
    });

    // And finnaly it filters using the user's preferences. If he/she wants to see men, women or both
    this.persons = this
        .persons
        .where((person) =>
            (!user.seeWoman == person.isMan) | (user.seeMan == person.isMan))
        .toList();

    this.gotList = true;
    return this.persons;
  }

  // profile picture load

  final FirebaseStorage storage = FirebaseStorage.instance;

  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;


  loadProfilePic(String userId) async {
    // load dummy
    refs = (await storage.ref('images').listAll()).items;
    for(var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }


    // load real
    Reference reference = storage.ref('${userId}profilepic.jpg');

    try {
      arquivos.add(await reference.getDownloadURL());
    }
    catch(e) {
      print(e.toString());
    }


    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.user =
        (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];

    return FutureBuilder<List<Person>>(
        future: this.getPersons(this.user),
        builder: (context, AsyncSnapshot<List<Person>> snapshot) {
          if (snapshot.hasData) {

            if (this.persons.isEmpty) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text("N??o h?? ningu??m"),
                    centerTitle: true,
                    backgroundColor: Colors.blue,
                  ), body: Text("Sem ningu??m para exibir"));
            }


            var appBar = AppBar(
              title: Text("Pessoas"),
              centerTitle: true,
              backgroundColor: Colors.blue,
            );

            if(!this.matchEngineInitialized) this.initMatchEngine(appBar);

            if (loading) {
              loadProfilePic(persons[personIndex].id);
            }

            return Scaffold(
              appBar: appBar,
              body: Column(
                children: [
                  // SwipeCards configuration
                  SwipeCards(
                      matchEngine: this._matchEngine,
                      onStackFinished: () {
                        this.persons = [];
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: (MediaQuery.of(context).size.height -
                              appBar.preferredSize.height) /
                              2,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.lightBlueAccent,
                          child: loading ? CircularProgressIndicator() : Image.network(arquivos.last)
                        );
                      }),
                  Row(
                    children: [
                      Text(
                        persons[personIndex].name,
                        style: TextStyle(fontSize: 30.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          persons[personIndex].birthday.toString(),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(persons[personIndex].bio),
                  ),
                ],
              ),
              floatingActionButton: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      // Dislike button
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          _matchEngine.currentItem!.nope();
                          loading = true;
                          loadProfilePic(persons[personIndex].id);
                        },
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    // Like button
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () async {
                        _matchEngine.currentItem!.like();
                        loading = true;
                        loadProfilePic(persons[personIndex].id);
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
            return const Center(
              child: SpinKitRing(
                color: Colors.white,
                size: 50.0,
              ),
            );
          }
        });
  }

  void initMatchEngine(AppBar appBar) {
    // Like and dislike code
    for (int i = 0; i < persons.length; i++) {
      _swipePersons.add(SwipeItem(

          content: Container(
            height: (MediaQuery.of(context).size.height -
                appBar.preferredSize.height) /
                2,
            width: MediaQuery.of(context).size.width,
            color: Colors.lightBlueAccent,
            child: Center(
                child: loading ? CircularProgressIndicator() : Image.network(arquivos.last)
            ),
          ),

          // If the user liked someone updates the database
          likeAction: () async {

            await liked_collection.add({
              "user": this.user.id,
              "person": this.persons[i].id
            });
            // TODO pushnotification if match

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Voc?? curtiu " + persons[i].name),
              duration: Duration(seconds: 1),
            ));

            setState(() {
              if (persons.length - 1 > this.personIndex) this.personIndex++;
            });


          },


          // If the user disliked someone updates the database
          nopeAction: () async {

            await disliked_collection.add({
              "user": this.user.id,
              "person": this.persons[i].id
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Voc?? rejeitou " + persons[i].name),
              duration: Duration(seconds: 1),
            ));

            setState(() {
              if (persons.length - 1 > this.personIndex) this.personIndex++;
            });

          },

          superlikeAction: () {
            print("N??o tem!");
          }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipePersons);
    this.matchEngineInitialized = true;
  }
}
