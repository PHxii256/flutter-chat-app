import 'package:bloc/bloc.dart';
import 'package:chat_app/features/auth/bloc/auth_state.dart';
import 'package:chat_app/features/auth/data/models/auth_response.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/chat/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInital());

  Future<void> initialize() async {
    final initState = await _getInitialAuthState();
    emit(initState);
  }

  Future<AuthState> _getInitialAuthState() async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        return user != null ? AuthData(user: user) : AuthUnauthenticated();
      }

      final refreshSuccess = await _authRepository.refreshTokens();

      if (refreshSuccess) {
        final user = await _authRepository.getCurrentUser();
        return user != null ? AuthData(user: user) : AuthUnauthenticated();
      }

      return AuthUnauthenticated();
    } catch (e) {
      return AuthError(message: e.toString());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout completed with errors'));
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError(message: 'Email and password are required'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(AuthError(message: 'Please enter a valid email'));
      return;
    }

    emit(AuthLoading());

    try {
      final response = await _authRepository.login(email, password);
      if (response is AuthSuccessResponse) {
        emit(AuthData(user: response.user));
      } else {
        emit(AuthError(message: "sorry, unable to currently log in."));
      }
    } catch (e) {
      emit(AuthError(message: "error logging in: ${e.toString()}"));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      emit(AuthError(message: 'All fields are required'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(AuthError(message: 'Please enter a valid email'));
      return;
    }

    if (password.length < 6) {
      emit(AuthError(message: 'Password must be at least 6 characters'));
      return;
    }

    if (password != confirmPassword) {
      emit(AuthError(message: 'Passwords do not match'));
      return;
    }

    emit(AuthLoading());

    try {
      final userData = {'email': email, 'password': password, 'username': username};

      final response = await _authRepository.register(userData);
      if (response is AuthSuccessResponse) {
        emit(AuthData(user: response.user));
      } else {
        emit(AuthError(message: "Registration failed. Please try again."));
      }
    } catch (e) {
      emit(AuthError(message: "Error registering: ${e.toString()}"));
    }
  }

  void clearError() => emit(AuthUnauthenticated());

  User? getCurrentUser() {
    final currentState = state;
    if (currentState is AuthData) {
      return currentState.user;
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
