import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/auth/data/services/token_storage_service.dart';
import 'package:chat_app/features/chat/services/image_upload_service.dart';
import 'package:chat_app/shared/utils/image_picker_helper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadResult {
  final bool success;
  final String? errorMessage;
  final List<String>? invalidImageNames;

  ImageUploadResult({required this.success, this.errorMessage, this.invalidImageNames});
}

class ImageUploadHandler {
  final TokenStorageService tokenStorageService;
  final AuthCubit authCubit;

  ImageUploadHandler({required this.tokenStorageService, required this.authCubit});

  Future<ImageUploadResult> uploadImages({
    required List<XFile> images,
    required String roomCode,
    String? content,
  }) async {
    try {
      // Get token
      final token = await tokenStorageService.getAccessToken();
      if (token == null) {
        return ImageUploadResult(success: false, errorMessage: 'No authentication token');
      }

      // Get current user
      final currentUser = authCubit.getCurrentUser();
      if (currentUser == null) {
        return ImageUploadResult(success: false, errorMessage: 'User not authenticated');
      }

      // Validate images and filter invalid ones
      List<XFile> validImages = [];
      List<String> invalidImageNames = [];

      for (var image in images) {
        if (ImagePickerHelper.isValidImageSize(image)) {
          validImages.add(image);
        } else {
          invalidImageNames.add(image.name);
        }
      }

      if (validImages.isEmpty) {
        return ImageUploadResult(
          success: false,
          errorMessage: 'All selected images exceed the maximum size (5MB)',
          invalidImageNames: invalidImageNames,
        );
      }

      // Upload valid images
      final uploadedImages = await ImageUploadService.uploadImages(
        images: validImages,
        roomCode: roomCode,
        token: token,
        senderId: currentUser.id,
        username: currentUser.username,
      );

      if (uploadedImages == null || uploadedImages.isEmpty) {
        return ImageUploadResult(
          success: false,
          errorMessage: 'Failed to upload images',
          invalidImageNames: invalidImageNames.isNotEmpty ? invalidImageNames : null,
        );
      }

      return ImageUploadResult(
        success: true,
        invalidImageNames: invalidImageNames.isNotEmpty ? invalidImageNames : null,
      );
    } catch (e) {
      return ImageUploadResult(success: false, errorMessage: 'Error uploading images: $e');
    }
  }
}
