import 'dart:convert';

class Message {
  final String id;
  final String? tempId;
  final String chatRoomId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.tempId,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['_id'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}
