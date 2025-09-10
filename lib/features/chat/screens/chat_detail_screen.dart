import 'package:flutter/material.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/message.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ChatDetailScreen extends StatefulWidget {
  static const String routeName = '/chat-detail';
  final String chatRoomId;
  final String receiverName;

  // Add a helper to extract arguments from ModalRoute
  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (_) => ChatDetailScreen(
        chatRoomId: args['chatRoomId'],
        receiverName: args['receiverName'],
      ),
    );
  }

  const ChatDetailScreen({
    Key? key,
    required this.chatRoomId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // This will hold messages

  @override
  void initState() {
    super.initState();
    _chatService.connect(context);
    _chatService.joinRoom(widget.chatRoomId);

    // TODO: Fetch initial messages via an HTTP request

    _chatService.listenForMessages((data) {
      if (mounted) {
        setState(() {
          _messages.add(data.toMap());
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      _chatService.sendMessage(
        chatId: widget.chatRoomId,
        chatRoomId: widget.chatRoomId,
        text: _messageController.text,
        senderId: user.id,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == user.id;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message['text']),
                  ),
                );
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
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
