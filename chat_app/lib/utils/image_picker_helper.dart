import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick multiple images from gallery
  static Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      return images;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return null;
    }
  }

  /// Pick a single image from gallery
  static Future<XFile?> pickSingleImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Show bottom sheet with image source options
  static Future<List<XFile>?> showImageSourceBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<List<XFile>?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 28),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from existing photos'),
                  onTap: () async {
                    final images = await pickMultipleImages();
                    if (context.mounted) {
                      Navigator.of(modalContext).pop(images);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, size: 28),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () async {
                    Navigator.of(modalContext).pop();
                    final image = await pickImageFromCamera();
                    if (context.mounted) {
                      if (image != null) {
                        Navigator.of(context).pop([image]);
                      } else {
                        Navigator.of(context).pop(null);
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Validate image file size (in MB)
  static bool isValidImageSize(XFile file, {double maxSizeMB = 5.0}) {
    final fileSizeInBytes = File(file.path).lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= maxSizeMB;
  }
}
