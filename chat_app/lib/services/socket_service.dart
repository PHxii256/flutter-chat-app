// ignore_for_file: avoid_print
// ignore: library_prefixes
import 'package:chat_app/models/message_data.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

String getSocketUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:3000/'; // For Flutter web in browser
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/'; // For Android emulator
  } else if (Platform.isIOS) {
    return 'http://127.0.0.1:3000/'; // For iOS simulator
  } else {
    return 'http://127.0.0.1:3000/'; // For desktop or other platforms
  }
}

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  factory SocketService() {
    return _instance;
  }

  Function(dynamic data)? onMessageReceived;

  Function(dynamic data)? onMessageUpdated;

  Function(dynamic data)? onReactionReceived;

  SocketService._internal();

  bool get isConnected => socket?.connected ?? false;

  Future<bool> connectAndListen({required String roomCode, required String username}) async {
    // Always create a new socket to ensure a clean state
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }

    final completer = Completer<bool>();

    socket = IO.io(getSocketUrl(), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Register listeners first
    socket!.on('connect', (_) {
      print('Connected to socket server');
      _joinRoom(roomCode: roomCode, username: username);
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    socket!.on('connect_error', (data) {
      print('Socket connect_error (unreadable): $data');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    socket!.on('chat-message', (data) {
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

    socket!.on('disconnect', (_) {
      print('Disconnected from socket server');
    });

    try {
      socket!.connect();

      // Set a timeout for connection attempt
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
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
    final Map<String, dynamic> userInfo = {'username': username, 'roomCode': roomCode};
    socket!.emit('join-room', userInfo);
    print('Joined room: $roomCode for user: $username');
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
    required String senderId,
    required String senderUsername,
    required String action, // 'add' or 'remove'
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('message-reaction', {
        "messageId": messageId,
        "roomCode": roomCode,
        "emoji": emoji,
        "senderId": senderId,
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
