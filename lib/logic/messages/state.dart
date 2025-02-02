import 'package:equatable/equatable.dart';
import '../../data/message_data.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<Message> messages;

  const MessageLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageError extends MessageState {
  final String error;

  const MessageError(this.error);

  @override
  List<Object?> get props => [error];
}
