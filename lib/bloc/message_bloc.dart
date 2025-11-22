import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/message_repository.dart';
import '../models/message_model.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _r;

  MessageBloc(this._r) : super(const MessageInitial()) {
    on<LoadMessages>(_onLoad);
    on<SendMessage>(_onSend);
  }

  Future<void> _onLoad(LoadMessages e, Emitter<MessageState> emit) async {
    emit(const MessageLoading());
    await emit.forEach<List<Message>>(_r.getMessagesStream(), onData: (m) => MessageLoaded(m), onError: (err, _) => MessageError('Failed to load: ${err.toString()}'));
  }

  Future<void> _onSend(SendMessage e, Emitter<MessageState> emit) async {
    if (e.text.trim().isEmpty) {
      emit(const MessageError('Message cannot be empty'));
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      emit(const MessageError('User not authenticated'));
      return;
    }
    try {
      final m = state is MessageLoaded ? (state as MessageLoaded).messages : <Message>[];
      emit(MessageSending(m));
      await _r.sendMessage(e.text);
    } catch (err) {
      emit(MessageError('Failed to send: ${err.toString()}'));
    }
  }
}
