import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:grupoamarelo20212/pages/contacts_screen.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ChatScreen extends StatefulWidget {

  final currentUserId;
  final matchId;
  final matchName;
  final matchOneId;

  const ChatScreen({Key? key, this.currentUserId, this.matchId, this.matchName, this.matchOneId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(currentUserId, matchId, matchName, matchOneId);
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final String matchId;
  final String matchName;
  final String matchOneId;
  final String currentUserId;
  var chatDocId;
  var _textController = new TextEditingController();
  var data;

  _ChatScreenState(this.currentUserId, this.matchId, this.matchName, this.matchOneId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkChats();
  }

  void checkChats() async{
    await chats
      .where('person', isEqualTo: {matchId: null, currentUserId: null})
      .limit(1)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if(querySnapshot.docs.isNotEmpty){
          setState(() {
            chatDocId = querySnapshot.docs.single.id;
          });
        }else{
          chats.add({
            'person':{
              currentUserId: null,
              matchId: null
            }
          }).then((value) => {
            chatDocId = value
          });
        }
      }).catchError((error) {

    });
  }

  

  void sendMessage(String msg) {
    if(msg == "") return;

    chats.doc(chatDocId.toString()).collection('messages').add({
      'lastMessage': FieldValue.serverTimestamp(),
      'uid': currentUserId,
      'message': msg
    }).then((value) => {
      _textController.text = ""
    });
  }

  Future postNotification(List<String> playersIds, String content, String headling) async{
    return await OneSignal.shared.postNotification(OSCreateNotification(
      playerIds: playersIds, //Lista de usuários que vão receber a notificação
      content: content, //Conteúdo da notificação
      heading: headling, //Título da notificação
      buttons: [
        OSActionButton(
          id: "resposta", 
          text: "Responder"
        ),
        OSActionButton(
          id: "cancelar", 
          text: "Cancelar"
        )
      ]
    ));
  }

  bool isSender(String friend){
    return friend == currentUserId;
  }

  Alignment getAlignment(friend){
    if(friend == currentUserId)
      return Alignment.topRight;
    return Alignment.topLeft;
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .orderBy('lastMessage', descending: true)
          .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError){
            return Center(
              child: Text("Ocorreu um Erro"),
            );
          }

          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasData){
            return Scaffold(
              backgroundColor: Color(0xFF527DAA),
              appBar: AppBar(
                title: Text("${matchName}"),
                centerTitle: true,
                backgroundColor: Colors.blue,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        reverse: true,
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          data = document.data();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChatBubble(
                              clipper: ChatBubbleClipper6(
                                nipSize: 0,
                                radius: 0,
                                type: BubbleType.receiverBubble,
                              ),
                              alignment: getAlignment(data['uid'].toString()),
                              margin: EdgeInsets.only(top: 20),
                              backGroundColor: isSender(data['uid'].toString())
                                  ?Color(0xFF08C187)
                                  :Color(0xffE7E7ED),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                    MediaQuery.of(context).size.width * 0.7
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(data['message'],
                                          style: TextStyle(
                                            color: isSender(
                                              data['uid'].toString())
                                                ? Colors.white
                                                : Colors.black
                                            ),
                                            maxLines: 100,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          data['lastMessage'] == null
                                              ? DateTime.now().toString()
                                              : data['lastMessage']
                                              .toDate()
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSender(
                                              data['uid'].toString())
                                              ? Colors.white
                                              : Colors.black
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: TextField(
                              controller: _textController,
                            )
                        ),
                        IconButton(
                            onPressed: () async{
                              sendMessage(_textController.text);
                              _textController.text = "";
                              await postNotification([matchOneId], "Você recebeu uma mensagem", "Mensagem");
                            },
                            icon: Icon(Icons.send_sharp),
                        )
                      ],
                    )
                  ],
                ),
              )
            );
          }

          return Container();
        }
    );
  }
}
