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
  final List<Message> m;
  const MessageLoaded(this.m);
  @override
  List<Object> get props => [m];
}

class MessageError extends MessageState {
  final String e;
  const MessageError(this.e);
  @override
  List<Object> get props => [e];
}

class MessageSending extends MessageState {
  final List<Message> m;
  const MessageSending(this.m);
  @override
  List<Object> get props => [m];
}
