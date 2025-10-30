import 'package:chat_app/features/conversations/models/message_preview_data.dart';
import 'package:chat_app/features/chat/models/user_model.dart';

class ConversationsData {
  final String roomCode;
  final String? roomName;
  final List<User> memberList;
  final MessagePreviewData? lastMessage;
  final int unreadCount;

  ConversationsData({
    required this.roomCode,
    this.roomName,
    required this.memberList,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationsData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("roomCode") || !json.containsKey("memberList")) {
      throw Exception("roomCode or memberList are missing from json response");
    }

    List<User> members = [];
    for (var m in json["memberList"]) {
      members.add(User.fromJson(m));
    }

    String? getRoomName() {
      try {
        return members.map((u) => u.username).join(", ");
      } catch (e) {
        print("Error!!! : $e");
        return null;
      }
    }

    MessagePreviewData? getLastMessage() {
      if (!json.containsKey("lastMessage")) return null;
      final lastMsgJson = json["lastMessage"];
      if (lastMsgJson == null || lastMsgJson is! Map<String, dynamic> || lastMsgJson.isEmpty) {
        return null;
      }
      try {
        return MessagePreviewData.fromJson(lastMsgJson);
      } catch (e) {
        print("Error parsing lastMessage: $e");
        return null;
      }
    }

    return ConversationsData(
      roomCode: json["roomCode"],
      memberList: members,
      roomName: getRoomName(),
      lastMessage: getLastMessage(),
      unreadCount: json["unreadCount"] ?? 0,
    );
  }
}
