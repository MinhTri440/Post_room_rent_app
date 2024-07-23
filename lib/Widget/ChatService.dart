import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:post_house_rent_app/model/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';

class ChatService {
  // get instant of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get user stream

  //send message
  Future<void> sendMessage(String receiverId, message, senderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? senderEmail = prefs.getString('email');
    Message newMessage = Message(
        senderID: senderId,
        senderEmail: senderEmail,
        receiveID: receiverId,
        message: message,
        timestamp: DateTime.now().toIso8601String());
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    List ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
  // get message
}
