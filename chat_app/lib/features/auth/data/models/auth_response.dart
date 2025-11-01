import 'package:chat_app/features/chat/models/user_model.dart';

sealed class AuthResponse {
  AuthResponse();
}

final class AuthFailureResponse extends AuthResponse {
  final String message;
  final int statusCode;

  AuthFailureResponse({required this.message, required this.statusCode});

  factory AuthFailureResponse.fromJson(
    Map<String, dynamic> json,
    String? statusMessage,
    int? statusCode,
  ) => AuthFailureResponse(
    statusCode: json['status'] ?? 500,
    message: json['message'] ?? statusMessage ?? 'no error message recieved',
  );
}

final class AuthSuccessResponse extends AuthResponse {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthSuccessResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSuccessResponse.fromJson(Map<String, dynamic> json, String? statusMessage) =>
      AuthSuccessResponse(
        message: json['message'] ?? statusMessage ?? 'success',
        accessToken: json['tokens']?['accessToken'] ?? '',
        refreshToken: json['tokens']?['refreshToken'] ?? '',
        user: User.fromJson(json['user'] ?? {}),
      );
}
