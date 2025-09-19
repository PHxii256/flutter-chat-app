// ignore_for_file: avoid_print
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' show Platform;
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

  SocketService._internal();

  void connectAndListen({required String roomCode, required String username}) {
    // Always create a new socket to ensure a clean state
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }
    socket = IO.io(getSocketUrl(), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // Register listeners first
    socket!.on('connect', (_) {
      print('Connected to socket server');
      _joinRoom(roomCode: roomCode, username: username);
    });
    socket!.on('connect_error', (data) {
      print('Socket connect_error (unreadable): $data');
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
    socket!.on('disconnect', (_) {
      print('Disconnected from socket server');
    });
    try {
      socket!.connect();
    } catch (e) {
      print('Error during socket connection: $e');
    }
  }

  void _joinRoom({required String roomCode, required String username}) {
    final Map<String, dynamic> userInfo = {'username': username, 'roomCode': roomCode};
    socket!.emit('join-room', userInfo);
    print('Joined room: $roomCode for user: $username');
  }

  void sendMessage({required String username, required String roomCode, required String content}) {
    final message = {
      "username": username,
      "roomCode": roomCode,
      "content": content,
      "createdAt": DateTime.now().toIso8601String(),
    };

    if (socket != null && socket!.connected) {
      socket!.emit('chat-message', message);
      print('Message sent: $message');
    } else {
      print('Cannot send message, socket not connected.');
    }
  }

  //to:do listen for the event both on the server and in the client
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

  void dispose() {
    socket?.disconnect();
    socket = null;
  }
}
