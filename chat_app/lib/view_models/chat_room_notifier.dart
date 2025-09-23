// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:collection/collection.dart';
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
      _chatroomService.onReactionReceived = null;
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
      _chatroomService.onReactionReceived = _parseReactionUpdate;
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
          reactions: [],
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

  void _parseReactionUpdate(dynamic msg) {
    try {
      if (msg == null) return;
      dynamic decodedMsg = jsonDecode(msg);

      if (state.hasValue) {
        final currentMessages = state.value!;
        final messageIndex = currentMessages.indexWhere((msg) => msg.id == decodedMsg["messageId"]);

        if (messageIndex != -1) {
          final message = currentMessages[messageIndex];
          final updatedReactions = [...message.reactions];

          final String action = decodedMsg["action"];
          final String emoji = decodedMsg["emoji"];
          final String senderId = decodedMsg["senderId"];
          final String senderUsername = decodedMsg["senderUsername"];

          if (action == "add") {
            // Add reaction if not already present
            final existingReactionIndex = updatedReactions.indexWhere(
              (r) => r.emoji == emoji && r.senderId == senderId,
            );

            if (existingReactionIndex == -1) {
              updatedReactions.add(
                MessageReact(
                  emoji: emoji,
                  messageId: message.id,
                  senderId: senderId,
                  senderUsername: senderUsername,
                ),
              );
            }
          } else if (action == "remove") {
            // Remove reaction
            updatedReactions.removeWhere((r) => r.emoji == emoji && r.senderId == senderId);
          }

          final updatedMessage = message.copyWith(reactions: updatedReactions);
          final newMessages = [...currentMessages];
          newMessages[messageIndex] = updatedMessage;
          state = AsyncValue.data(newMessages);

          print('Reaction updated: $action $emoji on message ${message.id}');
        }
      }
    } catch (e) {
      print('Error parsing reaction update: $e');
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

  static const int maxReactionsPerMessage = 50;
  static const int maxReactionsPerUserPerMessage = 5;

  Future<void> reactToMessage({
    required MessageData message,
    required String senderId,
    required String senderUsername,
    String? emoji,
  }) async {
    if (emoji == null || emoji.trim().isEmpty) {
      print('Invalid emoji provided');
      return;
    }

    // Validation checks
    if (message.reactions.length >= maxReactionsPerMessage) {
      print('Maximum reactions per message reached');
      return;
    }

    final userReactionsCount = message.reactions.where((r) => r.senderId == senderId).length;
    final existingReact = message.reactions.firstWhereOrNull(
      (mReact) => mReact.emoji == emoji && mReact.senderId == senderId,
    );

    // Check if user is trying to add a new reaction but already has max reactions
    if (existingReact == null && userReactionsCount >= maxReactionsPerUserPerMessage) {
      print('Maximum reactions per user per message reached');
      return;
    }

    if (!state.hasValue) {
      print('Cannot react: state not ready');
      return;
    }

    final messages = [...state.value!];
    final messageIndex = messages.indexWhere((m) => m.id == message.id);

    if (messageIndex == -1) {
      print('Message not found');
      return;
    }

    final originalMessage = messages[messageIndex];
    final originalReactions = [...originalMessage.reactions];

    // Determine action and update local state optimistically
    final String action = existingReact != null ? 'remove' : 'add';
    final updatedReactions = [...originalReactions];

    if (action == 'remove') {
      updatedReactions.removeWhere((react) => react.emoji == emoji && react.senderId == senderId);
      print('Optimistically removed reaction: $emoji from message ${message.id}');
    } else {
      updatedReactions.add(
        MessageReact(
          emoji: emoji,
          messageId: message.id,
          senderId: senderId,
          senderUsername: senderUsername,
        ),
      );
      print('Optimistically added reaction: $emoji to message ${message.id}');
    }

    // Update local state immediately (optimistic update)
    final updatedMessage = originalMessage.copyWith(reactions: updatedReactions);
    messages[messageIndex] = updatedMessage;
    state = AsyncValue.data(messages);

    // Send to server and handle potential failure
    try {
      if (_chatroomService.isConnected) {
        _chatroomService.sendReaction(
          messageId: message.id,
          roomCode: roomCode,
          emoji: emoji,
          senderId: senderId,
          senderUsername: senderUsername,
          action: action,
        );
      } else {
        throw Exception('Socket not connected');
      }
    } catch (e) {
      print('Failed to sync reaction with server: $e');

      // Rollback local state on server failure
      final rollbackMessage = originalMessage.copyWith(reactions: originalReactions);
      final rollbackMessages = [...state.value!];
      final rollbackIndex = rollbackMessages.indexWhere((m) => m.id == message.id);

      if (rollbackIndex != -1) {
        rollbackMessages[rollbackIndex] = rollbackMessage;
        state = AsyncValue.data(rollbackMessages);
        print('Rolled back reaction due to server error');
      }

      // Could also show user-facing error here
      rethrow; // Let calling code handle user notification
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

        // Update state by removing the message
        if (state.hasValue) {
          final currentMessages = state.value!;
          final updatedMessages = currentMessages.where((m) => m.id != msgId).toList();
          state = AsyncValue.data(updatedMessages);
          print('Message deleted successfully: $msgId');
        }
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
