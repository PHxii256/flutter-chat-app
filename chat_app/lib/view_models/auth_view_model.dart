import 'package:chat_app/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    // Initialize and check auth status
    _checkInitialAuthStatus();
    return const AuthState();
  }

  // Traditional MVVM: ViewModel contains business logic
  Future<void> login(String email, String password) async {
    // Validation business logic
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Email and password are required');
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(error: 'Please enter a valid email');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call repository (not service directly)
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(email, password);

      state = state.copyWith(user: response.user, isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''), isLoading: false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    // Business logic validation
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      state = state.copyWith(error: 'All fields are required');
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(error: 'Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      state = state.copyWith(error: 'Passwords do not match');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.register({
        'email': email,
        'password': password,
        'username': username,
      });

      state = state.copyWith(user: response.user, isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''), isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();

      state = const AuthState();
    } catch (e) {
      // Even if logout fails, clear local state
      state = const AuthState(error: 'Logout completed with errors');
    }
  }

  Future<void> _checkInitialAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);

      // Check if we have stored tokens
      final isAuthenticated = await repository.isAuthenticated();

      if (isAuthenticated) {
        // Try to get cached user data first
        final user = await repository.getCurrentUser();

        if (user != null) {
          // We have valid tokens and user data - auto login successful
          state = state.copyWith(user: user, isAuthenticated: true, isLoading: false);
          return;
        }
      }

      // If tokens are invalid or expired, try to refresh them
      final refreshSuccess = await repository.refreshTokens();

      if (refreshSuccess) {
        // Refresh successful, get user data again
        final user = await repository.getCurrentUser();
        state = state.copyWith(user: user, isAuthenticated: true, isLoading: false);
      } else {
        // Refresh failed - user needs to login manually
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      // Something went wrong - clear any partial state
      state = state.copyWith(
        error: 'Authentication check failed',
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  User? getCurrentUser() => state.user;

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Business logic helper methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
