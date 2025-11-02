import 'package:chat_app/features/chat/data/models/message_data.dart';

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
