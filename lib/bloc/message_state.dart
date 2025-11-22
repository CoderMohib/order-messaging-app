import 'package:equatable/equatable.dart';
import '../models/message_model.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {
  const MessageInitial();
}

class MessageLoading extends MessageState {
  const MessageLoading();
}

class MessageLoaded extends MessageState {
  final List<Message> messages;

  const MessageLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessageError extends MessageState {
  final String error;

  const MessageError(this.error);

  @override
  List<Object> get props => [error];
}

class MessageSending extends MessageState {
  final List<Message> messages;

  const MessageSending(this.messages);

  @override
  List<Object> get props => [messages];
}

