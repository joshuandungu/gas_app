import 'dart:convert';

import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/chat_room.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/models/message.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatService {
  io.Socket? _socket;

  void connect(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.token.isNotEmpty) {
      _socket = io.io(uri, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      _socket!.connect();

      _socket!.onConnect((_) {
        print('Connected to socket server');
      });

      _socket!.onDisconnect((_) => print('Disconnected from socket server'));
    }
  }

  void joinRoom(String chatId) {
    _socket?.emit('joinRoom', chatId);
  }

  void sendMessage({
    required String chatId,
    required String chatRoomId,
    required String text,
    required String senderId,
  }) {
    _socket?.emit('sendMessage', {
      'chatId': chatId,
      'chatRoomId': chatRoomId,
      'text': text,
      'senderId': senderId,
    });
  }

  void listenForMessages(Function(Message) onMessageReceived) {
    _socket?.on('receiveMessage', (data) {
      onMessageReceived(Message.fromMap(data));
    });
  }

  Future<ChatRoom?> getOrCreateChatRoom({
    required BuildContext context,
    required String receiverId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ChatRoom? chatRoom;
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/chat/get-or-create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'receiverId': receiverId}),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          chatRoom = ChatRoom.fromJson(res.body);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return chatRoom;
  }

  Future<List<ChatRoom>> getMyChats(BuildContext context) async {
    // Implementation for getting all chats
    return [];
  }

  Future<List<Message>> getChatMessages({
    required BuildContext context,
    required String chatRoomId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Message> messages = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/chat/messages/$chatRoomId'),
        headers: {'x-auth-token': userProvider.user.token},
      );
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            for (var item in jsonDecode(res.body)) {
              messages.add(Message.fromMap(item));
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return messages;
  }

  void dispose() {
    _socket?.dispose();
  }
}
