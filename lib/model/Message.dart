import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String? senderEmail;
  final String receiveID;
  final String message;
  final String timestamp;
  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiveID,
    required this.message,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiveID,
      'message': message,
      'timestamp': timestamp
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] as String,
      senderEmail: map['senderEmail'] as String?,
      receiveID: map['receiveID'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
