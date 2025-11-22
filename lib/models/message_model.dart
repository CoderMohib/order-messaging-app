import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final String senderName;
  final DateTime timestamp;

  const Message({required this.id, required this.text, required this.senderId, required this.receiverId, required this.senderName, required this.timestamp});

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Message(id: doc.id, text: d['text'] ?? '', senderId: d['senderId'] ?? '', receiverId: d['receiverId'] ?? '', senderName: d['senderName'] ?? '', timestamp: (d['timestamp'] as Timestamp).toDate());
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'senderId': senderId, 'receiverId': receiverId, 'senderName': senderName, 'timestamp': Timestamp.fromDate(timestamp)};
  }

  @override
  List<Object> get props => [id, text, senderId, receiverId, senderName, timestamp];
}
