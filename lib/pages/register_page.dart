import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'loginScreen.dart';

final CollectionReference _persons =
    FirebaseFirestore.instance.collection('person');

class RegisterPage extends StatefulWidget {
  final String title = 'Registration';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isMan = false;

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
                        FocusScope.of(context).requestFocus(new FocusNode());

                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));

                        _dateController.text =
                            DateFormat('dd/MM/yyyy').format(date!);
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

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Usuario cadastrado"),
                          duration: Duration(seconds: 1),
                        ));

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Example code for registration.
  Future<void> _register() async {
    print("Criar usuario");

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
}
