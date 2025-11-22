import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _collectionName = 'messages';
  static const String _orderTakerId = 'order_taker';

  // Send a message to Order Taker
  Future<void> sendMessage(String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    if (text.trim().isEmpty) throw Exception('Message cannot be empty');

    final message = Message(
      id: '',
      text: text.trim(),
      senderId: currentUser.uid,
      receiverId: _orderTakerId,
      senderName: currentUser.email ?? currentUser.uid,
      timestamp: DateTime.now(),
    );

    await _firestore.collection(_collectionName).add(message.toFirestore());
  }

  // Get real-time stream of messages
  Stream<List<Message>> getMessagesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    // Get sent messages (user -> Order Taker)
    final sentStream = _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: currentUser.uid)
        .where('receiverId', isEqualTo: _orderTakerId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());

    // Get received messages (Order Taker -> user)
    final receivedStream = _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: _orderTakerId)
        .where('receiverId', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());

    // Combine both streams
    return _combineStreams(sentStream, receivedStream);
  }

  // Simple helper to combine two streams
  Stream<List<Message>> _combineStreams(
    Stream<List<Message>> sent,
    Stream<List<Message>> received,
  ) {
    final controller = StreamController<List<Message>>.broadcast();
    List<Message> sentList = [];
    List<Message> receivedList = [];

    // Listen to sent messages
    final sentSub = sent.listen((messages) {
      sentList = messages;
      _emitCombined(controller, sentList, receivedList);
    });

    // Listen to received messages
    final receivedSub = received.listen((messages) {
      receivedList = messages;
      _emitCombined(controller, sentList, receivedList);
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      sentSub.cancel();
      receivedSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // Helper to merge and emit combined messages
  void _emitCombined(
    StreamController<List<Message>> controller,
    List<Message> sent,
    List<Message> received,
  ) {
    if (controller.isClosed) return;
    
    final all = <Message>[...sent, ...received];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    controller.add(all);
  }
}
