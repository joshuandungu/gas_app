import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/chat_room.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/services/home_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

enum ChatListView { allSellers, conversations }

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final HomeServices _homeServices = HomeServices();
  List<ChatRoom>? _chatRooms;
  List<User>? _allSellers;
  ChatListView _currentView = ChatListView.conversations;

  @override
  void initState() {
    super.initState();
    _chatService.connect(context);
    _fetchData();

    // Listen for updates to refresh the chat list
    _chatService.listenForChatListUpdates(() {
      if (mounted) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    _chatRooms = await _chatService.getMyChats(context);
    if (_currentView == ChatListView.allSellers) {
      _allSellers = await _homeServices.fetchTopSellers(context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToNewChat(
      {required String receiverId, required String receiverName}) async {
    final chatRoom = await _chatService.getOrCreateChatRoom(
        context: context, receiverId: receiverId);

    if (chatRoom != null && mounted) {
      final receiver =
          chatRoom.participants.firstWhere((p) => p.id == receiverId);
      Navigator.pushNamed(
        context,
        ChatDetailScreen.routeName,
        arguments: {
          'chatRoomId': chatRoom.id,
          'receiverName': receiverName,
          'receiver': receiver,
        },
      ).then((_) => _fetchData()); // Refresh when returning
    }
  }

  void _navigateToExistingChat(ChatRoom chatRoom) {
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
        'receiverName':
            otherUser.shopName.isNotEmpty ? otherUser.shopName : otherUser.name,
        'receiver': otherUser,
      },
    ).then((_) => _fetchData()); // Refresh when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Text(
              _currentView == ChatListView.allSellers
                  ? 'Start a Chat'
                  : 'My Chats',
              style: const TextStyle(color: Colors.black)),
          automaticallyImplyLeading: false,
          actions: [
            Tooltip(
              message: _currentView == ChatListView.allSellers
                  ? 'View my conversations'
                  : 'Start a new chat',
              child: IconButton(
                icon: Icon(
                  _currentView == ChatListView.allSellers
                      ? Icons.chat_bubble_outline
                      : Icons.add_comment_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _currentView = _currentView == ChatListView.allSellers
                        ? ChatListView.conversations
                        : ChatListView.allSellers;
                    _fetchData();
                  });
                },
              ),
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _currentView == ChatListView.allSellers
            ? _buildAllSellersList()
            : _buildConversationsList(),
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_chatRooms == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chatRooms!.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No conversations yet.', style: TextStyle(fontSize: 16)),
          const Text('Your chats with sellers will appear here.',
              style: TextStyle(color: Colors.grey)),
        ],
      ));
    }
    return ListView.builder(
      itemCount: _chatRooms!.length,
      itemBuilder: (context, index) {
        final chatRoom = _chatRooms![index];
        final currentUser =
            Provider.of<UserProvider>(context, listen: false).user;
        final otherUser =
            chatRoom.participants.firstWhere((p) => p.id != currentUser.id);

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
            leading: CircleAvatar(
              backgroundImage: otherUser.shopAvatar.isNotEmpty
                  ? NetworkImage(otherUser.shopAvatar)
                  : null,
              child: otherUser.shopAvatar.isEmpty
                  ? const Icon(Icons.storefront)
                  : null,
            ),
            title: Text(otherUser.shopName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
            onTap: () => _navigateToExistingChat(chatRoom),
          ),
        );
      },
    );
  }

  Widget _buildAllSellersList() {
    if (_allSellers == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allSellers!.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No sellers found.', style: TextStyle(fontSize: 16)),
        ],
      ));
    }
    return ListView.builder(
      itemCount: _allSellers!.length,
      itemBuilder: (context, index) {
        final seller = _allSellers![index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: seller.shopAvatar.isNotEmpty
                ? NetworkImage(seller.shopAvatar)
                : null,
            child:
                seller.shopAvatar.isEmpty ? const Icon(Icons.storefront) : null,
          ),
          title: Text(seller.shopName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () => _navigateToNewChat(
              receiverId: seller.id, receiverName: seller.shopName),
        );
      },
    );
  }
}
