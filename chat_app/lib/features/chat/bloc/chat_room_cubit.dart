// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/chat/services/socket_service.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/shared/utils/pretty_json.dart';
import 'package:chat_app/core/config/server_url.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

// States
sealed class ChatRoomState {
  const ChatRoomState();
}

class ChatRoomInitial extends ChatRoomState {
  const ChatRoomInitial();
}

class ChatRoomLoading extends ChatRoomState {
  const ChatRoomLoading();
}

class ChatRoomLoaded extends ChatRoomState {
  final List<MessageData> messages;
  const ChatRoomLoaded({required this.messages});
}

class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError({required this.message});
}

// Cubit
class ChatRoomCubit extends Cubit<ChatRoomState> {
  final String roomCode;
  final TokenStorageService _tokenStorageService;
  final AuthRepository _authRepository;
  final SocketService _chatroomService = SocketService();
  final List<MessageData> _pendingMessages = [];

  // Callbacks for UI events
  VoidCallback? onHistoryLoaded;
  VoidCallback? onMessagesChanged;
  String? currentUsername;

  ChatRoomCubit({
    required this.roomCode,
    required TokenStorageService tokenStorageService,
    required AuthRepository authRepository,
  }) : _tokenStorageService = tokenStorageService,
       _authRepository = authRepository,
       super(const ChatRoomInitial());

