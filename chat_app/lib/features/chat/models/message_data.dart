class ImageData {
  final String url;
  final String id;

  ImageData({required this.url, required this.id});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(url: json['url'], id: json['_id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'url': url, '_id': id};
  }
}

class ImageMessageData extends MessageData {
  final List<ImageData> imageData;

  ImageMessageData({
    required super.senderId,
    required super.roomCode,
    required super.username,
    required super.id,
    required super.createdAt,
    required super.reactions,
    required super.type,
    super.content,
    super.replyTo,
    super.updatedAt,
    required this.imageData,
  });

  factory ImageMessageData.fromJson(Map<String, dynamic> json, String roomCode) {
    List<ImageData> images = [];

    if (json['imageData'] is List) {
      images = (json['imageData'] as List).map((img) {
        if (img is Map<String, dynamic>) {
          if (img.containsKey('imageData') && img['imageData'] is Map<String, dynamic>) {
            return ImageData.fromJson(img['imageData']);
          } else {
            return ImageData.fromJson(img);
          }
        } else {
          throw Exception('Invalid image data structure');
        }
      }).toList();
    } else if (json['imageData'] != null) {
      images = [ImageData.fromJson(json['imageData'])];
    } else {
      throw Exception("imageData is null");
    }

    return ImageMessageData(
      senderId: json['senderId'] as String,
      roomCode: roomCode,
      username: json['username'] as String? ?? "anon",
      id: json['_id'] as String,
      content: json['content'] as String?,
      createdAt: MessageData.parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: MessageData.parseDate(json['updatedAt']) ?? DateTime.now(),
      replyTo: MessageData.getMsgRepliedTo(json),
      reactions: MessageData.getMsgReactions(json),
      type: json['type'] as String? ?? "text",
      imageData: images,
    );
  }

  @override
  ImageMessageData copyWith({
    String? senderId,
    String? roomCode,
    String? type,
    String? username,
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReplyTo? replyTo,
    List<MessageReact>? reactions,
    List<ImageData>? imageData,
  }) {
    return ImageMessageData(
      senderId: senderId ?? this.senderId,
      roomCode: roomCode ?? this.roomCode,
      type: type ?? this.type,
      username: username ?? this.username,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      imageData: imageData ?? this.imageData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    return {...base, 'images': imageData.map((img) => img.toJson()).toList()};
  }
}

class MessageData {
  final String senderId;
  final String roomCode;
  final String username;
  final String id;
  final String type;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReplyTo? replyTo;
  final List<MessageReact> reactions;

  const MessageData({
    required this.senderId,
    required this.roomCode,
    required this.username,
    required this.id,
    required this.type,
    this.content,
    required this.createdAt,
    required this.reactions,
    this.updatedAt,
    this.replyTo,
  });

  static ReplyTo? getMsgRepliedTo(Map<String, dynamic> json) {
    if (json.containsKey("replyTo") && json["replyTo"] != null) {
      return ReplyTo(content: json["replyTo"]["content"], messageId: json["replyTo"]["messageId"]);
    }
    return null;
  }

  static List<MessageReact> getMsgReactions(Map<String, dynamic> json) {
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

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  factory MessageData.fromJson(Map<String, dynamic> json, String roomCode) {
    if (json['type'] == "image") {
      return ImageMessageData.fromJson(json, roomCode);
    } else {
      return MessageData(
        senderId: json['senderId'] as String,
        roomCode: roomCode,
        username: json['username'] as String? ?? "anon",
        id: json['_id'] as String,
        content: json['content'] as String? ?? "empty message",
        createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseDate(json['updatedAt']),
        replyTo: getMsgRepliedTo(json),
        reactions: getMsgReactions(json),
        type: json['type'] ?? "text",
      );
    }
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
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'type': type,
    };
  }

  @override
  String toString() {
    return 'MessageData{senderId: $senderId, roomCode: $roomCode, username: $username, id: $id, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, replyTo: ${replyTo?.toJson()}, type: $type}';
  }

  MessageData copyWith({
    String? senderId,
    String? roomCode,
    String? type,
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
      type: type ?? this.type,
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
