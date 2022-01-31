import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:grupoamarelo20212/pages/chat_screen.dart';


// This is the contacts screen. This page shows the users who liked each other
// There is the options of chatting between them and knowing their last login location
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Person user;


  void callChatScreen(String pid, String uid, String name) {
    // Opens the chat screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  currentUserId: pid,
                  matchId: uid,
                  matchName: name,
                )));
  }

  Future<List<Person>> contactsList(Person user) async {
    //This method gets the people who matched
    List<String> likedIds = [];

    //First it gets who the user liked
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

    //Then it gets the people who liked the user from the list of 'who the user liked'
    await FirebaseFirestore.instance
        .collection("liked")
        .where("person", isEqualTo: user.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (likedIds.contains(doc["user"])) contactsIds.add(doc["user"]);
      });
    });

    if (contactsIds.isEmpty) return [];

    List<Person> contacts = [];

    //And finally it recovers their info from the database
    await FirebaseFirestore.instance
        .collection("person")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (contactsIds.contains(doc.id)) {

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

          Map map = doc.data() as Map;
          person.lat = map.containsKey("lat") ? doc["lat"] : 0.0;
          person.long = map.containsKey("long") ? doc["long"] : 0.0;

          contacts.add(person);

        }

      });
    });

    return contacts;
  }

  Widget contactTemplate(Person person, String url) {
    // The gesture detector catches user input and calls an app behavior
    return GestureDetector(
      onLongPress: () => showMapAlert(person),
      onTap: () => callChatScreen(user.id, person.id, person.name),
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30.0,
                backgroundImage: NetworkImage(url),
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

  // profile picture load
  final FirebaseStorage storage = FirebaseStorage.instance;

  List<String> arquivos = [];

  List<Person> people = [];
  List<Widget> contactsToShow = [];

  bool loading = true;

  Future<String> loadSinglePic(String userId) async {
    Reference reference = storage.ref('${userId}profilepic.jpg');
    String? retorno;

    try {
      arquivos.add(await reference.getDownloadURL());

      retorno = arquivos.last;
      arquivos = [];
      return retorno;
    } catch (e) {
      print(e.toString());

      reference = storage.ref('images/dummyprofilepic.jpg');
      arquivos.add(await reference.getDownloadURL());

      retorno = arquivos.last;
      arquivos = [];
      return retorno;
    }
  }

  loadAllPics(List<Person> listOfPeople) async {
    for (var p in listOfPeople) {
      String arquivo = await loadSinglePic(p.id);
      contactsToShow.add(contactTemplate(p, arquivo));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Show the contact list
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

            if (loading) {
              List<Person> people = snapshot.data!;

              loadAllPics(people);
            }

            return Scaffold(
              appBar: appBar,
              body: loading
                  ? CircularProgressIndicator()
                  : Column(
                      children: contactsToShow,
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

  showMapAlert(Person person) {
    // Shows an alert asking the user if he or she wants to view a matched users last place of login
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text("Mapa"),
              content: Text("Deseja ver " + person.name + " no mapa?"),
              actions: [
                CupertinoDialogAction(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/map", arguments: {
                      "lat": person.lat,
                      "long": person.long,
                    });
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Não"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
