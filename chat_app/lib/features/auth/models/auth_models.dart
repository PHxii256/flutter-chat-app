import 'user_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class AuthResponse {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    message: json['message'] ?? '',
    accessToken: json['tokens']?['accessToken'] ?? '',
    refreshToken: json['tokens']?['refreshToken'] ?? '',
    user: User.fromJson(json['user'] ?? {}),
  );
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({this.user, this.isLoading = false, this.error, this.isAuthenticated = false});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool? isAuthenticated}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