  Future<void> initialize({required String? username}) async {
    currentUsername = username ?? "placeholder";
    emit(const ChatRoomLoading());

    try {
      final history = await fetchChatHistory(roomCode);
      final connected = await initService(username: currentUsername, roomCode: roomCode);

      if (connected) {
        // Process any messages that arrived during initialization
        final allMessages = [...history, ..._pendingMessages];
        _pendingMessages.clear();

        emit(ChatRoomLoaded(messages: allMessages));

        // Trigger callback after history is loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onHistoryLoaded?.call();
        });
      } else {
        // If connection failed, just return history
        emit(ChatRoomLoaded(messages: history));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onHistoryLoaded?.call();
        });
      }
    } catch (e) {
      emit(ChatRoomError(message: 'Failed to initialize chat room: $e'));
    }
  }

  Future<bool> initService({required String? username, required String roomCode}) async {
    print("🚀 Socket Service init for user: $username, room: $roomCode");

    try {
      // Get the auth token from storage
      var authToken = await _tokenStorageService.getAccessToken();

      print(
        "🔑 Auth token status: ${authToken != null ? 'Found (${authToken.length} chars)' : 'Missing'}",
      );

      // If we don't have a token at all, try to refresh
      if (authToken == null || authToken.isEmpty) {
        print("⚠️ No token found, attempting to get fresh tokens...");
        final refreshSuccess = await _authRepository.refreshTokens();

        if (refreshSuccess) {
          print("✅ Token refreshed successfully");
          authToken = await _tokenStorageService.getAccessToken();
          print(
            "🔑 New token status: ${authToken != null ? 'Found (${authToken.length} chars)' : 'Missing'}",
          );
        } else {
          print("❌ Token refresh failed, user needs to login");
          return false;
        }
      } else {
        // Show first and last few characters for debugging (don't log full token for security)
        String tokenPreview = authToken.length > 10
            ? "${authToken.substring(0, 5)}...${authToken.substring(authToken.length - 5)}"
            : "Short token";
        print("🔍 Token preview: $tokenPreview");
      }

      try {
        if (authToken == null || authToken.isEmpty) {
          print("⚠️ No valid auth token available, cannot connect to socket");
          return false;
        }

        final authConnectionSuccess = await _chatroomService.connectAndListen(
          roomCode: roomCode,
          username: username,
          authToken: authToken,
        );

        if (authConnectionSuccess) {
          print("✅ Primary auth connection successful");
        } else {
          print("❌ Primary auth connection returned false");
        }
      } catch (e) {
        print("❌ Primary auth connection failed: $e");
        return false;
      }

      _chatroomService.onMessageReceived = _parseReceivedMsg;
      _chatroomService.onMessageUpdated = _parseUpdatedMsg;
      _chatroomService.onReactionReceived = _parseReactionUpdate;

      // Set up auth error callback to handle token refresh
      _chatroomService.onAuthError = () async {
        print('Auth error detected, attempting token refresh...');
        try {
          final refreshSuccess = await _authRepository.refreshTokens();

          if (refreshSuccess) {
            print("refreshed the token");
          } else {
            print('Token refresh failed, user may need to log in again');
          }
        } catch (e) {
          print('Error during auth error handling: $e');
        }
      };

      print('ChatroomRepo initialized successfully with auth token');
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
          type: 'text',
        );
      }

      // Check if state is ready (initialization complete)
      final currentState = state;
      if (currentState is ChatRoomLoaded) {
        // Normal operation: add to existing messages
        emit(ChatRoomLoaded(messages: [...currentState.messages, messageData]));

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

      final currentState = state;
      if (currentState is ChatRoomLoaded) {
        final currentMessages = currentState.messages;
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
          emit(ChatRoomLoaded(messages: newMessages));
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

      final currentState = state;
      if (currentState is ChatRoomLoaded) {
        final currentMessages = currentState.messages;
        final messageIndex = currentMessages.indexWhere((msg) => msg.id == decodedMsg["messageId"]);

        if (messageIndex != -1) {
          final message = currentMessages[messageIndex];
          final updatedReactions = [...message.reactions];

          final String action = decodedMsg["action"];
          final String emoji = decodedMsg["emoji"];
          final String senderId = decodedMsg["senderId"];
          final String senderUsername = decodedMsg["senderUsername"];

          if (action == "add") {
            // Add reaction only if not already present (avoid duplicates from optimistic updates)
            final existingReactionIndex = updatedReactions.indexWhere(
              (r) => r.emoji == emoji && r.senderUsername == senderUsername,
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
            } else {
              print('Reaction already exists (likely from optimistic update), skipping');
              return;
            }
          } else if (action == "remove") {
            final initialCount = updatedReactions.length;
            updatedReactions.removeWhere(
              (r) => r.emoji == emoji && r.senderUsername == senderUsername,
            );

            if (updatedReactions.length == initialCount) {
              print('Reaction to remove not found (likely already removed optimistically)');
              return;
            }
          }

          final updatedMessage = message.copyWith(reactions: updatedReactions);
          final newMessages = [...currentMessages];
          newMessages[messageIndex] = updatedMessage;
          emit(ChatRoomLoaded(messages: newMessages));

          print('Reaction updated: $action $emoji on message ${message.id}');
        }
      }
    } catch (e) {
      print('Error parsing reaction update: $e');
    }
  }

  void sendMessage({required String content, ReplyTo? replyTo}) {
    if (currentUsername == null) {
      print('User not found, please login to send a message');
      return;
    }
    if (_chatroomService.isConnected) {
      _chatroomService.sendMessage(
        username: currentUsername!,
        roomCode: roomCode,
        content: content,
        replyTo: replyTo,
      );
    } else {
      print('Cannot send message: not connected to socket');
    }
  }

  void sendImageMessage({required List<ImageData> images, String? content, ReplyTo? replyTo}) {
    if (currentUsername == null) {
      print('User not found, please login to send a message');
      return;
    }
    if (_chatroomService.isConnected) {
      _chatroomService.sendImageMessage(
        username: currentUsername!,
        roomCode: roomCode,
        images: images,
        content: content,
        replyTo: replyTo,
      );
    } else {
      print('Cannot send image message: not connected to socket');
    }
  }

  static const int maxReactionsPerMessage = 50;
  static const int maxReactionsPerUserPerMessage = 10;

  Future<void> reactToMessage({required MessageData message, required String emoji}) async {
    if (currentUsername == null) {
      print('User not found, please login to react');
      return;
    }

    // Validation checks
    if (message.reactions.length >= maxReactionsPerMessage) {
      print('Maximum reactions per message reached');
      return;
    }

    final userReactionsCount = message.reactions
        .where((r) => r.senderUsername == currentUsername)
        .length;
    final existingReact = message.reactions.firstWhereOrNull(
      (mReact) => mReact.emoji == emoji && mReact.senderUsername == currentUsername,
    );

    // Check if user is trying to add a new reaction but already has max reactions
    if (existingReact == null && userReactionsCount >= maxReactionsPerUserPerMessage) {
      print('Maximum reactions per user per message reached');
      return;
    }

    final currentState = state;
    if (currentState is! ChatRoomLoaded) {
      print('Cannot react: state not ready');
      return;
    }

    final messages = [...currentState.messages];
    final messageIndex = messages.indexWhere((m) => m.id == message.id);

    if (messageIndex == -1) {
      print('Message not found');
      return;
    }

    final String action = existingReact != null ? 'remove' : 'add';

    // Send to server and handle potential failure
    try {
      if (_chatroomService.isConnected) {
        // Optimistically update local state first for immediate UI feedback
        final updatedReactions = [...message.reactions];

        if (action == "add") {
          updatedReactions.add(
            MessageReact(
              emoji: emoji,
              messageId: message.id,
              senderId: currentUsername!,
              senderUsername: currentUsername!,
            ),
          );
        } else {
          updatedReactions.removeWhere(
            (r) => r.emoji == emoji && r.senderUsername == currentUsername,
          );
        }

        final updatedMessage = message.copyWith(reactions: updatedReactions);
        final newMessages = [...messages];
        newMessages[messageIndex] = updatedMessage;
        emit(ChatRoomLoaded(messages: newMessages));

        // Then send to server for synchronization with other users
        _chatroomService.sendReaction(
          messageId: message.id,
          roomCode: roomCode,
          emoji: emoji,
          senderUsername: currentUsername!,
          action: action,
        );
      } else {
        throw Exception('Socket not connected');
      }
    } catch (e) {
      print('Failed to sync reaction with server: $e');
      rethrow;
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

  Future<void> deleteMessage({required String msgId}) async {
    try {
      final res = await http.delete(Uri.parse("${getServertUrl()}room/$roomCode/deleteMsg/$msgId"));
      print("endpoint: room/$roomCode/deleteMsg/$msgId");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        print(json["message"]);

        // Update state by removing the message
        final currentState = state;
        if (currentState is ChatRoomLoaded) {
          final currentMessages = currentState.messages;
          final updatedMessages = currentMessages.where((m) => m.id != msgId).toList();
          emit(ChatRoomLoaded(messages: updatedMessages));
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
      final res = await http.get(Uri.parse("${getServertUrl()}room/chat-history/$roomCode"));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as List<dynamic>;
        prettyJsonPrint(json);
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

  @override
  Future<void> close() {
    _chatroomService.onMessageReceived = null;
    _chatroomService.onMessageUpdated = null;
    _chatroomService.onReactionReceived = null;
    _chatroomService.onAuthError = null;
    _chatroomService.dispose();
    onHistoryLoaded = null;
    onMessagesChanged = null;
    print('ChatRoomCubit disposed');
    return super.close();
  }
}
