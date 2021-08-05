import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterchat/controller/database.dart';
import 'package:flutterchat/provider/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
        "name": userData['userName'],
      };

      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
        print("messageId $messageId");
      }

      DataBaseManger()
          .sendMessage(chatRoomId, messageId, messageInfo)
          .then((value) {
        sendPushMessage(message);
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

  Widget chatBubble(name, message, bool sendByMe) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                message ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData
            ? snapshot.data!.docs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/chat.svg',
                          height: 280,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Start your conversation here...",
                          style: Theme.of(context).textTheme.headline6,
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot data = snapshot.data!.docs[index];
                      return Column(
                        crossAxisAlignment: userData['name'] == data['sendBy']
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          chatBubble(data['name'], data['message'],
                              userData['name'] == data['sendBy']),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                              DateFormat('h:mm a')
                                  .format(DateTime.parse(
                                      data['time'].toDate().toString()))
                                  .toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Future<void> sendPushMessage(String message) async {
    QuerySnapshot ref =
        await FirebaseFirestore.instance.collection('users').get();

    try {
      ref.docs.forEach((snapshot) async {
        var data = snapshot.data() as Map;
        if (userData['fcmToken'] != data['fcmToken']) {
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAA6xYgVGs:APA91bFwU8sjI-1eqadGArgYjD6aMzQaRBDlCguunRUsexgzAbkYSLuKF2q15FuClPtxPyIxDWdIXstQnfocf1I-EPkD6JictvW_ftqPb-kzHK3OhaQw4YKt3S_fVIn50V_VDpNNXdFK'
            },
            body: jsonEncode(
              <String, dynamic>{
                'notification': <String, dynamic>{
                  'body': message,
                  'title': userData['userName']
                },
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'id': '1',
                  'status': 'done'
                },
                'to': data['fcmToken'],
              },
            ),
          );
        }
      });
    } catch (e) {
      print("error push notification");
    }
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
                color: Theme.of(context).backgroundColor,
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
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).accentColor,
                        ),
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
