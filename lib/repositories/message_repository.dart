import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _f = FirebaseFirestore.instance;
  final FirebaseAuth _a = FirebaseAuth.instance;
  static const String _c = 'messages';
  static const String _o = 'order_taker';

  Future<void> sendMessage(String text) async {
    final u = _a.currentUser;
    if (u == null) throw Exception('User not authenticated');
    if (text.trim().isEmpty) throw Exception('Message cannot be empty');
    final m = Message(id: '', text: text.trim(), senderId: u.uid, receiverId: _o, senderName: u.email ?? u.uid, timestamp: DateTime.now());
    await _f.collection(_c).add(m.toFirestore());
  }

  Stream<List<Message>> getMessagesStream() {
    final u = _a.currentUser;
    if (u == null) return Stream.value([]);
    final s = _f.collection(_c).where('senderId', isEqualTo: u.uid).where('receiverId', isEqualTo: _o).orderBy('timestamp', descending: false).snapshots().map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
    final r = _f.collection(_c).where('senderId', isEqualTo: _o).where('receiverId', isEqualTo: u.uid).orderBy('timestamp', descending: false).snapshots().map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
    return _combine(s, r);
  }

  Stream<List<Message>> _combine(Stream<List<Message>> s, Stream<List<Message>> r) {
    final c = StreamController<List<Message>>.broadcast();
    List<Message> sl = [];
    List<Message> rl = [];
    s.listen((m) {
      sl = m;
      _emit(c, sl, rl);
    });
    r.listen((m) {
      rl = m;
      _emit(c, sl, rl);
    });
    c.onCancel = () {
      c.close();
    };
    return c.stream;
  }

  void _emit(StreamController<List<Message>> c, List<Message> sl, List<Message> rl) {
    if (c.isClosed) return;
    final all = <Message>[...sl, ...rl];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    c.add(all);
  }
}
