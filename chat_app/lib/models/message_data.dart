class MessageData {
  final String senderId;
  final String roomCode;
  final String username;
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageData({
    required this.senderId,
    required this.roomCode,
    required this.username,
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json, String roomCode) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return MessageData(
      senderId: json['senderId'] as String,
      roomCode: roomCode,
      username: json['username'] as String? ?? "anon",
      id: json['_id'] as String,
      content: json['content'] as String? ?? "empty message",
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']),
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
    };
  }

  @override
  String toString() {
    return 'MessageData{senderId: $senderId, roomCode: $roomCode, username: $username, id: $id, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  MessageData copyWith({
    String? senderId,
    String? roomCode,
    String? username,
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageData(
      senderId: senderId ?? this.senderId,
      roomCode: roomCode ?? this.roomCode,
      username: username ?? this.username,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
