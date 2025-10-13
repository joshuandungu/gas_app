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

enum ChatListView { allSellers, conversations, admin, allUsers }

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';
  const ChatListScreen({Key? key, this.initialView}) : super(key: key);

  final String? initialView;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final HomeServices _homeServices = HomeServices();
  List<ChatRoom>? _chatRooms;
  List<User>? _allSellers;
  List<User>? _allUsers;
  ChatListView _currentView = ChatListView.conversations;

  @override
  void initState() {
    super.initState();
    // Set initial view based on widget parameter or arguments
    if (widget.initialView == 'admin') {
      _currentView = ChatListView.admin;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          if (args['view'] == 'admin') {
            _currentView = ChatListView.admin;
          } else if (args['view'] == 'seller') {
            _currentView = ChatListView.allSellers;
          } else if (args['view'] == 'allUsers') {
            _currentView = ChatListView.allUsers;
          }
        }
        _fetchData();
      });
    }

    _chatService.connect(context);

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
    if (_currentView == ChatListView.allUsers) {
      _allUsers = await _homeServices.fetchAllUsers(context);
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
      User receiver;
      if (receiverId == 'admin') {
        // Create a dummy admin user since admin is not a real user in participants
        receiver = User(
          id: 'admin',
          name: 'Admin Support',
          email: 'admin@support.com',
          password: '',
          type: 'admin',
          status: 'active',
          shopName: 'Admin Support',
          shopDescription: '',
          shopAvatar: '',
          phoneNumber: '',
          address: '',
          token: '',
          cart: [],
        );
      } else {
        receiver = chatRoom.participants.firstWhere((p) => p.id == receiverId);
      }
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
    final user = Provider.of<UserProvider>(context, listen: false).user;
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
                  : _currentView == ChatListView.admin
                      ? 'Chat with Admin'
                      : _currentView == ChatListView.allUsers
                          ? 'Start a Chat'
                          : 'My Chats',
              style: const TextStyle(color: Colors.black)),
          automaticallyImplyLeading: false,
          actions: [
            if (user.type == 'admin')
              Tooltip(
                message: _currentView == ChatListView.conversations
                    ? 'View all users'
                    : 'View my conversations',
                child: IconButton(
                  icon: Icon(
                    _currentView == ChatListView.conversations
                        ? Icons.people
                        : Icons.chat_bubble_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_currentView == ChatListView.conversations) {
                        _currentView = ChatListView.allUsers;
                      } else {
                        _currentView = ChatListView.conversations;
                      }
                      _fetchData();
                    });
                  },
                ),
              )
            else
              Tooltip(
                message: _currentView == ChatListView.allSellers
                    ? 'View my conversations'
                    : _currentView == ChatListView.admin
                        ? 'Start a new chat'
                        : 'Start a new chat',
                child: IconButton(
                  icon: Icon(
                    _currentView == ChatListView.allSellers
                        ? Icons.chat_bubble_outline
                        : _currentView == ChatListView.admin
                            ? Icons.add_comment_outlined
                            : Icons.add_comment_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_currentView == ChatListView.conversations) {
                        _currentView = user.type == 'admin'
                            ? ChatListView.admin
                            : ChatListView.allSellers;
                      } else {
                        _currentView = ChatListView.conversations;
                      }
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
            : _currentView == ChatListView.admin
                ? _buildAdminChat()
                : _currentView == ChatListView.allUsers
                    ? _buildAllUsersList()
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

  Widget _buildAdminChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Chat with Admin', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Send queries and complaints to the admin',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _navigateToNewChat(
                receiverId: 'admin', receiverName: 'Admin Support'),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersList() {
    if (_allUsers == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allUsers!.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No users found.', style: TextStyle(fontSize: 16)),
        ],
      ));
    }
    return ListView.builder(
      itemCount: _allUsers!.length,
      itemBuilder: (context, index) {
        final user = _allUsers![index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.shopAvatar.isNotEmpty
                ? NetworkImage(user.shopAvatar)
                : null,
            child: user.shopAvatar.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.shopName.isNotEmpty ? user.shopName : user.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.type, style: TextStyle(color: Colors.grey)),
          onTap: () => _navigateToNewChat(
              receiverId: user.id, receiverName: user.shopName.isNotEmpty ? user.shopName : user.name),
        );
      },
    );
  }
}
