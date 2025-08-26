import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';
import 'package:gas/services/api_service.dart';
import 'dart:async';

class MessagesScreen extends StatefulWidget {
  final UserModel currentUser;

  const MessagesScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, String>> conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChatPartners();
  }

  Future<void> _fetchChatPartners() async {
    try {
      final List<dynamic> messages = await ApiService.get('messages/user/${widget.currentUser.id}');
      if (!mounted) return;

      // Process messages to find unique chat partners and their last messages
      Map<String, Map<String, String>> uniqueConversations = {};

      for (var msg in messages) {
        String partnerId;
        String partnerName;

        if (msg['sender_id'] == widget.currentUser.id) {
          partnerId = msg['receiver_id'];
          partnerName = msg['receiver_name'] ?? 'Unknown User'; // Assuming receiver_name is available
        } else {
          partnerId = msg['sender_id'];
          partnerName = msg['sender_name'] ?? 'Unknown User'; // Assuming sender_name is available
        }

        // Update last message and time for the conversation
        uniqueConversations[partnerId] = {
          'id': partnerId,
          'name': partnerName,
          'lastMessage': msg['content'],
          'time': _formatTimestamp(msg['created_at']),
        };
      }

      setState(() {
        conversations = uniqueConversations.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load conversations: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${dateTime.weekday}'; // Day of the week
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : conversations.isEmpty
                  ? const Center(child: Text('No conversations yet.'))
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final convo = conversations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[400],
                            child: Text(
                              convo['name']!.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            convo['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(convo['lastMessage']!),
                          trailing: Text(
                            convo['time']!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  currentUser: widget.currentUser,
                                  receiverId: convo['id']!,
                                  receiverName: convo['name']!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final UserModel currentUser;
  final String receiverId;
  final String receiverName;

  const ChatDetailScreen({
    Key? key,
    required this.currentUser,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final List<dynamic> fetchedMessages = await ApiService.get(
          'messages/conversation/${widget.currentUser.id}/${widget.receiverId}');
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        messages = fetchedMessages.map((msg) => {
              'text': msg['content'],
              'senderId': msg['sender_id'],
              'receiverId': msg['receiver_id'],
              'timestamp': DateTime.parse(msg['created_at']),
            }).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        _errorMessage = 'Failed to load messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessageData = {
      'sender_id': widget.currentUser.id,
      'receiver_id': widget.receiverId,
      'content': text,
    };

    _messageController.clear();

    try {
      await ApiService.post('messages', newMessageData);
      _fetchMessages(); // Refresh messages after sending
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: Column(
        children: [
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _errorMessage != null
                  ? Expanded(child: Center(child: Text(_errorMessage!)))
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          bool isMe = msg['senderId'] == widget.currentUser.id;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.green[300] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00C853)),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}