import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/message_data.dart';
import '../../logic/messages/cubit.dart';
import '../../logic/messages/state.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatPartnerId;
  final String chatPartnerName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.chatPartnerId,
    required this.chatPartnerName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late MessageCubit _messageCubit;

  @override
  void initState() {
    super.initState();
    _messageCubit = context.read<MessageCubit>();
    _messageCubit.fetchMessages(widget.currentUserId);
    _messageCubit.subscribeToMessages();
  }

  @override
  void dispose() {
    _messageCubit.unsubscribeFromMessages();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message.create(
      senderId: widget.currentUserId,
      receiverId: widget.chatPartnerId,
      messageText: _messageController.text.trim(),
    );

    _messageCubit.sendMessage(newMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.chatPartnerName),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageCubit, MessageState>(
              builder: (context, state) {
                if (state is MessageLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (state is MessageError) {
                  return Center(child: Text(state.error, style: TextStyle(color: Colors.white)));
                } else if (state is MessageLoaded) {
                  final messages = state.messages
                      .where((msg) =>
                  (msg.senderId == widget.currentUserId && msg.receiverId == widget.chatPartnerId) ||
                      (msg.senderId == widget.chatPartnerId && msg.receiverId == widget.currentUserId))
                      .toList();

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe = message.senderId == widget.currentUserId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.messageText,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("Start a conversation", style: TextStyle(color: Colors.white)));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

