import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseManger {
  Future addUserFormDB(String userId, Map<String, dynamic> userInfo) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfo);
  }

  Future sendMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfo) async {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfo);
  }

  updateMessage(String chatRoomId, String messageId,
      Map<String, dynamic> lastMessageInfo) async {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .update(lastMessageInfo);
  }

  createChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfo) async {
    final response = await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .get();

    if (response.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatroom")
          .doc(chatRoomId)
          .set(chatRoomInfo);
    }
  }

  Future<Stream<QuerySnapshot>> fetchMessage(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }
}
