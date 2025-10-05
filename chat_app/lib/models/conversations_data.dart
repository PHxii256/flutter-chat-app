import 'package:chat_app/models/user_model.dart';

class ConversationsData {
  final String roomCode;
  final String? roomName;
  final List<User> memberList;

  ConversationsData({required this.roomCode, this.roomName, required this.memberList});

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

    return ConversationsData(
      roomCode: json["roomCode"],
      memberList: members,
      roomName: getRoomName(),
    );
  }
}
