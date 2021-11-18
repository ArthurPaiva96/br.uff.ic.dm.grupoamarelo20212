import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key}) : super(key: key);

  late Person user;

  @override
  Widget build(BuildContext context) {

    user = (ModalRoute.of(context)!.settings.arguments as Map)["personLogged"];
    print(user.seeWoman);
    print(user.seeMan);

    return Scaffold(
      backgroundColor: Color(0xFF527DAA),
      appBar: AppBar(
        title: Text("Menu"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Pessoas"),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(300, 36),
              ),
              onPressed: (){
              print("Pressionou pessoas");
            },
            ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                child: Text("Chat"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(300, 36),
                ),
                onPressed: (){
                  print("Pressionou chat");
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                child: Text("Preferências"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(300, 36),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, "/preferences",
                      arguments: {
                        "personLogged": this.user,
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
