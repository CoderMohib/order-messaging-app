import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final String senderName;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.timestamp,
  });

  // Convert Firestore document to Message object
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderName: data['senderName'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert Message object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  @override
  List<Object> get props => [id, text, senderId, receiverId, senderName, timestamp];
}

