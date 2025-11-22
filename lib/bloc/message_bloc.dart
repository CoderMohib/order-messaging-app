import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/message_repository.dart';
import '../models/message_model.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _messageRepository;

  MessageBloc(this._messageRepository) : super(const MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessageState> emit,
  ) async {
    try {
      emit(const MessageLoading());

      // Listen to the stream and emit states as messages come in
      await emit.forEach<List<Message>>(
        _messageRepository.getMessagesStream(),
        onData: (messages) {
          return MessageLoaded(messages);
        },
        onError: (error, stackTrace) {
          return MessageError('Failed to load messages: ${error.toString()}');
        },
      );
    } catch (e) {
      emit(MessageError('Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessageState> emit,
  ) async {
    try {
      // Validate message
      if (event.text.trim().isEmpty) {
        emit(MessageError('Message cannot be empty'));
        return;
      }

      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(const MessageError('User not authenticated'));
        return;
      }

      // Get current messages if state is MessageLoaded
      final currentMessages = state is MessageLoaded
          ? (state as MessageLoaded).messages
          : <Message>[];

      emit(MessageSending(currentMessages));

      // Send message
      await _messageRepository.sendMessage(event.text);

      // State will be updated automatically through the stream
    } catch (e) {
      emit(MessageError('Failed to send message: ${e.toString()}'));
    }
  }
}

