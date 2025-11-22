import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends MessageEvent {
  const LoadMessages();
}

class SendMessage extends MessageEvent {
  final String text;

  const SendMessage(this.text);

  @override
  List<Object> get props => [text];
}

