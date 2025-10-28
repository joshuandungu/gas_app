import 'dart:convert';

import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';

class UnreadCount {
  final String userId;
  final int count;
  UnreadCount({required this.userId, required this.count});
}

class ChatRoom {
  final String id;
  final List<User> participants;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final List<UnreadCount> unreadCounts;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessageAt,
    this.lastMessage,
    required this.unreadCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'participants': participants.map((x) => x.toMap()).toList(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCounts': unreadCounts
          .map((x) => {'userId': x.userId, 'count': x.count})
          .toList(),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['_id'] ?? '',
      participants: List<User>.from(
        map['participants']?.map((x) => User.fromMap(x)) ?? [],
      ),
      lastMessageAt: DateTime.parse(
          map['lastMessageAt'] ?? DateTime.now().toIso8601String()),
      lastMessage: map['lastMessage'],
      unreadCounts: List<UnreadCount>.from(
        map['unreadCounts']?.map((x) => UnreadCount(
                  userId: x['userId'],
                  count: x['count'] ?? 0,
                )) ??
            [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoom.fromJson(String source) =>
      ChatRoom.fromMap(json.decode(source));

  ChatRoom copyWith({
    String? id,
    List<User>? participants,
    DateTime? lastMessageAt,
    String? lastMessage,
    List<UnreadCount>? unreadCounts,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}
