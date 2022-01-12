import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:grupoamarelo20212/services/image_handling.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late Person user;
  late var userDB;

  final ImageHandling _imageHandling = ImageHandling();
  final FirebaseStorage storage = FirebaseStorage.instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;


  loadDummyPic() async {
    refs = (await storage.ref('images').listAll()).items;
    for(var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }
    setState(() {
      loading = false;
    });
  }

  loadProfilePic(String userId) async {
    setState(() {
      loading = true;
    });

    Reference reference = storage.ref('${userId}profilepic.jpg');
    arquivos.add(await reference.getDownloadURL());

    setState(() {
      loading = false;
    });
  }

  Future signInAnon() async {
    try {
      UserCredential credential = await _firebaseAuth.signInAnonymously();
      User? firebaseUser = credential.user;
      return firebaseUser;
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  void printAnonLogin() async {
    dynamic result = await signInAnon();
    if (result == null) {
      print('erro ao logar anonimamente');
    }
    else {
      print('logou anonimamente');
      print(result);
    }

  }

  @override
  void initState() {
    super.initState();
    loadDummyPic();

    printAnonLogin();
  }

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
                child: Text("Salvar sua nova bio")),
            Padding(
              padding: EdgeInsets.all(15.0), //TODO profile pic DOWN here
              child: loading
                  ? Center(child: CircularProgressIndicator(),) : Padding(
                padding: EdgeInsets.all(24.0),
                child: arquivos.isEmpty
                    ? Center(child: Text('Não há imagens ainda'),) : SizedBox(
                  height: 120,
                  child: Image.network(arquivos.last),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _imageHandling.pickAndUploadImage(user);
                loadProfilePic(user.id);
              },
              child: Text('Trocar foto de perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                loadProfilePic(user.id);
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
