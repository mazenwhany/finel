import 'package:bloc/bloc.dart';
import 'package:final4/logic/messages/state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/message_data.dart';

class MessageCubit extends Cubit<MessageState> {
  final SupabaseClient supabase;

  MessageCubit(this.supabase) : super(MessageInitial());

  Future<void> fetchMessages(String userId) async {
    emit(MessageLoading());
    try {
      final response = await supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: true);

      final messages = response.map((json) => Message.fromJson(json)).toList();
      emit(MessageLoaded(messages));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      await supabase.from('messages').insert(message.toInsertJson());
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await supabase.from('messages').update({'read': true}).eq('id', messageId);
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  void subscribeToMessages() {
    supabase
        .channel('public:messages')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        final newMessage = Message.fromJson(payload.newRecord!);
        if (state is MessageLoaded) {
          final updatedMessages = List<Message>.from((state as MessageLoaded).messages)
            ..add(newMessage);
          emit(MessageLoaded(updatedMessages));
        }
      },
    )
        .subscribe();
  }

  void unsubscribeFromMessages() {
    supabase.channel('public:messages').unsubscribe();
  }
}
