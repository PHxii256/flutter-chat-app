import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/core/config/server_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as path; // For path.extension

class ImageUploadService {
  /// Upload multiple images and return ImageData list
  static Future<List<ImageData>?> uploadImages({
    required List<XFile> images,
    required String roomCode,
    required String token,
    required String senderId,
    required String username,
  }) async {
    try {
      if (token.isEmpty) {
        debugPrint('No authentication token provided');
        return null;
      }

      List<ImageData> uploadedImages = [];

      for (XFile image in images) {
        final imageData = await _uploadSingleImage(
          image: image,
          roomCode: roomCode,
          token: token,
          senderId: senderId,
          username: username,
        );
        if (imageData != null) {
          uploadedImages.add(imageData);
        }
      }

      return uploadedImages.isNotEmpty ? uploadedImages : null;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      return null;
    }
  }

  /// Upload a single image to the server
  static Future<ImageData?> _uploadSingleImage({
    required XFile image,
    required String roomCode,
    required String token,
    required String senderId,
    required String username,
  }) async {
    try {
      final uri = Uri.parse('${getServertUrl()}images/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['roomCode'] = roomCode;
      request.fields['senderId'] = senderId;
      request.fields['username'] = username;

      // Fix: Explicitly set the content type based on file extension
      String? mimeType = _getMimeType(image.path);

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: image.name,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(file);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log("server response to image upload: $responseData");

        // Parse the response to extract image data
        if (responseData['success'] == true && responseData['data'] != null) {
          final messageData = responseData['data'];
          if (messageData['imageData'] != null && messageData['imageData'] is List) {
            final imageDataList = messageData['imageData'] as List;
            if (imageDataList.isNotEmpty) {
              final imageInfo = imageDataList.first;
              return ImageData(url: imageInfo['url'] ?? '', id: imageInfo['_id'] ?? '');
            }
          }
        }

        debugPrint('Invalid response format for image upload');
        return null;
      } else {
        debugPrint('Failed to upload image: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading single image: $e');
      return null;
    }
  }

  // Helper method to determine MIME type from file extension
  static String? _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      default:
        return null;
    }
  }
}
