import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../models/message_model.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});
  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _c = TextEditingController();
  final _s = ScrollController();
  final _u = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(const LoadMessages());
  }

  @override
  void dispose() {
    _c.dispose();
    _s.dispose();
    super.dispose();
  }

  void _send() {
    final t = _c.text.trim();
    if (t.isNotEmpty) {
      context.read<MessageBloc>().add(SendMessage(t));
      _c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages - Order Taker')),
      body: BlocConsumer<MessageBloc, MessageState>(
        listener: (c, s) {
          if (s is MessageError) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(s.e)));
          if (s is MessageLoaded && _s.hasClients) Future.delayed(const Duration(milliseconds: 100), () => _s.jumpTo(_s.position.maxScrollExtent));
        },
        builder: (c, s) {
          if (s is MessageInitial || s is MessageLoading) return const Center(child: CircularProgressIndicator());
          if (s is MessageError && s is! MessageLoaded) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64), const SizedBox(height: 16), Text(s.e), const SizedBox(height: 16), ElevatedButton(onPressed: () => c.read<MessageBloc>().add(const LoadMessages()), child: const Text('Retry'))]));
          final m = s is MessageLoaded ? s.m : s is MessageSending ? s.m : <Message>[];
          return Column(children: [
            Expanded(child: m.isEmpty ? const Center(child: Text('No messages yet. Start a conversation!', style: TextStyle(fontSize: 16))) : ListView.builder(controller: _s, padding: const EdgeInsets.all(16), itemCount: m.length, itemBuilder: (c, i) {
              final msg = m[i];
              final isS = msg.senderId == _u?.uid;
              return Padding(padding: const EdgeInsets.only(bottom: 12), child: Align(alignment: isS ? Alignment.centerRight : Alignment.centerLeft, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)), constraints: BoxConstraints(maxWidth: MediaQuery.of(c).size.width * 0.75), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isS ? 'You' : msg.senderName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(msg.text, style: const TextStyle(fontSize: 16)), const SizedBox(height: 4), Text(_f(msg.timestamp), style: const TextStyle(fontSize: 10))]))));
            })),
            Container(padding: const EdgeInsets.all(8), child: SafeArea(child: Row(children: [Expanded(child: TextField(controller: _c, decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()), textInputAction: TextInputAction.send, onSubmitted: (_) => _send())), const SizedBox(width: 8), IconButton(icon: const Icon(Icons.send), onPressed: _send)]))),
          ]);
        },
      ),
    );
  }

  String _f(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays == 0) {
      if (d.inHours == 0) return d.inMinutes == 0 ? 'Just now' : '${d.inMinutes}m ago';
      return '${d.inHours}h ago';
    }
    if (d.inDays == 1) return 'Yesterday';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}
