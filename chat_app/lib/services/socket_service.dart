// ignore: library_prefixes
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/utils/server_url.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  factory SocketService() {
    return _instance;
  }

  Function(dynamic data)? onMessageReceived;

  Function(dynamic data)? onMessageUpdated;

  Function(dynamic data)? onReactionReceived;

  Function()? onAuthError;

  SocketService._internal();

  bool get isConnected => socket?.connected ?? false;

  Future<bool> connectAndListen({
    required String roomCode,
    required String username,
    required String authToken,
    bool testConnection = false, // Add test mode for debugging
  }) async {
    // Always create a new socket to ensure a clean state
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }

    final completer = Completer<bool>();

    // Prepare socket options
    Map<String, dynamic> socketOptions = {
      'transports': ['websocket'],
      'autoConnect': false,
    };

    // Only add auth if token is provided and not empty, and not in test mode
    if (!testConnection && authToken.isNotEmpty) {
      socketOptions['auth'] = {'token': authToken};
      print("Auth token added to socket options: $authToken");
    } else {
      print("No auth token provided - socket connection may fail");
    }

    socket = IO.io(getServertUrl(), socketOptions);
    print('🌐 Socket connecting to: ${getServertUrl()}');
    print('📋 Socket options: $socketOptions');

    // Register listeners first
    socket!.on('connect', (_) {
      print('✅ Socket connected successfully to server');
      print('🏠 Attempting to join room: $roomCode as user: $username');
      _joinRoom(roomCode: roomCode, username: username);
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    socket!.on('connect_error', (data) {
      print('❌ Socket connection error: $data');
      print('🔍 Error type: ${data.runtimeType}');

      // Check if error is auth-related
      String errorMsg = data.toString().toLowerCase();
      if (errorMsg.contains('authentication') ||
          errorMsg.contains('token') ||
          errorMsg.contains('unauthorized') ||
          errorMsg.contains('invalid') ||
          errorMsg.contains('expired')) {
        print('🔐 Authentication error detected in socket connection');
        onAuthError?.call();
      }

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    socket!.on('chat-message', (data) {
      print("update!!!!!!!!!!!! data: $data");
      if (data == null) {
        print('Received null data from socket');
        return;
      }
      onMessageReceived?.call(data);
      print('New message: $data');
    });

    socket!.on('message-update', (data) {
      if (data == null) {
        print('Received null data from socket');
        return;
      }
      onMessageUpdated?.call(data);
      print('New message update!!!!!!!!: $data');
    });

    socket!.on('message-reaction', (data) {
      if (data == null) {
        print('Received null reaction data from socket');
        return;
      }
      onReactionReceived?.call(data);
      print('New reaction update: $data');
    });

    // Listen for backend-specific events
    socket!.on('room-joined', (data) {
      print('🎉 Successfully joined room: $data');
    });

    socket!.on('error', (data) {
      print('⚠️ Server error: $data');

      // Check if this is an auth-related error
      if (data != null) {
        String errorMsg = data.toString().toLowerCase();
        if (errorMsg.contains('token') ||
            errorMsg.contains('invalid') ||
            errorMsg.contains('expired') ||
            errorMsg.contains('authentication')) {
          print('🔐 Token-related server error detected');
          onAuthError?.call();
        }
      }

      // Mark connection as failed if it's still pending
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    socket!.on('disconnect', (_) {
      print('🔌 Disconnected from socket server');
    });

    try {
      print('🔌 Initiating socket connection...');
      socket!.connect();

      // Add debugging for connection state changes
      socket!.on('connecting', (_) {
        print('🔄 Socket is connecting...');
      });

      socket!.on('reconnect', (_) {
        print('🔄 Socket is reconnecting...');
      });

      socket!.on('reconnect_attempt', (_) {
        print('🔄 Socket reconnect attempt...');
      });

      socket!.on('reconnect_error', (data) {
        print('❌ Socket reconnect error: $data');
      });

      socket!.on('reconnect_failed', (_) {
        print('❌ Socket reconnect failed');
      });

      // Set a timeout for connection attempt (increased for auth processing)
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          print('⏱️ Socket connection timeout after 10 seconds');
          print('🔍 Socket state: ${socket?.connected ?? 'null'}');
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      print('Error during socket connection: $e');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return false;
    }
  }

  void _joinRoom({required String roomCode, required String username}) {
    // Backend expects only roomCode as it gets user info from authenticated socket
    final Map<String, dynamic> roomInfo = {'roomCode': roomCode};
    socket!.emit('join-room', roomInfo);
    print('Joining room: $roomCode for user: $username');
  }

  void sendMessage({
    required String username,
    required String roomCode,
    required String content,
    ReplyTo? replyTo,
  }) {
    final message = {
      "username": username,
      "roomCode": roomCode,
      "content": content,
      "createdAt": DateTime.now().toIso8601String(),
      "replyTo": replyTo?.toJson(),
    };

    if (socket != null && socket!.connected) {
      socket!.emit('chat-message', message);
      print('Message sent: $message');
    } else {
      print('Cannot send message, socket not connected.');
    }
  }

  void sendImageMessage({
    required String username,
    required String roomCode,
    required List<ImageData> images,
    String? content,
    ReplyTo? replyTo,
  }) {
    final message = {
      "username": username,
      "roomCode": roomCode,
      "type": "image",
      "content": content,
      "imageData": images.map((img) => img.toJson()).toList(),
      "createdAt": DateTime.now().toIso8601String(),
      "replyTo": replyTo?.toJson(),
    };

    if (socket != null && socket!.connected) {
      socket!.emit('chat-message', message);
      print('Image message sent: $message');
    } else {
      print('Cannot send image message, socket not connected.');
    }
  }

  void updateMessage({
    required String messageId,
    required String newContent,
    required String roomCode,
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('message-update', {
        "messageId": messageId,
        "roomCode": roomCode,
        "newContent": newContent,
      });
    } else {
      print('Cannot update message, socket not connected.');
    }
  }

  void sendReaction({
    required String messageId,
    required String roomCode,
    required String emoji,
    //required String senderId,
    required String senderUsername,
    required String action, // 'add' or 'remove'
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('message-reaction', {
        "messageId": messageId,
        "roomCode": roomCode,
        "emoji": emoji,
        //"senderId": senderId,
        "senderUsername": senderUsername,
        "action": action,
        "timestamp": DateTime.now().toIso8601String(),
      });
      print('Reaction sent: $action $emoji on message $messageId');
    } else {
      print('Cannot send reaction, socket not connected.');
    }
  }

  void dispose() {
    socket?.disconnect();
    socket = null;
  }
}
