import 'package:flutter/material.dart';

class ErrorToast extends StatelessWidget {
  const ErrorToast({super.key, required this.error, required this.clearErrorHandler});

  final String error;
  final Function() clearErrorHandler;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
          IconButton(onPressed: clearErrorHandler, icon: const Icon(Icons.close), iconSize: 20),
        ],
      ),
    );
  }
}
