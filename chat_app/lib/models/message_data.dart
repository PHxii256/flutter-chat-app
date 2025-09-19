class MessageData {
  final String? userId;
  final String? roomCode;
  final String username;
  final String? id;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageData({
    this.userId,
    required this.roomCode,
    this.username = "anon",
    this.id,
    this.content = "empty message",
    this.createdAt,
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
      userId: json['userId'] as String?,
      roomCode: json['code'] as String?,
      username: json['username'] as String? ?? "anon",
      id: json['_id'] as String?,
      content: json['content'] as String? ?? "empty message",
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roomCode': roomCode,
      'username': username,
      '_id': id,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MessageData{userId: $userId, roomCode: $roomCode, username: $username, id: $id, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  MessageData copyWith({
    String? userId,
    String? roomCode,
    String? username,
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageData(
      userId: userId ?? this.userId,
      roomCode: roomCode ?? this.roomCode,
      username: username ?? this.username,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
