import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/chat_room.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerChatListScreen extends StatefulWidget {
  static const String routeName = '/seller-chat-list';
  const SellerChatListScreen({Key? key}) : super(key: key);

  @override
  State<SellerChatListScreen> createState() => _SellerChatListScreenState();
}

class _SellerChatListScreenState extends State<SellerChatListScreen> {
  final ChatService _chatService = ChatService();
  List<ChatRoom>? _chatRooms;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    _chatRooms = await _chatService.getMyChats(context);
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToChatDetail(ChatRoom chatRoom) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    // Determine the other user in the chat
    final otherUser = chatRoom.participants.firstWhere(
      (p) => p.id != currentUser.id,
      orElse: () => chatRoom.participants.first, // Fallback
    );

    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: {
        'chatRoomId': chatRoom.id,
        'receiverName': otherUser.name,
        'receiver': otherUser,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchChatRooms,
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
                    const Text('No chats yet.', style: TextStyle(fontSize: 16)),
                    const Text(
                        'Your conversations with buyers will appear here.',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : ListView.builder(
                  itemCount: _chatRooms!.length,
                  itemBuilder: (context, index) {
                    final chatRoom = _chatRooms![index];
                    final currentUser =
                        Provider.of<UserProvider>(context, listen: false).user;
                    final otherUser = chatRoom.participants
                        .firstWhere((p) => p.id != currentUser.id);

                    final unreadInfo = chatRoom.unreadCounts.firstWhere(
                        (uc) => uc.userId == currentUser.id,
                        orElse: () => UnreadCount(userId: '', count: 0));

                    return Dismissible(
                      key: Key(chatRoom.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _chatService.deleteChat(
                            context: context, chatRoomId: chatRoom.id);
                        setState(() {
                          _chatRooms!.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Conversation deleted")),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(otherUser.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          chatRoom.lastMessage ?? 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: unreadInfo.count > 0
                            ? badges.Badge(
                                badgeContent: Text(
                                unreadInfo.count.toString(),
                                style: const TextStyle(color: Colors.white),
                              ))
                            : null,
                        onTap: () => _navigateToChatDetail(chatRoom),
                      ),
                    );
                  },
                ),
    );
  }
}
