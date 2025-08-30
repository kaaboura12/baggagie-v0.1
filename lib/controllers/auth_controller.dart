import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  app_user.User? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  app_user.User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthController() {
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    _checkAuthState();
    _listenToAuthChanges();
  }

  /// Check current authentication state
  void _checkAuthState() {
    final user = AuthService.currentUser;
    if (user != null) {
      _currentUser = AuthService.convertToUserModel(user);
      _isAuthenticated = true;
    } else {
      _currentUser = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    AuthService.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            _currentUser = AuthService.convertToUserModel(session!.user!);
            _isAuthenticated = true;
            _errorMessage = null;
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _isAuthenticated = false;
          _errorMessage = null;
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            _currentUser = AuthService.convertToUserModel(session!.user!);
          }
          break;
        case AuthChangeEvent.passwordRecovery:
          // Handle password recovery if needed
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = AuthService.convertToUserModel(response.user!);
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError('Sign in failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      // For Supabase, sign up is successful even if user is null
      // because email confirmation is required
      if (response.user != null) {
        // User is immediately authenticated (email confirmation disabled)
        _currentUser = AuthService.convertToUserModel(response.user!);
        _isAuthenticated = true;
      }
      
      _setLoading(false);
      return true; // Sign up was successful, email confirmation sent
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await AuthService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      if (user != null) {
        _currentUser = AuthService.convertToUserModel(user);
        _setLoading(false);
        return true;
      } else {
        _setError('Profile update failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please check your credentials.';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account.';
        case 'User already registered':
        case 'A user with this email address has already been registered':
          return 'An account with this email already exists. Please sign in instead.';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long.';
        case 'Invalid email':
          return 'Please enter a valid email address.';
        case 'Signup is disabled':
          return 'Account creation is currently disabled. Please contact support.';
        case 'Email rate limit exceeded':
          return 'Too many sign up attempts. Please wait a few minutes and try again.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Clear error manually (useful for UI)
  void clearError() {
    _clearError();
  }
}
