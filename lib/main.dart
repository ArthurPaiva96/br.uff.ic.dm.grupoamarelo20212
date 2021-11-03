import 'package:flutter/material.dart';
import 'package:grupoamarelo20212/models/person.dart';


void main() {
  runApp(MaterialApp(
    home: PersonView(),
  ));
}

class PersonView extends StatelessWidget {
  PersonView({Key? key}) : super(key: key);

  Person personTest = Person(name: "Fulana1", age: 20);


  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(personTest.name),
      centerTitle: true,
      backgroundColor: Colors.blue,
    );
    return Scaffold(
      appBar: appBar,
     body: Column(
       children: [
         Container(
           height: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 2,
           width: MediaQuery.of(context).size.width,
           color: Colors.lightBlueAccent,
           child: Center(child: Text("FOTO AQUI", style: TextStyle(fontSize: 50.0) ,)),
         ),
         Row(
           children: [
             Text(personTest.name, style: TextStyle(fontSize: 30.0),),
             Padding(
               padding: const EdgeInsets.only(left: 10.0),
               child: Text(personTest.age.toString(), style: TextStyle(fontSize: 20.0),),
             )
           ],
         ),
         Padding(
           padding: const EdgeInsets.only(top: 20.0),
           child: Text(personTest.bio),
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
                onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Você rejeitou " + personTest.name),
                    duration: Duration(seconds: 1),
                  ));
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
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Você curtiu " + personTest.name),
                  duration: Duration(seconds: 1),
                ));
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }

}
