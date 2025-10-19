class MessagePreviewData {
  final String senderId;
  final String content;
  final String username;
  final DateTime createdAt;

  const MessagePreviewData({
    required this.senderId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory MessagePreviewData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return MessagePreviewData(
      senderId: json['senderId'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}
