// ignore_for_file: avoid_print
import 'package:chat_app/chat_room.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String username = "Anonymous User";
  String roomCode = "general";
  final usernameController = TextEditingController();
  final roomController = TextEditingController();

  void submit() {
    if (mounted) {
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
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                  child: Text(
                    "Enter Chat Room",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
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
                      labelText: 'Room Code',
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
                    child: ElevatedButton(onPressed: submit, child: Text("Start Chatting")),
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
