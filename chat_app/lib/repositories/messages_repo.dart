// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:http/http.dart' as http;

Future<List<MessageData>> fetchChatHistory(String roomCode) async {
  try {
    final res = await http.get(Uri.parse("${getSocketUrl()}room/chat-history/$roomCode"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as List<dynamic>;
      List<MessageData> messages = [];
      for (var msg in json) {
        messages.add(MessageData.fromJson(msg, roomCode));
      }
      return messages;
    } else {
      print('${res.body}: ${res.statusCode}');
      return [];
    }
  } catch (e) {
    throw Exception('Error fetching chat history: $e');
  }
}
