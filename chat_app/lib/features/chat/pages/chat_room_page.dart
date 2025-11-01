// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/bloc/chat_room_cubit.dart';
import 'package:chat_app/features/chat/bloc/toast_cubit.dart';
import 'package:chat_app/features/chat/widgets/message_tile.dart';
import 'package:chat_app/features/chat/widgets/chat_screen_input.dart';
import 'package:chat_app/features/chat/widgets/members_drawer.dart';
import 'package:chat_app/features/chat/widgets/message_options_menu.dart';
import 'package:chat_app/features/chat/widgets/message_tile_factory.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/conversations/bloc/conversation_members_cubit.dart';
import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, this.username = "default user", this.roomCode = "general"});

  final String username;
  final String roomCode;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void jumpToMessageById(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext != null) {
      // Use Scrollable.ensureVisible for precise scrolling
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      MessageTile.highlightByKey(key);
    }
  }

  void jumpToLastMessage({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final current = scrollController.offset;
        // Only animate if not already at the bottom
        if ((maxScroll - current).abs() > 10) {
          if (animated) {
            scrollController.animateTo(
              maxScroll,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else {
            scrollController.jumpTo(maxScroll);
          }
        }
      }
    });
  }

  void setupAutoScroll() {
    // Set up callback for the cubit to trigger scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ChatRoomCubit>();
      cubit.onMessagesChanged = () {
        jumpToLastMessage(animated: true);
      };
      cubit.onHistoryLoaded = () {
        jumpToLastMessage(animated: false);
      };
    });
  }

  void showOptionsMenu(MessageData message) {
    if (mounted && message.senderId != "Server") {
      showModalBottomSheet(
        context: context,
        builder: (modalContext) {
          return BlocProvider.value(
            value: context.read<ChatRoomCubit>(),
            child: BlocProvider.value(
              value: context.read<ToastCubit>(),
              child: MessageOptionsMenu(textController: textController, message: message),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    // Set up callback for the cubit to trigger scrolling
    setupAutoScroll();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = ChatRoomCubit(
              roomCode: widget.roomCode,
              tokenStorageService: TokenStorageService(const FlutterSecureStorage()),
              authRepository: context.read<AuthRepository>(),
            );
            cubit.initialize(username: widget.username);
            return cubit;
          },
        ),
        BlocProvider(create: (context) => ToastCubit()),
        BlocProvider(
          create: (context) {
            final cubit = ConversationMembersCubit(
              roomCode: widget.roomCode,
              conversationsCubit: context.read<ConversationsCubit>(),
            );
            cubit.loadMembers();
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        endDrawer: MembersDrawer(roomCode: widget.roomCode),
        appBar: AppBar(title: Text(t.chatRoomTitle(widget.roomCode))),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
                  builder: (context, state) {
                    if (state is ChatRoomLoaded) {
                      return Scrollbar(
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            // Create or get existing key for this message
                            _messageKeys.putIfAbsent(message.id, () => GlobalKey());
                            return MessageTileFactory(
                              currentUsername: widget.username,
                              roomCode: widget.roomCode,
                              key: _messageKeys[message.id],
                              jumpToMessage: (String messageId) => jumpToMessageById(messageId),
                              message: message,
                              index: index,
                              onLongPress: () => showOptionsMenu(message),
                            );
                          },
                        ),
                      );
                    } else if (state is ChatRoomError) {
                      return Text(t.errorMessage(state.message));
                    } else {
                      return Center(
                        child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ),
            ChatScreenInput(textController: textController, roomCode: widget.roomCode),
          ],
        ),
      ),
    );
  }
}
