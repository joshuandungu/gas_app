import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/chat_room.dart'; // Corrected model path
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<ChatRoom>? _chatRooms;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    _chatRooms = await _chatService.getMyChats(context);
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToChatDetail(ChatRoom chatRoom) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    // Find the other participant in the chat
    final otherParticipant = chatRoom.participants.firstWhere(
      (p) => p.id != currentUser.id,
      // A more robust fallback in case the current user is the only participant
      // which shouldn't happen in a 1-on-1 chat.
      orElse: () => chatRoom.participants.first,
    );

    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: {
        'chatRoomId': chatRoom.id,
        'receiverName': otherParticipant.shopName.isNotEmpty
            ? otherParticipant.shopName
            : otherParticipant.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: GlobalVariables.appBarGradient)),
          title: const Text('My Chats', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChats,
        child: _chatRooms == null
            ? const Center(child: CircularProgressIndicator())
            : _chatRooms!.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('You have no active chats.',
                          style: TextStyle(fontSize: 16)),
                      const Text('Start a conversation from a product page.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ))
                : ListView.builder(
                    itemCount: _chatRooms!.length,
                    itemBuilder: (context, index) {
                      final chatRoom = _chatRooms![index];
                      final currentUser =
                          Provider.of<UserProvider>(context, listen: false)
                              .user;
                      final otherParticipant = chatRoom.participants.firstWhere(
                        (p) => p.id != currentUser.id,
                        orElse: () =>
                            chatRoom.participants.first, // Safe fallback
                      );

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              otherParticipant.shopAvatar.isNotEmpty
                                  ? NetworkImage(otherParticipant.shopAvatar)
                                  : null,
                          onBackgroundImageError: (_, __) {},
                          child: otherParticipant.shopAvatar.isEmpty
                              ? const Icon(Icons.storefront)
                              : null,
                        ),
                        title: Text(
                          otherParticipant.shopName.isNotEmpty
                              ? otherParticipant.shopName
                              : otherParticipant.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            chatRoom.lastMessage ?? 'Tap to view conversation'),
                        trailing: Text(DateFormat('h:mm a')
                            .format(chatRoom.lastMessageAt)),
                        onTap: () => _navigateToChatDetail(chatRoom),
                      );
                    },
                  ),
      ),
    );
  }
}
