class MessageData {
  final String senderId;
  final String roomCode;
  final String username;
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReplyTo? replyTo;
  final List<MessageReact> reactions;

  const MessageData({
    required this.senderId,
    required this.roomCode,
    required this.username,
    required this.id,
    required this.content,
    required this.createdAt,
    required this.reactions,
    this.updatedAt,
    this.replyTo,
  });

  factory MessageData.fromJson(Map<String, dynamic> json, String roomCode) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    ReplyTo? getMsgRepliedTo() {
      if (json.containsKey("replyTo") && json["replyTo"] != null) {
        return ReplyTo(
          content: json["replyTo"]["content"],
          messageId: json["replyTo"]["messageId"],
        );
      }
      return null;
    }

    List<MessageReact> getMsgReactions() {
      if (json.containsKey("reactions") && json["reactions"] != null) {
        List<MessageReact> msgReacts = [];
        for (Map<String, dynamic> react in json["reactions"]) {
          msgReacts.add(
            MessageReact(
              emoji: react["emoji"],
              messageId: json['_id'],
              senderId: react["senderId"],
              senderUsername: react["senderUsername"],
            ),
          );
        }
        return msgReacts;
      }
      return [];
    }

    return MessageData(
      senderId: json['senderId'] as String,
      roomCode: roomCode,
      username: json['username'] as String? ?? "anon",
      id: json['_id'] as String,
      content: json['content'] as String? ?? "empty message",
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']),
      replyTo: getMsgRepliedTo(),
      reactions: getMsgReactions(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'roomCode': roomCode,
      'username': username,
      '_id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'replyTo': replyTo?.toJson(),
      'reactions': reactions,
    };
  }

  @override
  String toString() {
    return 'MessageData{senderId: $senderId, roomCode: $roomCode, username: $username, id: $id, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, replyTo: ${replyTo?.toJson()}}';
  }

  MessageData copyWith({
    String? senderId,
    String? roomCode,
    String? username,
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReplyTo? replyTo,
    List<MessageReact>? reactions,
  }) {
    return MessageData(
      senderId: senderId ?? this.senderId,
      roomCode: roomCode ?? this.roomCode,
      username: username ?? this.username,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
    );
  }
}

class ReplyTo {
  final String messageId;
  final String content;
  const ReplyTo({required this.content, required this.messageId});

  Map<String, dynamic> toJson() {
    return {'messageId': messageId, 'content': content};
  }
}

class MessageReact {
  final String messageId;
  final String senderId;
  final String senderUsername;
  final String emoji;
  const MessageReact({
    required this.emoji,
    required this.messageId,
    required this.senderId,
    required this.senderUsername,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'react': emoji,
    };
  }
}
