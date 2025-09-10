import 'package:flutter/material.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/message.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ChatDetailScreen extends StatefulWidget {
  static const String routeName = '/chat-detail';
  final String chatRoomId;
  final String receiverName;
  final User receiver;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoomId,
    required this.receiverName,
    required this.receiver,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = []; // This will hold messages
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _chatService.connect(context);
    _chatService.joinRoom(widget.chatRoomId);

    _chatService.listenForMessages((data) {
      if (mounted) {
        final user = Provider.of<UserProvider>(context, listen: false).user;
        // If the received message is from the current user,
        // remove the temporary optimistic message and add the real one from the server.
        final tempMessageId = data.tempId;
        if (data.senderId == user.id && tempMessageId != null) {
          setState(() {
            // Find the index of the temporary message and replace it
            final index = _messages.indexWhere((msg) => msg.id == tempMessageId);
            if (index != -1) {
              _messages[index] = data;
            }
          });
        } else {
          setState(() {
            _messages.add(data); // Add message from the other user
          });
        }
      }
    });
  }

  void _fetchMessages() async {
    var fetchedMessages = await _chatService.getChatMessages(
        context: context, chatRoomId: widget.chatRoomId);
    setState(() {
      _messages.addAll(fetchedMessages);
      _isLoading = false;
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

      // Generate a unique temporary ID for optimistic update
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Add the message to the UI instantly
      final tempMessage = Message(
        id: tempId, // Use the unique temporary ID
        chatRoomId: widget.chatRoomId,
        senderId: user.id,
        text: _messageController.text,
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(tempMessage);
      });

      // Send the message to the server
      _chatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        text: _messageController.text,
        senderId: user.id,
        receiverId: widget.receiver.id,
        tempId: tempId, // Pass the temporary ID to the server
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == user.id;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(message.text),
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
          )
        ],
      ),
    );
  }
}
