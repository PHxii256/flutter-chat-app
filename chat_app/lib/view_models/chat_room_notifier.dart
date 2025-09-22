// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part "chat_room_notifier.g.dart";

@riverpod
class ChatRoomNotifier extends _$ChatRoomNotifier {
  final SocketService _chatroomService = SocketService();
  final List<MessageData> _pendingMessages = []; // Buffer for messages during initialization

  // Callbacks for UI events
  VoidCallback? onHistoryLoaded;
  VoidCallback? onMessagesChanged;

  @override
  Future<List<MessageData>> build({required String username, required String roomCode}) async {
    final history = await fetchChatHistory(roomCode);
    final connected = await initService(username: username, roomCode: roomCode);

    // Set up cleanup when notifier is disposed
    ref.onDispose(() {
      _chatroomService.onMessageReceived = null;
      _chatroomService.onMessageUpdated = null;
      _chatroomService.dispose();
      onHistoryLoaded = null;
      onMessagesChanged = null;
      print('ChatRoomNotifier disposed');
    });

    if (connected) {
      // Process any messages that arrived during initialization
      final allMessages = [...history, ..._pendingMessages];
      _pendingMessages.clear();

      // Trigger callback after history is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHistoryLoaded?.call();
      });

      return allMessages;
    } else {
      // If connection failed, just return history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHistoryLoaded?.call();
      });
      return history;
    }
  }

  Future<bool> initService({required String username, required String roomCode}) async {
    try {
      await _chatroomService.connectAndListen(roomCode: roomCode, username: username);
      _chatroomService.onMessageReceived = _parseReceivedMsg;
      _chatroomService.onMessageUpdated = _parseUpdatedMsg;
      print('ChatroomRepo initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing ChatroomRepo: $e');
      return false;
    }
  }

  void _parseReceivedMsg(dynamic msg) {
    try {
      if (msg == null) return;
      dynamic decodedMsg = jsonDecode(msg);

      MessageData messageData;

      if (decodedMsg["serverMsg"] == null) {
        messageData = MessageData.fromJson(decodedMsg, roomCode);
      } else {
        messageData = MessageData(
          roomCode: roomCode,
          id: "${DateTime.now().toIso8601String()}: ${decodedMsg["serverMsg"].toString()}",
          senderId: 'Server',
          content: decodedMsg["serverMsg"].toString(),
          createdAt: DateTime.now(),
          username: 'Server',
        );
      }

      // Check if state is ready (initialization complete)
      if (state.hasValue) {
        // Normal operation: add to existing messages
        state = AsyncValue.data([...state.value!, messageData]);

        // Trigger callback for new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessagesChanged?.call();
        });
      } else {
        // Still initializing: buffer the message
        _pendingMessages.add(messageData);
        print('Message buffered during initialization: ${messageData.content}');
      }
    } catch (e) {
      print('Error parsing received message: $e');
    }
  }

  void _parseUpdatedMsg(dynamic msg) {
    try {
      if (msg == null) return;
      dynamic decodedMsg = jsonDecode(msg);

      if (state.hasValue) {
        final currentMessages = state.value!;
        final indexToBeUpdated = currentMessages.indexWhere(
          (msg) => msg.id == decodedMsg["messageId"],
        );

        if (indexToBeUpdated != -1) {
          final MessageData updatedMessage = currentMessages[indexToBeUpdated].copyWith(
            content: decodedMsg["newContent"],
            updatedAt: DateTime.now(),
          );

          final newMessages = [...currentMessages];
          newMessages[indexToBeUpdated] = updatedMessage;
          state = AsyncValue.data(newMessages);
          print('Message updated, new content: ${updatedMessage.content}');
        }
      } else {
        print('Message update ignored during initialization');
      }
    } catch (e) {
      print('Error parsing updated message: $e');
    }
  }

  void sendMessage({required String username, required String content, ReplyTo? replyTo}) {
    if (_chatroomService.isConnected) {
      _chatroomService.sendMessage(
        username: username,
        roomCode: roomCode,
        content: content,
        replyTo: replyTo,
      );
    } else {
      print('Cannot send message: not connected to socket');
    }
  }

  void updateMessage({required String messageId, required String newContent}) {
    if (_chatroomService.isConnected) {
      _chatroomService.updateMessage(
        messageId: messageId,
        newContent: newContent,
        roomCode: roomCode,
      );
    } else {
      print('Cannot update message: not connected to socket');
    }
  }

  void deleteMessage({required String msgId, required String roomCode}) async {
    try {
      final res = await http.delete(Uri.parse("${getSocketUrl()}room/$roomCode/deleteMsg/$msgId"));
      print("endpoint: room/$roomCode/deleteMsg/$msgId");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        print(json["message"]);
      } else {
        print('${res.body}: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

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
}
