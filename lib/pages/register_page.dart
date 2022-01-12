import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:intl/intl.dart';

final CollectionReference _persons = FirebaseFirestore.instance.collection('person');

class RegisterPage extends StatefulWidget {
  final String title = 'Cadastro de Usuario';
  final User? user;

  const RegisterPage({Key? key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.user?.displayName ?? "");
  final TextEditingController _loginController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController(text: widget.user?.email ?? "");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isMan = false;

  @override
  void dispose() {
    //Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Escreva o seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(labelText: 'Login'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Escreva o seu login';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Escreva seu email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Escreva a sua senha';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                          labelText: "Data de nascimento",
                          hintText: "Ex. 01/01/1999"),
                      onTap: () async {
                        DateTime? date = DateTime(1900);
                        FocusScope.of(context).requestFocus(FocusNode());

                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));

                        _dateController.text = DateFormat('dd/MM/yyyy').format(date!);
                      }),
                  const SizedBox(
                    height: 16.0,
                  ),
                  SwitchListTile(
                    title: const Text('Masculino'),
                    onChanged: (bool value) {
                      setState(() {
                        _isMan = !_isMan;
                      });
                      // print(_isMan);
                    },
                    value: _isMan,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _register();
                        }

                        if(widget.user != null){
                          await signOutGoogle();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Usuario cadastrado"),
                          duration: Duration(seconds: 1),
                        ));

                        await signIn();
                      },
                      child: const Text('Finalizar cadastro'),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Future<void> signOutGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Failed to signOut' + e.toString());
    }
  }

  Future<void> _register() async {

    return _persons
        .add({
          'bio': 'Escreva algo...',
          'birthday': _dateController.text,
          'isMan': _isMan,
          'login': _loginController.text,
          'name': _nameController.text,
          'password': _passwordController.text,
          'seeMan': true,
          'seeWoman': true,
          'email': _emailController.text
        })
        .then((value) => print("Person $value added"))
        .catchError((error) => print("Failed to add person: $error"));
    // _persons.add(data)
    // if (user != null) {
    //   //save new user
    //   setState(() {
    //     _success = true;
    //     _userEmail = user.email ?? '';
    //   });
    // } else {
    //
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text("Usuário já cadastrado"),
    //     duration: Duration(seconds: 1),
    //   ));
    // }
  }

  Future<void> signIn() async{
    await FirebaseFirestore.instance
        .collection("person")
        .where("login", isEqualTo: _loginController.text)
        .where("email", isEqualTo: _emailController.text)
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

            Navigator.pushReplacementNamed(context, "/menu", arguments: {
              "personLogged": person,
            });
          });
        });
  }
}
