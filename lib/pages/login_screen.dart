import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:grupoamarelo20212/pages/register_page.dart';

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  var loading = false;
  bool logged = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Login',
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: loginController,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Escreva seu login',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Senha',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Escreva sua senha',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildForgotPasswordBtn() {
  //   return Container(
  //     alignment: Alignment.centerRight,
  //     child: FlatButton(
  //       onPressed: () => print('Forgot Password Button Pressed'),
  //       padding: EdgeInsets.only(right: 0.0),
  //       child: Text(
  //         'Forgot Password?',
  //         style: kLabelStyle,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          setState(() {
            this.loading = true;
          });
          await FirebaseFirestore.instance
              .collection("person")
              .where("login", isEqualTo: loginController.text)
              .where("password", isEqualTo: passwordController.text)
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {

              if(!this.logged){
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
                this.logged = true;
              }

            });
          });
          setState(() {
            this.loading = false;
          });
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: const Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
  //
  // Widget _buildSignInWithText() {
  //   return Column(
  //     children: <Widget>[
  //       Text(
  //         '- OR -',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       SizedBox(height: 20.0),
  //       Text(
  //         'Sign in with',
  //         style: kLabelStyle,
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSocialBtn(Function onTap, AssetImage logo) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 60.0,
  //       width: 60.0,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black26,
  //             offset: Offset(0, 2),
  //             blurRadius: 6.0,
  //           ),
  //         ],
  //         image: DecorationImage(
  //           image: logo,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // _buildSocialBtn(
          //       () => print('Login with Facebook'),
          //   AssetImage(
          //     'assets/logos/facebook.jpg',
          //   ),
          // ),
          // with custom text
          SignInButton(
            Buttons.Google,
            text: "Continuar com o Google",
            onPressed: () async {
              UserCredential credentials = await signInWithGoogle();
              bool checked = await checkUser(credentials.user);
              if(checked == false){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage(user: credentials.user))
                );
              }
              // await signOutGoogle();
            },
          )
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage())
        )
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Precisando de uma conta? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Registre-se',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _getPersons() {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => const PersonInformation()),
  //       );
  //     },
  //     child: const Text('Lista de pessoas',
  //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //   );
  // }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Failed to signOut' + e.toString());
    }
  }

  Future<bool> checkUser(User? user) async {

    setState(() {
      this.loading = true;
    });

    await FirebaseFirestore.instance
        .collection("person")
        .where("email", isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            print("Achei o usuario");
            if(!this.logged){
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

              await signOutGoogle();
              Navigator.pushReplacementNamed(context, "/menu", arguments: {
                "personLogged": person,
              });
              this.logged = true;
            }
          });
        })
        .catchError((onError) {
          print("Erro ao buscar pelo email");
        });
    setState(() {
      this.loading = false;
    });

    return false;
  }

  Widget _fetchingUser() {
    if (this.loading)
      return SpinKitRing(
        color: Colors.white,
        size: 50.0,
      );
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildEmailTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      //_buildForgotPasswordBtn(),
                      _buildLoginBtn(),
                      //_buildSignInWithText(),
                      _buildSocialBtnRow(),
                      _buildSignupBtn(),
                      _fetchingUser()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
