// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/auth/providers/auth_view_model.dart';
import 'package:chat_app/features/chat/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnterRoom extends ConsumerStatefulWidget {
  final void Function()? closeDialog;
  const EnterRoom({super.key, this.closeDialog});

  @override
  ConsumerState<EnterRoom> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<EnterRoom> {
  String username = "Anonymous User";
  String roomCode = "general";
  bool editableUsername = true;
  final usernameController = TextEditingController();
  final roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the provider is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authViewModelProvider.notifier).getCurrentUser();
      if (currentUser != null) {
        usernameController.text = currentUser.username;
        setState(() {
          editableUsername = false;
        });
      }
    });
  }

  void submit() {
    if (mounted) {
      if (widget.closeDialog != null) widget.closeDialog!();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoom(
            username: usernameController.text.isEmpty ? username : usernameController.text,
            roomCode: roomController.text.isEmpty ? roomCode : roomController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    return Center(
      child: SizedBox(
        height: 280,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(0, 8, 0, 16),
                  child: Text(
                    t.enterChatRoom,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    enabled: editableUsername,
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: t.username,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black12, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black12, width: 2.0),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: roomController,
                    decoration: InputDecoration(
                      labelText: t.roomCode,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black12, width: 1.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black12, width: 1.0),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(onPressed: submit, child: Text(t.startChatting)),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(authViewModelProvider.notifier).logout();
                            if (mounted) {
                              if (widget.closeDialog != null) widget.closeDialog!();
                            }
                          },
                          child: Text(t.logout, style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
