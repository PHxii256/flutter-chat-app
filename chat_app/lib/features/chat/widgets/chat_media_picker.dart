import 'package:chat_app/shared/utils/image_picker_helper.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/features/chat/services/image_upload_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatMediaPicker extends StatelessWidget {
  final TextEditingController textController;
  final String roomCode;
  const ChatMediaPicker({super.key, required this.textController, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    Future<void> pickAndSendImages() async {
      if (!context.mounted) return;

      try {
        final List<XFile>? pickedImages = await ImagePickerHelper.showImageSourceBottomSheet(
          context,
        );
        if (pickedImages == null || pickedImages.isEmpty) return;

        // Show loading indicator during upload
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        }
        if (context.mounted) {
          // Create upload handler and upload images
          final imageUploadHandler = ImageUploadHandler(
            tokenStorageService: TokenStorageService(const FlutterSecureStorage()),
            authCubit: context.read<AuthCubit>(),
          );

          final result = await imageUploadHandler.uploadImages(
            images: pickedImages,
            roomCode: roomCode,
            content: textController.text.isNotEmpty ? textController.text : null,
          );

          // Close loading dialog

          if (context.mounted) Navigator.of(context).pop();

          // Handle result
          if (result.success) {
            // Clear text controller on success
            textController.clear();

            // Show warning if some images were invalid
            if (result.invalidImageNames != null && result.invalidImageNames!.isNotEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Some images were too large (max 5MB): ${result.invalidImageNames!.join(", ")}',
                    ),
                  ),
                );
              }
            }
          } else {
            // Show error message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.errorMessage ?? 'Failed to upload images')),
              );
            }
          }
        }
      } catch (e) {
        // Close loading dialog if still open
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }

    return IconButton.outlined(
      onPressed: () async {
        await pickAndSendImages();
      },
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: Colors.black12, width: 2.0)),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        minimumSize: WidgetStateProperty.all(Size(58, 58)),
      ),
      icon: Icon(Icons.library_add_outlined, size: 26),
    );
  }
}
