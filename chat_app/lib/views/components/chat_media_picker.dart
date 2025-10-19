import 'package:chat_app/services/image_upload_service.dart';
import 'package:chat_app/services/token_storage_service.dart';
import 'package:chat_app/utils/image_picker_helper.dart';
import 'package:chat_app/view_models/auth_view_model.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChatMediaPicker extends ConsumerWidget {
  final TextEditingController textController;
  final ChatRoomNotifierProvider chatRoomProvider;
  final String username;
  final String roomCode;
  final InputToast? Function() getToast;
  final Function() closeToast;
  const ChatMediaPicker({
    super.key,
    required this.chatRoomProvider,
    required this.textController,
    required this.username,
    required this.roomCode,
    required this.getToast,
    required this.closeToast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> pickAndSendImages() async {
      if (!context.mounted) return;

      try {
        // Pick images using the helper (no loading indicator for selection)
        final List<XFile>? pickedImages = await ImagePickerHelper.showImageSourceBottomSheet(
          context,
        );

        if (pickedImages == null || pickedImages.isEmpty) {
          return;
        }

        // Show loading indicator only during upload process
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        // Validate image sizes
        final List<XFile> validImages = [];
        for (final image in pickedImages) {
          if (ImagePickerHelper.isValidImageSize(image)) {
            validImages.add(image);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Image ${image.name} is too large (max 5MB)')));
            }
          }
        }

        if (validImages.isEmpty) {
          if (!context.mounted) Navigator.of(context).pop(); // Close loading dialog
          return;
        }

        // Get auth token
        final tokenService = ref.read(tokenStorageServiceProvider);
        final token = await tokenService.getAccessToken();

        if (token == null || token.isEmpty) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Authentication required to send images')));
          }
          return;
        }

        final String? senderId = ref.read(authViewModelProvider).user?.id;
        final String? username = ref.read(authViewModelProvider).user?.username;
        if (senderId == null || username == null) {
          print("SenderId null");
          return;
        }
        // Upload images
        final uploadedImages = await ImageUploadService.uploadImages(
          images: validImages,
          roomCode: roomCode,
          token: token,
          senderId: senderId,
          username: username,
        );

        if (context.mounted) Navigator.of(context).pop(); // Close loading dialog

        if (uploadedImages != null && uploadedImages.isNotEmpty) {
          // Clear text controller if it had content
          if (textController.text.isNotEmpty) {
            textController.clear();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Failed to upload images')));
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog if still open
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error sending images: $e')));
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
