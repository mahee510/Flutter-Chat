import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/controller/database.dart';
import 'package:flutterchat/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId = "Flutter Group", messageId = "";
  TextEditingController messageController = new TextEditingController();
  Stream<QuerySnapshot>? messageStream;

  var userData;
  @override
  void initState() {
    fetchUserDataToPref();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  createChatRoom() async {
    Map<String, dynamic> chatRoomInfo = {
      "users": [
        userData['name'],
      ]
    };
    DataBaseManger().createChatRoom(chatRoomId, chatRoomInfo);
  }

  fetchUserDataToPref() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    userData = jsonDecode(pref.getString("userData")!);
    // chatRoomId = userData['name'];
    await createChatRoom();
    await getMessages();
  }

  addMessage(bool sendClicked) {
    if (messageController.text != '') {
      String message = messageController.text;

      var msgTime = DateTime.now();

      Map<String, dynamic> messageInfo = {
        "message": message,
        "sendBy": userData['name'],
        "time": msgTime,
        "image": userData['image'],
      };

      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
        print("messageId $messageId");
      }

      DataBaseManger()
          .sendMessage(chatRoomId, messageId, messageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          "message": message,
          "lasteMessageTime": msgTime,
          "lastMessageSendBy": userData['name'],
        };
        DataBaseManger().updateMessage(chatRoomId, messageId, lastMessageInfo);
        if (sendClicked) {
          messageController.clear();
          messageId = "";
        }
      });
    }
  }

  getMessages() async {
    messageStream = await DataBaseManger().fetchMessage(chatRoomId);
    setState(() {});
  }

  Widget chatBubble(message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
              bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
            ),
            gradient: LinearGradient(
              colors: [
                Color(0xFFED4040),
                Color(0xFFFF9E75),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 1.0],
            ),
          ),
          child: Text(message),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: snapshot.data!.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot data = snapshot.data!.docs[index];
                  return chatBubble(
                      data['message'], userData['name'] == data['sendBy']);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Group A"),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<Auth>(context, listen: false).signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessage(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                color: Colors.white24,
                child: TextField(
                  // onChanged: (value) => addMessage(false),
                  controller: messageController,
                  decoration: InputDecoration(
                    // contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    border: InputBorder.none,
                    hintText: "Type a message here...",
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            addMessage(true);
                            // FocusScope.of(context).unfocus();
                          });
                        },
                        icon: Icon(Icons.send),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
