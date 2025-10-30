import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/services/image_upload_service.dart';
import 'package:chat_app/features/auth/services/token_storage_service.dart';
import 'package:chat_app/shared/utils/image_picker_helper.dart';
import 'package:chat_app/features/auth/providers/auth_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'image_upload_provider.g.dart';

/// Result object for image upload operations
class ImageUploadResult {
  final bool success;
  final String? errorMessage;
  final List<String>? invalidImageNames;

  ImageUploadResult({required this.success, this.errorMessage, this.invalidImageNames});
}

@riverpod
Future<ImageUploadResult> uploadImages(
  Ref ref, {
  required List<XFile> images,
  required String roomCode,
  String? content,
  ReplyTo? replyTo,
}) async {
  // Keep the provider alive during the async operation
  final keepAlive = ref.keepAlive();

  // Cancel the keep-alive when done
  ref.onDispose(() {
    keepAlive.close();
  });

  try {
    // Validate image sizes
    final List<XFile> validImages = [];
    final List<String> invalidImageNames = [];

    for (final image in images) {
      if (ImagePickerHelper.isValidImageSize(image)) {
        validImages.add(image);
      } else {
        invalidImageNames.add(image.name);
      }
    }

    if (validImages.isEmpty) {
      return ImageUploadResult(
        success: false,
        errorMessage: invalidImageNames.isEmpty
            ? 'No images selected'
            : 'All images are too large (max 5MB): ${invalidImageNames.join(", ")}',
      );
    }

    // Get auth token
    final tokenService = ref.read(tokenStorageServiceProvider);
    final token = await tokenService.getAccessToken();

    // Check if still mounted after async gap
    if (!ref.mounted) {
      return ImageUploadResult(success: false, errorMessage: 'Operation cancelled');
    }

    if (token == null || token.isEmpty) {
      return ImageUploadResult(
        success: false,
        errorMessage: 'Authentication required to send images',
      );
    }

    // Get user info - read synchronously
    final user = ref.read(authViewModelProvider).user;
    final senderId = user?.id;
    final username = user?.username;

    if (senderId == null || username == null) {
      return ImageUploadResult(success: false, errorMessage: 'User information not available');
    }

    // Upload images
    final uploadedImages = await ImageUploadService.uploadImages(
      images: validImages,
      roomCode: roomCode,
      token: token,
      senderId: senderId,
      username: username,
    );

    // Check if still mounted after upload
    if (!ref.mounted) {
      return ImageUploadResult(success: false, errorMessage: 'Operation cancelled');
    }

    if (uploadedImages == null || uploadedImages.isEmpty) {
      return ImageUploadResult(success: false, errorMessage: 'Failed to upload images');
    }

    // Send success - images were uploaded via the service
    return ImageUploadResult(
      success: true,
      invalidImageNames: invalidImageNames.isNotEmpty ? invalidImageNames : null,
    );
  } catch (e) {
    print('Error in uploadAndSendImages: $e');
    return ImageUploadResult(success: false, errorMessage: 'Error uploading images: $e');
  }
}
